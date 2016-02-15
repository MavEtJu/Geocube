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

@interface WaypointTableViewCell ()
{
    GCLabel *description;
    GCLabel *name;
    UIImageView *size;
    GCLabel *ratingDLabel, *ratingTLabel;
    UIImageView *ratingDIV, *ratingTIV;
    GCLabel *favouritesLabel;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgRatingBase, *imgFavourites, *imgSize;
    UIImageView *icon, *favouritesIV;
    GCLabel *stateCountry;
    GCLabel *bearing;
    GCLabel *compass;
    GCLabel *distance;

    dbWaypoint *waypoint;

    CGRect rectIcon;
    CGRect rectDescription;
    CGRect rectName;
    CGRect rectFavouritesLabel;
    CGRect rectFavouritesIV;
    CGRect rectSize;
    CGRect rectRatingDIV;
    CGRect rectRatingTIV;
    CGRect rectRatingDLabel;
    CGRect rectRatingTLabel;
    CGRect rectBearing;
    CGRect rectCompass;
    CGRect rectStateCountry;
    CGRect rectDistance;
}

@end

@implementation WaypointTableViewCell

@synthesize description, name, icon, stateCountry, bearing, compass, distance;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

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
    [self.contentView addSubview:icon];

    // Description
    description = [[GCLabel alloc] initWithFrame:rectDescription];
    description.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:description];

    // Name
    name = [[GCLabel alloc] initWithFrame:rectName];
    name.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:name];

    // Bearing
    bearing = [[GCLabel alloc] initWithFrame:rectBearing];
    bearing.font = [UIFont systemFontOfSize:10.0];
    bearing.textAlignment = NSTextAlignmentCenter;
    //bearing.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:bearing];

    // Compass
    compass = [[GCLabel alloc] initWithFrame:rectCompass];
    compass.font = [UIFont systemFontOfSize:10.0];
    compass.textAlignment = NSTextAlignmentCenter;
    //compass.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:compass];

    // State country
    stateCountry = [[GCLabel alloc] initWithFrame:rectStateCountry];
    stateCountry.font = [UIFont systemFontOfSize:10];
    //stateCountry.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:stateCountry];

    // Distance
    distance = [[GCLabel alloc] initWithFrame:rectDistance];
    distance.font = [UIFont systemFontOfSize:10.0];
    //distance.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:distance];

    // Favourites
    favouritesIV = [[UIImageView alloc] initWithFrame:rectFavouritesIV];
    favouritesIV.image = imgFavourites;
    [self.contentView addSubview:favouritesIV];
    favouritesIV.hidden = TRUE;

    favouritesLabel = [[GCLabel alloc] initWithFrame:rectFavouritesLabel];
    favouritesLabel.font = [UIFont boldSystemFontOfSize:10];
    favouritesLabel.textColor = [UIColor whiteColor];
    favouritesLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:favouritesLabel];

    // Difficulty rating
    ratingDLabel = [[GCLabel alloc] initWithFrame:rectRatingDLabel];
    ratingDLabel.font = [UIFont systemFontOfSize:10.0];
    ratingDLabel.text = @"D";
    [self.contentView addSubview:ratingDLabel];

    ratingDIV = [[UIImageView alloc] initWithFrame:rectRatingDIV];
    //ratingD.image = imgRatingBase;
    [self.contentView addSubview:ratingDIV];

    // Terrain rating
    ratingTLabel = [[GCLabel alloc] initWithFrame:rectRatingTLabel];
    ratingTLabel.font = [UIFont systemFontOfSize:10.0];
    ratingTLabel.text = @"T";
    [self.contentView addSubview:ratingTLabel];

    ratingTIV = [[UIImageView alloc] initWithFrame:rectRatingTIV];
    //ratingT.image = imgRatingBase;
    [self.contentView addSubview:ratingTIV];

    // Size
    size = [[UIImageView alloc] initWithFrame:rectSize];
    size.image = imgSize;
    [self.contentView addSubview:size];

    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = [self cellHeight];

    /*
     +---+--------------------+---+
     |   | Description        | F |  Favourites
     |   +--------------------+   |  Difficulty
     |   | Name               |   |  Terrain
     +---+--------------+-----+---+  Angle
     | A | State Country| D XXXXX |  Compass
     | C | Distance     | T XXXXX |
     +---+--------------+---------+
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

    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    rectName = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, NAME_HEIGHT);
    rectFavouritesIV = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    rectSize = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH / 2, STAR_HEIGHT / 2);
    rectRatingDIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectRatingTIV = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectBearing = CGRectMake(BORDER, height - BORDER - 2 * BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    rectCompass = CGRectMake(BORDER, height - BORDER - BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, height - DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingTIV.size.width, DISTANCE_HEIGHT);
    rectDistance = CGRectMake(BORDER + ICON_WIDTH, height - 2 * DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingDIV.size.width, DISTANCE_HEIGHT);

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
    size.frame = rectSize;
    ratingDIV.frame = rectRatingDIV;
    ratingTIV.frame = rectRatingTIV;
    bearing.frame = rectBearing;
    compass.frame = rectCompass;
    stateCountry.frame = rectStateCountry;
    distance.frame = rectDistance;

    ratingDLabel.frame = rectRatingDLabel;
    ratingTLabel.frame = rectRatingTLabel;
//    [self calculateCellHeight];
}

- (void)changeTheme
{
    [name changeTheme];
    [stateCountry changeTheme];
    [distance changeTheme];
    [bearing changeTheme];
    [compass changeTheme];
    [ratingDLabel changeTheme];
    [ratingTLabel changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs terrain:(float)t difficulty:(float)d size:(NSInteger)sz
{
    ratingDIV.image = [imageLibrary getRating:d];
    ratingTIV.image = [imageLibrary getRating:t];

    if (favs != 0) {
        favouritesLabel.text = [NSString stringWithFormat:@"%ld", (long)favs];
        favouritesIV.hidden = FALSE;
    } else {
        favouritesLabel.text = nil;
        favouritesIV.hidden = TRUE;;
    }

    size.image = [imageLibrary get:sz];
}

+ (NSInteger)cellHeight
{
    return BORDER * 2 + FAVOURITES_HEIGHT + STAR_HEIGHT * 2;
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + FAVOURITES_HEIGHT + STAR_HEIGHT * 2;
}

- (void)showGroundspeak:(BOOL)yesno
{
    ratingDIV.hidden = !yesno;
    ratingTIV.hidden = !yesno;
    ratingDLabel.hidden = !yesno;
    ratingTLabel.hidden = !yesno;
}

@end
