//
//  WaypointTableViewCell.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation WaypointTableViewCell

@synthesize description, name, favourites, icon, stateCountry, bearing, compass, distance;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    NSInteger height = [self cellHeight];

    imgRatingOff = [imageLibrary get:ImageWaypointView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageWaypointView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageWaypointView_ratingHalf];
    imgFavourites = [imageLibrary get:ImageWaypointView_favourites];

    UILabel *l;
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
    CGRect rectRatingsD = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectRatingsT = CGRectMake(width - 2 * BORDER - 5 * STAR_WIDTH, BORDER + FAVOURITES_HEIGHT + STAR_HEIGHT, 5 * STAR_WIDTH, STAR_HEIGHT);
    CGRect rectBearing = CGRectMake(BORDER, height - BORDER - 2 * BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    CGRect rectCompass = CGRectMake(BORDER, height - BORDER - BEARING_HEIGHT, ICON_WIDTH, BEARING_HEIGHT);
    CGRect rectDistance = CGRectMake(BORDER + ICON_WIDTH, height - DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingsT.size.width, DISTANCE_HEIGHT);
    CGRect rectStateCountry = CGRectMake(BORDER + ICON_WIDTH, height - 2 * DISTANCE_HEIGHT - BORDER, width - 2 * BORDER - ICON_WIDTH - rectRatingsD.size.width, DISTANCE_HEIGHT);
    // Icon
    icon = [[UIImageView alloc] initWithFrame:rectIcon];
    icon.image = [imageLibrary get:ImageCaches_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:icon];
    
    // Description
    description = [[UILabel alloc] initWithFrame:rectDescription];
    description.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:description];
    
    // Name
    name = [[UILabel alloc] initWithFrame:rectName];
    name.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:name];
    
    // Bearing
    bearing = [[UILabel alloc] initWithFrame:rectBearing];
    bearing.font = [UIFont systemFontOfSize:10.0];
    bearing.textAlignment = NSTextAlignmentCenter;
    //bearing.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:bearing];
    
    // Compass
    compass = [[UILabel alloc] initWithFrame:rectCompass];
    compass.font = [UIFont systemFontOfSize:10.0];
    compass.textAlignment = NSTextAlignmentCenter;
    //compass.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:compass];
    
    // State country
    stateCountry = [[UILabel alloc] initWithFrame:rectStateCountry];
    stateCountry.font = [UIFont systemFontOfSize:10];
    //stateCountry.backgroundColor = [UIColor purpleColor];
    [self.contentView addSubview:stateCountry];
    
    // Distance
    distance = [[UILabel alloc] initWithFrame:rectDistance];
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
    favourites = [[UILabel alloc] initWithFrame:r];
    favourites.font = [UIFont boldSystemFontOfSize:10];
    favourites.textColor = [UIColor whiteColor];
    favourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:favourites];

    // Difficulty rating
    r = rectRatingsD;
    r.origin.x -= 10;
    l = [[UILabel alloc] initWithFrame:r];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"D";
    [self.contentView addSubview:l];

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
    l = [[UILabel alloc] initWithFrame:r];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"T";
    [self.contentView addSubview:l];

    r = rectRatingsT;
    r.size.width = STAR_WIDTH;
    for (NSInteger i = 0; i < 5; i++) {
        ratingT[i] = [[UIImageView alloc] initWithFrame:r];
        ratingT[i].image = imgRatingOff;
        [self.contentView addSubview:ratingT[i]];
        r.origin.x += STAR_WIDTH;
    }

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
        favourites.text = [NSString stringWithFormat:@"%ld", favs];
        imgFavouritesIV.hidden = FALSE;
    }
}

+ (NSInteger)cellHeight
{
    return BORDER * 2 + FAVOURITES_HEIGHT + STAR_HEIGHT * 2;
}

- (NSInteger)cellHeight
{
    return BORDER * 2 + FAVOURITES_HEIGHT + STAR_HEIGHT * 2;
}

@end
