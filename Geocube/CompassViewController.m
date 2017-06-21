/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface CompassViewController ()
{
    UIImage *compassImage;
    UIImage *lineImage;

    NSInteger width;

    UIDeviceOrientation currentOrienation;
    float bearingAdjustment;
}

@property (nonatomic, weak) IBOutlet GCLabel *labelWPCode;
@property (nonatomic, weak) IBOutlet GCLabel *labelWPDescription;
@property (nonatomic, weak) IBOutlet GCLabel *labelWPLat;
@property (nonatomic, weak) IBOutlet GCLabel *labelWPLon;
@property (nonatomic, weak) IBOutlet GCLabel *labelWPRatingD;
@property (nonatomic, weak) IBOutlet GCLabel *labelWPRatingT;
@property (nonatomic, weak) IBOutlet GCLabel *labelGPSLat;
@property (nonatomic, weak) IBOutlet GCLabel *labelGPSLon;
@property (nonatomic, weak) IBOutlet GCLabel *labelGPSAccuracy;
@property (nonatomic, weak) IBOutlet GCLabel *labelGPSAltitude;
@property (nonatomic, weak) IBOutlet GCLabel *labelGPSDistance;

@property (nonatomic, weak) IBOutlet GCImageView *ivGPSCompassBackground;
@property (nonatomic, weak) IBOutlet GCImageView *ivGPSCompassLine;
@property (nonatomic, weak) IBOutlet GCImageView *ivWPContainer;
@property (nonatomic, weak) IBOutlet GCImageView *ivWPSize;

@end

@implementation CompassViewController

- (instancetype)init
{
    self = [super init];

    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[[NSBundle mainBundle] loadNibNamed:@"CompassView" owner:self options:nil] objectAtIndex:0];
    [self changeTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

    /* Initiate the current cache */
    Coordinates *coords = [[Coordinates alloc] init:waypointManager.currentWaypoint.wpt_lat lon:waypointManager.currentWaypoint.wpt_lon];

    if (waypointManager.currentWaypoint == nil) {
        self.ivWPContainer.hidden = YES;
        self.ivWPSize.hidden = YES;
        self.labelWPRatingD.hidden = YES;
        self.labelWPRatingT.hidden = YES;
    } else {
        self.ivWPContainer.hidden = NO;
        self.ivWPSize.hidden = NO;
        self.labelWPRatingD.hidden = NO;
        self.labelWPRatingT.hidden = NO;
        self.ivWPContainer.image = [imageLibrary getType:waypointManager.currentWaypoint];
        self.ivWPSize.image = [imageLibrary get:waypointManager.currentWaypoint.gs_container.icon];
        self.labelWPRatingD.text = [NSString stringWithFormat:@"D: %0.1f", waypointManager.currentWaypoint.gs_rating_difficulty];
        self.labelWPRatingT.text = [NSString stringWithFormat:@"T: %0.1f", waypointManager.currentWaypoint.gs_rating_terrain];
    }

    self.labelGPSAltitude.text = @"";
    self.labelGPSAccuracy.text = @"";
    self.labelGPSDistance.text = @"";

    if (waypointManager.currentWaypoint != nil) {
        self.labelWPCode.text = waypointManager.currentWaypoint.wpt_name;
        self.labelWPDescription.text = waypointManager.currentWaypoint.wpt_urlname;
        self.labelWPLat.text = [coords lat_degreesDecimalMinutes];
        self.labelWPLon.text = [coords lon_degreesDecimalMinutes];
    } else {
        self.labelWPCode.text = @"";
        self.labelWPDescription.text = @"";
        self.labelWPLat.text = @"";
        self.labelWPLon.text = @"";
    }

    // Update compass type
    switch (configManager.compassType) {
        case COMPASS_REDONBLUECOMPASS:
            compassImage = [imageLibrary get:ImageCompass_RedArrowOnBlueCompass];
            self.ivGPSCompassBackground.image = compassImage;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlueArrow];
            self.ivGPSCompassLine.image = lineImage;
            break;
        case COMPASS_WHITEARROWONBLACK:
            self.ivGPSCompassBackground.image = nil;
            lineImage = [imageLibrary get:ImageCompass_WhiteArrowOnBlack];
            self.ivGPSCompassLine.image = lineImage;
            break;
        case COMPASS_REDARROWONBLACK:
            self.ivGPSCompassBackground.image = nil;
            lineImage = [imageLibrary get:ImageCompass_RedArrowOnBlack];
            self.ivGPSCompassLine.image = lineImage;
            break;
        case COMPASS_AIRPLANE:
            self.ivGPSCompassBackground.image = [imageLibrary get:ImageCompass_AirplaneCompass];
            lineImage = [imageLibrary get:ImageCompass_AirplaneAirplane];
            self.ivGPSCompassLine.image = lineImage;
            break;
    }

    if (configManager.soundDirection == YES)
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
    bearingAdjustment = 0;
    return;

    //    switch (currentOrienation) {
    //        case UIDeviceOrientationFaceUp:
    //        case UIDeviceOrientationFaceDown:
    //        case UIDeviceOrientationUnknown:
    //        case UIDeviceOrientationPortrait:
    //            bearingAdjustment = 0;
    //            break;
    //        case UIDeviceOrientationLandscapeLeft:
    //            bearingAdjustment = - M_PI / 2;
    //            break;
    //        case UIDeviceOrientationLandscapeRight:
    //            bearingAdjustment = M_PI / 2;
    //            break;
    //        case UIDeviceOrientationPortraitUpsideDown:
    //            bearingAdjustment = M_PI;
    //            break;
    //    }
}

/* Receive data from the location manager */
- (void)updateLocationManagerLocation
{
    self.labelGPSAccuracy.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:LM.accuracy]];
    self.labelGPSAltitude.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:LM.altitude]];

    //    NSLog(@"new location: %f, %f", LM.coords.latitude, LM.coords.longitude);

    Coordinates *c = [[Coordinates alloc] init:LM.coords];
    self.labelGPSLat.text = [c lat_degreesDecimalMinutes];
    self.labelGPSLon.text = [c lon_degreesDecimalMinutes];

    /* Draw the compass */
    float newCompass = -LM.direction * M_PI / 180.0f + bearingAdjustment;

    self.ivGPSCompassBackground.transform = CGAffineTransformMakeRotation(newCompass);

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:waypointManager.currentWaypoint.coordinates] - LM.direction;
    float fBearing = bearing * M_PI / 180.0 + bearingAdjustment;

    /* Draw the line */
    if (waypointManager.currentWaypoint == nil) {
        self.ivGPSCompassLine.hidden = YES;
    } else {
        self.ivGPSCompassLine.hidden = NO;

        self.ivGPSCompassLine.transform = CGAffineTransformMakeRotation(fBearing);
        self.labelGPSDistance.text = [MyTools niceDistance:[c distance:waypointManager.currentWaypoint.coordinates]];
    }

    if (configManager.soundDirection == YES) {
        bearing = labs(bearing);
        if (bearing > 180)
            bearing = 360 - bearing;
        NSInteger freq = (bearing < 10 ? 1000 : 700) - 2 * bearing;
        //NSLog(@"bearing: %ld - freq: %ld", bearing, freq);
        [audioFeedback setTheFrequency:freq];
    }

}

@end
