//
//  CompassViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CompassViewController : GCViewController<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    UIImage *compassImage;
    UIImageView *compassImageView;
    
    UIImageView *cacheIcon;
    UILabel *cacheName;
    UILabel *cacheLat;
    UILabel *cacheLon;
    UILabel *myLat;
    UILabel *myLon;
    UILabel *accuracy;
    UILabel *altitude;
}

@property (nonatomic,retain) CLLocationManager *locationManager;

@end
