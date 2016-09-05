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

@interface MapWaypointInfoView ()
{
    GCLabel *ratingDLabel, *ratingTLabel;
    GCImageView *ratingDIV, *ratingTIV;
    GCLabel *favouritesLabel;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgRatingBase, *imgFavourites, *imgSize;
    GCImageView *favouritesIV;
    GCButton *setAsTarget;

    GCLabel *description;
    GCLabel *name;
    GCImageView *icon;
    GCLabel *country;
    GCLabel *stateCountry;
    GCLabel *bearing;
    GCLabel *labelSize;
    GCLabel *coordinates;
    GCLabel *whomWhen;
    GCImageView *imageSize;

    CGRect rectIcon;
    CGRect rectDescription;
    CGRect rectName;
    CGRect rectFavouritesLabel;
    CGRect rectFavouritesIV;
    CGRect rectSize;
    CGRect rectSizeLabel;
    CGRect rectRatingDIV;
    CGRect rectRatingTIV;
    CGRect rectRatingDLabel;
    CGRect rectRatingTLabel;
    CGRect rectBearing;
    CGRect rectStateCountry;
    CGRect rectCoordinates;
    CGRect rectByWhomWhen;
    CGRect rectSetAsTarget;

    dbWaypoint *waypoint;
}

@end

@implementation MapWaypointInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    imgRatingOff = [imageLibrary get:ImageCacheView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageCacheView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageCacheView_ratingHalf];
    imgRatingBase = [imageLibrary get:ImageCacheView_ratingBase];
    imgFavourites = [imageLibrary get:ImageCacheView_favourites];
    imgSize = [imageLibrary get:ImageSize_NotChosen];

    [self calculateRects];

    // Icon
    icon = [[GCImageView alloc] initWithFrame:rectIcon];
    icon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self addSubview:icon];

    // Description
    description = [[GCLabel alloc] initWithFrame:rectDescription];
    description.font = [UIFont boldSystemFontOfSize:14.0];
    [self addSubview:description];

    // Whom and when
    whomWhen = [[GCLabel alloc] initWithFrame:rectByWhomWhen];
    whomWhen.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:whomWhen];

    // Name
    name = [[GCLabel alloc] initWithFrame:rectName];
    name.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:name];

    // Bearing
    bearing = [[GCLabel alloc] initWithFrame:rectBearing];
    bearing.font = [UIFont systemFontOfSize:10.0];
    [self addSubview:bearing];

    // Coordinates
    coordinates = [[GCLabel alloc] initWithFrame:rectCoordinates];
    coordinates.font = [UIFont systemFontOfSize:10];
    coordinates.backgroundColor = [UIColor purpleColor];
    [self addSubview:coordinates];

    // State country
    stateCountry = [[GCLabel alloc] initWithFrame:rectStateCountry];
    stateCountry.font = [UIFont systemFontOfSize:10];
    [self addSubview:stateCountry];

    // Favourites
    favouritesIV = [[GCImageView alloc] initWithFrame:rectFavouritesIV];
    favouritesIV.image = imgFavourites;
    [self addSubview:favouritesIV];
    favouritesIV.hidden = TRUE;

    favouritesLabel = [[GCLabel alloc] initWithFrame:rectFavouritesLabel];
    favouritesLabel.backgroundColor = [UIColor clearColor];
    favouritesLabel.font = [UIFont boldSystemFontOfSize:10];
    favouritesLabel.textColor = [UIColor whiteColor];
    favouritesLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:favouritesLabel];

    // Difficulty rating
    ratingDLabel = [[GCLabel alloc] initWithFrame:rectRatingDLabel];
    ratingDLabel.font = [UIFont systemFontOfSize:10.0];
    ratingDLabel.text = @"D";
    [self addSubview:ratingDLabel];

    ratingDIV = [[GCImageView alloc] initWithFrame:rectRatingDIV];
    [self addSubview:ratingDIV];

    // Terrain rating
    ratingTLabel = [[GCLabel alloc] initWithFrame:rectRatingTLabel];
    ratingTLabel.font = [UIFont systemFontOfSize:10.0];
    ratingTLabel.text = @"T";
    [self addSubview:ratingTLabel];

    ratingTIV = [[GCImageView alloc] initWithFrame:rectRatingTIV];
    [self addSubview:ratingTIV];

    // Size
    imageSize = [[GCImageView alloc] initWithFrame:rectSize];
    imageSize.image = imgSize;
    [self addSubview:imageSize];
    labelSize = [[GCLabel alloc] initWithFrame:rectSizeLabel];
    labelSize.text = @"";
    labelSize.font = [UIFont systemFontOfSize:10];
    [self addSubview:labelSize];

    // Set as target
    setAsTarget = [GCButton buttonWithType:UIButtonTypeSystem];
    setAsTarget.frame = rectSetAsTarget;
    [setAsTarget addTarget:self action:@selector(setAsTarget:) forControlEvents:UIControlEventTouchDown];
    [setAsTarget setImage:[imageLibrary get:ImageIcon_FindMe] forState:UIControlStateNormal];
    [self addSubview:setAsTarget];

    [self changeTheme];

    return self;
}

