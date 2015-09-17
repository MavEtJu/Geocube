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

@implementation CompassViewController

- (id)init
{
    menuItems = nil;

    wpIcon = nil;
    wpName = nil;
    wpLat = nil;
    wpLon = nil;
    myLat = nil;
    myLon = nil;
    accuracy = nil;
    altitude = nil;

    oldCompass = 0;
    oldBearing = 0;

    self = [super init];

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
    NSInteger height = self.view.frame.size.height - 50;

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

#define HEIGHT  height / 18
#define WIDTH  width / 3

    UIFont *f = [UIFont systemFontOfSize:14];
    NSInteger textHeight = f.lineHeight;

    CGRect rectIcon = CGRectMake(WIDTH / 3, 0.5 * textHeight, WIDTH / 3, 2.5 * textHeight);
    CGRect rectName = CGRectMake(WIDTH, 0 * textHeight, WIDTH, textHeight);
    CGRect rectCoordLat = CGRectMake(WIDTH, 1.5 * textHeight, WIDTH, textHeight);
    CGRect rectCoordLon = CGRectMake(WIDTH, 2.5 * textHeight, WIDTH, textHeight);
    CGRect rectSize = CGRectMake(2 * WIDTH, 0 * textHeight, WIDTH, textHeight);
    CGRect rectRatingD = CGRectMake(2 * WIDTH, 1.5 * textHeight, WIDTH, textHeight);
    CGRect rectRatingT = CGRectMake(2 * WIDTH, 2.5 * textHeight, WIDTH, textHeight);

    CGRect rectDistance = CGRectMake(0, 4 * textHeight, 3 * WIDTH, textHeight);
    CGRect rectDescription = CGRectMake(0, height - 5 * textHeight, 3 * WIDTH, textHeight);
    CGRect rectCompass = CGRectMake(0, 5 * textHeight, 3 * WIDTH, rectDescription.origin.y - rectDistance.origin.y);

    CGRect rectAccuracyText = CGRectMake(0, height - 3.5 * textHeight, WIDTH, 1 * textHeight);
    CGRect rectAccuracy = CGRectMake(0, height - 2 * textHeight, WIDTH, textHeight);
    CGRect rectMyLatText = CGRectMake(WIDTH, height - 3.5 * textHeight, WIDTH, textHeight);
    CGRect rectMyLat = CGRectMake(WIDTH, height - 2 * textHeight, WIDTH, textHeight);
    CGRect rectMyLon = CGRectMake(WIDTH, height - 1 * textHeight, WIDTH, textHeight);
    CGRect rectAltitudeText = CGRectMake(2 * WIDTH, height - 3.5 * textHeight, WIDTH, textHeight);
    CGRect rectAltitude = CGRectMake(2 * WIDTH, height - 2 * textHeight, WIDTH, textHeight);

    GCLabel *l;

    wpIcon = [[UIImageView alloc] initWithFrame:rectIcon];
    [self.view addSubview:wpIcon];

#define FONTSIZE    14

    wpName = [[GCLabel alloc] initWithFrame:rectName];
    wpName.textAlignment = NSTextAlignmentCenter;
    wpName.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:wpName];

    wpLat = [[GCLabel alloc] initWithFrame:rectCoordLat];
    wpLat.font = [UIFont systemFontOfSize:FONTSIZE];
    wpLat.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wpLat];

    wpLon = [[GCLabel alloc] initWithFrame:rectCoordLon];
    wpLon.font = [UIFont systemFontOfSize:FONTSIZE];
    wpLon.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:wpLon];

    containerSize = [[UIImageView alloc] initWithFrame:rectSize];
    containerSize.image = [imageLibrary get:ImageSize_NotChosen];
    [self.view addSubview:containerSize];

    ratingD = [[UIImageView alloc] initWithFrame:rectRatingD];
    ratingD.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingD];

    ratingT = [[UIImageView alloc] initWithFrame:rectRatingT];
    ratingT.image = [imageLibrary get:ImageCacheView_ratingBase];
    [self.view addSubview:ratingT];

    l = [[GCLabel alloc] initWithFrame:rectMyLatText];
    l.text = @"My location";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];

    myLat = [[GCLabel alloc] initWithFrame:rectMyLat];
    myLat.text = @"-";
    myLat.textAlignment = NSTextAlignmentCenter;
    myLat.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLat];

    myLon = [[GCLabel alloc] initWithFrame:rectMyLon];
    myLon.text = @"";
    myLon.textAlignment = NSTextAlignmentCenter;
    myLon.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:myLon];

    l = [[GCLabel alloc] initWithFrame:rectAccuracyText];
    l.text = @"Accuracy";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];
    accuracy = [[GCLabel alloc] initWithFrame:rectAccuracy];
    accuracy.text = @"-";
    accuracy.textAlignment = NSTextAlignmentCenter;
    accuracy.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:accuracy];

    l = [[GCLabel alloc] initWithFrame:rectAltitudeText];
    l.text = @"Altitude";
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:l];
    altitude = [[GCLabel alloc] initWithFrame:rectAltitude];
    altitude.text = @"-";
    altitude.textAlignment = NSTextAlignmentCenter;
    altitude.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:altitude];

    distance = [[GCLabel alloc] initWithFrame:rectDistance];
    distance.text = @"-";
    distance.textAlignment = NSTextAlignmentCenter;
    distance.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:distance];

    wpDescription = [[GCLabel alloc] initWithFrame:rectDescription];
    wpDescription.text = waypointManager.currentWaypoint.urlname;
    wpDescription.textAlignment = NSTextAlignmentCenter;
    wpDescription.font = [UIFont systemFontOfSize:FONTSIZE];
    [self.view addSubview:wpDescription];

    if (rectCompass.size.height < rectCompass.size.width)
        rectCompass.size.width = rectCompass.size.height;
    else
        rectCompass.size.height = rectCompass.size.width;
    rectCompass.origin.x = (width - rectCompass.size.width) / 2;
    compassImageView = [[UIImageView alloc] initWithFrame:rectCompass];
    [self.view addSubview:compassImageView];
    lineImageView = [[UIImageView alloc] initWithFrame:rectCompass];
    [self.view addSubview:lineImageView];

    [self changeTheme];
}

