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
    UIImageView *icon, *imgFavouritesIV;
    UILabel *stateCountry;
    UILabel *bearing;
    UILabel *compass;
    UILabel *distance;
}

@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *favourites;
@property (nonatomic, retain) UILabel *country;
@property (nonatomic, retain) UILabel *stateCountry;
@property (nonatomic, retain) UILabel *bearing;
@property (nonatomic, retain) UILabel *compass;
@property (nonatomic, retain) UILabel *distance;


- (NSInteger)cellHeight;
+ (NSInteger)cellHeight;
- (void)setRatings:(NSInteger)favourites terrain:(float)t difficulty:(float)v;

@end


