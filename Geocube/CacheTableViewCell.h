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

@interface CacheTableViewCell : UITableViewCell {
    UILabel *description;
    UILabel *name;
    UIImageView *size;
    UIImageView *ratingD;
    UIImageView *ratingT;
    UILabel *favourites;
    UIImage *imgRatingOff, *imgRatingOn, *imgRatingHalf, *imgRatingBase, *imgFavourites, *imgSize;
    UIImageView *icon, *imgFavouritesIV;
    UILabel *stateCountry;
    UILabel *bearing;
    UILabel *compass;
    UILabel *distance;
}

@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *country;
@property (nonatomic, retain) UILabel *stateCountry;
@property (nonatomic, retain) UILabel *bearing;
@property (nonatomic, retain) UILabel *compass;
@property (nonatomic, retain) UILabel *distance;


- (NSInteger)cellHeight;
+ (NSInteger)cellHeight;
- (void)setRatings:(NSInteger)favourites terrain:(float)t difficulty:(float)v size:(NSInteger)sz;

@end


