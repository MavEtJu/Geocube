//
//  CompassViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation CompassViewController

@synthesize locationManager;

- (id)init
{
    self = [super init];

    menuItems = [NSArray arrayWithObjects:@"XNothing", nil];

    cacheIcon = nil;
    cacheName = nil;
    cacheLat = nil;
    cacheLon = nil;
    myLat = nil;
    myLon = nil;
    accuracy = nil;
    altitude = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    NSInteger width = applicationFrame.size.width;
    NSInteger height = self.view.frame.size.height - 100;

    /*
     +------+-------+------+
     |Icon  |GC Code| SIze |
     |      |Coordin|Rating|
     +------+-------+------+
     |       Distance      |
     |                     |
     |      Compass        |
     |                     |
     |                     |
     |      Cache Name     |
     +------+-------+------+
     |Accura|My coor|Altitu|
     |      |       |      |
     +------+-------+------+
     */

#define HEIGHT  height / 3
#define BLOCK  width / 3
    CGRect rectIcon = CGRectMake(0, 0, BLOCK, HEIGHT);
    CGRect rectName = CGRectMake(BLOCK, 0, BLOCK, HEIGHT / 3);
    CGRect rectCoordLat = CGRectMake(BLOCK, HEIGHT / 3, width - 2 * BLOCK, HEIGHT / 3);
    CGRect rectCoordLon = CGRectMake(BLOCK, 2 * HEIGHT / 3, width - 2 * BLOCK, HEIGHT / 3);
    CGRect rectSize = CGRectMake(width - BLOCK, 0, BLOCK, HEIGHT / 3);
    CGRect rectRatingD = CGRectMake(width - BLOCK, HEIGHT / 3, BLOCK, HEIGHT / 3);
    CGRect rectRatingT = CGRectMake(width - BLOCK, 2 * HEIGHT / 3, BLOCK, HEIGHT / 3);

    CGRect rectCompass = CGRectMake(0, HEIGHT, width, HEIGHT);

    CGRect rectAccuracyText = CGRectMake(0, height - HEIGHT, BLOCK, HEIGHT / 3);
    CGRect rectAccuracy = CGRectMake(0, height - 2 * HEIGHT / 3, BLOCK, HEIGHT / 3);
    CGRect rectMyLat = CGRectMake(BLOCK, height - 2 * HEIGHT / 3, BLOCK, HEIGHT / 3);
    CGRect rectMyLon = CGRectMake(BLOCK, height - 1 * HEIGHT / 3, BLOCK, HEIGHT / 3);
    CGRect rectAltitudeText = CGRectMake(width - BLOCK, height - 2 * HEIGHT / 3, BLOCK, HEIGHT / 3);
    CGRect rectAltitude = CGRectMake(width - BLOCK, height - 1 * HEIGHT / 3, BLOCK, HEIGHT / 3);

    UILabel *l;

    cacheIcon = [[UIImageView alloc] initWithFrame:rectIcon];
    cacheIcon.backgroundColor = [UIColor redColor];
    [self.view addSubview:cacheIcon];

#define FONTSIZE    14

    cacheName = [[UILabel alloc] initWithFrame:rectName];
    cacheName.backgroundColor = [UIColor blueColor];
    cacheName.textAlignment = NSTextAlignmentCenter;
    cacheName.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:cacheName];

    cacheLat = [[UILabel alloc] initWithFrame:rectCoordLat];
    cacheLat.backgroundColor = [UIColor greenColor];
    cacheLat.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:cacheLat];

    cacheLon = [[UILabel alloc] initWithFrame:rectCoordLon];
    cacheLon.backgroundColor = [UIColor yellowColor];
    cacheLon.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:cacheLon];

    myLat = [[UILabel alloc] initWithFrame:rectMyLat];
    myLat.text = @"-";
    myLat.backgroundColor = [UIColor brownColor];
    myLat.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLat];

    myLon = [[UILabel alloc] initWithFrame:rectMyLon];
    myLon.text = @"-";
    myLon.backgroundColor = [UIColor yellowColor];
    myLon.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLon];

    l = [[UILabel alloc] initWithFrame:rectAccuracyText];
    l.text = @"Accuracy";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];
    accuracy = [[UILabel alloc] initWithFrame:rectAccuracy];
    accuracy.text = @"-";
    accuracy.backgroundColor = [UIColor purpleColor];
    accuracy.textAlignment = NSTextAlignmentCenter;
    accuracy.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:accuracy];

    l = [[UILabel alloc] initWithFrame:rectAltitudeText];
    l.text = @"Altitude";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];
    altitude = [[UILabel alloc] initWithFrame:rectAltitude];
    altitude.text = @"-";
    altitude.backgroundColor = [UIColor yellowColor];
    altitude.textAlignment = NSTextAlignmentCenter;
    altitude.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:altitude];

    compassImage  = [UIImage imageNamed:[NSString stringWithFormat:@"%@/compass.png", [MyTools DataDistributionDirectory]]];
    compassImageView = [[UIImageView alloc] initWithFrame:rectCompass];
    compassImageView.image = compassImage;
    [self.view addSubview:compassImageView];

    /* Initiate the location manager */
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    locationManager.headingFilter = 1;
    locationManager.delegate = self;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    /* Start the location manager */
    [locationManager startUpdatingHeading];
    [locationManager startUpdatingLocation];

    /* Initiate the current cache */
    Coordinates *coords = [[Coordinates alloc] init:currentCache.lat_float lon:currentCache.lon_float];

    cacheIcon.image = [imageLibrary get:currentCache.cache_type.icon];
    cacheName.text = currentCache.name;
    cacheLat.text = [coords lat_degreesDecimalMinutes];
    cacheLon.text = [coords lon_degreesDecimalMinutes];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    accuracy.text = [NSString stringWithFormat:@"%ld m", (NSInteger)newLocation.horizontalAccuracy];
    altitude.text = [NSString stringWithFormat:@"%ld m", (NSInteger)manager.location.altitude];

    NSLog(@"new location: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    Coordinates *c = [[Coordinates alloc] initWithCLLocationCoordinate2D:newLocation.coordinate];
    myLat.text = [c lat_degreesDecimalMinutes];
    myLon.text = [c lon_degreesDecimalMinutes];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // Convert Degree to Radian and move the needle
    float oldRad = -manager.heading.trueHeading * M_PI / 180.0f;
    float newRad = -newHeading.trueHeading * M_PI / 180.0f;

    CABasicAnimation *theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
    theAnimation.toValue = [NSNumber numberWithFloat:newRad];
    theAnimation.duration = 0.5f;
    [compassImageView.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    compassImageView.transform = CGAffineTransformMakeRotation(newRad);

//    NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, oldRad, newHeading.trueHeading, newRad);

    altitude.text = [NSString stringWithFormat:@"%0f", manager.location.altitude];

    Coordinates *c = [[Coordinates alloc] initWithCLLocationCoordinate2D:manager.location.coordinate];
    myLat.text = [c lat_degreesDecimalMinutes];
    myLon.text = [c lon_degreesDecimalMinutes];
}

@end
