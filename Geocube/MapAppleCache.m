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

@interface MapAppleCache ()
{
    NSString *shortprefix;
    NSString *prefix;
    NSDate *now;
}

@end

@implementation MapAppleCache

+ (NSString *)createPrefix:(NSString *)_prefix;
{
    NSString *p = [NSString stringWithFormat:@"%@/MapCache/%@", [MyTools FilesDir], _prefix];
    if ([fileManager fileExistsAtPath:p] == NO)
        [fileManager createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];

    if ([_prefix isEqualToString:@""] == YES)
        return p;

    // The has directories be z, y % 10, x % 10
    for (NSInteger z = 1; z <= 20; z++) {
        for (NSInteger y = 0; y < 10; y++) {
            for (NSInteger x = 0; x < 10; x++) {
                NSString *d = [NSString stringWithFormat:@"%@/%ld/%ld/%ld", p, (long)z, (long)y, (long)x];
                if ([fileManager fileExistsAtPath:d] == NO)
                    [fileManager createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
    }
    return p;
}

+ (void)cleanupCache
{
    [[self class] performSelectorInBackground:@selector(cleanupCacheBackground) withObject:nil];
}

+ (void)cleanupCacheBackground
{
    NSString *prefix = [MapAppleCache createPrefix:@""];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:prefix];
    NSString *filename;
    NSError *error;
    NSTimeInterval now = time(NULL);
    NSTimeInterval maxtime = configManager.mapcacheMaxAge * 86400;
    NSTimeInterval oldest = now;
    NSInteger totalFileSize = 0;
    NSInteger filesize;
    NSInteger checked = 0, deletedAge = 0, deletedSize = 0;

    // Purge the whole cache
    error = nil;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_clearmapcache"] == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_clearmapcache"];

        NSLog(@"%@ - Purging map cache", [self class]);
        while ((filename = [dirEnum nextObject]) != nil) {
            NSString *fullfilename = [NSString stringWithFormat:@"%@%@", prefix, filename];
            [fileManager removeItemAtPath:fullfilename error:&error];
        }
        return;
    }

    // Give the startup phase some time to complete before doing a disk I/O intensive job.
    [NSThread sleepForTimeInterval:5.0];

    /* Clean up objects older than N days */
    while ((filename = [dirEnum nextObject]) != nil) {
        NSString *fullfilename = [NSString stringWithFormat:@"%@/%@", prefix, filename];
        NSDictionary *dict = [fileManager attributesOfItemAtPath:fullfilename error:&error];
        NSDate *date = [dict objectForKey:NSFileModificationDate];

        if ([[dict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            continue;

        checked++;
        if ([date timeIntervalSince1970] - now > maxtime) {
            NSLog(@"%@ - Removing %@", [self class], filename);
            [fileManager removeItemAtPath:fullfilename error:&error];
            deletedAge++;
            continue;
        }

        oldest = MIN([date timeIntervalSince1970], oldest);

        filesize = [[dict objectForKey:NSFileSize] integerValue];
        totalFileSize += filesize;
    }

    /* Clean up objects if size is more than N */
    while (totalFileSize > configManager.mapcacheMaxSize * 1024 * 1024) {
        NSInteger found = 0;
        oldest += 86400;

        dirEnum = [fileManager enumeratorAtPath:prefix];
        while ((filename = [dirEnum nextObject]) != nil) {
            NSString *fullfilename = [NSString stringWithFormat:@"%@/%@", prefix, filename];
            NSDictionary *dict = [fileManager attributesOfItemAtPath:fullfilename error:&error];

            if ([[dict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
                continue;

            found++;
            if ([[dict objectForKey:NSFileModificationDate ] timeIntervalSince1970] < oldest) {
                NSLog(@"%@ - Removing %@", [self class], filename);
                [fileManager removeItemAtPath:fullfilename error:&error];
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
    prefix = [MapAppleCache createPrefix:_prefix];
    self.hits = 0;
    self.misses = 0;
    self.saves = 0;
    now = [NSDate date];    // Just give them all todays date

    return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path
{
    NSURL *url = [super URLForTilePath:path];
    return url;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    NSString *cachefile = [NSString stringWithFormat:@"%@/%d/%d/%d/tile_%ld_%ld_%ld", prefix, (int)path.z, (int)path.y % 10, (int)path.x % 10, (long)path.z, (long)path.y, (long)path.x];

    if (configManager.mapcacheEnable == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            result(tileData, error);
        }];
        return;
    }

    if ([fileManager fileExistsAtPath:cachefile] == NO) {
        NSError *err = nil;

        NSDictionary *modificationDateAttr = [NSDictionary dictionaryWithObjectsAndKeys:now, NSFileModificationDate, nil];
        [fileManager setAttributes:modificationDateAttr ofItemAtPath:cachefile error:&err];

        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            if (error == nil) {
                NSString *s = [[NSString alloc] initWithData:tileData encoding:NSUTF8StringEncoding];
                if ([s containsString:@"404 Not Found"] == YES) {
                    NSLog(@"Tile (%ld, %ld, %ld) not found", (long)path.z, (long)path.y, (long)path.x);
                    tileData = nil;
                    self.notfounds++;
                } else {
                    [tileData writeToFile:cachefile atomically:NO];
                    NSLog(@"Saving %@ tile (%ld, %ld, %ld)", shortprefix, (long)path.z, (long)path.y, (long)path.x);
                    self.saves++;
                }
            }
            self.misses++;
            result(tileData, error);
        }];
        return;
    }

    __block NSData *d = [NSData dataWithContentsOfFile:cachefile];
    NSLog(@"Loading %@ tile (%ld, %ld, %ld)", shortprefix, (long)path.z, (long)path.y, (long)path.x);
    self.hits++;
    result(d, nil);
}

@end
