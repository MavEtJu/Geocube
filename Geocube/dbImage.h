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

- (instancetype)init:(NSString *)url name:(NSString *)name datafile:(NSString *)datafile;
+ (NSString *)createDataFilename:(NSString *)url;
+ (dbImage *)dbGetByURL:(NSString *)url;
+ (NSId)dbCreate:(dbImage *)img;
- (BOOL)dbLinkedtoWaypoint:(NSId)wp_id;
- (void)dbLinkToWaypoint:(NSId)wp_id type:(ImageCategory)type;
+ (NSInteger)dbCountByWaypoint:(NSId)wp_id;
+ (NSInteger)dbCountByWaypoint:(NSId)wp_id type:(ImageCategory)type;
+ (NSArray *)dbAllByWaypoint:(NSId)wp_id type:(ImageCategory)type;
- (BOOL)imageHasBeenDowloaded;
- (UIImage *)imageGet;
+ (NSString *)filename:(NSString *)url;
- (void)dbUnlinkFromWaypoint:(NSId)wp_id;

@end
