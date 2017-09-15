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

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageCategory) {
    IMAGECATEGORY_NONE = 0,
    IMAGECATEGORY_LOG = 1,
    IMAGECATEGORY_CACHE = 2,
    IMAGECATEGORY_USER = 3,
};

@interface dbImage : dbObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *datafile;
@property (nonatomic) CLLocationDegrees lat;
@property (nonatomic) CLLocationDegrees lon;

+ (NSString *)createDataFilename:(NSString *)url;
+ (dbImage *)dbGetByURL:(NSString *)url;
- (BOOL)dbLinkedtoWaypoint:(dbWaypoint *)wp;
- (void)dbLinkToWaypoint:(dbWaypoint *)wp type:(ImageCategory)type;
+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wpid;
+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp type:(ImageCategory)type;
+ (NSArray<dbImage *> *)dbAllByWaypoint:(dbWaypoint *)wp type:(ImageCategory)type;
- (BOOL)imageHasBeenDowloaded;
- (UIImage *)imageGet;
+ (NSString *)filename:(NSString *)url;
- (void)dbUnlinkFromWaypoint:(dbWaypoint *)wp;
+ (void)dbUnlinkFromWaypoint:(dbWaypoint *)wp;

@end
