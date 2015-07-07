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
}

@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *name;

+ (NSInteger)cellHeight;
- (void)setRating:(NSInteger)t difficulty:(NSInteger)v;

@end


