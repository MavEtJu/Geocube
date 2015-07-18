//
//  GCLocationManager.h
//  Geocube
//
//  Created by Edwin Groothuis on 17/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@class GCLocationManager;

@protocol GCLocationManagerDelegate

- (void)updateData;

@end

@interface GCLocationManager : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *_LM;

    CLLocationAccuracy accuracy;
    CLLocationDistance altitude;
    CLLocationDirection direction;
    CLLocationCoordinate2D coords;
    NSInteger delegateCounter;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) CLLocationDistance altitude;
@property (nonatomic) CLLocationDirection direction;
@property (nonatomic) CLLocationCoordinate2D coords;

- (void)startDelegation:(id)delegate isNavigating:(BOOL)isNavigating;
- (void)stopDelegation:(id)delegate;
- (void)updateDataDelegate;

@end
