//
//  WaypointTableViewCell.h
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaypointTableViewCell : UITableViewCell {
    UILabel *description;
    UILabel *name;
    UIImageView *ratingD[5];
    UIImageView *ratingT[5];
    UILabel *favourites;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgFavourites;
    UIImageView *icon;
    UILabel *country, *state;
}

@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *favourites;
@property (nonatomic, retain) UILabel *country;
@property (nonatomic, retain) UILabel *state;


+ (NSInteger)cellHeight;
- (void)setRating:(NSInteger)t difficulty:(NSInteger)v;

@end


