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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "BaseObjectsLibrary/GCCoordsHistorical.h"

#import "LocationManager-enum.h"

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

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) NSMutableArray<id> *delegatesLocation;
@property (nonatomic, retain) NSMutableArray<id> *delegatesHistory;
@property (nonatomic, retain) NSMutableArray<id> *delegatesSpeed;
@property (nonatomic, retain) NSMutableArray<id> *delegatesHeading;
@property (nonatomic) float speed;

@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) CLLocationDistance altitude;
@property (nonatomic) CLLocationDirection direction;
@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) NSMutableArray<GCCoordsHistorical *> *coordsHistorical;
@property (nonatomic, readonly) BOOL useGNSS;

- (void)startDelegationLocation:(id<LocationManagerLocationDelegate>)delegate isNavigating:(BOOL)isNavigating;
- (void)stopDelegationLocation:(id<LocationManagerLocationDelegate>)delegate;
- (void)startDelegationHistory:(id<LocationManagerHistoryDelegate>)delegate;
- (void)stopDelegationHistory:(id<LocationManagerHistoryDelegate>)delegate;
- (void)startDelegationSpeed:(id<LocationManagerSpeedDelegate>)delegate;
- (void)stopDelegationSpeed:(id<LocationManagerSpeedDelegate>)delegate;
- (void)startDelegationHeading:(id<LocationManagerHeadingDelegate>)delegate;
- (void)stopDelegationHeading:(id<LocationManagerHeadingDelegate>)delegate;

- (void)useGNSS:(BOOL)_useGNSS coordinates:(CLLocationCoordinate2D)newcoords;
- (void)clearCoordsHistorical;

@end

extern LocationManager *LM;