- (void)waypointData:(dbWaypoint *)wp
{
    waypoint = wp;

    description.text = wp.wpt_urlname;
    if (wp.gs_owner == nil)
        whomWhen.text = [NSString stringWithFormat:@"Yours on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    else
        whomWhen.text = [NSString stringWithFormat:@"by %@ on %@", wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    name.text = [NSString stringWithFormat:@"%@ (%@)", wp.wpt_name, wp.account.site];
    icon.image = [imageLibrary getType:wp];
    if (wp.flag_highlight == YES)
        description.backgroundColor = [UIColor yellowColor];
    else
        description.backgroundColor = [UIColor clearColor];

    [self setRatings:wp.gs_favourites terrain:wp.gs_rating_terrain difficulty:wp.gs_rating_difficulty size:wp.gs_container.icon];

    NSInteger b = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    bearing.text = [NSString stringWithFormat:@"%ld° (%@) at %@", (long)b, [Coordinates bearing2compass:b], [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]]];
    coordinates.text = [Coordinates NiceCoordinates:wp.coordinates];

    labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        labelSize.hidden = NO;
        imageSize.hidden = YES;
    } else {
        labelSize.hidden = YES;
        imageSize.hidden = NO;
    }

    stateCountry.text = [wp makeLocaleStateCountry];
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
     +---+---------------------+---+
     |   | Name                | F |  Favourites
     | C | By X on Y           |   |  Difficulty
     |   | GC Code             |   |  Terrain
     |   |---------------+-----+---+  Angle
     | T | A at Distance | D XXXXX |
     |   | State Country | T XXXXX |
     +---+---------------+---------+
     */
#define BORDER 1
#define ICON_WIDTH 30
#define ICON_HEIGHT 30
#define DESCRIPTION_HEIGHT 16
#define NAME_HEIGHT 14
#define FAVOURITES_WIDTH 20
#define FAVOURITES_HEIGHT 30
#define STAR_WIDTH 19
#define STAR_HEIGHT 18
#define DISTANCE_HEIGHT 14
#define BEARING_HEIGHT 14
#define COORDINATES_HEIGHT 14

    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    rectSetAsTarget = CGRectMake(BORDER, 2 * BORDER + ICON_HEIGHT, setAsTargetSize.width, setAsTargetSize.height * 1.5);
    rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    rectByWhomWhen = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, NAME_HEIGHT);
    rectName = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + NAME_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, NAME_HEIGHT);
    rectBearing = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 2 * NAME_HEIGHT, width - 2 * BORDER - ICON_WIDTH, BEARING_HEIGHT);
    rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 3 * NAME_HEIGHT, width - 2 * BORDER - ICON_WIDTH - rectRatingTIV.size.width, DISTANCE_HEIGHT);
    rectCoordinates = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + 4 * NAME_HEIGHT, width - 2 * BORDER - ICON_WIDTH - rectRatingDIV.size.width, COORDINATES_HEIGHT);

    rectFavouritesIV = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    rectSize = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH / 2, STAR_HEIGHT / 2);
    rectSizeLabel = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH, STAR_HEIGHT / 2);
    rectRatingDIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectRatingTIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);

    rectFavouritesLabel = rectFavouritesIV;
    rectFavouritesLabel.size.height /= 2;

    rectRatingDLabel = rectRatingDIV;
    rectRatingDLabel.origin.x -= 10;

    rectRatingTLabel = rectRatingTIV;
    rectRatingTLabel.origin.x -= 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    icon.frame = rectIcon;
    description.frame = rectDescription;
    whomWhen.frame = rectByWhomWhen;
    name.frame = rectName;
    favouritesIV.frame = rectFavouritesIV;
    favouritesLabel.frame = rectFavouritesLabel;
    imageSize.frame = rectSize;
    labelSize.frame = rectSizeLabel;
    ratingDIV.frame = rectRatingDIV;
    ratingTIV.frame = rectRatingTIV;
    bearing.frame = rectBearing;
    stateCountry.frame = rectStateCountry;
    coordinates.frame = rectCoordinates;
    setAsTarget.frame = rectSetAsTarget;

    ratingDLabel.frame = rectRatingDLabel;
    ratingTLabel.frame = rectRatingTLabel;
}

- (void)changeTheme
{
    [name changeTheme];
    [stateCountry changeTheme];
    [bearing changeTheme];
    [ratingDLabel changeTheme];
    [ratingTLabel changeTheme];
    [labelSize changeTheme];
    [coordinates changeTheme];
    [whomWhen changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs terrain:(float)t difficulty:(float)d size:(NSInteger)sz
{
    if (t != 0) {
        ratingTIV.image = [imageLibrary getRating:t];
        ratingTLabel.hidden = NO;
        ratingTIV.hidden = NO;
    } else {
        ratingTIV.hidden = YES;
        ratingTLabel.hidden = YES;
    }
    if (d != 0) {
        ratingDIV.image = [imageLibrary getRating:d];
        ratingDLabel.hidden = NO;
        ratingDIV.hidden = NO;
    } else {
        ratingDIV.hidden = YES;
        ratingDLabel.hidden = YES;
    }

    if (favs != 0) {
        favouritesLabel.text = [NSString stringWithFormat:@"%ld", (long)favs];
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

+ (NSInteger)cellHeight
{
    return BORDER * 2 + DESCRIPTION_HEIGHT + 4 * NAME_HEIGHT;
}

- (NSInteger)cellHeight
{
    return [MapWaypointInfoView cellHeight];
}

@end
