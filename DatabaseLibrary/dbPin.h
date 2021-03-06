/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface dbPin : dbObject

@property (nonatomic, retain) NSString *rgb;
@property (nonatomic, retain) NSString *rgb_default;
@property (nonatomic, retain) NSString *desc;

@property (nonatomic, retain) UIColor *colour;
@property (nonatomic, retain) UIImage *img;
@property (nonatomic        ) BOOL selected;

+ (NSArray<dbPin *> *)dbAll;
+ (dbPin *)getByDescription:(NSString *)desc;
+ (dbPin *)dbGet:(NSId)_id;
- (void)dbUpdateRGB;

@end
