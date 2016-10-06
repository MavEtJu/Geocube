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
    GCImageView *imageFavourites;
    GCLabel *labelFavourites;

    CGRect rectIcon;
    CGRect rectImageFavourites;
    CGRect rectLabelFavourites;
    CGRect rectSize;
    CGRect rectRatingsD;
    CGRect rectRatingsT;

    CGRect rectLatLon;
    CGRect rectBearDis;
    CGRect rectLocation;
}

@end

@implementation WaypointHeaderTableViewCell

@synthesize imageIcon, labelLatLon, labelBearDis, imageSize, labelFavourites, labelLocation, labelRatingT, labelRatingD;

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
#define BORDER 5
#define BORDER 5
#define ICON_WIDTH imageIcon.image.size.width
#define ICON_HEIGHT imageIcon.image.size.height
#define FAVOURITES_WIDTH_IMAGE imageFavourites.image.size.width
#define FAVOURITES_HEIGHT_IMAGE imageFavourites.image.size.height
#define FAVOURITES_WIDTH_LABEL imageFavourites.image.size.width
#define FAVOURITES_HEIGHT_LABEL labelFavourites.font.lineHeight
#define RATINGD_HEIGHT labelRatingD.font.lineHeight
#define RATINGT_HEIGHT labelRatingT.font.lineHeight
#define LATLON_HEIGHT labelLatLon.font.lineHeight
#define BEARDIS_HEIGHT labelBearDis.font.lineHeight
#define LOCATION_HEIGHT labelLocation.font.lineHeight
#define SIZE_HEIGHT imageSize.image.size.height
#define SIZE_WIDTH imageSize.image.size.width

    // Icon
    imageIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageIcon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self.contentView addSubview:imageIcon];

    // Favourites
    imageFavourites = [[GCImageView alloc] initWithFrame:CGRectZero];
    imageFavourites.image = [imageLibrary get:ImageCacheView_favourites];
    [self.contentView addSubview:imageFavourites];
    imageFavourites.hidden = TRUE;
    labelFavourites = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelFavourites.font = [UIFont boldSystemFontOfSize:10];
    labelFavourites.backgroundColor = [UIColor clearColor];
    labelFavourites.textColor = [UIColor whiteColor];
    labelFavourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:labelFavourites];

    // ContainerSize
    /*
    r = rectSize;
    r.origin.x -= 10;
    l = [[GCLabel alloc] initWithFrame:r];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"S";
    [self.contentView addSubview:l];
     */

    imageSize = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageSize.image = [imageLibrary get:ImageContainerSize_NotChosen];
    [self.contentView addSubview:imageSize];

    // Difficulty rating
    labelRatingD = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingD.font = [UIFont systemFontOfSize:10.0];
    labelRatingD.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:labelRatingD];

    // Terrain rating
    labelRatingT = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingT.font = [UIFont systemFontOfSize:10];
    labelRatingT.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:labelRatingT];

    // LatLon
    labelLatLon = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelLatLon.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelLatLon];

    // BearDis
    labelBearDis = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBearDis.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelBearDis];

    // Location
    labelLocation = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelLocation.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelLocation];

    [self viewWillTransitionToSize];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = [self cellHeight];

    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    rectLabelFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_LABEL, BORDER + 4, FAVOURITES_WIDTH_LABEL, FAVOURITES_HEIGHT_LABEL);
    rectImageFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_IMAGE, BORDER, FAVOURITES_WIDTH_IMAGE, FAVOURITES_HEIGHT_IMAGE);

    rectSize = CGRectMake(width - 2 * BORDER - SIZE_WIDTH, [self cellHeight] - BORDER - RATINGT_HEIGHT - RATINGD_HEIGHT - SIZE_HEIGHT, SIZE_WIDTH, SIZE_HEIGHT);
    rectRatingsD = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - BORDER - RATINGT_HEIGHT - RATINGD_HEIGHT, 30, RATINGD_HEIGHT);
    rectRatingsT = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - BORDER - RATINGT_HEIGHT, 30, RATINGT_HEIGHT);

    rectLatLon = CGRectMake(BORDER, height - BORDER - LATLON_HEIGHT - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER - 30, LATLON_HEIGHT);
    rectBearDis = CGRectMake(BORDER, height - BORDER - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER - 30, BEARDIS_HEIGHT);
    rectLocation = CGRectMake(BORDER, height - BORDER - LOCATION_HEIGHT, width - 2 * BORDER - 30, LOCATION_HEIGHT);
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    imageIcon.frame = rectIcon;
    imageFavourites.frame = rectImageFavourites;
    labelFavourites.frame = rectLabelFavourites;
    imageSize.frame = rectSize;
    labelRatingD.frame = rectRatingsD;
    labelRatingT.frame = rectRatingsT;
    labelLatLon.frame = rectLatLon;
    labelBearDis.frame = rectBearDis;
    labelLocation.frame = rectLocation;
}

- (void)changeTheme
{
    [imageFavourites changeTheme];
    [labelRatingT changeTheme];
    [labelRatingD changeTheme];
    [labelLatLon changeTheme];
    [labelBearDis changeTheme];
    [labelLocation changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs
{
    if (favs != 0) {
        labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        imageFavourites.hidden = NO;
    } else {
        imageFavourites.hidden = YES;
    }
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + ICON_HEIGHT + LATLON_HEIGHT + BEARDIS_HEIGHT + LOCATION_HEIGHT;
}

@end
