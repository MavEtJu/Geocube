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

@interface WaypointHeaderTableViewCell ()

@property (nonatomic, retain) IBOutlet UIImageView *ivContainer;
@property (nonatomic, retain) IBOutlet UIImageView *ivSize;
@property (nonatomic, retain) IBOutlet UIImageView *ivFavourites;
@property (nonatomic, retain) IBOutlet GCLabel *labelLatLon;
@property (nonatomic, retain) IBOutlet GCLabel *labelBearDis;
@property (nonatomic, retain) IBOutlet GCLabel *labelLocation;
@property (nonatomic, retain) IBOutlet GCLabel *labelRatingD;
@property (nonatomic, retain) IBOutlet GCLabel *labelRatingT;
@property (nonatomic, retain) IBOutlet GCLabel *labelFavourites;
@property (nonatomic, retain) IBOutlet GCLabel *labelSize;

@end

@implementation WaypointHeaderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
    self.ivFavourites.image = [imageLibrary get:ImageCacheView_favourites];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelLatLon changeTheme];
    [self.labelBearDis changeTheme];
    [self.labelLocation changeTheme];
    [self.labelRatingD changeTheme];
    [self.labelRatingT changeTheme];
    [self.labelFavourites changeTheme];
    [self.labelSize changeTheme];
}

- (void)setWaypoint:(dbWaypoint *)wp
{
    Coordinates *c = [[Coordinates alloc] init:wp.wpt_lat_float lon:wp.wpt_lon_float];
    self.labelLatLon.text = [NSString stringWithFormat:@"%@ %@", [c lat_degreesDecimalMinutes], [c lon_degreesDecimalMinutes]];
    if (wp.gs_rating_terrain == 0)
        self.labelRatingT.text = @"";
    else
        self.labelRatingT.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    if (wp.gs_rating_difficulty == 0)
        self.labelRatingD.text = @"";
    else
        self.labelRatingD.text = [NSString stringWithFormat:@"D: %0.1f", wp.gs_rating_difficulty];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    self.labelBearDis.text = [NSString stringWithFormat:@"%ldº (%@) at %@",
                              (long)[Coordinates coordinates2bearing:LM.coords to:wp.coordinates],
                              [Coordinates bearing2compass:bearing],
                              [MyTools niceDistance:[Coordinates coordinates2distance:wp.coordinates to:LM.coords]]];
    self.labelLocation.text = [wp makeLocaleStateCountry];

    self.ivContainer.image = [imageLibrary getType:wp];

    if (wp.gs_favourites == 0) {
        self.ivFavourites.hidden = YES;
        self.labelFavourites.hidden = YES;
    } else {
        self.ivFavourites.hidden = NO;
        self.labelFavourites.hidden = NO;
        self.labelFavourites.text = [NSString stringWithFormat:@"%ld", wp.gs_favourites];
    }

    self.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        self.labelSize.hidden = NO;
        self.ivSize.hidden = YES;
    } else {
        self.labelSize.hidden = YES;
        self.ivSize.hidden = NO;
    }
    if (wp.gs_container.icon != 0) {
        self.ivSize.image = [imageLibrary get:wp.gs_container.icon];
        self.ivSize.hidden = NO;
    } else {
        self.ivSize.hidden = YES;
    }
}

@end

