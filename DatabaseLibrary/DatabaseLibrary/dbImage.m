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

#import "dbImage.h"

#import <CommonCrypto/CommonDigest.h>
#import <ToolsLibrary/MyTools.h>

#import "Geocube-Globals.h"
#import "dbWaypoint.h"

@interface dbImage ()

@end

@implementation dbImage

TABLENAME(@"images")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into images(url, datafile, filename, lat, lon) values(?, ?, ?, ?, ?)");

        SET_VAR_TEXT  (1, self.url);
        SET_VAR_TEXT  (2, self.datafile);
        SET_VAR_TEXT  (3, self.name);
        SET_VAR_DOUBLE(4, self.lat);
        SET_VAR_DOUBLE(5, self.lon);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

+ (NSArray<dbImage *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbImage *> *is = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, url, datafile, filename, lat, lon from images "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbImage *i = [[dbImage alloc] init];
            INT_FETCH   (0, i._id);
            TEXT_FETCH  (1, i.url);
            TEXT_FETCH  (2, i.datafile);
            TEXT_FETCH  (3, i.name);
            DOUBLE_FETCH(4, i.lat);
            DOUBLE_FETCH(5, i.lon);
            [i finish];
            [is addObject:i];
        }
        DB_FINISH;
    }
    return is;
}

+ (NSArray<dbImage *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbImage *> *)dbAllByWaypoint:(dbWaypoint *)wp type:(ImageCategory)type
{
    return [self dbAllXXX:@"where id in (select image_id from image2waypoint where waypoint_id = ? and type = ?)" keys:@"ii" values:@[[NSNumber numberWithId:wp._id], [NSNumber numberWithInteger:type]]];
}

+ (dbImage *)dbGetByURL:(NSString *)url
{
    return [[self dbAllXXX:@"where url = ?" keys:@"s" values:@[url]] firstObject];
}

/* Other methods */

+ (NSString *)createDataFilename:(NSString *)url
{
    // Create pointer to the string as UTF8
    const char *ptr = [url UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];

    return output;
}

- (BOOL)dbLinkedtoWaypoint:(dbWaypoint *)wp
{
    BOOL linked = NO;
    @synchronized (db) {
        DB_PREPARE(@"select id from image2waypoint where waypoint_id = ? and image_id = ?");

        SET_VAR_INT(1, wp._id);
        SET_VAR_INT(2, self._id);

        DB_IF_STEP {
            linked = YES;
        }
        DB_FINISH;
    }
    return linked;
}

- (void)dbLinkToWaypoint:(dbWaypoint *)wp type:(ImageCategory)type
{
    @synchronized (db) {
        DB_PREPARE(@"insert into image2waypoint(image_id, waypoint_id, type) values(?, ?, ?)");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, wp._id);
        SET_VAR_INT(3, type);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp type:(ImageCategory)type
{
    NSInteger linked = 0;
    @synchronized (db) {
        DB_PREPARE(@"select count(id) from image2waypoint where waypoint_id = ? and type = ?");

        SET_VAR_INT(1, wp._id);
        SET_VAR_INT(2, type);

        DB_IF_STEP {
            INT_FETCH(0, linked);
        }
        DB_FINISH;
    }
    return linked;
}

+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp
{
    NSInteger linked = 0;
    @synchronized (db) {
        DB_PREPARE(@"select count(id) from image2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_IF_STEP {
            INT_FETCH(0, linked);
        }
        DB_FINISH;
    }
    return linked;
}

- (UIImage *)imageGet
{
    return [UIImage imageWithContentsOfFile:[MyTools ImageFile:self.datafile]];
}

+ (NSString *)filename:(NSString *)url
{
    return [url lastPathComponent];
}

- (void)dbUnlinkFromWaypoint:(dbWaypoint *)wp
{
    @synchronized (db) {
        DB_PREPARE(@"delete from image2waypoint where waypoint_id = ? and image_id = ?");

        SET_VAR_INT(1, wp._id);
        SET_VAR_INT(2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbUnlinkFromWaypoint:(dbWaypoint *)wp
{
    @synchronized (db) {
        DB_PREPARE(@"delete from image2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (BOOL)imageHasBeenDowloaded
{
    return [fileManager fileExistsAtPath:[MyTools ImageFile:self.datafile]];
}

@end
