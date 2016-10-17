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

@interface MapWaypointInfoView ()
{
    GCLabel *favouritesLabel;
    UIImage *imgFavourites, *imgSize;
    GCImageView *favouritesIV;
    GCButton *setAsTarget;

    GCImageView *icon;
    GCImageView *imageSize;

    GCLabel *labelDescription;
    GCLabel *labelWhoWhen;
    GCLabel *labelGCCode;
    GCLabel *labelBearing;
    GCLabel *labelSize;
    GCLabel *labelStateCountry;
    GCLabel *labelCoordinates;
    GCLabel *labelRatingD, *labelRatingT;

    CGRect rectIcon;
    CGRect rectDescription;
    CGRect rectGCCode;
    CGRect rectFavouritesLabel;
    CGRect rectFavouritesIV;
    CGRect rectSizeImage;
    CGRect rectSizeLabel;
    CGRect rectRatingD;
    CGRect rectRatingT;
    CGRect rectBearing;
    CGRect rectStateCountry;
    CGRect rectCoordinates;
    CGRect rectWhoWhen;
    CGRect rectSetAsTarget;

    dbWaypoint *waypoint;
}

@end

@implementation MapWaypointInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    imgFavourites = [imageLibrary get:ImageCacheView_favourites];
    imgSize = [imageLibrary get:ImageContainerSize_NotChosen];

    // Icon
    icon = [[GCImageView alloc] initWithFrame:CGRectZero];
    icon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self addSubview:icon];

    // Description
    labelDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDescription.font = [UIFont boldSystemFontOfSize:14.0];
    [self addSubview:labelDescription];

    // Whom and when
    labelWhoWhen = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelWhoWhen.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:labelWhoWhen];

    // GC-Code
    labelGCCode = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelGCCode.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:labelGCCode];

    // Bearing
    labelBearing = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBearing.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:labelBearing];

    // Coordinates
    labelCoordinates = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelCoordinates.font = [UIFont systemFontOfSize:10];
    labelCoordinates.backgroundColor = [UIColor purpleColor];
    [self addSubview:labelCoordinates];

    // State country
    labelStateCountry = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelStateCountry.font = [UIFont systemFontOfSize:10];
    [self addSubview:labelStateCountry];

    // Favourites
    favouritesIV = [[GCImageView alloc] initWithFrame:CGRectZero];
    favouritesIV.image = imgFavourites;
    [self addSubview:favouritesIV];
    favouritesIV.hidden = TRUE;

    favouritesLabel = [[GCLabel alloc] initWithFrame:CGRectZero];
    favouritesLabel.backgroundColor = [UIColor clearColor];
    favouritesLabel.font = [UIFont boldSystemFontOfSize:10];
    favouritesLabel.textColor = [UIColor whiteColor];
    favouritesLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:favouritesLabel];

    // Difficulty rating
    labelRatingD = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingD.font = [UIFont systemFontOfSize:10.0];
    labelRatingD.textAlignment = NSTextAlignmentRight;
    [self addSubview:labelRatingD];

    // Terrain rating
    labelRatingT = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingT.font = [UIFont systemFontOfSize:10.0];
    labelRatingT.textAlignment = NSTextAlignmentRight;
    [self addSubview:labelRatingT];

    // Size
    imageSize = [[GCImageView alloc] initWithFrame:CGRectZero];
    imageSize.image = imgSize;
    [self addSubview:imageSize];
    labelSize = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelSize.text = @"";
    labelSize.font = [UIFont systemFontOfSize:10];
    labelSize.textAlignment = NSTextAlignmentRight;
    [self addSubview:labelSize];

    // Set as target
    setAsTarget = [GCButton buttonWithType:UIButtonTypeSystem];
    setAsTarget.frame = CGRectZero;
    [setAsTarget addTarget:self action:@selector(setAsTarget:) forControlEvents:UIControlEventTouchDown];
    [setAsTarget setImage:[imageLibrary get:ImageIcon_FindMe] forState:UIControlStateNormal];
    [self addSubview:setAsTarget];

    [self viewWillTransitionToSize];
    [self changeTheme];

    [waypointManager startDelegation:self];

    return self;
}

