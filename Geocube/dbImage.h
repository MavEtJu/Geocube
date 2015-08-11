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

enum ImageTypes {
    IMAGETYPE_NONE = 0,
    IMAGETYPE_LOG = 1,
    IMAGETYPE_CACHE = 2,
    IMAGETYPE_USER = 3,
};

@interface dbImage : dbObject {
    NSString *url;
    NSString *name;
    NSString *datafile;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *datafile;

- (id)init:(NSString *)url name:(NSString *)name datafile:(NSString *)datafile;
+ (NSString *)createDataFilename:(NSString *)url;
+ (dbImage *)dbGetByURL:(NSString *)url;
+ (NSId)dbCreate:(dbImage *)img;
- (BOOL)dbLinkedtoWaypoint:(NSId)wp_id;
- (void)dbLinkToWaypoint:(NSId)wp_id type:(NSInteger)type;
+ (NSInteger)dbCountByWaypoint:(NSId)wp_id;
+ (NSArray *)dbAllByWaypoint:(NSId)wp_id type:(NSInteger)type;
- (UIImage *)imageGet;
+ (NSString *)filename:(NSString *)url;

@end
