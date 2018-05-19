/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface OwnTracksManager ()

@property (nonatomic, retain) NSOperationQueue *runqueue;
@property (nonatomic        ) BOOL isRunning;
@property (nonatomic        ) NSInteger errorCount;
@property (nonatomic        ) BOOL alertedNoConnection;

@end

@implementation OwnTracksManager

- (instancetype)init
{
    self = [super init];

    self.runqueue = [[NSOperationQueue alloc] init];
    // Gets started in startDelivering

    // Needed for the battery level
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

    [self startDelivering];
    return self;
}

- (void)startDelivering
{
    self.isRunning = NO;
    if (configManager.ownTracksEnable == NO)
        return;

    if (IS_EMPTY(configManager.owntracksUsername) == YES)
        return;

    if (IS_EMPTY(configManager.owntracksSecret) == YES)
        [self obtainSecret];

    // If the obtain failed
    if (IS_EMPTY(configManager.owntracksSecret) == YES)
        return;

    self.isRunning = YES;
    [self alertAppStarted];
    [self.runqueue addOperationWithBlock:^{
        [self processSendQueue];
    }];

}

- (void)stopDelivering:(BOOL)sendLWT
{
    [self.runqueue cancelAllOperations];
    if (sendLWT == YES)
        [self alertAppStopped];

    self.isRunning = NO;
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url parameters:(NSString *)parameters
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@/%@", configManager.owntracksURL, url];
    if (parameters != nil)
        [urlString appendFormat:@"?%@", parameters];

    NSURL *urlURL = [NSURL URLWithString:urlString];
    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:urlURL];

    [urlRequest setValue:@"none" forHTTPHeaderField:@"Accept-Encoding"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    return urlRequest;
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url
{
    return [self prepareURLRequest:url parameters:nil];
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url method:(NSString *)method
{
    GCMutableURLRequest *req = [self prepareURLRequest:url parameters:nil];
    [req setHTTPMethod:method];
    return req;
}

- (GCDictionary *)performURLRequest:(NSURLRequest *)urlRequest
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem infoItem:nil];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //  NSLog(@"error: %@", [error description]);
    //  NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //  NSLog(@"retbody: %@", retbody);

    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }
    if (response.statusCode != 200) {
        NSLog(@"statusCode: %ld", (long)response.statusCode);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionary *json = [[GCDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (void)obtainSecret
{
    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"post.php" method:@"POST"];

    NSDictionary *dict = @{
        @"username": configManager.owntracksUsername,
    };
    NSError *error = nil;

    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    GCDictionary *json = [self performURLRequest:urlRequest];
    if (json == nil)
        return;

    [configManager owntracksSecretUpdate:[json objectForKey:@"secret"]];
}

- (void)processSendQueue
{
    while (TRUE) {
        // Delay if there is nothing, retry if there is nothing afterwards.
        if ([dbOwnTrack dbCount] == 0) {
            [NSThread sleepForTimeInterval:10];
            if ([dbOwnTrack dbCount] == 0)
                continue;
        }

        // Keep it in the queue when there is no network connectivity
        if ([MyTools hasAnyNetwork] == NO) {
            if (self.alertedNoConnection == YES) {
                [NSThread sleepForTimeInterval:10];
                continue;
            }
            [self alertedNoConnection];
            self.alertedNoConnection = YES;
            [NSThread sleepForTimeInterval:10];
            continue;
        }

        if (self.alertedNoConnection == YES) {
            [self alertReconnectedToInternet];
            self.alertedNoConnection = NO;
        }

        GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"post.php" method:@"POST"];

        dbOwnTrack *o = [dbOwnTrack dbGetFirst];
        o.timeDelivered = time(NULL);

        NSDictionary *dict = @{
        @"id": [NSNumber numberWithInteger:o._id],
        @"info": o.info,
        @"timeSubmitted": [NSNumber numberWithInteger:o.timeSubmitted],
        @"timeDelivered": [NSNumber numberWithInteger:o.timeDelivered],
        @"batteryLevel": [NSNumber numberWithInteger:o.batteryLevel],
        @"password": IS_EMPTY(o.password) == YES ? [NSNull null] : o.password,
        @"coordinate": @{
                @"latitude": [NSNumber numberWithFloat:o.coord.latitude],
                @"longitude": [NSNumber numberWithFloat:o.coord.longitude],
                @"accuracy": [NSNumber numberWithFloat:o.accuracy],
                @"altitude": [NSNumber numberWithInteger:o.altitude],
                },
        };
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        NSString *encryptedData = [self encrypt:data];

        dict = @{
             @"username": configManager.owntracksUsername,
             @"data": encryptedData,
        };

        NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
        urlRequest.HTTPBody = body;

        GCDictionary *json = [self performURLRequest:urlRequest];

        // If something fails then retry later
        if (json == nil) {
            self.errorCount++;
            if (self.errorCount > 10) {
                [self stopDelivering:FALSE];
                [MyTools messageBox:[MyTools topMostController] header:_(@"owntracks-OwnTracks disabled") text:_(@"owntracks-The OwnTracks service has been disabled because of the more than 10 errors received from the server.")];
            }
        } else {
            self.errorCount = 0;
            [o dbDelete];
        }
    }
}

- (NSString *)encrypt:(NSData *)sin
{
    NSMutableData *sout = [NSMutableData data];
    NSInteger sizek = [configManager.owntracksSecret length];
    for (NSInteger i = 0; i < [sin length]; i++) {
        char c;
        [sin getBytes:&c range:NSMakeRange(i, 1)];
        char k = [configManager.owntracksSecret characterAtIndex:(i % sizek)];
        c = c ^ k;
        [sout appendBytes:&c length:1];
    }
    return [sout base64EncodedStringWithOptions:0];
}

#define ALERT(__funcname__, __info__) \
    - (void)__funcname__ \
    { \
        dbOwnTrack *o = [[dbOwnTrack alloc] initInitialized]; \
        o.info = __info__; \
        [o dbCreate]; \
    }

#define ALERT_WP(__funcname__, __info__) \
    - (void)__funcname__:(dbWaypoint *)wp \
    { \
        dbOwnTrack *o = [[dbOwnTrack alloc] initInitialized]; \
        o.info = [NSString stringWithFormat:__info__, wp.wpt_name]; \
        [o dbCreate]; \
    }

ALERT(alertAppStarted, @"App started")
ALERT(alertAppStopped, @"Delivery stopped")
ALERT(alertLostConnectionToInternet, @"Lost connection to the internet")
ALERT(alertReconnectedToInternet, @"Regained connection to the internet")
ALERT(alertCarParked, @"Keep Track: Remember location")
ALERT(alertBeeperStarted, @"Keep Track: Beeper started")

ALERT_WP(alertWaypointLog, @"Logged %@")
ALERT_WP(alertWaypointSetTarget, @"Set target to %@")
ALERT_WP(alertWaypointRemoveTarget, @"Remove target from %@")

- (void)alertAppChangePassword
{
    dbOwnTrack *o = [[dbOwnTrack alloc] initInitialized];
    o.info = @"Password changed";
    o.password = configManager.owntracksPassword;
    [o dbCreate];
}

- (void)alertWaypointMarkAs:(dbWaypoint *)wp markAs:(Flag)markAs;
{
    dbOwnTrack *o = [[dbOwnTrack alloc] initInitialized];
    switch (markAs) {
        case FLAGS_IGNORED:
            o.info = [NSString stringWithFormat:@"Marked %@ as ignored", wp.wpt_name];
            break;
        case FLAGS_PLANNED:
            o.info = [NSString stringWithFormat:@"Marked %@ as planned", wp.wpt_name];
            break;
        case FLAGS_MARKEDDNF:
            o.info = [NSString stringWithFormat:@"Marked %@ as DNF", wp.wpt_name];
            break;
        case FLAGS_INPROGRESS:
            o.info = [NSString stringWithFormat:@"Marked %@ as in progress", wp.wpt_name];
            break;
        case FLAGS_HIGHLIGHTED:
            o.info = [NSString stringWithFormat:@"Marked %@ as highlighted", wp.wpt_name];
            break;
        case FLAGS_MARKEDFOUND:
            o.info = [NSString stringWithFormat:@"Marked %@ as found", wp.wpt_name];
            break;
    }
    [o dbCreate];
}

@end
