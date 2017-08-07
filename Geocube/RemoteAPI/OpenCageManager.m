/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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
{
    NSArray<NSString *> *locale_order, *state_order, *country_order;
    NSString *urlFormat;
    NSMutableArray<dbWaypoint *> *queue;
    BOOL isRunning;
    BOOL disabled;
}

@end

@implementation OpenCageManager

- (instancetype)init
{
    self = [super init];

    locale_order = @[@"village",
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

    state_order = @[@"province",
                    @"state",
                    @"region",
                    @"island"
                    ];

    country_order = @[@"country"
                     ];

    urlFormat = @"https://api.opencagedata.com/geocode/v1/json?q=%f,%f&no_annotations=1&key=%@";
    queue = [NSMutableArray arrayWithCapacity:20];
    isRunning = NO;
    disabled = NO;

    return self;
}

- (void)addForProcessing:(dbWaypoint *)wp
{
    if (disabled == YES)
        return;
    if (IS_EMPTY(configManager.opencageKey) == YES)
        return;

    if (wp.gs_country != nil && wp.gs_state != nil && wp.gca_locale != nil)
        return;

    @synchronized (self) {
        [queue addObject:wp];
    }
    if (isRunning == NO)
        [self performSelectorInBackground:@selector(runQueue) withObject:nil];
}

- (void)runQueue
{
    dbWaypoint *wp;

    isRunning = YES;
    while (TRUE) {
        @synchronized (self) {
            NSLog(@"%@ - queue size is %ld", [self class], (long)[queue count]);
            if ([queue count] == 0)
                break;
            wp = [queue lastObject];
            [queue removeLastObject];
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
    isRunning = NO;
}

- (void)runQueue:(dbWaypoint *)wp
{
    NSString *urlString = [NSString stringWithFormat:urlFormat, wp.wpt_latitude, wp.wpt_longitude, configManager.opencageKey];
    NSURL *url = [NSURL URLWithString:urlString];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoViewer:nil iiDownload:0];

    if (error == nil && response.statusCode == 200) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSArray<NSDictionary *> *results = [json objectForKey:@"results"];
        NSDictionary *annotation = [results objectAtIndex:0];
        NSDictionary *components = [annotation objectForKey:@"components"];

        BOOL needsUpdate = NO;

        if (wp.gca_locale == nil) {
            __block NSString *locale = nil;
            [locale_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                locale = [components objectForKey:field];
                if (locale != nil)
                    *stop = YES;
            }];
            if (locale != nil) {
                [dbLocale makeNameExist:locale];
                wp.gca_locale = [dbc Locale_get_byName:locale];
                needsUpdate = YES;
            }
        }
        if (wp.gs_state == nil) {
            __block NSString *state = nil;
            [state_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                state = [components objectForKey:field];
                if (state != nil)
                    *stop = YES;
            }];
            if (state != nil) {
                [dbState makeNameExist:state];
                wp.gs_state = [dbc State_get_byNameCode:state];
                needsUpdate = YES;
            }
        }
        if (wp.gs_country == nil) {
            __block NSString *country = nil;
            [country_order enumerateObjectsUsingBlock:^(NSString * _Nonnull field, NSUInteger idx, BOOL * _Nonnull stop) {
                country = [components objectForKey:field];
                if (country != nil)
                    *stop = YES;
            }];
            if (country != nil) {
                [dbCountry makeNameExist:country];
                wp.gs_country = [dbc Country_get_byNameCode:country];
                needsUpdate = YES;
            }
        }

        [wp dbUpdateCountryStateLocale];
    } else {
        disabled = YES;
        @synchronized (self) {
            [queue removeAllObjects];
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
