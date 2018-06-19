/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface LocationManager ()

@property (nonatomic, retain) CLLocationManager *_LM;

@property (nonatomic, retain) NSDate *lastHistory;
@property (nonatomic        ) CLLocationCoordinate2D coordsHistoricalLast;

@property (nonatomic, retain) NSMutableArray<dbTrackElement *> *historyData;
@property (nonatomic, retain) NSMutableArray<GCCoordsHistorical *> *coordsSpeed;
@property (nonatomic        ) NSInteger lastSync;
@property (nonatomic        ) NSInteger lastAccuracy;
@property (nonatomic        ) NSInteger lastIsNavigating;

@property (nonatomic        ) BOOL gotUpdate;

@property (nonatomic, readwrite) BOOL useGNSS;

@end

@implementation LocationManager

- (instancetype)init
{
    self = [super init];

    self.coordsHistorical = [NSMutableArray arrayWithCapacity:1000];
    self.lastHistory = [NSDate date];
    self.speed = 0;

    /* Initiate the location manager */
    self._LM = [[CLLocationManager alloc] init];
    [self adjustAccuracy:LMACCURACY_1000M];
    self._LM.distanceFilter = 1;
    self._LM.headingFilter = 1;
    self._LM.delegate = self;

    self.coordsRealNotFake = self.coords = self._LM.location.coordinate;
    NSLog(@"%@: Starting at %@", [self class], [Coordinates niceCoordinates:self.coords]);

    self.delegatesHistory = [NSMutableArray arrayWithCapacity:5];
    self.delegatesLocation = [NSMutableArray arrayWithCapacity:5];
    self.delegatesSpeed = [NSMutableArray arrayWithCapacity:5];
    self.delegatesHeading = [NSMutableArray arrayWithCapacity:5];
    self.useGNSS = YES;

    self.lastSync = 0;
    self.historyData = [NSMutableArray arrayWithCapacity:configManager.keeptrackSync / configManager.keeptrackTimeDeltaMax];
    self.coordsSpeed = [NSMutableArray arrayWithCapacity:configManager.speedSamples];

    CLAuthorizationStatus stat = [CLLocationManager authorizationStatus];
    if (stat == kCLAuthorizationStatusNotDetermined ||
        stat == kCLAuthorizationStatusRestricted ||
        stat == kCLAuthorizationStatusDenied)
        [self._LM requestWhenInUseAuthorization];

    BACKGROUND(backgroundUpdater, nil);

    return self;
}

- (void)updateLocationDelegates
{
    // Disable updates when not needed.
    if (self.useGNSS == NO)
        return;

    [self.delegatesLocation enumerateObjectsUsingBlock:^(id<LocationManagerLocationDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate locationManagerUpdateLocation];
    }];
}

- (void)updateHistoryDelegates:(GCCoordsHistorical *)ch
{
    [self.delegatesHistory enumerateObjectsUsingBlock:^(id<LocationManagerHistoryDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate locationManagerUpdateHistory:ch];
    }];
}

- (void)updateSpeedDelegates
{
    [self.delegatesSpeed enumerateObjectsUsingBlock:^(id<LocationManagerSpeedDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate locationManagerUpdateSpeed];
    }];
}

- (void)updateHeadingDelegates
{
    [self.delegatesHeading enumerateObjectsUsingBlock:^(id<LocationManagerHeadingDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate locationManagerUpdateHeading];
    }];
}

- (void)checkStopDelegations
{
    if ([self.delegatesLocation count] > 0 ||
        [self.delegatesSpeed count] > 0 ||
        [self.delegatesHeading count] > 0 ||
        [self.delegatesHistory count] > 0)
        return;

    [self._LM stopUpdatingHeading];
    [self._LM stopUpdatingLocation];
    NSLog(@"%@: Stopped all of them", [self class]);
}

- (void)startDelegationLocation:(id)_delegate isNavigating:(BOOL)isNavigating
{
    NSLog(@"%@: Location starting for %@ (isNavigating:%d)", [self class], [_delegate class], isNavigating);
    [self adjustAccuracy:isNavigating];
    [self._LM startUpdatingHeading];
    [self._LM startUpdatingLocation];

    if (_delegate != nil) {
        [self.delegatesLocation addObject:_delegate];
        [_delegate locationManagerUpdateLocation];
    }
}

- (void)stopDelegationLocation:(id)_delegate
{
    NSLog(@"%@: Location stopping for %@", [self class], [_delegate class]);
    [self.delegatesLocation removeObject:_delegate];
    [self adjustAccuracy:0];
    [self checkStopDelegations];
}

- (void)startDelegationHistory:(id)_delegate
{
    NSLog(@"%@: History starting for %@", [self class], [_delegate class]);
    [self.delegatesHistory addObject:_delegate];
    [_delegate locationManagerUpdateHistory:nil];
}

- (void)stopDelegationHistory:(id)_delegate
{
    NSLog(@"%@: History stopping for %@", [self class], [_delegate class]);
    [self.delegatesHistory removeObject:_delegate];
    [self checkStopDelegations];
}

