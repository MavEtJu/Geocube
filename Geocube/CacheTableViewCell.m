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

@implementation CacheTableViewCell

@synthesize description, name, icon, stateCountry, bearing, compass, distance;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    NSInteger height = [self cellHeight];

    imgRatingOff = [imageLibrary get:ImageCacheView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageCacheView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageCacheView_ratingHalf];
    imgRatingBase = [imageLibrary get:ImageCacheView_ratingBase];
    imgFavourites = [imageLibrary get:ImageCacheView_favourites];
    imgSize = [imageLibrary get:ImageSize_NotChosen];

    CGRect r;

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

    CGRect rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    CGRect rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    CGRect rectName = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - FAVOURITES_WIDTH, NAME_HEIGHT);
    CGRect rectFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    CGRect rectSize = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT / 2, 5 * STAR_WIDTH / 2, STAR_HEIGHT / 2);
    CGRect rectRatingsD = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectRatingsT = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectBearing = CGRectMake(BORDER, height - BORDER - 2 * BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    CGRect rectCompass = CGRectMake(BORDER, height - BORDER - BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    CGRect rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, height - DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingsT.size.width, DISTANCE_HEIGHT);
    CGRect rectDistance = CGRectMake(BORDER + ICON_WIDTH, height - 2 * DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingsD.size.width, DISTANCE_HEIGHT);
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
    imgFavouritesIV = [[UIImageView alloc] initWithFrame:rectFavourites];
    imgFavouritesIV.image = imgFavourites;
    [self.contentView addSubview:imgFavouritesIV];
    imgFavouritesIV.hidden = TRUE;
    r = rectFavourites;
    r.size.height /= 2;
    favourites = [[GCLabel alloc] initWithFrame:r];
    favourites.font = [UIFont boldSystemFontOfSize:10];
    favourites.textColor = [UIColor whiteColor];
    favourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:favourites];

    // Difficulty rating
    r = rectRatingsD;
    r.origin.x -= 10;
    labelRatingD = [[GCLabel alloc] initWithFrame:r];
    labelRatingD.font = [UIFont systemFontOfSize:10.0];
    labelRatingD.text = @"D";
    [self.contentView addSubview:labelRatingD];

    imgRatingD = [[UIImageView alloc] initWithFrame:rectRatingsD];
    //ratingD.image = imgRatingBase;
    [self.contentView addSubview:imgRatingD];

    // Terrain rating
    r = rectRatingsT;
    r.origin.x -= 10;
    labelRatingT = [[GCLabel alloc] initWithFrame:r];
    labelRatingT.font = [UIFont systemFontOfSize:10.0];
    labelRatingT.text = @"T";
    [self.contentView addSubview:labelRatingT];

    imgRatingT = [[UIImageView alloc] initWithFrame:rectRatingsT];
    //ratingT.image = imgRatingBase;
    [self.contentView addSubview:imgRatingT];

    // Size
    size = [[UIImageView alloc] initWithFrame:rectSize];
    size.image = imgSize;
    [self.contentView addSubview:size];

    return self;
}

- (void)changeTheme
{
    [name changeTheme];
    [stateCountry changeTheme];
    [distance changeTheme];
    [bearing changeTheme];
    [compass changeTheme];
    [labelRatingD changeTheme];
    [labelRatingT changeTheme];
    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs terrain:(float)t difficulty:(float)d size:(NSInteger)sz
{
    imgRatingD.image = [imageLibrary getRating:d];
    imgRatingT.image = [imageLibrary getRating:t];

    if (favs != 0) {
        favourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        imgFavouritesIV.hidden = FALSE;
    } else {
        favourites.text = nil;
        imgFavouritesIV.hidden = TRUE;;
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
    imgRatingD.hidden = !yesno;
    imgRatingT.hidden = !yesno;
    labelRatingD.hidden = !yesno;
    labelRatingT.hidden = !yesno;
}

@end
