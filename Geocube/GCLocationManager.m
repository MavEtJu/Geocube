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
    
    /* Initiate the location manager */
    _LM = [[CLLocationManager alloc] init];
    _LM.desiredAccuracy = kCLLocationAccuracyBest;
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

- (void)startDelegation:(id)_delegate
{
    if (delegate != nil)
        NSAssert(0, @"%s: self.delegate != nil", __FUNCTION__);

    [_LM startUpdatingHeading];
    [_LM startUpdatingLocation];
    delegate = _delegate;
}

- (void)stopDelegation:(id)_delegate
{
    if (self.delegate != _delegate)
        NSAssert(0, @"%s: self.delegate == nil", __FUNCTION__);

    delegate = nil;
    [_LM stopUpdatingHeading];
    [_LM stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    altitude = manager.location.altitude;
    coords = newLocation.coordinate;

    accuracy = newLocation.horizontalAccuracy;

    [self updateDataDelegate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    altitude = manager.location.altitude;
    coords = manager.location.coordinate;

    direction = newHeading.trueHeading;

    [self updateDataDelegate];
}

@end
