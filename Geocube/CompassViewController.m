/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface CompassViewController ()
{
    UIImage *compassImage;
    UIImageView *compassIV;
    UIImage *lineImage;
    UIImageView *lineIV;

    UIImageView *wpIconIV;
    GCLabel *wpNameLabel;
    GCLabel *wpDescriptionLabel;
    GCLabel *wpLatLabel;
    GCLabel *wpLonLabel;
    UIImageView *containerSizeIV;
    UIImageView *ratingDIV;
    UIImageView *ratingTIV;
    GCLabel *myLocationLabel;
    GCLabel *myLatLabel;
    GCLabel *myLonLabel;
    GCLabel *accuracyTextLabel;
    GCLabel *accuracyLabel;
    GCLabel *altitudeTextLabel;
    GCLabel *altitudeLabel;
    GCLabel *distanceLabel;

    NSInteger width;

    CGRect rectIcon;
    CGRect rectName;
    CGRect rectCoordLat;
    CGRect rectCoordLon;
    CGRect rectSize;
    CGRect rectRatingD;
    CGRect rectRatingT;

    CGRect rectDistance;
    CGRect rectDescription;
    CGRect rectCompass;

    CGRect rectAccuracyText;
    CGRect rectAccuracy;
    CGRect rectMyLocation;
    CGRect rectMyLat;
    CGRect rectMyLon;
    CGRect rectAltitudeText;
    CGRect rectAltitude;

    float oldCompass;
    UIDeviceOrientation currentOrienation;
    float bearingAdjustment;
}

@end

@implementation CompassViewController

- (instancetype)init
{
    self = [super init];

    wpIconIV = nil;
    wpNameLabel = nil;
    wpLatLabel = nil;
    wpLonLabel = nil;
    myLatLabel = nil;
    myLonLabel = nil;
    accuracyLabel = nil;
    altitudeLabel = nil;

    oldCompass = 0;
    currentOrienation = UIDeviceOrientationPortrait;
    bearingAdjustment = 0;

    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

#define FONTSIZE    14

    wpIconIV = [[UIImageView alloc] initWithFrame:rectIcon];
    [self.view addSubview:wpIconIV];

    wpNameLabel = [[GCLabel alloc] initWithFrame:rectName];
    wpNameLabel.textAlignment = NSTextAlignmentCenter;
    wpNameLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:wpNameLabel];

    wpLatLabel = [[GCLabel alloc] initWithFrame:rectCoordLat];
    wpLatLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    wpLatLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wpLatLabel];

    wpLonLabel = [[GCLabel alloc] initWithFrame:rectCoordLon];
    wpLonLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    wpLonLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wpLonLabel];

    containerSizeIV = [[UIImageView alloc] initWithFrame:rectSize];
    containerSizeIV.image = [imageLibrary get:ImageSize_NotChosen];
    [self.view addSubview:containerSizeIV];

    ratingDIV = [[UIImageView alloc] initWithFrame:rectRatingD];
    ratingDIV.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingDIV];

    ratingTIV = [[UIImageView alloc] initWithFrame:rectRatingT];
    ratingTIV.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingTIV];

    myLocationLabel = [[GCLabel alloc] initWithFrame:rectMyLocation];
    myLocationLabel.text = @"My location";
    myLocationLabel.textAlignment = NSTextAlignmentCenter;
    myLocationLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLocationLabel];

    myLatLabel = [[GCLabel alloc] initWithFrame:rectMyLat];
    myLatLabel.text = @"-";
    myLatLabel.textAlignment = NSTextAlignmentCenter;
    myLatLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLatLabel];

    myLonLabel = [[GCLabel alloc] initWithFrame:rectMyLon];
    myLonLabel.text = @"";
    myLonLabel.textAlignment = NSTextAlignmentCenter;
    myLonLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLonLabel];

    accuracyTextLabel = [[GCLabel alloc] initWithFrame:rectAccuracyText];
    accuracyTextLabel.text = @"Accuracy";
    accuracyTextLabel.textAlignment = NSTextAlignmentCenter;
    accuracyTextLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:accuracyTextLabel];
    accuracyLabel = [[GCLabel alloc] initWithFrame:rectAccuracy];
    accuracyLabel.text = @"-";
    accuracyLabel.textAlignment = NSTextAlignmentCenter;
    accuracyLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:accuracyLabel];

    altitudeTextLabel = [[GCLabel alloc] initWithFrame:rectAltitudeText];
    altitudeTextLabel.text = @"Altitude";
    altitudeTextLabel.textAlignment = NSTextAlignmentCenter;
    altitudeTextLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:altitudeTextLabel];
    altitudeLabel = [[GCLabel alloc] initWithFrame:rectAltitude];
    altitudeLabel.text = @"-";
    altitudeLabel.textAlignment = NSTextAlignmentCenter;
    altitudeLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:altitudeLabel];

    distanceLabel = [[GCLabel alloc] initWithFrame:rectDistance];
    distanceLabel.text = @"-";
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    distanceLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:distanceLabel];

    wpDescriptionLabel = [[GCLabel alloc] initWithFrame:rectDescription];
    wpDescriptionLabel.text = waypointManager.currentWaypoint.wpt_urlname;
    wpDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    wpDescriptionLabel.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:wpDescriptionLabel];

    if (rectCompass.size.height < rectCompass.size.width)
        rectCompass.size.width = rectCompass.size.height;
    else
        rectCompass.size.height = rectCompass.size.width;
    rectCompass.origin.x = (width - rectCompass.size.width) / 2;
    compassIV = [[UIImageView alloc] initWithFrame:rectCompass];
    [self.view addSubview:compassIV];
    lineIV = [[UIImageView alloc] initWithFrame:rectCompass];
    [self.view addSubview:lineIV];

    [self changeTheme];
}