//@interface WaypointHeaderTableViewCell ()
//{
//    GCImageView *imageFavourites;
//    GCLabel *labelFavourites;
//
//    CGRect rectIcon;
//    CGRect rectImageFavourites;
//    CGRect rectLabelFavourites;
//    CGRect rectSize;
//    CGRect rectRatingsD;
//    CGRect rectRatingsT;
//
//    CGRect rectLatLon;
//    CGRect rectBearDis;
//    CGRect rectLocation;
//}
//
//@end
//
//@implementation WaypointHeaderTableViewCell
//
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//
//    /*
//     +---+--------------+-----+---+
//     | I |              | S XX| F |  Icon
//     +---+--------------+-----+---+  Size
//     | Lat              | D XXXXX |  Difficulty
//     | Lon              | T XXXXX |  Terrain
//     | BearDis          |         |  Favourites
//     | Location         |         |
//     +------------------+---------+
//     */
//#define BORDER 5
//#define BORDER 5
//#define ICON_WIDTH self.imageIcon.image.size.width
//#define ICON_HEIGHT self.imageIcon.image.size.height
//#define FAVOURITES_WIDTH_IMAGE imageFavourites.image.size.width
//#define FAVOURITES_HEIGHT_IMAGE imageFavourites.image.size.height
//#define FAVOURITES_WIDTH_LABEL imageFavourites.image.size.width
//#define FAVOURITES_HEIGHT_LABEL labelFavourites.font.lineHeight
//#define RATINGD_HEIGHT self.labelRatingD.font.lineHeight
//#define RATINGT_HEIGHT self.labelRatingT.font.lineHeight
//#define LATLON_HEIGHT self.labelLatLon.font.lineHeight
//#define BEARDIS_HEIGHT self.labelBearDis.font.lineHeight
//#define LOCATION_HEIGHT self.labelLocation.font.lineHeight
//#define SIZE_HEIGHT self.imageSize.image.size.height
//#define SIZE_WIDTH self.imageSize.image.size.width
//
//    // Icon
//    self.imageIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
//    self.imageIcon.image = [imageLibrary get:ImageTypes_TraditionalCache];
//    [self.contentView addSubview:self.imageIcon];
//
//    // Favourites
//    imageFavourites = [[GCImageView alloc] initWithFrame:CGRectZero];
//    imageFavourites.image = [imageLibrary get:ImageCacheView_favourites];
//    [self.contentView addSubview:imageFavourites];
//    imageFavourites.hidden = TRUE;
//    labelFavourites = [[GCLabel alloc] initWithFrame:CGRectZero];
//    labelFavourites.font = [UIFont boldSystemFontOfSize:10];
//    labelFavourites.backgroundColor = [UIColor clearColor];
//    labelFavourites.textColor = [UIColor whiteColor];
//    labelFavourites.textAlignment = NSTextAlignmentCenter;
//    [self.contentView addSubview:labelFavourites];
//
//    // ContainerSize
//    /*
//    r = rectSize;
//    r.origin.x -= 10;
//    l = [[GCLabel alloc] initWithFrame:r];
//    l.font = [UIFont systemFontOfSize:10.0];
//    l.text = @"S";
//    [self.contentView addSubview:l];
//     */
//
//    self.imageSize = [[UIImageView alloc] initWithFrame:CGRectZero];
//    self.imageSize.image = [imageLibrary get:ImageContainerSize_NotChosen];
//    [self.contentView addSubview:self.imageSize];
//
//    // Difficulty rating
//    self.labelRatingD = [[GCLabel alloc] initWithFrame:CGRectZero];
//    self.labelRatingD.font = [UIFont systemFontOfSize:10.0];
//    self.labelRatingD.textAlignment = NSTextAlignmentRight;
//    [self.contentView addSubview:self.labelRatingD];
//
//    // Terrain rating
//    self.labelRatingT = [[GCLabel alloc] initWithFrame:CGRectZero];
//    self.labelRatingT.font = [UIFont systemFontOfSize:10];
//    self.labelRatingT.textAlignment = NSTextAlignmentRight;
//    [self.contentView addSubview:self.labelRatingT];
//
//    // LatLon
//    self.labelLatLon = [[GCLabel alloc] initWithFrame:CGRectZero];
//    self.labelLatLon.font = [UIFont systemFontOfSize:10];
//    [self.contentView addSubview:self.labelLatLon];
//
//    // BearDis
//    self.labelBearDis = [[GCLabel alloc] initWithFrame:CGRectZero];
//    self.labelBearDis.font = [UIFont systemFontOfSize:10];
//    [self.contentView addSubview:self.labelBearDis];
//
//    // Location
//    self.labelLocation = [[GCLabel alloc] initWithFrame:CGRectZero];
//    self.labelLocation.font = [UIFont systemFontOfSize:10];
//    [self.contentView addSubview:self.labelLocation];
//
//    [self viewWillTransitionToSize];
//
//    return self;
//}
//
//- (void)calculateRects
//{
//    CGRect bounds = [[UIScreen mainScreen] bounds];
//    NSInteger width = bounds.size.width;
//    NSInteger height = [self cellHeight];
//
//    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
//    rectLabelFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_LABEL, BORDER + 4, FAVOURITES_WIDTH_LABEL, FAVOURITES_HEIGHT_LABEL);
//    rectImageFavourites = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_IMAGE, BORDER, FAVOURITES_WIDTH_IMAGE, FAVOURITES_HEIGHT_IMAGE);
//
//    rectSize = CGRectMake(width - 2 * BORDER - SIZE_WIDTH, [self cellHeight] - BORDER - RATINGT_HEIGHT - RATINGD_HEIGHT - SIZE_HEIGHT, SIZE_WIDTH, SIZE_HEIGHT);
//    rectRatingsD = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - BORDER - RATINGT_HEIGHT - RATINGD_HEIGHT, 30, RATINGD_HEIGHT);
//    rectRatingsT = CGRectMake(width - 2 * BORDER - 30, [self cellHeight] - BORDER - RATINGT_HEIGHT, 30, RATINGT_HEIGHT);
//
//    rectLatLon = CGRectMake(BORDER, height - BORDER - LATLON_HEIGHT - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER - 30, LATLON_HEIGHT);
//    rectBearDis = CGRectMake(BORDER, height - BORDER - BEARDIS_HEIGHT - LOCATION_HEIGHT, width - 2 * BORDER - 30, BEARDIS_HEIGHT);
//    rectLocation = CGRectMake(BORDER, height - BORDER - LOCATION_HEIGHT, width - 2 * BORDER - 30, LOCATION_HEIGHT);
//}
//
//- (void)viewWillTransitionToSize
//{
//    [self calculateRects];
//    self.imageIcon.frame = rectIcon;
//    imageFavourites.frame = rectImageFavourites;
//    labelFavourites.frame = rectLabelFavourites;
//    self.imageSize.frame = rectSize;
//    self.labelRatingD.frame = rectRatingsD;
//    self.labelRatingT.frame = rectRatingsT;
//    self.labelLatLon.frame = rectLatLon;
//    self.labelBearDis.frame = rectBearDis;
//    self.labelLocation.frame = rectLocation;
//}
//
//- (void)changeTheme
//{
//    [imageFavourites changeTheme];
//    [self.labelRatingT changeTheme];
//    [self.labelRatingD changeTheme];
//    [self.labelLatLon changeTheme];
//    [self.labelBearDis changeTheme];
//    [self.labelLocation changeTheme];
//
//    [super changeTheme];
//}
//
//- (void)setRatings:(NSInteger)favs
//{
//    if (favs != 0) {
//        labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
//        imageFavourites.hidden = NO;
//    } else {
//        imageFavourites.hidden = YES;
//    }
//}
//
//- (NSInteger)cellHeight
//{
//    return BORDER * 2 + ICON_HEIGHT + LATLON_HEIGHT + BEARDIS_HEIGHT + LOCATION_HEIGHT;
//}
//
//@end
