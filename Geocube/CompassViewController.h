//
//  CompassViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CompassViewController : GCViewController<GCLocationManagerDelegate> {

    UIImage *compassImage;
    UIImageView *compassImageView;

    UIImageView *cacheIcon;
    UILabel *cacheName;
    UILabel *cacheLat;
    UILabel *cacheLon;
    UIImageView *containerSize;
    UIImageView *ratingD;
    UIImageView *ratingT;
    UILabel *myLat;
    UILabel *myLon;
    UILabel *accuracy;
    UILabel *altitude;
    UILabel *distance;

    float oldRad;
}

@end
