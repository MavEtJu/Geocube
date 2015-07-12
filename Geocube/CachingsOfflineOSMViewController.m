//
//  CachingsOfflineOSMViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 12/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#import "Mapbox.h"

@implementation CachingsOfflineOSMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoibWF2ZXRqdSIsImEiOiJkOTY4Nzk0MDA3Y2ZhYzVmOGFjNDlmYzcxNzMzZjMyOSJ9.7eDiNLp-j4BD_w9Nw8Skbw"];
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"mapbox.run-bike-hike"];
    
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                            andTilesource:tileSource];
    // set zoom
    mapView.zoom = 1;
    
    // set coordinates
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(38.910003,-77.015533);
    
    // center the map to the coordinates
    mapView.centerCoordinate = center;
    
    [self.view addSubview:mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
