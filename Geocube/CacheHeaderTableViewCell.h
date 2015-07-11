//
//  CacheHeaderTableViewCell.h
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CacheHeaderTableViewCell : UITableViewCell {
    UIImageView *icon, *imgFavouritesIV;
    UILabel *lat, *lon;
    UIImageView *size;
    UIImageView *ratingD[5];
    UIImageView *ratingT[5];
    UILabel *favourites;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgFavourites;
}

@property (nonatomic, retain)UIImageView *icon;
@property (nonatomic, retain)UIImageView *size;
@property (nonatomic, retain)UILabel *lat;
@property (nonatomic, retain)UILabel *lon;
@property (nonatomic, retain)UILabel *favourites;

+ (NSInteger)cellHeight;
- (NSInteger)cellHeight;
- (void)setRatings:(NSInteger)favourites terrain:(float)t difficulty:(float)v;

@end
