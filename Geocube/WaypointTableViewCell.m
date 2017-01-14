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

@interface WaypointTableViewCell ()
{
    GCLabel *labelRatingD, *labelRatingT;
    GCLabel *labelFavourites;
    UIImage *imgFavourites, *imgSize;
    GCImageView *imageViewFavourites, *imageViewSize;

    GCLabel *labelDescription;
    GCLabel *labelGCCode;
    GCImageView *imageViewIcon;
    GCLabel *labelStateCountry;
    GCLabel *labelBearing;
    GCLabel *labelCompass;
    GCLabel *labelDistance;
    GCLabel *labelSize;
    GCLabel *labelWhoWhen;

    dbWaypoint *waypoint;

    CGRect rectIcon;
    CGRect rectDescription;
    CGRect rectGCCode;
    CGRect rectFavouritesLabel;
    CGRect rectFavouritesImageView;
    CGRect rectSizeImage;
    CGRect rectSizeLabel;
    CGRect rectBearing;
    CGRect rectCompass;
    CGRect rectStateCountry;
    CGRect rectDistance;
    CGRect rectWhoWhen;
    CGRect rectRatingD, rectRatingT;
}

@end

@implementation WaypointTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.accessoryType = UITableViewCellAccessoryNone;

    imgFavourites = [imageLibrary get:ImageCacheView_favourites];
    imgSize = [imageLibrary get:ImageContainerSize_NotChosen];

    // Icon
    imageViewIcon = [[GCImageView alloc] initWithFrame:CGRectZero];
    imageViewIcon.image = [imageLibrary get:ImageTypes_TraditionalCache];
    [self.contentView addSubview:imageViewIcon];

    // Description
    labelDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDescription.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:labelDescription];

    // GCCode
    labelGCCode = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelGCCode.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:labelGCCode];

    // Bearing
    labelBearing = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBearing.font = [UIFont systemFontOfSize:10.0];
    labelBearing.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:labelBearing];

    // Compass
    labelCompass = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelCompass.font = [UIFont systemFontOfSize:10.0];
    labelCompass.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:labelCompass];

    // Who and when
    labelWhoWhen = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelWhoWhen.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelWhoWhen];

    // State country
    labelStateCountry = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelStateCountry.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelStateCountry];

    // Distance
    labelDistance = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDistance.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:labelDistance];

    // Favourites
    imageViewFavourites = [[GCImageView alloc] initWithFrame:CGRectZero];
    imageViewFavourites.image = imgFavourites;
    [self.contentView addSubview:imageViewFavourites];
    imageViewFavourites.hidden = TRUE;

    labelFavourites = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelFavourites.backgroundColor = [UIColor clearColor];
    labelFavourites.font = [UIFont boldSystemFontOfSize:10];
    labelFavourites.textColor = [UIColor whiteColor];
    labelFavourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:labelFavourites];

    // Difficulty rating
    labelRatingD = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingD.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:labelRatingD];

    // Terrain rating
    labelRatingT = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelRatingT.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:labelRatingT];

    // Size
    imageViewSize = [[GCImageView alloc] initWithFrame:CGRectZero];
    imageViewSize.image = imgSize;
    [self.contentView addSubview:imageViewSize];
    labelSize = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelSize.text = @"";
    labelSize.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:labelSize];

    [self viewWillTransitionToSize];
    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = [self cellHeight];

    /*
     +---+-----------------+------+
     |   | Description     |    F |  Favourites
     |   | GCCode          | Size |  Difficulty
     +---+--------------+---------+  Angle
     | A | Distance     | D XXXXX |  Compass
     | C | StateCountry | T XXXXX |  Terrain
     +---+--------------+---------+
     */

