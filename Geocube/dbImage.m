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

#import "Geocube-Prefix.pch"

@implementation dbImage

@synthesize url, name, datafile;

- (id)init:(NSString *)_url name:(NSString *)_name datafile:(NSString *)_datafile
{
    self = [super init];

    url = _url;
    datafile = _datafile;
    name = _name;

    [self finish];

    return self;
}

+ (NSId)dbCreate:(dbImage *)img
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into images(url, datafile, filename) values(?, ?, ?)");

        SET_VAR_TEXT( 1, img.url);
        SET_VAR_TEXT( 2, img.datafile);
        SET_VAR_TEXT( 3, img.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    img._id = _id;
    return _id;
}

+ (NSArray *)dbAll:(NSId)_wp_id
{
    NSMutableArray *is = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, url, datafile, filename from images");

        DB_WHILE_STEP {
            dbImage *i = [[dbImage alloc] init];;
            INT_FETCH(  0, i._id);
            TEXT_FETCH( 1, i.url);
            TEXT_FETCH( 2, i.datafile);
            TEXT_FETCH( 3, i.name);
            [i finish];
            [is addObject:i];
        }
        DB_FINISH;
    }
    return is;
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id type:(NSInteger)type
{
    NSMutableArray *is = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, url, datafile, filename from images where id in (select image_id from image2waypoint where waypoint_id = ? and type = ?)");

        SET_VAR_INT(1, wp_id);
        SET_VAR_INT(2, type);

        DB_WHILE_STEP {
            dbImage *i = [[dbImage alloc] init];;
            INT_FETCH(  0, i._id);
            TEXT_FETCH( 1, i.url);
            TEXT_FETCH( 2, i.datafile);
            TEXT_FETCH( 3, i.name);
            [i finish];
            [is addObject:i];
        }
        DB_FINISH;
    }
    return is;
}

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

+ (dbImage *)dbGetByURL:(NSString *)url
{
    dbImage *img;

    @synchronized (db.dbaccess) {
        DB_PREPARE(@"select id, url, datafile, filename from images where url = ?");

        SET_VAR_TEXT(1, url);
        DB_IF_STEP {
            img = [[dbImage alloc] init];
            INT_FETCH(0, img._id);
            TEXT_FETCH(1, img.url);
            TEXT_FETCH(2, img.datafile);
            TEXT_FETCH(3, img.name);
        }
        DB_FINISH;
    }
    return img;
}

- (BOOL)dbLinkedtoWaypoint:(NSId)wp_id
{
    BOOL linked = NO;
    @synchronized (db.dbaccess) {
        DB_PREPARE(@"select id from image2waypoint where waypoint_id = ? and image_id = ?");

        SET_VAR_INT(1, wp_id);
        SET_VAR_INT(2, _id);

        DB_IF_STEP {
            linked = YES;
        }
        DB_FINISH;
    }
    return linked;
}

- (void)dbLinkToWaypoint:(NSId)wp_id type:(NSInteger)type
{
    @synchronized (db.dbaccess) {
        DB_PREPARE(@"insert into image2waypoint(image_id, waypoint_id, type) values(?, ?, ?)");

        SET_VAR_INT(1, _id);
        SET_VAR_INT(2, wp_id);
        SET_VAR_INT(3, type);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger linked = 0;
    @synchronized (db.dbaccess) {
        DB_PREPARE(@"select count(id) from image2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_IF_STEP {
            INT_FETCH(0, linked);
        }
        DB_FINISH;
    }
    return linked;
}

- (UIImage *)imageGet
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], datafile]];
}

+ (NSString *)filename:(NSString *)url
{
    return [url lastPathComponent];
}

- (void)dbUnlinkFromWaypoint:(NSId)wp_id
{
    @synchronized (db.dbaccess) {
        DB_PREPARE(@"delete from image2waypoint where waypoint_id = ? and image_id = ?");

        SET_VAR_INT(1, wp_id);
        SET_VAR_INT(2, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