- (void)calculateRects
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    width = applicationFrame.size.width;
    NSInteger height = applicationFrame.size.height - 50;

    UIFont *f = [UIFont systemFontOfSize:14];
    NSInteger textHeight = f.lineHeight;

    if (height > width) {
        /*
         +------+-------+------+
         |Icon  |GC Code| Size |
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

        NSInteger width3 = width / 3;

        rectIcon = CGRectMake(width3 / 2 - wpIconIV.image.size.width, 3.5 * textHeight / 2 - wpIconIV
                              .image.size.height, 2 * wpIconIV.image.size.width, 2 * wpIconIV.image.size.height);
        rectName = CGRectMake(width3, 0 * textHeight, width3, textHeight);
        rectCoordLat = CGRectMake(width3, 1.5 * textHeight, width3, textHeight);
        rectCoordLon = CGRectMake(width3, 2.5 * textHeight, width3, textHeight);
        rectSize = CGRectMake(2 * width3, 0 * textHeight, width3, textHeight);
        rectRatingD = CGRectMake(2 * width3, 1.5 * textHeight, width3, textHeight);
        rectRatingT = CGRectMake(2 * width3, 2.5 * textHeight, width3, textHeight);

        rectDistance = CGRectMake(0, 4 * textHeight, 3 * width3, textHeight);
        rectDescription = CGRectMake(0, height - 5 * textHeight, 3 * width3, textHeight);
        rectCompass = CGRectMake(0, 5 * textHeight, 3 * width3, rectDescription.origin.y - rectDistance.origin.y);
        if (rectCompass.size.height < rectCompass.size.width)
            rectCompass.size.width = rectCompass.size.height;
        else
            rectCompass.size.height = rectCompass.size.width;
        rectCompass.origin.x = (width - rectCompass.size.width) / 2;

        rectAccuracyText = CGRectMake(0, height - 3.5 * textHeight, width3, 1 * textHeight);
        rectAccuracy = CGRectMake(0, height - 2 * textHeight, width3, textHeight);
        rectMyLocation = CGRectMake(width3, height - 3.5 * textHeight, width3, textHeight);
        rectMyLat = CGRectMake(width3, height - 2 * textHeight, width3, textHeight);
        rectMyLon = CGRectMake(width3, height - 1 * textHeight, width3, textHeight);
        rectAltitudeText = CGRectMake(2 * width3, height - 3.5 * textHeight, width3, textHeight);
        rectAltitude = CGRectMake(2 * width3, height - 2 * textHeight, width3, textHeight);

    } else {
        /*
         +---------+------------+-------+
         | Coordin |  GC Code   | My coo|
         |         |            |       |
         | Icon    |  Compass   | Dista |
         |         |            |       |
         | Size    |            | Accur |
         | Rating  | Cache Name | Altit |
         +---------+------------+-------+
         */

        NSInteger width5 = width / 5;

        rectName = CGRectMake(0, 0.5, width5, textHeight);
        rectCoordLat = CGRectMake(0, 1.5 * textHeight, width5, textHeight);
        rectCoordLon = CGRectMake(0, 2.5 * textHeight, width5, textHeight);
        rectIcon = CGRectMake(width5 / 2 - wpIconIV.image.size.width, height / 2 - wpIconIV.image.size.height, 2 * wpIconIV.image.size.width, 2 * wpIconIV.image.size.height);
        rectSize = CGRectMake(0, height - 4 * textHeight, width5, textHeight);
        rectRatingD = CGRectMake(0, height - 3 * textHeight, width5, textHeight);
        rectRatingT = CGRectMake(0, height - 2 * textHeight, width5, textHeight);

        rectDescription = CGRectMake(width5, height - 2 * textHeight, 3 * width5, textHeight);
        rectCompass = CGRectMake(width5, 0, 3 * width5, height - 1.5 * textHeight);
        if (rectCompass.size.height < rectCompass.size.width)
            rectCompass.size.width = rectCompass.size.height;
        else
            rectCompass.size.height = rectCompass.size.width;
        rectCompass.origin.x = (width - rectCompass.size.width) / 2;

        rectMyLocation = CGRectMake(width - width5, 0, width5, textHeight);
        rectMyLat = CGRectMake(width - width5, 1 * textHeight, width5, textHeight);
        rectMyLon = CGRectMake(width - width5, 2 * textHeight, width5, textHeight);
        rectDistance = CGRectMake(width - width5, height / 2 - textHeight, width5, textHeight);
        rectAccuracyText = CGRectMake(width - width5, height - 5 * textHeight, width5, textHeight);
        rectAccuracy = CGRectMake(width - width5, height - 4 * textHeight, width5, textHeight);
        rectAltitudeText = CGRectMake(width - width5, height - 3 * textHeight, width5, textHeight);
        rectAltitude = CGRectMake(width - width5, height - 2 * textHeight, width5, textHeight);
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self calculateRects];
                                     [self viewWilltransitionToSize];
                                 }
     ];
}

