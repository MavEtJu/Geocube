//
//  GCLocationManager.m
//  Geocube
//
//  Created by Edwin Groothuis on 17/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation GCLocationManager

@synthesize altitude, accuracy, coords, direction, delegate;

- (id)init
{
    self = [super init];

    delegateCounter = 0;
    
    /* Initiate the location manager */
    _LM = [[CLLocationManager alloc] init];
    _LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _LM.distanceFilter = 1;
    _LM.headingFilter = 1;
    _LM.delegate = self;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_LM requestWhenInUseAuthorization];
    }

    return self;
}

- (void)updateDataDelegate
{
    if (delegate == nil)
        return;
    [delegate updateData];
}

- (void)startDelegation:(id)_delegate isNavigating:(BOOL)isNavigating
{
    delegateCounter++;

    NSLog(@"GCLocationManager: starting (isNavigating:%d)", isNavigating);
    if (isNavigating == YES)
        _LM.desiredAccuracy = kCLLocationAccuracyBest;
    else
        _LM.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_LM startUpdatingHeading];
    [_LM startUpdatingLocation];
    delegate = _delegate;
}

- (void)stopDelegation:(id)_delegate
{
    delegateCounter--;
    if (delegateCounter > 0)
        return;

    NSLog(@"GCLocationManager: stopping");
    delegate = nil;
    [_LM stopUpdatingHeading];
    [_LM stopUpdatingLocation];
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
