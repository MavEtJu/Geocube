//
//  WaypointTableViewCell.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "WaypointTableViewCell.h"
#import "My Tools.h"

@implementation WaypointTableViewCell

@synthesize description, name;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    NSString *s = [NSString stringWithFormat:@"%@/waypoint rating star off.png", [MyTools DataDistributionDirectory]];
    imgRatingOff = [UIImage imageNamed:s];
    s = [NSString stringWithFormat:@"%@/waypoint rating star on", [MyTools DataDistributionDirectory]];
    imgRatingOn = [UIImage imageNamed:s];
    s = [NSString stringWithFormat:@"%@/waypoint rating star half", [MyTools DataDistributionDirectory]];
    imgRatingHalf = [UIImage imageNamed:s];

    
    UILabel *l;
    
    // Description
    description = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 16)];
    description.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:description];
    
    // Name
    name = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 100, 12)];
    name.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:name];

    // Difficulty rating
    l = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 20, 12)];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"D";
    [self.contentView addSubview:l];

    CGRect r = CGRectMake(220, 0, 10, 10);
    for (NSInteger i = 0; i < 5; i++) {
        ratingD[i] = [[UIImageView alloc] initWithFrame:r];
        ratingD[i].image = imgRatingOff;
        [self.contentView addSubview:ratingD[i]];
        r.origin.x += 10;
    }

    // Terrain rating
    l = [[UILabel alloc] initWithFrame:CGRectMake(200, 12, 20, 12)];
    l.font = [UIFont systemFontOfSize:10.0];
    l.text = @"T";
    [self.contentView addSubview:l];

    r = CGRectMake(220, 12, 10, 10);
    for (NSInteger i = 0; i < 5; i++) {
        ratingT[i] = [[UIImageView alloc] initWithFrame:r];
        ratingT[i].image = imgRatingOff;
        [self.contentView addSubview:ratingT[i]];
        r.origin.x += 10;
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
    return 28;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