- (void)startDelegationSpeed:(id)_delegate
{
    NSLog(@"%@: Speed starting for %@", [self class], [_delegate class]);
    [self.delegatesSpeed addObject:_delegate];
    [_delegate locationManagerUpdateSpeed];
}

- (void)stopDelegationSpeed:(id)_delegate
{
    NSLog(@"%@: Speed stopping for %@", [self class], [_delegate class]);
    [self.delegatesSpeed removeObject:_delegate];
    [self checkStopDelegations];
}

- (void)startDelegationHeading:(id)_delegate
{
    NSLog(@"%@: Heading starting for %@", [self class], [_delegate class]);
    [self.delegatesHeading addObject:_delegate];
    [_delegate locationManagerUpdateHeading];
}

- (void)stopDelegationHeading:(id)_delegate
{
    NSLog(@"%@: Heading stopping for %@", [self class], [_delegate class]);
    [self.delegatesHeading removeObject:_delegate];
    [self checkStopDelegations];
}

- (void)setNewAccuracy:(LM_ACCURACY)accuracy
{
    if (accuracy == self.lastAccuracy)
        return;
    self.lastAccuracy = accuracy;
    NSLog(@"%@: New accuracy: %ld", [self class], (long)accuracy);

    switch (accuracy) {
        case LMACCURACY_3000M:
            self._LM.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            break;
        case LMACCURACY_1000M:
            self._LM.desiredAccuracy = kCLLocationAccuracyKilometer;
            break;
        case LMACCURACY_100M:
            self._LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case LMACCURACY_10M:
            self._LM.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case LMACCURACY_BEST:
            self._LM.desiredAccuracy = kCLLocationAccuracyBest;
            break;
        case LMACCURACY_BESTFORNAVIGATION:
            self._LM.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        default:
            abort();
    }
}

- (void)adjustAccuracy:(BOOL)isNavigating
{
    /*

                far
     +-----------------------+
     |                       |
     |                       |
     |        midrange       | GNNS accuracy
     |                       | DynamicAccuracyNear - Accuracy within the Near radius
     |        +-----+        | DynamicAccuracyMidrange - Accuracy within the Midrange radius
     |        |near |        | DynamicAccuracyFar - Accuracy outside the Far radius
     |        |  +  |        |
     |        |     |        | DynamicDistanceNeartoMidrange - Radius of Near
     |        +-----+        | DynamicDistanceMidrangeToFar - Radius of Midrange
     |                       |
     |                       | GNNS coordinate update interval
     |                       | DynamicDeltaDNear - Distance to move to send coordinates to delegates within Near radius
     |                       | DynamicDeltaDMidrange - Distance to move to send coordinates to delegates within Midrange radius
     +-----------------------+ DynamicDeltaDFar - Distance to move to send coordinates to delegates within Far radius

     Multiple scenarios:
     - No target waypoint is set, app is just being used to cruise:
       o  Set the GNNS accuracy to far as it doesn't matter to be close by anything.
       o  Set the GNNS coordinate update interval to far as it doesn't matter to be really up-to-date
     - Target is set, current waypoint is in the "far" area:
       o  Set the GNNS accuracy to "far" (100 meter).
       o  Set the GNNS coordinate update interval to "far" (10 meters).
     - Target is set, current waypoint is in the "midrange" area (250 meters)
       o  Set the GNNS accuracy to "midrange" (10 meter).
       o  Set the GNNS coordinate update interval to "midrange" (5 meters).
     - Target is set, current waypoint is in the "near" area (50 meters)
       o  Set the GNNS accuracy to "near" (best).
       o  Set the GNNS coordinate update interval to "near" (0 meters).

     Interesting information:
     http://evgenii.com/blog/power-consumption-of-location-services-in-ios/
     http://www.bionoren.com/blog/2013/08/why-do-navigation-apps-drain-your-battery/

     */

    self.lastIsNavigating = isNavigating;

    // Static stuff, easy:
    if (configManager.accuracyDynamicEnable == NO) {
        if (isNavigating == NO) {
            [self setNewAccuracy:configManager.accuracyStaticAccuracyNonNavigating];
            self._LM.distanceFilter = configManager.accuracyStaticDeltaDNonNavigating;
        } else {
            [self setNewAccuracy:configManager.accuracyStaticAccuracyNavigating];
            self._LM.distanceFilter = configManager.accuracyStaticDeltaDNavigating;
        }
        return;
    }

    // Not navigating or no waypoint selected, as such assume "far"
    if (isNavigating == NO || waypointManager.currentWaypoint == nil) {
        [self setNewAccuracy:configManager.accuracyDynamicAccuracyFar];
        self._LM.distanceFilter = configManager.accuracyDynamicDeltaDFar;
        return;
    }

    // Check the distances
    NSInteger d = [Coordinates coordinates2distance:self.coords toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude];
    if (d <= configManager.accuracyDynamicDistanceNearToMidrange) {
        [self setNewAccuracy:configManager.accuracyDynamicAccuracyNear];
        self._LM.distanceFilter = configManager.accuracyDynamicDeltaDNear;
    } else if (d <= configManager.accuracyDynamicDistanceMidrangeToFar) {
        [self setNewAccuracy:configManager.accuracyDynamicAccuracyMidrange];
        self._LM.distanceFilter = configManager.accuracyDynamicDeltaDMidrange;
    } else {
        [self setNewAccuracy:configManager.accuracyDynamicAccuracyFar];
        self._LM.distanceFilter = configManager.accuracyDynamicDeltaDFar;
    }
}

