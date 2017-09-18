//
//  LocationManager-delegate.h
//  ManagersLibrary
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@class GCCoordsHistorical;

@protocol LocationManagerLocationDelegate

- (void)updateLocationManagerLocation;

@end

@protocol LocationManagerHeadingDelegate

- (void)updateLocationManagerHeading;

@end

@protocol LocationManagerSpeedDelegate

- (void)updateLocationManagerSpeed;

@end

@protocol LocationManagerHistoryDelegate

- (void)updateLocationManagerHistory:(GCCoordsHistorical *)ch;

@end
