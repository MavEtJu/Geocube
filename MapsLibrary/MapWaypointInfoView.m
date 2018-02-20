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

@interface MapWaypointInfoView ()

@property (nonatomic, retain) UIImage *imgFavourites;

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
@property (weak, nonatomic) IBOutlet GCLabel *labelRatingDT;

@property (weak, nonatomic) IBOutlet GCButton *buttonOverlay;
@property (weak, nonatomic) IBOutlet GCButton *buttonSetAsTarget;

@end

@implementation MapWaypointInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    self.imgFavourites = [imageManager get:ImageCacheView_favourites];

    self.firstView = [[[NSBundle mainBundle] loadNibNamed:@"MapWaypointInfoView" owner:self options:nil] firstObject];
    self.firstView.frame = CGRectMake((frame.size.width - self.firstView.frame.size.width) / 2, 0, self.firstView.frame.size.width, self.firstView.frame.size.height);
    [self addSubview:self.firstView];

    self.ivFavourites.image = self.imgFavourites;
    self.ivTarget.image = [imageManager get:ImageIcon_Target];
    [self.buttonOverlay addTarget:self action:@selector(actionShowWaypoint:) forControlEvents:UIControlEventTouchDown];
    [self.buttonSetAsTarget addTarget:self action:@selector(actionSetAsTarget:) forControlEvents:UIControlEventTouchDown];

    [self changeTheme];

    [waypointManager startDelegationWaypoints:self];

    return self;
}

- (void)removeSelf
{
    [waypointManager stopDelegationWaypoints:self];
}

- (void)recalculateRects:(CGRect)rect
{
    CGRect r = CGRectMake((rect.size.width - self.firstView.frame.size.width) / 2, 0, self.firstView.frame.size.width, self.firstView.frame.size.height);
    self.firstView.frame = r;
    self.frame = rect;
}

- (void)clearLabels;
{
    self.labelDescription.text = @"";
    self.labelWhoWhen.text = @"";
    self.labelGCCode.text = @"";
    self.labelRatingDT.text = @"";
    self.labelBearing.text = @"";
    self.labelSize.text = @"";
    self.labelStateCountry.text = @"";
}

- (void)showWaypoint:(dbWaypoint *)wp
{
    [self clearLabels];
    self.waypoint = wp;

    self.labelDescription.text = wp.wpt_urlname;
    if (wp.gs_owner == nil) {
        if ([wp hasGSData] == YES)
            self.labelWhoWhen.text = [NSString stringWithFormat:_(@"mapwaypointinfoview-Yours on %@"), [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
        else
            self.labelWhoWhen.text = [NSString stringWithFormat:_(@"mapwaypointinfoview-Placed on %@"), [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    } else
        self.labelWhoWhen.text = [NSString stringWithFormat:_(@"mapwaypointinfoview-by %@ on %@"), wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];

    NSMutableString *nameText = [NSMutableString stringWithString:wp.wpt_name];
    if (wp.account.site != nil)
        [nameText appendFormat:@" (%@)", wp.account.site];
    self.labelGCCode.text = nameText;

    self.ivContainer.image = [imageManager getType:wp];
    if (wp.flag_highlight == YES)
        self.labelDescription.backgroundColor = currentTheme.labelHighlightBackgroundColor;
    else
        self.labelDescription.backgroundColor = [UIColor clearColor];

    if (wp.gs_rating_terrain != 0)
        self.labelRatingDT.text = [NSString stringWithFormat:@"%@: %0.1f/%0.1f", _(@"rating-D/T"), wp.gs_rating_difficulty, wp.gs_rating_terrain];
    [self setRatings:wp.gs_favourites size:wp.gs_container.icon];

    NSInteger b = [Coordinates coordinates2bearing:LM.coords toLatitude:wp.wpt_latitude toLongitude:wp.wpt_longitude];
    self.labelBearing.text = [NSString stringWithFormat:@"%ld° (%@) %@ %@", (long)b, [Coordinates bearing2compass:b], _(@"mapwaypointinfoview-at"), [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords toLatitude:wp.wpt_latitude toLongitude:wp.wpt_longitude]]];

    self.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        self.labelSize.hidden = NO;
        self.ivSize.hidden = YES;
    } else {
        self.labelSize.hidden = YES;
        self.ivSize.hidden = NO;
    }

    self.labelStateCountry.text = [wp makeLocalityStateCountry];
}

- (void)actionShowWaypoint:(UIButton *)showWaypoint
{
    [self.parentMap openWaypointView:self.waypoint];
}

- (void)actionSetAsTarget:(UIButton *)setAsTarget
{
    [waypointManager setTheCurrentWaypoint:self.waypoint];

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
    [self.labelRatingDT changeTheme];
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
        self.ivSize.image = [imageManager get:sz];
        self.ivSize.hidden = NO;
    } else {
        self.ivSize.hidden = YES;
    }
}

+ (NSInteger)viewHeight
{
    if (IS_IPAD)
        return 97;
    else
        return 77;
}

#pragma -- WaypointManagerDelegate

- (void)refreshWaypoints
{
    self.ivContainer.image = [imageManager getType:self.waypoint];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    self.ivContainer.image = [imageManager getType:self.waypoint];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    self.waypoint = wp;
    self.ivContainer.image = [imageManager getType:self.waypoint];
}

- (void)removeWaypoint:(dbWaypoint *)wp
{
    // Nothing!
}

@end