- (void)backgroundUpdater
{
    do {
        // Wait for a second and updates
        [NSThread sleepForTimeInterval:1];
        if (self.gotUpdate == NO)
            continue;
        self.gotUpdate = NO;

        // Keep a copy of the current data
        NSDate *now = [NSDate date];
        NSTimeInterval td = [now timeIntervalSince1970];

        GCCoordsHistorical *ch = [[GCCoordsHistorical alloc] init];
        ch.when = td;
        ch.coord = LM.coords;
        ch.restart = NO;

        [self.coordsHistorical addObject:ch];

        // Calculate speed over the last ten units.
        if (configManager.speedEnable == YES) {
            [self.coordsSpeed addObject:ch];
            if ([self.coordsSpeed count] >= configManager.speedSamples) {
                GCCoordsHistorical *ch0 = [self.coordsSpeed firstObject];
                td = ch.when - ch0.when;
                float distance = [Coordinates coordinates2distance:ch.coord to:ch0.coord];
                if (td != 0) {
                    self.speed = distance / td;
                    [self updateSpeedDelegates];
                }
                [self.coordsSpeed removeObjectAtIndex:0];
            }
        }

        // Change the accuracy for the receiver
        [self adjustAccuracy:self.lastIsNavigating];

        if (configManager.keeptrackEnable == NO && configManager.keeptrackMemoryOnly == YES)
            [self updateHistoryDelegates:ch];

        if (configManager.keeptrackEnable == YES) {
            // Update the historical track.
            // To save from random data changes, only do it every 5 seconds or every 100 meters, whatever comes first.
            float distance = [Coordinates coordinates2distance:ch.coord to:self.coordsHistoricalLast];
            td = ch.when - self.lastHistory.timeIntervalSince1970;
            if (td > configManager.keeptrackTimeDeltaMin || distance > configManager.keeptrackDistanceDeltaMin) {
                BOOL jump = (td > configManager.keeptrackTimeDeltaMax || distance > configManager.keeptrackDistanceDeltaMax);
                if (jump == YES) {
                    ch.restart = YES;
                    self.speed = 0;
                    [self.coordsSpeed removeAllObjects];
                    [self updateSpeedDelegates];
                }
                [self updateHistoryDelegates:ch];

                self.coordsHistoricalLast = ch.coord;
                self.lastHistory = now;
                if (configManager.currentTrack != 0) {
                    dbTrackElement *te = [[dbTrackElement alloc] init];
                    te.track = configManager.currentTrack;
                    te.lat = self.coords.latitude;
                    te.lon = self.coords.longitude;
                    te.height = self.altitude;
                    te.timestamp_epoch = time(NULL);
                    te.restart = jump;
                    [te dbCreate];
                    [self.historyData addObject:te];

                    // Sync
                    if (self.lastSync + configManager.keeptrackSync < te.timestamp_epoch) {
                        [self.historyData enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
                            [e dbCreate];
                        }];
                        [self.historyData removeAllObjects];
                        self.lastSync = te.timestamp_epoch;
                    }
                }
            }
        }

        NSLog(@"Coordinates: %@ - Direction: %ld - speed: %0.2lf m/s", [Coordinates niceCoordinates:self.coords], (long)LM.direction, LM.speed);

    } while (YES);
}

- (void)clearCoordsHistorical
{
    [self.coordsHistorical removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    if (self.useGNSS == NO) {
        self.coordsRealNotFake = [locations lastObject].coordinate;
        return;
    }

    CLLocation *newLocation = [locations lastObject];

    if (self.altitude == manager.location.altitude &&
        self.coords.latitude == newLocation.coordinate.latitude &&
        self.coords.longitude == newLocation.coordinate.longitude &&
        self.accuracy == newLocation.horizontalAccuracy)
        return;

    // Keep track of new values
    self.altitude = manager.location.altitude;
    self.coordsRealNotFake = self.coords = newLocation.coordinate;
    self.accuracy = newLocation.horizontalAccuracy;

    // Send out the location and direction changes
    [self updateLocationDelegates];

    // Let somebody else deal with the expensive stuff.
    self.gotUpdate = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (self.useGNSS == NO)
        return;

    self.direction = newHeading.trueHeading;

    // NSLog(@"Coordinates: %@ - Direction: %ld - speed: %0.2lf m/s", [Coordinates NiceCoordinates:coords], (long)LM.direction, LM.speed);

    [self updateHeadingDelegates];
}

- (void)useGNSS:(BOOL)useGNSS coordinates:(CLLocationCoordinate2D)newcoords
{
    if (useGNSS == YES) {
        self.useGNSS = YES;
        [self updateLocationDelegates];
    } else {
        self.coords = newcoords;
        // First tell the others, then disable.
        [self updateLocationDelegates];
        self.useGNSS = NO;
    }
}

@end
