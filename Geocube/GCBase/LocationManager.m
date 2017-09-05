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

@interface LocationManager ()
{
    CLLocationManager *_LM;

    NSDate *lastHistory;
    CLLocationCoordinate2D coordsHistoricalLast;

    NSMutableArray<dbTrackElement *> *historyData;
    NSInteger lastSync;
    NSInteger lastAccuracy;
    NSInteger lastIsNavigating;
}

@property (nonatomic, readwrite) BOOL useGNSS;

@end

@implementation LocationManager

- (instancetype)init
{
    self = [super init];

    self.coordsHistorical = [NSMutableArray arrayWithCapacity:1000];
    lastHistory = [NSDate date];
    self.speed = 0;

    /* Initiate the location manager */
    _LM = [[CLLocationManager alloc] init];
    [self adjustAccuracy:LMACCURACY_1000M];
    _LM.distanceFilter = 1;
    _LM.headingFilter = 1;
    _LM.delegate = self;

    self.coords = _LM.location.coordinate;
    NSLog(@"%@: Starting at %@", [self class], [Coordinates niceCoordinates:self.coords]);

    self.delegates = [NSMutableArray arrayWithCapacity:5];
    self.useGNSS = YES;

    lastSync = 0;
    historyData = [NSMutableArray arrayWithCapacity:configManager.keeptrackSync / configManager.keeptrackTimeDeltaMax];

    CLAuthorizationStatus stat = [CLLocationManager authorizationStatus];
    if (stat == kCLAuthorizationStatusNotDetermined ||
        stat == kCLAuthorizationStatusRestricted ||
        stat == kCLAuthorizationStatusDenied)
        [_LM requestWhenInUseAuthorization];

    return self;
}

- (void)updateDataDelegates
{
    // Disable updates when not needed.
    if (self.useGNSS == NO)
        return;

    if ([self.delegates count] == 0)
        return;
    [self.delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate updateLocationManagerLocation];
    }];
}

- (void)updateHistoryDelegate:(GCCoordsHistorical *)ch
{
    if ([self.delegates count] == 0)
        return;
    [self.delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([delegate respondsToSelector:@selector(updateLocationManagerHistory:)])
            [delegate updateLocationManagerHistory:ch];
    }];
}

- (void)setNewAccuracy:(LM_ACCURACY)accuracy
{
    if (accuracy == lastAccuracy)
        return;
    lastAccuracy = accuracy;
    NSLog(@"%@: New accuracy: %ld", [self class], (long)accuracy);

    switch (accuracy) {
        case LMACCURACY_3000M:
            _LM.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            break;
        case LMACCURACY_1000M:
            _LM.desiredAccuracy = kCLLocationAccuracyKilometer;
            break;
        case LMACCURACY_100M:
            _LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case LMACCURACY_10M:
            _LM.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case LMACCURACY_BEST:
            _LM.desiredAccuracy = kCLLocationAccuracyBest;
            break;
        case LMACCURACY_BESTFORNAVIGATION:
            _LM.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        default:
            abort();
    }
}

- (void)adjustAccuracy:(BOOL)isNavigating
{
    lastIsNavigating = isNavigating;

    // Static stuff, easy:
    if (configManager.accuracyDynamicEnable == NO) {
        if (isNavigating == NO)
            [self setNewAccuracy:configManager.accuracyStaticNonNavigating];
        else
            [self setNewAccuracy:configManager.accuracyStaticNavigating];
        return;
    }

    // Not navigating or no waypoint selected, as such assume "far"
    if (isNavigating == NO || waypointManager.currentWaypoint == nil) {
        [self setNewAccuracy:configManager.accuracyDynamicFar];
        return;
    }

    // Check the distances
    NSInteger d = [Coordinates coordinates2distance:self.coords toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude];
    if (d <= configManager.accuracyDynamicNearToMidrange)
        [self setNewAccuracy:configManager.accuracyDynamicNear];
    else if (d <= configManager.accuracyDynamicMidrangeToFar)
        [self setNewAccuracy:configManager.accuracyDynamicMidrange];
    else
        [self setNewAccuracy:configManager.accuracyDynamicFar];
}

- (void)startDelegation:(id)_delegate isNavigating:(BOOL)isNavigating
{
    NSLog(@"%@: starting for %@ (isNavigating:%d)", [self class], [_delegate class], isNavigating);

    [self adjustAccuracy:isNavigating];
    [_LM startUpdatingHeading];
    [_LM startUpdatingLocation];

    if (_delegate != nil) {
        [self.delegates addObject:_delegate];
        [_delegate updateLocationManagerLocation];
        if ([_delegate respondsToSelector:@selector(updateLocationManagerHistory:)])
            [_delegate updateLocationManagerHistory:nil];
    }
}

