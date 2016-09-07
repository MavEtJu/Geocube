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

@interface WaypointHeaderTableViewCell ()
{
    UIImageView *imgFavouritesIV;
    GCLabel *labelRatingD, *labelRatingT;
    UIImageView *ratingD[5];
    UIImageView *ratingT[5];
    GCLabel *favourites;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgFavourites;
    UIFont *font10;

    CGRect rectIcon;
    CGRect rectFavourites;
    CGRect rectSize;
    CGRect rectRatingsD;
    CGRect rectRatingsT;

    CGRect rectLat;
    CGRect rectLon;
    CGRect rectBearDis;
    CGRect rectLocation;
}

@end

@implementation WaypointHeaderTableViewCell

@synthesize icon, lat, lon, beardis, size, favourites, location;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    /*
     +---+--------------+-----+---+
     | I |              | S XX| F |  Icon
     +---+--------------+-----+---+  Size
     | Lat              | D XXXXX |  Difficulty
     | Lon              | T XXXXX |  Terrain
     | BearDis          |         |  Favourites
     | Location         |         |
     +------------------+---------+
     */
#define BORDER_SIDE 5
#define BORDER_TOP 5
#define ICON_WIDTH 30
#define ICON_HEIGHT 30
#define FAVOURITES_WIDTH 20
#define FAVOURITES_HEIGHT 30
#define STAR_WIDTH 19
#define STAR_HEIGHT 18
#define LAT_HEIGHT font10.lineHeight
#define LON_HEIGHT font10.lineHeight
#define BEARDIS_HEIGHT font10.lineHeight
#define LOCATION_HEIGHT font10.lineHeight

    // Icon
    icon = [[UIImageView alloc] initWithFrame:rectIcon];
    icon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self.contentView addSubview:icon];

    // Favourites
    imgFavouritesIV = [[UIImageView alloc] initWithFrame:rectFavourites];
    imgFavouritesIV.image = imgFavourites;
    [self.contentView addSubview:imgFavouritesIV];
    imgFavouritesIV.hidden = TRUE;
    CGRect r = rectFavourites;
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
    labelRatingT.font = font10;
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
    lon.font = font10;
    [self.contentView addSubview:lon];

    // Lat
    lat = [[GCLabel alloc] initWithFrame:rectLat];
    lat.font = font10;
    [self.contentView addSubview:lat];

    // BearDis
    beardis = [[GCLabel alloc] initWithFrame:rectBearDis];
    beardis.font = font10;
    [self.contentView addSubview:beardis];

    // Location
    location = [[GCLabel alloc] initWithFrame:rectLocation];
    location.font = font10;
    [self.contentView addSubview:location];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    font10 = [UIFont systemFontOfSize:10.0];
    NSInteger height = [self cellHeight];

    imgRatingOff = [imageLibrary get:ImageCacheView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageCacheView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageCacheView_ratingHalf];
    imgFavourites = [imageLibrary get:ImageCacheView_favourites];

    rectIcon = CGRectMake(BORDER_SIDE, BORDER_TOP, ICON_WIDTH, ICON_HEIGHT);
    rectFavourites = CGRectMake(width - 2 * BORDER_SIDE - FAVOURITES_WIDTH, BORDER_TOP, FAVOURITES_WIDTH, FAVOURITES_HEIGHT);
    rectSize = CGRectMake(width - 2 * BORDER_SIDE - 5 * STAR_WIDTH, BORDER_TOP + FAVOURITES_HEIGHT - STAR_HEIGHT, 5 * STAR_WIDTH - FAVOURITES_WIDTH - BORDER_SIDE, STAR_HEIGHT);
    rectRatingsD = CGRectMake(width - 2 * BORDER_SIDE - 5 * STAR_WIDTH, BORDER_TOP + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    rectRatingsT = CGRectMake(width - 2 * BORDER_SIDE - 5 * STAR_WIDTH, BORDER_TOP + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);

    rectLat = CGRectMake(BORDER_SIDE, height - BORDER_TOP - LON_HEIGHT - LAT_HEIGHT - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER_SIDE - 5 * STAR_WIDTH - 10, LAT_HEIGHT);
    rectLon = CGRectMake(BORDER_SIDE, height - BORDER_TOP - LON_HEIGHT - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER_SIDE - 5 * STAR_WIDTH - 10, LON_HEIGHT);
    rectBearDis = CGRectMake(BORDER_SIDE, height - BORDER_TOP - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER_SIDE - 5 * STAR_WIDTH - 10, BEARDIS_HEIGHT);
    rectLocation = CGRectMake(BORDER_SIDE, height - BORDER_TOP - LOCATION_HEIGHT, width - 2 * BORDER_SIDE - 5 * STAR_WIDTH - 10, LOCATION_HEIGHT);
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    icon.frame = rectIcon;
    favourites.frame = rectFavourites;
    size.frame = rectSize;
    labelRatingD.frame = rectRatingsD;
    labelRatingT.frame = rectRatingsT;
    lat.frame = rectLat;
    lon.frame = rectLon;
    beardis.frame = rectBearDis;
    location.frame = rectLocation;
}

- (void)changeTheme
{
    [favourites changeTheme];
    [labelRatingT changeTheme];
    [labelRatingD changeTheme];
    [lat changeTheme];
    [lon changeTheme];
    [beardis changeTheme];
    [location changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs terrain:(float)t difficulty:(float)d
{
    if (t != 0) {
        labelRatingT.hidden = NO;
        for (NSInteger i = 0; i < 5; i++)
            ratingT[i].hidden = NO;

        for (NSInteger i = 0; i < t; i++)
            ratingT[i].image = imgRatingOn;
        for (NSInteger i = t; i < 5; i++)
            ratingT[i].image = imgRatingOff;
        if (t - (int)t != 0)
            ratingT[(int)t].image = imgRatingHalf;
    } else {
        for (NSInteger i = 0; i < 5; i++)
            ratingT[i].hidden = YES;
        labelRatingT.hidden = YES;
    }

    if (d != 0) {
        labelRatingD.hidden = NO;
        for (NSInteger i = 0; i < 5; i++)
            ratingD[i].hidden = NO;

        for (NSInteger i = 0; i < d; i++)
            ratingD[i].image = imgRatingOn;
        for (NSInteger i = d; i < 5; i++)
            ratingD[i].image = imgRatingOff;
        if (d - (int)d != 0)
            ratingD[(int)d].image = imgRatingHalf;
    } else {
        for (NSInteger i = 0; i < 5; i++)
            ratingD[i].hidden = YES;
        labelRatingD.hidden = YES;
    }

    if (favs != 0) {
        favourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        imgFavouritesIV.hidden = NO;
    } else {
        imgFavouritesIV.hidden = YES;
    }
}

- (NSInteger)cellHeight
{
    return BORDER_TOP * 2 + ICON_HEIGHT + LAT_HEIGHT + LON_HEIGHT + BEARDIS_HEIGHT + LOCATION_HEIGHT;
}

@end
