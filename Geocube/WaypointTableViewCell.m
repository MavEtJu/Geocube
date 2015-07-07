//
//  WaypointTableViewCell.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "WaypointTableViewCell.h"
#import "My Tools.h"
#import "Geocube.h"
#import "ImageLibrary.h"

@implementation WaypointTableViewCell

@synthesize description, name;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;

    imgRatingOff = [imageLibrary get:ImageWaypointView_ratingOff];
    imgRatingOn = [imageLibrary get:ImageWaypointView_ratingOn];
    imgRatingHalf = [imageLibrary get:ImageWaypointView_ratingHalf];
    imgFavourites = [imageLibrary get:ImageWaypointView_favourites];

    UILabel *l;
    UIImageView *iv;
    
    // Description
    description = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width - 20 - 10 * 5 - 10 - 20, 16)];
    description.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:description];
    
    // Name
    name = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, width - 20 - 10 * 5 - 10 - 20 , 12)];
    name.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:name];

    // Favourites
    iv = [[UIImageView alloc] initWithFrame:CGRectMake(width - 20, 0, 20, 30)];
    iv.image = imgFavourites;
    [self.contentView addSubview:iv];
    favourites = [[UILabel alloc] initWithFrame:CGRectMake(width - 20, 0, 20, 20)];
    favourites.text = @"12";
    favourites.font = [UIFont systemFontOfSize:8];
    favourites.textColor = [UIColor whiteColor];
    favourites.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:favourites];

    // Difficulty rating
    l = [[UILabel alloc] initWithFrame:CGRectMake(width - 20 - 20 * 5 - 10, 0, 19, 18)];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"D";
    [self.contentView addSubview:l];

    CGRect r = CGRectMake(width - 20 - 20 * 5, 0, 19, 18);
    for (NSInteger i = 0; i < 5; i++) {
        ratingD[i] = [[UIImageView alloc] initWithFrame:r];
        ratingD[i].image = imgRatingOff;
        [self.contentView addSubview:ratingD[i]];
        r.origin.x += 20;
    }

    // Terrain rating
    l = [[UILabel alloc] initWithFrame:CGRectMake(width - 20 - 20 * 5 - 10, 12, 19, 18)];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"T";
    [self.contentView addSubview:l];

    r = CGRectMake(width - 20 - 20 * 5, 12, 19, 18);
    for (NSInteger i = 0; i < 5; i++) {
        ratingT[i] = [[UIImageView alloc] initWithFrame:r];
        ratingT[i].image = imgRatingOff;
        [self.contentView addSubview:ratingT[i]];
        r.origin.x += 20;
    }

    return self;
}

- (void)setRating:(NSInteger)t difficulty:(NSInteger)d
{
    for (NSInteger i = 0; i < t; i += 2)
        ratingT[i / 2].image = imgRatingOn;
    if (t % 2 == 1)
        ratingT[t / 2].image = imgRatingHalf;
    
    for (NSInteger i = 0; i < d; i += 2)
        ratingD[i / 2].image = imgRatingOn;
    if (d % 2 == 1)
        ratingD[d / 2].image = imgRatingHalf;
}

+ (NSInteger)cellHeight
{
    return 30;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
