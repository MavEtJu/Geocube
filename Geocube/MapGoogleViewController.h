//
//  CachingsOfflineGoogleMapsViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@import GoogleMaps;

@interface MapGoogleViewController : MapTemplateViewController {
    GMSMapView *mapView;
    GMSMarker *me;
}

@end