- (void)viewWilltransitionToSize
{
    wpIconIV.frame = rectIcon;
    wpNameLabel.frame = rectName;
    wpLatLabel.frame = rectCoordLat;
    wpLonLabel.frame = rectCoordLon;
    containerSizeIV.frame = rectSize;
    ratingDIV.frame = rectRatingD;
    ratingTIV.frame = rectRatingT;

    myLocationLabel.frame = rectMyLocation;
    myLatLabel.frame = rectMyLat;
    myLonLabel.frame = rectMyLon;

    accuracyTextLabel.frame = rectAccuracyText;
    accuracyLabel.frame = rectAccuracy;
    altitudeTextLabel.frame = rectAltitudeText;
    altitudeLabel.frame = rectAltitude;

    distanceLabel.frame = rectDistance;
    wpDescriptionLabel.frame = rectDescription;

    compassIV.transform = CGAffineTransformMakeRotation(0);
    compassIV.frame = rectCompass;
    lineIV.transform = CGAffineTransformMakeRotation(0);
    lineIV.frame = rectCompass;

    [self updateLocationManagerLocation];
}

- (void)changeTheme
{
    [themeManager changeThemeArray:[self.view subviews]];
    [super changeTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

    /* Initiate the current cache */
    Coordinates *coords = [[Coordinates alloc] init:waypointManager.currentWaypoint.wpt_lat_float lon:waypointManager.currentWaypoint.wpt_lon_float];

    if (waypointManager.currentWaypoint == nil) {
        wpIconIV.hidden = YES;
        containerSizeIV.hidden = YES;
        ratingDIV.hidden = YES;
        ratingTIV.hidden = YES;
    } else {
        wpIconIV.hidden = NO;
        containerSizeIV.hidden = NO;
        ratingDIV.hidden = NO;
        ratingTIV.hidden = NO;
        wpIconIV.image = [imageLibrary getType:waypointManager.currentWaypoint];
        containerSizeIV.image = [imageLibrary get:waypointManager.currentWaypoint.gs_container.icon];
        ratingDIV.image = [imageLibrary getRating:waypointManager.currentWaypoint.gs_rating_difficulty];
        ratingTIV.image = [imageLibrary getRating:waypointManager.currentWaypoint.gs_rating_terrain];
    }

    altitudeLabel.text = @"";
    accuracyLabel.text = @"";
    distanceLabel.text = @"";

    if (waypointManager.currentWaypoint != nil) {
        wpNameLabel.text = waypointManager.currentWaypoint.wpt_name;
        wpDescriptionLabel.text = waypointManager.currentWaypoint.wpt_urlname;
        wpLatLabel.text = [coords lat_degreesDecimalMinutes];
        wpLonLabel.text = [coords lon_degreesDecimalMinutes];
    } else {
        wpNameLabel.text = @"";
        wpDescriptionLabel.text = @"";
        wpLatLabel.text = @"";
        wpLonLabel.text = @"";
    }

    // Update compass type
    switch (myConfig.compassType) {
        case COMPASS_REDONBLUECOMPASS:
            compassImage = [imageLibrary get:ImageCompass_RedArrowOnBlueCompass];
            compassIV.image = compassImage;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlueArrow];
            lineIV.image = lineImage;
            break;
        case COMPASS_WHITEARROWONBLACK:
            compassIV.image = nil;
            lineImage = [imageLibrary get:ImageCompass_WhiteArrowOnBlack];
            lineIV.image = lineImage;
            break;
        case COMPASS_REDARROWONBLACK:
            compassIV.image = nil;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlack];
            lineIV.image = lineImage;
            break;
        case COMPASS_AIRPLANE:
            compassIV.image = [imageLibrary get:ImageCompass_AirplaneCompass];
            lineImage = [imageLibrary get:ImageCompass_AirplaneAirplane];
            lineIV.image = lineImage;
            break;
    }

    if (myConfig.soundDirection == YES)
        [audioFeedback togglePlay:YES];
    else
        [audioFeedback togglePlay:NO];

    [self calculateRects];
    [self viewWilltransitionToSize];

    /* Start the location manager */
    [LM startDelegation:self isNavigating:TRUE];
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [audioFeedback togglePlay:NO];
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    currentOrienation = [[UIDevice currentDevice] orientation];

    switch (currentOrienation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
            bearingAdjustment = 0;
            break;
        case UIDeviceOrientationLandscapeLeft:
            bearingAdjustment = - M_PI / 2;
            break;
        case UIDeviceOrientationLandscapeRight:
            bearingAdjustment = M_PI / 2;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            bearingAdjustment = M_PI;
            break;
    }
}


