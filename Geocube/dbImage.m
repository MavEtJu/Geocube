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

@synthesize url, datafile;

- (id)init:(NSString *)_url datafile:(NSString *)_datafile
{
    self = [super init];

    url = _url;
    datafile = _datafile;

    [self finish];

    return self;
}

+ (NSId)dbCreate:(dbImage *)img
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into images(url, datafile) values(?, ?)");

        SET_VAR_TEXT( 1, img.url);
        SET_VAR_TEXT( 2, img.datafile);

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
        DB_PREPARE(@"select id, url, datafile from images");

        DB_WHILE_STEP {
            dbImage *i = [[dbImage alloc] init];;
            INT_FETCH(  0, i._id);
            TEXT_FETCH( 1, i.url);
            TEXT_FETCH( 2, i.datafile);
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
        DB_PREPARE(@"select id, url, datafile from images where url = ?");

        SET_VAR_TEXT(1, url);
        DB_IF_STEP {
            img = [[dbImage alloc] init];
            INT_FETCH(0, img._id);
            TEXT_FETCH(1, img.url);
            TEXT_FETCH(2, img.datafile);
        }
        DB_FINISH;
    }
    return img;
}

@end
