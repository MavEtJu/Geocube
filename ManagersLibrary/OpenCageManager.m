/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

@interface OpenCageManager ()

@property (nonatomic, retain) NSArray<NSString *> *locale_order;
@property (nonatomic, retain) NSArray<NSString *> *state_order;
@property (nonatomic, retain) NSArray<NSString *> *country_order;
@property (nonatomic, retain) NSString *urlFormat;
@property (nonatomic, retain) NSMutableArray<dbWaypoint *> *queue;
@property (nonatomic        ) BOOL isRunning;
@property (nonatomic        ) BOOL disabled;

@end

@implementation OpenCageManager

- (instancetype)init
{
    self = [super init];

    self.locale_order = @[@"village",
                          @"hamlet",
                          @"locality",
                          @"suburb",
                          @"city_district",
                          @"town",
                          @"city",
                          @"county",
                          @"state_district",
                          @"province",
                          @"state",
                          @"region",
                          @"island"
                          ];

    self.state_order = @[@"province",
                         @"state",
                         @"region",
                         @"island"
                         ];

    self.country_order = @[@"country"
                     ];

    self.urlFormat = @"https://api.opencagedata.com/geocode/v1/json?q=%f,%f&no_annotations=1&key=%@&language=en";
    self.queue = [NSMutableArray arrayWithCapacity:20];
    self.isRunning = NO;
    self.disabled = NO;

    return self;
}

- (void)addForProcessing:(dbWaypoint *)wp
{
    if (self.disabled == YES)
        return;
    if (configManager.opencageEnable == NO)
        return;
    if (IS_EMPTY(configManager.opencageKey) == YES)
        return;

    if (wp.gs_country != nil && wp.gs_state != nil && wp.gca_locality != nil)
        return;

    @synchronized(self) {
        [self.queue addObject:wp];
    }
    if (self.isRunning == NO)
        BACKGROUND(runQueue, nil);
}

- (void)runQueue
{
    dbWaypoint *wp;

    self.isRunning = YES;
    while (TRUE) {
        @synchronized(self) {
            NSLog(@"%@ - queue size is %ld", [self class], (long)[self.queue count]);
            if ([self.queue count] == 0)
                break;
            wp = [self.queue lastObject];
            [self.queue removeLastObject];
        }
        if (wp != nil) {
            if ([MyTools hasWifiNetwork] == NO && configManager.opencageWifiOnly == YES)
                continue;
            NSLog(@"%@ - running for %@", [self class], wp.wpt_name);
            [self runQueue:wp];
        }
        [NSThread sleepForTimeInterval:1];
    }
    NSLog(@"%@ - finished", [self class]);
    self.isRunning = NO;
}

- (void)runQueue:(dbWaypoint *)wp
{
    NSString *urlString = [NSString stringWithFormat:self.urlFormat, wp.wpt_latitude, wp.wpt_longitude, configManager.opencageKey];
    NSURL *url = [NSURL URLWithString:urlString];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoItem:nil];

    if (error == nil && response.statusCode == 200) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<NSDictionary *> *results = [json objectForKey:@"results"];
        NSDictionary *annotation = [results objectAtIndex:0];
        NSDictionary *components = [annotation objectForKey:@"components"];

        BOOL needsUpdate = NO;

        if (wp.gca_locality == nil) {
            __block NSString *locality = nil;
            [self.locale_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                locality = [components objectForKey:field];
                if (locality != nil)
                    *stop = YES;
            }];
            if (locality != nil) {
                [dbLocality makeNameExist:locality];
                wp.gca_locality = [dbc localityGetByName:locality];
                needsUpdate = YES;
            }
        }
        if (wp.gs_state == nil) {
            __block NSString *state = nil;
            [self.state_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                state = [components objectForKey:field];
                if (state != nil)
                    *stop = YES;
            }];
            if (state != nil) {
                [dbState makeNameExist:state];
                wp.gs_state = [dbc stateGetByNameCode:state];
                needsUpdate = YES;
            }
        }
        if (wp.gs_country == nil) {
            __block NSString *country = nil;
            [self.country_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                country = [components objectForKey:field];
                if (country != nil)
                    *stop = YES;
            }];
            if (country != nil) {
                [dbCountry makeNameExist:country];
                wp.gs_country = [dbc countryGetByNameCode:country];
                needsUpdate = YES;
            }
        }

        if (needsUpdate == YES)
            [wp dbUpdateCountryStateLocality];
    } else {
        self.disabled = YES;
        @synchronized(self) {
            [self.queue removeAllObjects];
        }

        if (error != nil) {
            NSLog(@"%@ - Error %@, bailing", [self class], [error description]);
            [MyTools messageBox:[MyTools topMostController] header:_(@"opencagemanager-OpenCage Manager") text:_(@"opencagemanager-The OpenCage interface ran into a problem. It will be disabled until Geocube has been restarted.") error:[error description]];
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSDictionary *status = [json objectForKey:@"status"];
            NSLog(@"%@ - Error %@, bailing", [self class], [status objectForKey:@"message"]);
            [MyTools messageBox:[MyTools topMostController] header:_(@"opencagemanager-OpenCage Manager") text:_(@"opencagemanager-The OpenCage interface ran into a problem. It will be disabled until Geocube has been restarted.") error:[status objectForKey:@"message"]];
        }
    }
}

@end