- (void)changeTheme
{
    [themeManager changeThemeArray:[self.view subviews]];
    [super changeTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    /* Start the location manager */
    [LM startDelegation:self isNavigating:TRUE];

    /* Initiate the current cache */
    Coordinates *coords = [[Coordinates alloc] init:waypointManager.currentWaypoint.lat_float lon:waypointManager.currentWaypoint.lon_float];

    wpIcon.image = [imageLibrary getType:waypointManager.currentWaypoint];
    containerSize.image = [imageLibrary get:waypointManager.currentWaypoint.groundspeak.container.icon];
    ratingD.image = [imageLibrary getRating:waypointManager.currentWaypoint.groundspeak.rating_difficulty];
    ratingT.image = [imageLibrary getRating:waypointManager.currentWaypoint.groundspeak.rating_terrain];

    altitude.text = @"";
    accuracy.text = @"";
    distance.text = @"";

    if (waypointManager.currentWaypoint != nil) {
        wpName.text = waypointManager.currentWaypoint.name;
        wpDescription.text = waypointManager.currentWaypoint.urlname;
        wpLat.text = [coords lat_degreesDecimalMinutes];
        wpLon.text = [coords lon_degreesDecimalMinutes];
    } else {
        wpName.text = @"";
        wpDescription.text = @"";
        wpLat.text = @"";
        wpLon.text = @"";
    }

    // Update compass type
    switch (myConfig.compassType) {
        case COMPASS_REDONBLUECOMPASS:
            compassImage  = [imageLibrary get:ImageCompass_RedArrowOnBlueCompass];
            compassImageView.image = compassImage;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlueArrow];
            lineImageView.image = lineImage;
            break;
        case COMPASS_WHITEARROWONBLACK:
            compassImageView.image = nil;
            lineImage = [imageLibrary get:ImageCompass_WhiteArrowOnBlack];
            lineImageView.image = lineImage;
            break;
        case COMPASS_REDARROWONBLACK:
            compassImageView.image = nil;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlack];
            lineImageView.image = lineImage;
            break;
        case COMPASS_AIRPLANE:
            compassImageView.image = [imageLibrary get:ImageCompass_AirplaneCompass];
            lineImage = [imageLibrary get:ImageCompass_AirplaneAirplane];
            lineImageView.image = lineImage;
            break;
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
}

/* Receive data from the location manager */
- (void)updateData
{
    accuracy.text = [NSString stringWithFormat:@"%@", [MyTools NiceDistance:LM.accuracy]];
    altitude.text = [NSString stringWithFormat:@"%@", [MyTools NiceDistance:LM.altitude]];

//    NSLog(@"new location: %f, %f", LM.coords.latitude, LM.coords.longitude);

    Coordinates *c = [[Coordinates alloc] init:LM.coords];
    myLat.text = [c lat_degreesDecimalMinutes];
    myLon.text = [c lon_degreesDecimalMinutes];

    float newCompass = -LM.direction * M_PI / 180.0f;

    CABasicAnimation *theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:newCompass];
    theAnimation.toValue = [NSNumber numberWithFloat:newCompass];
    theAnimation.duration = 0.5f;
    [compassImageView.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    compassImageView.transform = CGAffineTransformMakeRotation(newCompass);
    oldCompass = newCompass;

    if (waypointManager.currentWaypoint == nil) {
        lineImageView.hidden = YES;
        return;
    }
    lineImageView.hidden = NO;

    float newBearing = ([Coordinates coordinates2bearing:LM.coords to:waypointManager.currentWaypoint.coordinates] - LM.direction ) * M_PI / 180.0;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    theAnimation.fromValue = [NSNumber numberWithFloat:newBearing];
    theAnimation.toValue = [NSNumber numberWithFloat:newBearing];
    theAnimation.duration = 0.5f;
    [lineImageView.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
    lineImageView.transform = CGAffineTransformMakeRotation(newBearing);
    oldBearing = newBearing;

    distance.text = [MyTools NiceDistance:[c distance:waypointManager.currentWaypoint.coordinates]];
}

@end
