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
    UIImageView *imageSize;
    GCLabel *ratingDLabel, *ratingTLabel;
    UIImageView *ratingDIV, *ratingTIV;
    GCLabel *favouritesLabel;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgRatingBase, *imgFavourites, *imgSize;
    UIImageView *icon, *favouritesIV;
    GCLabel *labelSize;

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
}

@end

@implementation MapWaypointInfoView

@synthesize description, name, icon, stateCountry, bearing, labelSize, imageSize, coordinates;

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
    icon = [[UIImageView alloc] initWithFrame:rectIcon];
    icon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self addSubview:icon];

    // Description
    description = [[GCLabel alloc] initWithFrame:rectDescription];
    description.font = [UIFont boldSystemFontOfSize:14.0];
    [self addSubview:description];

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
    //stateCountry.backgroundColor = [UIColor purpleColor];
    [self addSubview:stateCountry];

    // Favourites
    favouritesIV = [[UIImageView alloc] initWithFrame:rectFavouritesIV];
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

    ratingDIV = [[UIImageView alloc] initWithFrame:rectRatingDIV];
    //ratingD.image = imgRatingBase;
    [self addSubview:ratingDIV];

    // Terrain rating
    ratingTLabel = [[GCLabel alloc] initWithFrame:rectRatingTLabel];
    ratingTLabel.font = [UIFont systemFontOfSize:10.0];
    ratingTLabel.text = @"T";
    [self addSubview:ratingTLabel];

    ratingTIV = [[UIImageView alloc] initWithFrame:rectRatingTIV];
    //ratingT.image = imgRatingBase;
    [self addSubview:ratingTIV];

    // Size
    imageSize = [[UIImageView alloc] initWithFrame:rectSize];
    imageSize.image = imgSize;
    [self addSubview:imageSize];
    labelSize = [[GCLabel alloc] initWithFrame:rectSizeLabel];
    labelSize.text = @"";
    labelSize.font = [UIFont systemFontOfSize:10];
    [self addSubview:labelSize];

    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = [MapWaypointInfoView cellHeight];

    /*
     +---+---------------------+---+
     |   | Description         | F |  Favourites
     |   +---------------------+   |  Difficulty
     |   | Name                |   |  Terrain
     +---+---------------------+---+  Angle
     | Coordinates                 |  Compass
     | A | Distance      | D XXXXX |
     | C | State Country | T XXXXX |
     +---+--------------+----------+
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
    rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    rectName = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, NAME_HEIGHT);
    rectFavouritesIV = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    rectSize = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH / 2, STAR_HEIGHT / 2);
    rectSizeLabel = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH, STAR_HEIGHT / 2);
    rectRatingDIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectRatingTIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectBearing = CGRectMake(BORDER + ICON_WIDTH, height - BORDER - 2 * BEARING_HEIGHT, width - 2 * BORDER - ICON_WIDTH, BEARING_HEIGHT);
    rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, height - DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingTIV.size.width, DISTANCE_HEIGHT);
    rectCoordinates = CGRectMake(BORDER + ICON_WIDTH, height - 2 * DISTANCE_HEIGHT - COORDINATES_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingDIV.size.width, COORDINATES_HEIGHT);

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

    ratingDLabel.frame = rectRatingDLabel;
    ratingTLabel.frame = rectRatingTLabel;
    //    [self calculateCellHeight];
}

- (void)changeTheme
{
    [name changeTheme];
    [stateCountry changeTheme];
    [bearing changeTheme];
    [ratingDLabel changeTheme];
    [ratingTLabel changeTheme];
    [labelSize changeTheme];

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
    return BORDER * 2 + FAVOURITES_HEIGHT + STAR_HEIGHT * 2 + COORDINATES_HEIGHT;
}

- (NSInteger)cellHeight
{
    return [MapWaypointInfoView cellHeight];
}

@end
