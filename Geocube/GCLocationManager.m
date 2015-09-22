/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@implementation GCLocationManager

@synthesize altitude, accuracy, coords, direction, delegates;

- (instancetype)init
{
    self = [super init];

    /* Initiate the location manager */
    _LM = [[CLLocationManager alloc] init];
    _LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _LM.distanceFilter = 1;
    _LM.headingFilter = 1;
    _LM.delegate = self;

    delegates = [NSMutableArray arrayWithCapacity:5];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_LM requestWhenInUseAuthorization];
    }

    return self;
}

- (void)updateDataDelegate
{
    if ([delegates count] == 0)
        return;
    [delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL *stop) {
        [delegate updateData];
    }];
}

- (void)startDelegation:(id)_delegate isNavigating:(BOOL)isNavigating
{
    NSLog(@"GCLocationManager: starting for %@ (isNavigating:%d)", [_delegate class], isNavigating);
    if (isNavigating == YES)
        _LM.desiredAccuracy = kCLLocationAccuracyBest;
    else
        _LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_LM startUpdatingHeading];
    [_LM startUpdatingLocation];
    if (_delegate != nil)
        [delegates addObject:_delegate];
}

- (void)stopDelegation:(id)_delegate
{
    NSLog(@"GCLocationManager: stopping for %@", [_delegate class]);
    [delegates removeObject:_delegate];

    if ([delegates count] > 0)
        return;
    [_LM stopUpdatingHeading];
    [_LM stopUpdatingLocation];
    NSLog(@"GCLocationManager: stopping");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    altitude = manager.location.altitude;
    coords = newLocation.coordinate;

    accuracy = newLocation.horizontalAccuracy;

//    NSLog(@"New coordinates: %@", [Coordinates NiceCoordinates:coords]);

    [self updateDataDelegate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    altitude = manager.location.altitude;
    coords = manager.location.coordinate;

    direction = newHeading.trueHeading;

//    NSLog(@"New coordinates: %@", [Coordinates NiceCoordinates:coords]);

    [self updateDataDelegate];
}

@end
