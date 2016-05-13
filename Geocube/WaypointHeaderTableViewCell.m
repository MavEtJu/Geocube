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

@interface WaypointHeaderTableViewCell ()
{
    UIImageView *icon, *imgFavouritesIV;
    GCLabel *lat, *lon;
    UIImageView *size;
    GCLabel *labelRatingD, *labelRatingT;
    UIImageView *ratingD[5];
    UIImageView *ratingT[5];
    GCLabel *favourites;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgFavourites;
}

@end

@implementation WaypointHeaderTableViewCell

@synthesize icon, lat, lon, beardis, size, favourites;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = [self cellHeight];

    imgRatingOff = [imageLibrary get:ImageCacheView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageCacheView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageCacheView_ratingHalf];
    imgFavourites = [imageLibrary get:ImageCacheView_favourites];

    CGRect r;

    /*
     +---+--------------+-----+---+
     | I |              | S XX| F |  Icon
     +---+--------------+-----+---+  Size
     | Lat              | D XXXXX |  Difficulty
     | Lon              | T XXXXX |  Terrain
     | BearDis          |         |  Favourites
     +------------------+---------+
     */
#define BORDER 1
#define ICON_WIDTH 30
#define ICON_HEIGHT 30
#define FAVOURITES_WIDTH 20
#define FAVOURITES_HEIGHT 30
#define STAR_WIDTH 19
#define STAR_HEIGHT 18
#define LAT_HEIGHT 10
#define LON_HEIGHT 10
#define BEARDIS_HEIGHT 10

#define N 5
    CGRect rectIcon = CGRectMake(BORDER + N, BORDER, ICON_WIDTH - N, ICON_HEIGHT);
    CGRect rectFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH - N, BORDER, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    CGRect rectSize = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT - STAR_HEIGHT - N, 5 * STAR_WIDTH - FAVOURITES_WIDTH - BORDER, STAR_HEIGHT);
    CGRect rectRatingsD = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT - N, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectRatingsT = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT - N, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectLat = CGRectMake(BORDER + N, height - BORDER - LON_HEIGHT - LAT_HEIGHT - BEARDIS_HEIGHT + N, width - 2 * BORDER - 5 * STAR_WIDTH - N - 10, LAT_HEIGHT);
    CGRect rectLon = CGRectMake(BORDER + N, height - BORDER - LON_HEIGHT - BEARDIS_HEIGHT + N, width - 2 * BORDER - 5 * STAR_WIDTH - N - 10, LON_HEIGHT);
    CGRect rectBearDis = CGRectMake(BORDER + N, height - BORDER - BEARDIS_HEIGHT + N, width - 2 * BORDER - 5 * STAR_WIDTH - N - 10, BEARDIS_HEIGHT);

    // Icon
    icon = [[UIImageView alloc] initWithFrame:rectIcon];
    icon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self.contentView addSubview:icon];

    // Favourites
    imgFavouritesIV = [[UIImageView alloc] initWithFrame:rectFavourites];
    imgFavouritesIV.image = imgFavourites;
    [self.contentView addSubview:imgFavouritesIV];
    imgFavouritesIV.hidden = TRUE;
    r = rectFavourites;
    r.size.height /= 2;
    favourites = [[GCLabel alloc] initWithFrame:r];
    favourites.font = [UIFont boldSystemFontOfSize:10];
    favourites.backgroundColor = [UIColor clearColor];
    favourites.textColor = [UIColor whiteColor];
    favourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:favourites];

    // ContainerSize
    /*
    r = rectSize;
    r.origin.x -= 10;
    l = [[GCLabel alloc] initWithFrame:r];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"S";
    [self.contentView addSubview:l];
     */

    size = [[UIImageView alloc] initWithFrame:rectSize];
    size.image = [imageLibrary get:ImageSize_NotChosen];
    [self.contentView addSubview:size];

    // Difficulty rating
    r = rectRatingsD;
    r.origin.x -= 10;
    labelRatingD = [[GCLabel alloc] initWithFrame:r];
    labelRatingD.font = [UIFont systemFontOfSize:10.0];
    labelRatingD.text = @"D";
    [self.contentView addSubview:labelRatingD];

    r = rectRatingsD;
    r.size.width = STAR_WIDTH;
    for (NSInteger i = 0; i < 5; i++) {
        ratingD[i] = [[UIImageView alloc] initWithFrame:r];
        ratingD[i].image = imgRatingOff;
        [self.contentView addSubview:ratingD[i]];
        r.origin.x += STAR_WIDTH;
    }

    // Terrain rating
    r = rectRatingsT;
    r.origin.x -= 10;
    labelRatingT = [[GCLabel alloc] initWithFrame:r];
    labelRatingT.font = [UIFont systemFontOfSize:10.0];
    labelRatingT.text = @"T";
    [self.contentView addSubview:labelRatingT];

    r = rectRatingsT;
    r.size.width = STAR_WIDTH;
    for (NSInteger i = 0; i < 5; i++) {
        ratingT[i] = [[UIImageView alloc] initWithFrame:r];
        ratingT[i].image = imgRatingOff;
        [self.contentView addSubview:ratingT[i]];
        r.origin.x += STAR_WIDTH;
    }

    // Lon
    lon = [[GCLabel alloc] initWithFrame:rectLon];
    lon.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:lon];

    // Lat
    lat = [[GCLabel alloc] initWithFrame:rectLat];
    lat.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:lat];

    // BearDis
    beardis = [[GCLabel alloc] initWithFrame:rectBearDis];
    beardis.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:beardis];

    return self;
}

- (void)setRatings:(NSInteger)favs terrain:(float)t difficulty:(float)d
{
    for (NSInteger i = 0; i < t; i++)
        ratingT[i].image = imgRatingOn;
    for (NSInteger i = t; i < 5; i++)
        ratingT[i].image = imgRatingOff;
    if (t - (int)t != 0)
        ratingT[(int)t].image = imgRatingHalf;

    for (NSInteger i = 0; i < d; i++)
        ratingD[i].image = imgRatingOn;
    for (NSInteger i = d; i < 5; i++)
        ratingD[i].image = imgRatingOff;
    if (d - (int)d != 0)
        ratingD[(int)d].image = imgRatingHalf;

    if (favs != 0) {
        favourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        imgFavouritesIV.hidden = FALSE;
    }
}

+ (NSInteger)cellHeight
{
    return BORDER * 2 + ICON_HEIGHT + LAT_HEIGHT + LON_HEIGHT + BEARDIS_HEIGHT;
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + ICON_HEIGHT + LAT_HEIGHT + LON_HEIGHT + BEARDIS_HEIGHT;
}

@end