/* Receive data from the location manager */
- (void)updateLocationManagerLocation
{
    accuracyLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:LM.accuracy]];
    altitudeLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:LM.altitude]];

//    NSLog(@"new location: %f, %f", LM.coords.latitude, LM.coords.longitude);

    Coordinates *c = [[Coordinates alloc] init:LM.coords];
    myLatLabel.text = [c lat_degreesDecimalMinutes];
    myLonLabel.text = [c lon_degreesDecimalMinutes];

    /* Draw the compass */
    float newCompass = -LM.direction * M_PI / 180.0f + bearingAdjustment;

    compassIV.transform = CGAffineTransformMakeRotation(newCompass);
    oldCompass = newCompass;

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:waypointManager.currentWaypoint.coordinates] - LM.direction;
    float fBearing = bearing * M_PI / 180.0 + bearingAdjustment;

    /* Draw the line */
    if (waypointManager.currentWaypoint == nil) {
        lineIV.hidden = YES;
    } else {
        lineIV.hidden = NO;

        lineIV.transform = CGAffineTransformMakeRotation(fBearing);
        distanceLabel.text = [MyTools niceDistance:[c distance:waypointManager.currentWaypoint.coordinates]];
    }

    if (myConfig.soundDirection == YES) {
        bearing = labs(bearing);
        if (bearing > 180)
            bearing = 360 - bearing;
        NSInteger freq = (bearing < 10 ? 1000 : 700) - 2 * bearing;
        //NSLog(@"bearing: %ld - freq: %ld", bearing, freq);
        [audioFeedback setFrequency:freq];
    }

}

@end
