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

@interface MapWaypointInfoView ()
{
    UIImage *imgFavourites, *imgSize;

    dbWaypoint *waypoint;
}

@property (weak, nonatomic) IBOutlet GCImageView *ivFavourites;
@property (weak, nonatomic) IBOutlet GCLabel *labelFavourites;
@property (weak, nonatomic) IBOutlet GCImageView *ivContainer;
@property (weak, nonatomic) IBOutlet GCImageView *ivSize;
@property (weak, nonatomic) IBOutlet GCLabel *labelSize;
@property (weak, nonatomic) IBOutlet GCImageView *ivTarget;

@property (weak, nonatomic) IBOutlet GCLabel *labelDescription;
@property (weak, nonatomic) IBOutlet GCLabel *labelWhoWhen;
@property (weak, nonatomic) IBOutlet GCLabel *labelGCCode;
@property (weak, nonatomic) IBOutlet GCLabel *labelBearing;
@property (weak, nonatomic) IBOutlet GCLabel *labelStateCountry;
@property (weak, nonatomic) IBOutlet GCLabel *labelRatingD;
@property (weak, nonatomic) IBOutlet GCLabel *labelRatingT;

@property (weak, nonatomic) IBOutlet GCButton *buttonOverlay;
@property (weak, nonatomic) IBOutlet GCButton *buttonSetAsTarget;

@end

@implementation MapWaypointInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    imgFavourites = [imageLibrary get:ImageCacheView_favourites];
    imgSize = [imageLibrary get:ImageContainerSize_NotChosen];

    UIView *firstViewUIView = [[[NSBundle mainBundle] loadNibNamed:@"MapWaypointInfoView" owner:self options:nil] firstObject];
    [self addSubview:firstViewUIView];

    self.ivFavourites.image = imgFavourites;
    self.ivTarget.image = [imageLibrary get:ImageIcon_Target];
    [self.buttonOverlay addTarget:self action:@selector(actionShowWaypoint:) forControlEvents:UIControlEventTouchDown];
    [self.buttonSetAsTarget addTarget:self action:@selector(actionSetAsTarget:) forControlEvents:UIControlEventTouchDown];

    [self changeTheme];

    [waypointManager startDelegation:self];

    return self;
}

- (void)clearLabels;
{
    self.labelDescription.text = @"";
    self.labelWhoWhen.text = @"";
    self.labelGCCode.text = @"";
    self.labelRatingD.text = @"";
    self.labelRatingT.text = @"";
    self.labelBearing.text = @"";
    self.labelSize.text = @"";
    self.labelStateCountry.text = @"";
}

- (void)setWaypoint:(dbWaypoint *)wp
{
    [self clearLabels];
    waypoint = wp;

    self.labelDescription.text = wp.wpt_urlname;
    if (wp.gs_owner == nil) {
        if ([wp hasGSData] == YES)
            self.labelWhoWhen.text = [NSString stringWithFormat:@"Yours on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
        else
            self.labelWhoWhen.text = [NSString stringWithFormat:@"Placed on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    } else
        self.labelWhoWhen.text = [NSString stringWithFormat:@"by %@ on %@", wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];

    NSMutableString *nameText = [NSMutableString stringWithString:wp.wpt_name];
    if (wp.account.site != nil)
        [nameText appendFormat:@" (%@)", wp.account.site];
    self.labelGCCode.text = nameText;

    self.ivContainer.image = [imageLibrary getType:wp];
    if (wp.flag_highlight == YES)
        self.labelDescription.backgroundColor = [UIColor yellowColor];
    else
        self.labelDescription.backgroundColor = [UIColor clearColor];

    if (wp.gs_rating_terrain != 0)
        self.labelRatingT.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    if (wp.gs_rating_difficulty != 0)
        self.labelRatingD.text = [NSString stringWithFormat:@"D: %0.1f", wp.gs_rating_difficulty];
    [self setRatings:wp.gs_favourites size:wp.gs_container.icon];

    NSInteger b = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    self.labelBearing.text = [NSString stringWithFormat:@"%ld° (%@) at %@", (long)b, [Coordinates bearing2compass:b], [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]]];

    self.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        self.labelSize.hidden = NO;
        self.ivSize.hidden = YES;
    } else {
        self.labelSize.hidden = YES;
        self.ivSize.hidden = NO;
    }

    self.labelStateCountry.text = [wp makeLocaleStateCountry];
}

- (void)actionShowWaypoint:(UIButton *)showWaypoint
{
    [self.parentMap openWaypointView:waypoint];
}

- (void)actionSetAsTarget:(UIButton *)setAsTarget
{
    [waypointManager setTheCurrentWaypoint:waypoint];

    MHTabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapTemplateViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb setSelectedIndex:VC_NAVIGATE_COMPASS animated:YES];
}

- (void)changeTheme
{
    [super changeTheme];

    [self.labelGCCode changeTheme];
    [self.labelStateCountry changeTheme];
    [self.labelBearing changeTheme];
    [self.labelRatingD changeTheme];
    [self.labelRatingT changeTheme];
    [self.labelSize changeTheme];
    [self.labelWhoWhen changeTheme];
}

- (void)setRatings:(NSInteger)favs size:(NSInteger)sz
{
    if (favs != 0) {
        self.labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        self.labelFavourites.textColor = [UIColor whiteColor];
        self.ivFavourites.hidden = NO;
    } else {
        self.labelFavourites.text = nil;
        self.ivFavourites.hidden = YES;
    }

    if (sz != 0) {
        self.ivSize.image = [imageLibrary get:sz];
        self.ivSize.hidden = NO;
    } else {
        self.ivSize.hidden = YES;
    }
}

+ (NSInteger)viewHeight
{
    return 77;
}

#pragma -- WaypointManagerDelegate

- (void)refreshWaypoints
{
    self.ivContainer.image = [imageLibrary getType:waypoint];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    self.ivContainer.image = [imageLibrary getType:waypoint];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    waypoint = wp;
    self.ivContainer.image = [imageLibrary getType:waypoint];
}

- (void)removeWaypoint:(dbWaypoint *)wp
{
    // Nothing!
}

@end