#define BORDER 1
#define ICON_WIDTH imageViewIcon.image.size.width
#define ICON_HEIGHT imageViewIcon.image.size.height
#define DESCRIPTION_HEIGHT labelDescription.font.lineHeight
#define GCCODE_HEIGHT labelGCCode.font.lineHeight
#define FAVOURITES_WIDTH_LABEL labelFavourites.font.lineHeight
#define FAVOURITES_HEIGHT_LABEL labelFavourites.font.lineHeight
#define FAVOURITES_WIDTH_IMAGE imageViewFavourites.image.size.width
#define FAVOURITES_HEIGHT_IMAGE imageViewFavourites.image.size.height
#define DISTANCE_HEIGHT labelDistance.font.lineHeight
#define BEARING_HEIGHT labelBearing.font.lineHeight
#define WHOWHEN_HEIGHT labelWhoWhen.font.lineHeight
#define SIZE_WIDTH_LABEL labelSize.font.lineHeight
#define SIZE_HEIGHT_LABEL 30
#define SIZE_WIDTH_IMAGE imageViewSize.image.size.width
#define SIZE_HEIGHT_IMAGE imageViewSize.image.size.height
#define RATING_WIDTH 30
#define RATING_HEIGHT labelRatingT.font.lineHeight

    rectIcon = CGRectMake(BORDER, BORDER, ICON_WIDTH, ICON_HEIGHT);
    rectDescription = CGRectMake(BORDER + ICON_WIDTH, BORDER, width - ICON_WIDTH - 2 * BORDER, DESCRIPTION_HEIGHT);
    rectGCCode = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT, width - 2 * BORDER - SIZE_WIDTH_LABEL, GCCODE_HEIGHT);
    rectWhoWhen = CGRectMake(BORDER + ICON_WIDTH, BORDER + DESCRIPTION_HEIGHT + GCCODE_HEIGHT, width - 2 * BORDER - SIZE_WIDTH_LABEL, WHOWHEN_HEIGHT);

    rectBearing = CGRectMake(BORDER, height - BORDER - 2 * BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    rectCompass = CGRectMake(BORDER, height - BORDER - BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);

    rectFavouritesImageView = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_IMAGE, BORDER, FAVOURITES_WIDTH_IMAGE, FAVOURITES_HEIGHT_IMAGE);
    rectFavouritesLabel = CGRectMake(width - 2 * BORDER - FAVOURITES_WIDTH_LABEL, BORDER, FAVOURITES_WIDTH_LABEL, FAVOURITES_HEIGHT_LABEL);
    rectSizeImage = CGRectMake(width - 2 * BORDER - SIZE_WIDTH_IMAGE, BORDER + FAVOURITES_HEIGHT_IMAGE, SIZE_WIDTH_IMAGE, SIZE_HEIGHT_IMAGE);
    rectSizeLabel = CGRectMake(width - 2 * BORDER - SIZE_WIDTH_LABEL, BORDER + FAVOURITES_HEIGHT_IMAGE, SIZE_WIDTH_LABEL, SIZE_HEIGHT_LABEL);
    rectRatingD = CGRectMake(width - 2 * BORDER - RATING_WIDTH, [self cellHeight] - BORDER - 2 * RATING_HEIGHT, RATING_WIDTH, RATING_HEIGHT);
    rectRatingT = CGRectMake(width - 2 * BORDER - RATING_WIDTH, [self cellHeight] - BORDER - RATING_HEIGHT, RATING_WIDTH, RATING_HEIGHT);
    rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, height - DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingT.size.width, DISTANCE_HEIGHT);
    rectDistance = CGRectMake(BORDER + ICON_WIDTH, height - 2 * DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingD.size.width, DISTANCE_HEIGHT);

    rectFavouritesLabel = rectFavouritesImageView;
    rectFavouritesLabel.size.height /= 2;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    imageViewIcon.frame = rectIcon;
    labelDescription.frame = rectDescription;
    labelGCCode.frame = rectGCCode;
    labelFavourites.frame = rectFavouritesLabel;
    imageViewFavourites.frame = rectFavouritesImageView;
    imageViewSize.frame = rectSizeImage;
    labelSize.frame = rectSizeLabel;
    labelRatingD.frame = rectRatingD;
    labelRatingT.frame = rectRatingT;
    labelBearing.frame = rectBearing;
    labelCompass.frame = rectCompass;
    labelWhoWhen.frame = rectWhoWhen;
    labelStateCountry.frame = rectStateCountry;
    labelDistance.frame = rectDistance;
}

- (void)changeTheme
{
    [labelGCCode changeTheme];
    [labelStateCountry changeTheme];
    [labelDistance changeTheme];
    [labelBearing changeTheme];
    [labelCompass changeTheme];
    [labelRatingT changeTheme];
    [labelRatingD changeTheme];
    [labelSize changeTheme];
    [labelWhoWhen changeTheme];

    [super changeTheme];
}

- (void)setRatings:(NSInteger)favs size:(NSInteger)sz
{
    if (favs != 0) {
        labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        imageViewFavourites.hidden = NO;
    } else {
        labelFavourites.text = nil;
        imageViewFavourites.hidden = YES;
    }

    if (sz != 0) {
        imageViewSize.image = [imageLibrary get:sz];
        imageViewSize.hidden = NO;
    } else {
        imageViewSize.hidden = YES;
    }
}

- (void)setWaypoint:(dbWaypoint *)wp
{
    labelDescription.text = wp.wpt_urlname;
    labelGCCode.text = wp.wpt_name;
    imageViewIcon.image = [imageLibrary getType:wp];

    if (wp.gs_owner == nil) {
        if ([wp hasGSData] == NO)
            labelWhoWhen.text = [NSString stringWithFormat:@"Placed on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
        else
            labelWhoWhen.text = [NSString stringWithFormat:@"Yours on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    } else
        labelWhoWhen.text = [NSString stringWithFormat:@"by %@ on %@", wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];

    if (wp.flag_highlight == YES)
        labelDescription.backgroundColor = [UIColor yellowColor];
    else
        labelDescription.backgroundColor = [UIColor clearColor];

    if (wp.gs_rating_terrain == 0)
        labelRatingT.text = @"";
    else
        labelRatingT.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    if (wp.gs_rating_difficulty == 0)
        labelRatingD.text = @"";
    else
        labelRatingD.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_difficulty];

    [self setRatings:wp.gs_favourites size:wp.gs_container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    labelBearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    labelCompass.text = [Coordinates bearing2compass:bearing];
    labelDistance.text = [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];
    labelStateCountry.text = [wp makeLocaleStateCountry];

    labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        labelSize.hidden = NO;
        imageViewSize.hidden = YES;
    } else {
        labelSize.hidden = YES;
        imageViewSize.hidden = NO;
    }

    [self viewWillTransitionToSize];
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + FAVOURITES_HEIGHT_IMAGE + SIZE_HEIGHT_IMAGE + 2 * RATING_HEIGHT;
}

@end
