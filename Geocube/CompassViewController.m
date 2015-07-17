//
//  CompassViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation CompassViewController

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

    oldRad = 0;

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

#define HEIGHT  height / 18
#define WIDTH  width / 3
    CGRect rectIcon = CGRectMake(WIDTH / 3, HEIGHT, WIDTH / 3, 1 * HEIGHT);
    CGRect rectName = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    CGRect rectCoordLat = CGRectMake(WIDTH, HEIGHT, WIDTH, HEIGHT);
    CGRect rectCoordLon = CGRectMake(WIDTH, 2 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectSize = CGRectMake(2 * WIDTH, 0, WIDTH, HEIGHT);
    CGRect rectRatingD = CGRectMake(2 * WIDTH, HEIGHT, WIDTH, HEIGHT);
    CGRect rectRatingT = CGRectMake(2 * WIDTH, 2 * HEIGHT, WIDTH, HEIGHT);

    CGRect rectDistance = CGRectMake(0, 3 * HEIGHT, 3 * WIDTH, HEIGHT);
    CGRect rectCompass = CGRectMake(0, 4 * HEIGHT, 3 * WIDTH, 10 * HEIGHT);
    CGRect rectDescription = CGRectMake(0, 14 * HEIGHT, 3 * WIDTH, HEIGHT);

    CGRect rectAccuracyText = CGRectMake(0, height - 3 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectAccuracy = CGRectMake(0, height - 2 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectMyLatText = CGRectMake(WIDTH, height - 3 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectMyLat = CGRectMake(WIDTH, height - 2 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectMyLon = CGRectMake(WIDTH, height - 1 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectAltitudeText = CGRectMake(2 * WIDTH, height - 3 * HEIGHT, WIDTH, HEIGHT);
    CGRect rectAltitude = CGRectMake(2 * WIDTH, height - 2 * HEIGHT, WIDTH, HEIGHT);

    UILabel *l;

    cacheIcon = [[UIImageView alloc] initWithFrame:rectIcon];
    [self.view addSubview:cacheIcon];

#define FONTSIZE    14

    cacheName = [[UILabel alloc] initWithFrame:rectName];
    cacheName.textAlignment = NSTextAlignmentCenter;
    cacheName.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:cacheName];

    cacheLat = [[UILabel alloc] initWithFrame:rectCoordLat];
    cacheLat.font = [UIFont systemFontOfSize:FONTSIZE];
    cacheLat.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:cacheLat];

    cacheLon = [[UILabel alloc] initWithFrame:rectCoordLon];
    cacheLon.font = [UIFont systemFontOfSize:FONTSIZE];
    cacheLon.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:cacheLon];

    containerSize = [[UIImageView alloc] initWithFrame:rectSize];
    containerSize.image = [imageLibrary get:ImageContainer_Unknown];
    [self.view addSubview:containerSize];

    ratingD = [[UIImageView alloc] initWithFrame:rectRatingD];
    ratingD.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingD];

    ratingT = [[UIImageView alloc] initWithFrame:rectRatingT];
    ratingT.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingT];

    l = [[UILabel alloc] initWithFrame:rectMyLatText];
    l.text = @"My location";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];

    myLat = [[UILabel alloc] initWithFrame:rectMyLat];
    myLat.text = @"-";
    myLat.textAlignment = NSTextAlignmentCenter;
    myLat.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLat];

    myLon = [[UILabel alloc] initWithFrame:rectMyLon];
    myLon.text = @"-";
    myLon.textAlignment = NSTextAlignmentCenter;
    myLon.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLon];

    l = [[UILabel alloc] initWithFrame:rectAccuracyText];
    l.text = @"Accuracy";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];
    accuracy = [[UILabel alloc] initWithFrame:rectAccuracy];
    accuracy.text = @"-";
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
    altitude.textAlignment = NSTextAlignmentCenter;
    altitude.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:altitude];

    distance = [[UILabel alloc] initWithFrame:rectDistance];
    distance.text = @"-";
    distance.textAlignment = NSTextAlignmentCenter;
    distance.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:distance];

    l = [[UILabel alloc] initWithFrame:rectDescription];
    l.text = currentCache.description;
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];

    compassImage  = [UIImage imageNamed:[NSString stringWithFormat:@"%@/compass.png", [MyTools DataDistributionDirectory]]];
    compassImageView = [[UIImageView alloc] initWithFrame:rectCompass];
    compassImageView.image = compassImage;
    [self.view addSubview:compassImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    /* Start the location manager */
    [LM startDelegation:self];

    /* Initiate the current cache */
    Coordinates *coords = [[Coordinates alloc] init:currentCache.lat_float lon:currentCache.lon_float];

    cacheIcon.image = [imageLibrary get:currentCache.cache_type.icon];
    containerSize.image = [imageLibrary get:currentCache.gc_containerSize.icon];
    ratingD.image = [imageLibrary getRating:currentCache.gc_rating_difficulty];
    ratingT.image = [imageLibrary getRating:currentCache.gc_rating_terrain];

    cacheName.text = currentCache.name;
    cacheLat.text = [coords lat_degreesDecimalMinutes];
    cacheLon.text = [coords lon_degreesDecimalMinutes];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [LM stopDelegation:self];
}

/* Receive data from the location manager */
- (void)updateData
{
    accuracy.text = [NSString stringWithFormat:@"%ld m", (NSInteger)LM.accuracy];
    altitude.text = [NSString stringWithFormat:@"%ld m", (NSInteger)LM.altitude];

    NSLog(@"new location: %f, %f", LM.coords.latitude, LM.coords.longitude);

    Coordinates *c = [[Coordinates alloc] initWithCLLocationCoordinate2D:LM.coords];
    myLat.text = [c lat_degreesDecimalMinutes];
    myLon.text = [c lon_degreesDecimalMinutes];

    float newRad = -LM.direction * M_PI / 180.0f;

    CABasicAnimation *theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
    theAnimation.toValue = [NSNumber numberWithFloat:newRad];
    theAnimation.duration = 0.5f;
    [compassImageView.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    compassImageView.transform = CGAffineTransformMakeRotation(newRad);

    oldRad = newRad;

    if (currentCache == nil)
        return;

    distance.text = [Coordinates NiceDistance:[c distance:MKCoordinates(currentCache.lat_float, currentCache.lon_float)]];

}

@end
