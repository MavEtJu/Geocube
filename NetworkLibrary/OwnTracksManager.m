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
    self.runqueue.maxConcurrentOperationCount = 1;

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

- (void)send:(OwnTracksObject *)o
{
    // Keep it in the queue when there is no network connectivity
    if ([MyTools hasAnyNetwork] == NO) {
        if (self.alertedNoConnection == YES) {
            // Keep it in the queue
            [self.runqueue addOperationWithBlock:^{
                [self send:o];
            }];
            return;
        }
        [self alertedNoConnection];
        self.alertedNoConnection = YES;
        [NSThread sleepForTimeInterval:10];
    }
    if (self.alertedNoConnection == YES) {
        [self alertReconnectedToInternet];
        self.alertedNoConnection = NO;
    }

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"post.php" method:@"POST"];

    o.timeDelivered = time(NULL);

    NSDictionary *dict = @{
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
        [self.runqueue addOperationWithBlock:^{
            [self send:o];
        }];
        if (self.errorCount > 10) {
            [self stopDelivering:FALSE];
            [MyTools messageBox:[MyTools topMostController] header:_(@"owntracks-OwnTracks disabled") text:_(@"owntracks-The OwnTracks service has been disabled because of the more than 10 errors received from the server.")];
        }
    } else {
        self.errorCount = 0;
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

- (void)alertAppStarted
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = @"App started";
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertAppStopped
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = @"Delivery stopped";
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertAppChangePassword
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = @"Password changed";
    o.password = configManager.owntracksPassword;
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertLostConnectionToInternet
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = @"Lost connection to the internet";
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertReconnectedToInternet
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = @"Regained connection to the internet";
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertWaypointSetTarget:(dbWaypoint *)wp
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = [NSString stringWithFormat:@"Set target to %@", wp.wpt_name];
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertWaypointRemoveTarget:(dbWaypoint *)wp
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = [NSString stringWithFormat:@"Remove target from %@", wp.wpt_name];
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertWaypointMarkAs:(dbWaypoint *)wp markAs:(Flag)markAs;
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
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
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertWaypointLog:(dbWaypoint *)wp;
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = [NSString stringWithFormat:@"Logged %@", wp.wpt_name];
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

- (void)alertKeepTrackRememberLocation:(dbWaypoint *)wp
{
    OwnTracksObject *o = [[OwnTracksObject alloc] init];
    o.info = [NSString stringWithFormat:@"Keep Track: Remember location"];
    [self.runqueue addOperationWithBlock:^{
        [self send:o];
    }];
}

@end
