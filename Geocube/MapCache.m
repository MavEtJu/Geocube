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

@interface MapCache ()
{
    NSString *shortprefix;
    NSString *prefix;

    NSInteger hits, misses, saves;
}

@end

@implementation MapCache

@synthesize hits, misses, saves;

+ (NSString *)createPrefix:(NSString *)_prefix;
{
    NSString *p = [NSString stringWithFormat:@"%@/MapCache/%@", [MyTools FilesDir], _prefix];
    if ([fm fileExistsAtPath:p] == NO)
        [fm createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];
    return p;
}

+ (void)cleanupCache
{
    NSString *prefix = [MapCache createPrefix:@""];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:prefix];
    NSString *filename;
    NSError *error;
    NSTimeInterval now = time(NULL);
    NSTimeInterval maxtime = myConfig.mapcacheMaxAge * 86400;
    NSTimeInterval oldest = now;
    NSInteger totalFileSize = 0;
    NSInteger filesize;
    NSInteger checked = 0, deletedAge = 0, deletedSize = 0;;

    /* Clean up objects older than N days */
    while ((filename = [dirEnum nextObject]) != nil) {
        NSString *fullfilename = [NSString stringWithFormat:@"%@/%@", prefix, filename];
        NSDictionary *dict = [fm attributesOfItemAtPath:fullfilename error:&error];
        NSDate *date = [dict objectForKey:NSFileCreationDate];

        if ([[dict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            continue;

        checked++;
        if ([date timeIntervalSince1970] - now > maxtime) {
            NSLog(@"%@ - Removing %@", [self class], filename);
            [fm removeItemAtPath:fullfilename error:&error];
            deletedAge++;
            continue;
        }

        oldest = MIN([date timeIntervalSince1970], oldest);

        filesize = [[dict objectForKey:NSFileSize] integerValue];
        totalFileSize += filesize;
    }

    /* Clean up objects if size is more than N */
    while (totalFileSize > myConfig.mapcacheMaxSize * 1024 * 1024) {
        NSInteger found = 0;
        oldest += 86400;

        dirEnum = [fm enumeratorAtPath:prefix];
        while ((filename = [dirEnum nextObject]) != nil) {
            NSString *fullfilename = [NSString stringWithFormat:@"%@/%@", prefix, filename];
            NSDictionary *dict = [fm attributesOfItemAtPath:fullfilename error:&error];

            if ([[dict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
                continue;

            found++;
            if ([[dict objectForKey:NSFileCreationDate ] timeIntervalSince1970] < oldest) {
                NSLog(@"%@ - Removing %@", [self class], filename);
                [fm removeItemAtPath:fullfilename error:&error];
                deletedSize++;
                totalFileSize -= [[dict objectForKey:@"NSFileSize"] integerValue];
                continue;
            }
        }

        // If there are no files left, stop it.
        if (found == 0)
            break;
   }

    NSLog(@"%@ - Checked %ld tiles in %ld Mb, deleted %ld tiles for age, deleted %ld tiles for size", [self class], (long)checked, (long)totalFileSize / (1024 * 1024), (long)deletedAge, (long)deletedSize);
}

- (instancetype)initWithURLTemplate:(NSString *)template prefix:(NSString *)_prefix
{
    self = [super initWithURLTemplate:template];

    shortprefix = _prefix;
    prefix = [MapCache createPrefix:_prefix];
    hits = 0;
    misses = 0;
    saves = 0;

    return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path
{
    NSURL *url = [super URLForTilePath:path];
    return url;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    NSString *cachefile = [NSString stringWithFormat:@"%@/tile_%ld_%ld_%ld", prefix, (long)path.z, (long)path.y, (long)path.x];

    if (myConfig.mapcacheEnable == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            result(tileData, error);
        }];
        return;
    }

    if ([fm fileExistsAtPath:cachefile] == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            if (error == nil) {
                [tileData writeToFile:cachefile atomically:NO];
                NSLog(@"Saving %@ tile (%ld, %ld, %ld)", shortprefix, (long)path.z, (long)path.y, (long)path.x);
                saves++;
            }
            misses++;
            result(tileData, error);
        }];
        return;
    }

    __block NSData *d = [NSData dataWithContentsOfFile:cachefile];
    NSLog(@"Loading %@ tile (%ld, %ld, %ld)", shortprefix, (long)path.z, (long)path.y, (long)path.x);
    hits++;
    result(d, nil);
}

@end