- (void)waypointData:(dbWaypoint *)wp
{
    waypoint = wp;

    labelDescription.text = wp.wpt_urlname;
    if (wp.gs_owner == nil) {
        if ([wp hasGSData] == YES)
            labelWhoWhen.text = [NSString stringWithFormat:@"Yours on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
        else
            labelWhoWhen.text = [NSString stringWithFormat:@"Placed on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    } else
        labelWhoWhen.text = [NSString stringWithFormat:@"by %@ on %@", wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];

    NSMutableString *nameText = [NSMutableString stringWithString:wp.wpt_name];
    if (wp.account.site != nil)
        [nameText appendFormat:@" (%@)", wp.account.site];
    labelGCCode.text = nameText;

    icon.image = [imageLibrary getType:wp];
    if (wp.flag_highlight == YES)
        labelDescription.backgroundColor = [UIColor yellowColor];
    else
        labelDescription.backgroundColor = [UIColor clearColor];

    if (wp.gs_rating_terrain != 0)
        labelRatingT.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    else
        labelRatingT.text = @"";
    if (wp.gs_rating_difficulty != 0)
        labelRatingD.text = [NSString stringWithFormat:@"D: %0.1f", wp.gs_rating_difficulty];
    else
        labelRatingD.text = @"";
    [self setRatings:wp.gs_favourites size:wp.gs_container.icon];

    NSInteger b = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    labelBearing.text = [NSString stringWithFormat:@"%ld° (%@) at %@", (long)b, [Coordinates bearing2compass:b], [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]]];
    labelCoordinates.text = [Coordinates NiceCoordinates:wp.coordinates];

    labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        labelSize.hidden = NO;
        imageSize.hidden = YES;
    } else {
        labelSize.hidden = YES;
        imageSize.hidden = NO;
    }

    labelStateCountry.text = [wp makeLocaleStateCountry];
}

- (void)setAsTarget:(UIButton *)setAsTarget
{
    [waypointManager setCurrentWaypoint:waypoint];

    MHTabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb setSelectedIndex:VC_NAVIGATE_COMPASS animated:YES];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    CGSize setAsTargetSize = setAsTarget.imageView.image.size;

    /*
     +---+-------------------+-----+
     |   | Description       |  F  |  Favourites
     | C | By X on Y         |Size |  Difficulty
     |   | GC Code           |     |  Terrain
     | T | A at Distance     | D: x|  Angle
     |   | State Country     | T: x|
     +---+-------------------------+
     */
#define BORDER 1
#define ICON_WIDTH 30
#define ICON_HEIGHT 30

#define DESCRIPTION_HEIGHT labelDescription.font.lineHeight
#define GCCODE_HEIGHT labelGCCode.font.lineHeight
#define DISTANCE_HEIGHT 14
#define BEARING_HEIGHT 14
#define STATECOUNTRY_HEIGHT labelStateCountry.font.lineHeight

#define SIZELABEL_WIDTH 100
#define SIZELABEL_HEIGHT labelSize.font.lineHeight
#define SIZEIMAGE_WIDTH imgSize.size.width
#define SIZEIMAGE_HEIGHT imgSize.size.height

#define FAVOURITES_WIDTH 20
#define FAVOURITES_HEIGHT 30
#define COORDINATES_HEIGHT labelCoordinates.font.lineHeight
#define RATING_HEIGHT   labelRatingT.font.lineHeight

    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    rectSetAsTarget = CGRectMake(BORDER, 2 * BORDER + ICON_HEIGHT, setAsTargetSize.width, setAsTargetSize.height * 1.5);

    rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    rectWhoWhen = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, GCCODE_HEIGHT);
    rectGCCode = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + GCCODE_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, GCCODE_HEIGHT);
    rectBearing = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 2 * GCCODE_HEIGHT, width - 2 * BORDER - ICON_WIDTH, BEARING_HEIGHT);

    rectFavouritesIV = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    rectSizeImage = CGRectMake(width - 2 * BORDER - SIZEIMAGE_WIDTH, [self cellHeight] - 2 * RATING_HEIGHT - SIZEIMAGE_HEIGHT, SIZEIMAGE_WIDTH, SIZEIMAGE_HEIGHT);
    rectSizeLabel = CGRectMake(width - 2 * BORDER - SIZELABEL_WIDTH, [self cellHeight] - 2 * RATING_HEIGHT - SIZELABEL_HEIGHT, SIZELABEL_WIDTH, SIZELABEL_HEIGHT);
    rectRatingD = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - 2 * RATING_HEIGHT, 30, RATING_HEIGHT);
    rectRatingT = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - RATING_HEIGHT, 30, RATING_HEIGHT);

    rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 3 * GCCODE_HEIGHT, width - 2 * BORDER - ICON_WIDTH - rectRatingD.size.width, DISTANCE_HEIGHT);
    rectCoordinates = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 4 * GCCODE_HEIGHT, width - 2 * BORDER - ICON_WIDTH - rectRatingD.size.width, COORDINATES_HEIGHT);

    rectFavouritesLabel = rectFavouritesIV;
    rectFavouritesLabel.size.height /= 2;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    icon.frame = rectIcon;
    labelDescription.frame = rectDescription;
    labelWhoWhen.frame = rectWhoWhen;
    labelGCCode.frame = rectGCCode;
    favouritesIV.frame = rectFavouritesIV;
    favouritesLabel.frame = rectFavouritesLabel;
    imageSize.frame = rectSizeImage;
    labelSize.frame = rectSizeLabel;
    labelBearing.frame = rectBearing;
    labelStateCountry.frame = rectStateCountry;
    labelCoordinates.frame = rectCoordinates;
    setAsTarget.frame = rectSetAsTarget;

    labelRatingD.frame = rectRatingD;
    labelRatingT.frame = rectRatingT;
}

- (void)changeTheme
{
    [labelGCCode changeTheme];
    [labelStateCountry changeTheme];
    [labelBearing changeTheme];
    [labelRatingD changeTheme];
    [labelRatingT changeTheme];
    [labelSize changeTheme];
    [labelCoordinates changeTheme];
    [labelWhoWhen changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs size:(NSInteger)sz
{
    if (favs != 0) {
        favouritesLabel.text = [NSString stringWithFormat:@"%ld", (long)favs];
        favouritesLabel.textColor = [UIColor whiteColor];
        favouritesIV.hidden = NO;
    } else {
        favouritesLabel.text = nil;
        favouritesIV.hidden = YES;
    }

    if (sz != 0) {
        imageSize.image = [imageLibrary get:sz];
        imageSize.hidden = NO;
    } else {
        imageSize.hidden = YES;
    }
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + DESCRIPTION_HEIGHT + 4 * GCCODE_HEIGHT;
}

#pragma -- WaypointManagerDelegate

- (void)refreshWaypoints
{
    icon.image = [imageLibrary getType:waypoint];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    icon.image = [imageLibrary getType:waypoint];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    waypoint = wp;
    icon.image = [imageLibrary getType:waypoint];
}

- (void)removeWaypoint:(dbWaypoint *)wp
{
    // Nothing!
}

@end
