//
//  CachesOfflineOSMViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface MapOSMViewController : GCViewController<MKMapViewDelegate> {
    NSArray *wps;
    NSInteger wpCount;
    MKMapView *mapView;
}

@end