- (void)stopDelegation:(id)_delegate
{
    NSLog(@"%@: stopping for %@", [self class], [_delegate class]);
    [self.delegates removeObject:_delegate];
    [self adjustAccuracy:0];

    if ([self.delegates count] > 0)
        return;
    [_LM stopUpdatingHeading];
    [_LM stopUpdatingLocation];
    NSLog(@"%@: stopped all of them", [self class]);
}

- (void)clearCoordsHistorical
{
    [self.coordsHistorical removeAllObjects];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (self.useGNSS == NO)
        return;

    // Keep track of new values
    self.altitude = manager.location.altitude;
    self.coords = newLocation.coordinate;
    self.accuracy = newLocation.horizontalAccuracy;

    // If the location hasn't changed, don't do anything at all.
    if ([self.coordsHistorical count] != 0) {
        GCCoordsHistorical *chLast = [self.coordsHistorical objectAtIndex:[self.coordsHistorical count] - 1];
        if (chLast.coord.longitude == newLocation.coordinate.longitude &&
            chLast.coord.latitude == newLocation.coordinate.latitude) {
            return;
        }
    }

    // Keep a copy of the current data
    NSDate *now = [NSDate date];
    NSTimeInterval td = [now timeIntervalSince1970];

    GCCoordsHistorical *ch = [[GCCoordsHistorical alloc] init];
    ch.when = td;
    ch.coord = newLocation.coordinate;
    ch.restart = NO;

    [self.coordsHistorical addObject:ch];

    // Calculate speed over the last ten units.
    if ([self.coordsHistorical count] > 10) {
        GCCoordsHistorical *ch0 = [self.coordsHistorical objectAtIndex:[self.coordsHistorical count] - 10];
        td = ch.when - ch0.when;
        float distance = [Coordinates coordinates2distance:ch.coord to:ch0.coord];
        if (td != 0)
            self.speed = distance / td;
    }

    // Send out the location and direction changes
    [self updateDataDelegates];

    // Change the accuracy for the receiver
    [self adjustAccuracy:lastIsNavigating];

    // Update the historical track.
    // To save from random data changes, only do it every 5 seconds or every 100 meters, whatever comes first.
    float distance = [Coordinates coordinates2distance:ch.coord to:coordsHistoricalLast];
    td = ch.when - lastHistory.timeIntervalSince1970;
    if (td > configManager.keeptrackTimeDeltaMin || distance > configManager.keeptrackDistanceDeltaMin) {
        BOOL jump = (td > configManager.keeptrackTimeDeltaMax || distance > configManager.keeptrackDistanceDeltaMax);
        if (jump)
            ch.restart = YES;
        [self updateHistoryDelegate:ch];

        coordsHistoricalLast = ch.coord;
        lastHistory = now;
        if (configManager.currentTrack != 0) {
            dbTrackElement *te = [[dbTrackElement alloc] init];
            te.track = configManager.currentTrack;
            te.lat = self.coords.latitude;
            te.lon = self.coords.longitude;
            te.height = self.altitude;
            te.restart = jump;
            [te dbCreate];
            [historyData addObject:te];
            if (lastSync + configManager.keeptrackSync < te.timestamp_epoch) {
                [historyData enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
                    [e dbCreate];
                }];
                [historyData removeAllObjects];
                lastSync = te.timestamp_epoch;
            }
        }
    }

    NSLog(@"Coordinates: %@ - Direction: %ld - speed: %0.2lf m/s", [Coordinates niceCoordinates:self.coords], (long)LM.direction, LM.speed);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (self.useGNSS == NO)
        return;

    self.altitude = manager.location.altitude;
    self.coords = manager.location.coordinate;
    self.direction = newHeading.trueHeading;

    // NSLog(@"Coordinates: %@ - Direction: %ld - speed: %0.2lf m/s", [Coordinates NiceCoordinates:coords], (long)LM.direction, LM.speed);

    [self updateDataDelegates];
}

- (void)useGNSS:(BOOL)useGNSS coordinates:(CLLocationCoordinate2D)newcoords
{
    if (useGNSS == YES) {
        self.useGNSS = YES;
        [self updateDataDelegates];
    } else {
        self.coords = newcoords;
        // First tell the others, then disable.
        [self updateDataDelegates];
        self.useGNSS = NO;
    }
}

@end
