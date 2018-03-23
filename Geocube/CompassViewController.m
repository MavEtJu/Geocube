/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) UIImage *compassImage;
@property (nonatomic, retain) UIImage *lineImage;

@property (nonatomic        ) NSInteger width;
@property (nonatomic        ) UIDeviceOrientation currentOrienation;
@property (nonatomic        ) float bearingAdjustment;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPCode;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPDescription;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPLat;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPLon;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPRatingD;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWPRatingT;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelGNSSLat;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelGNSSLon;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelGNSSAccuracy;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelGNSSAltitude;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelGNSSDistance;

@property (nonatomic, weak) IBOutlet GCImageView *ivGNSSCompassBackground;
@property (nonatomic, weak) IBOutlet GCImageView *ivGNSSCompassLine;
@property (nonatomic, weak) IBOutlet GCImageView *ivWPContainer;
@property (nonatomic, weak) IBOutlet GCImageView *ivWPSize;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelMyLocation;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelSpeed;

@end

@implementation CompassViewController

- (instancetype)init
{
    self = [super init];

    self.lmi = nil;

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
    Coordinates *coords = [[Coordinates alloc] initWithDegrees:waypointManager.currentWaypoint.wpt_latitude longitude:waypointManager.currentWaypoint.wpt_longitude];

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
        self.ivWPContainer.image = [imageManager getType:waypointManager.currentWaypoint];
        self.ivWPSize.image = [imageManager get:waypointManager.currentWaypoint.gs_container.icon];
        self.labelWPRatingD.text = [NSString stringWithFormat:@"%@: %0.1f", _(@"compassviewcontroller-D"), waypointManager.currentWaypoint.gs_rating_difficulty];
        self.labelWPRatingT.text = [NSString stringWithFormat:@"%@: %0.1f", _(@"compassviewcontroller-T"),  waypointManager.currentWaypoint.gs_rating_terrain];
    }

    self.labelGNSSAltitude.text = @"";
    self.labelGNSSAccuracy.text = @"";
    self.labelGNSSDistance.text = @"";
    self.labelSpeed.text = @"";

    self.labelMyLocation.text = _(@"compassviewcontroller-My location");

    if (waypointManager.currentWaypoint != nil) {
        self.labelWPCode.text = waypointManager.currentWaypoint.wpt_name;
        self.labelWPDescription.text = waypointManager.currentWaypoint.wpt_urlname;
        self.labelWPLat.text = [coords lat];
        self.labelWPLon.text = [coords lon];
    } else {
        self.labelWPCode.text = @"";
        self.labelWPDescription.text = @"";
        self.labelWPLat.text = @"";
        self.labelWPLon.text = @"";
    }

    // Update compass type
    switch (configManager.compassType) {
        case COMPASS_REDONBLUECOMPASS:
            self.compassImage = [imageManager get:ImageCompass_RedArrowOnBlueCompass];
            self.ivGNSSCompassBackground.image = self.compassImage;
            self.lineImage = [imageManager get:ImageCompass_RedArrowOnBlueArrow];
            self.ivGNSSCompassLine.image = self.lineImage;
            break;
        case COMPASS_WHITEARROWONBLACK:
            self.ivGNSSCompassBackground.image = nil;
            self.lineImage = [imageManager get:ImageCompass_WhiteArrowOnBlack];
            self.ivGNSSCompassLine.image = self.lineImage;
            break;
        case COMPASS_REDARROWONBLACK:
            self.ivGNSSCompassBackground.image = nil;
            self.lineImage = [imageManager get:ImageCompass_RedArrowOnBlack];
            self.ivGNSSCompassLine.image = self.lineImage;
            break;
        case COMPASS_AIRPLANE:
            self.ivGNSSCompassBackground.image = [imageManager get:ImageCompass_AirplaneCompass];
            self.lineImage = [imageManager get:ImageCompass_AirplaneAirplane];
            self.ivGNSSCompassLine.image = self.lineImage;
            break;
    }

    if (configManager.soundDirection == YES)
        [audioFeedback togglePlay:YES];
    else
        [audioFeedback togglePlay:NO];

    [self calculateRects];
    [self viewWilltransitionToSize];

    /* Start the location manager */
    [LM startDelegationLocation:self isNavigating:TRUE];
    [LM startDelegationSpeed:self];
    [LM startDelegationHeading:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [audioFeedback togglePlay:NO];
    [LM stopDelegationLocation:self];
    [LM stopDelegationSpeed:self];
    [LM stopDelegationHeading:self];
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    self.currentOrienation = [[UIDevice currentDevice] orientation];
    self.bearingAdjustment = 0;
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
- (void)updateLocationManagerSpeed
{
    NSString *t = @"";
    float speedkmph = LM.speed * 3.6;
    if (speedkmph > configManager.speedMinimum)
        t = [NSString stringWithFormat:_(@"compassviewcontroller-Speed: %@"), [MyTools niceSpeed:speedkmph]];
    MAINQUEUE(
        self.labelSpeed.text = t;
    )
}

/* Receive data from the location manager */
- (void)updateLocationManagerLocation
{
    NSString *t1 = [NSString stringWithFormat:_(@"compassviewcontroller-Accuracy: %@"), [MyTools niceDistance:LM.accuracy]];
    NSString *t2 = [NSString stringWithFormat:_(@"compassviewcontroller-Altitude: %@"), [MyTools niceDistance:LM.altitude]];
    MAINQUEUE(
        self.labelGNSSAccuracy.text = t1;
        self.labelGNSSAltitude.text = t2;
    );

    //    NSLog(@"new location: %f, %f", LM.coords.latitude, LM.coords.longitude);

    Coordinates *c = [[Coordinates alloc] initWithCoordinates:LM.coords];
    self.labelGNSSLat.text = [c lat];
    self.labelGNSSLon.text = [c lon];

    if (waypointManager.currentWaypoint != nil)
        self.labelGNSSDistance.text = [MyTools niceDistance:[c distance:waypointManager.currentWaypoint.wpt_latitude longitude:waypointManager.currentWaypoint.wpt_longitude]];
}

/* Receive data from the location manager */
- (void)updateLocationManagerHeading
{
    /* Draw the compass */
    float newCompass = -LM.direction * M_PI / 180.0f + self.bearingAdjustment;

    self.ivGNSSCompassBackground.transform = CGAffineTransformMakeRotation(newCompass);

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude] - LM.direction;
    float fBearing = bearing * M_PI / 180.0 + self.bearingAdjustment;

    /* Draw the line */
    if (waypointManager.currentWaypoint == nil) {
        self.ivGNSSCompassLine.hidden = YES;
    } else {
        self.ivGNSSCompassLine.hidden = NO;

        self.ivGNSSCompassLine.transform = CGAffineTransformMakeRotation(fBearing);
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
