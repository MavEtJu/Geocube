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

@interface MapCache ()

@end

@implementation MapCache

+ (NSString *)createPrefix:(NSString *)prefix;
{
    // The cache has moved from files/MapCache/x to MapCache/x
    if ([prefix isEqualToString:@""] == NO) {
        NSString *old = [NSString stringWithFormat:@"%@/MapCache/%@", [MyTools FilesDir], prefix];
        if ([fileManager fileExistsAtPath:old] == YES) {
            if ([fileManager fileExistsAtPath:[MyTools MapCacheDir]] == NO)
                [fileManager createDirectoryAtPath:[MyTools MapCacheDir] withIntermediateDirectories:YES attributes:nil error:nil];
            NSError *e = nil;
            [fileManager moveItemAtPath:old toPath:[NSString stringWithFormat:@"%@/%@", [MyTools MapCacheDir], prefix] error:&e];
        }
    }

    NSMutableString *p = [NSMutableString stringWithString:[MyTools MapCacheDir]];
    if ([prefix isEqualToString:@""] == NO)
        [p appendFormat:@"/%@", prefix];
    if ([fileManager fileExistsAtPath:p] == NO)
        [fileManager createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];

    if ([prefix isEqualToString:@""] == YES)
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
    NSString *prefix = [MapCache createPrefix:@""];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:prefix];
    NSString *filename;
    NSError *error;
    NSTimeInterval now = time(NULL);
    NSTimeInterval maxtime = configManager.mapcacheMaxAge * 86400;
    NSTimeInterval oldest = now;
    NSInteger totalFileSize = 0;
    NSInteger filesize;
    NSInteger checked = 0, deletedAge = 0, deletedSize = 0;
    MyClock *clock = [[MyClock alloc] initClock:@"cleanupCacheBackground"];

    [clock clockEnable:YES];
    [clock clockShowAndReset:@"start"];

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
            if ([[dict objectForKey:NSFileModificationDate] timeIntervalSince1970] < oldest) {
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

    [clock clockShowAndReset:@"finished"];
    NSLog(@"%@ - Checked %ld tiles in %ld Mb, deleted %ld tiles for age, deleted %ld tiles for size", [self class], (long)checked, (long)totalFileSize / (1024 * 1024), (long)deletedAge, (long)deletedSize);
}

+ (NSString *)cacheFileForTile:(NSString *)prefix z:(NSInteger)z x:(NSInteger)x y:(NSInteger)y
{
    return [NSString stringWithFormat:@"%@/%d/%d/%d/tile_%ld_%ld_%ld", prefix, (int)z, (int)y % 10, (int)x % 10, (long)z, (long)y, (long)x];
}

+ (NSString *)templateToString:(NSString *)t z:(NSInteger)z x:(NSInteger)x y:(NSInteger)y
{
    NSString *s = [NSString stringWithString:t];
    s = [s stringByReplacingOccurrencesOfString:@"{x}" withString:@"%ld"];
    s = [NSString stringWithFormat:s, x];
    s = [s stringByReplacingOccurrencesOfString:@"{y}" withString:@"%ld"];
    s = [NSString stringWithFormat:s, y];
    s = [s stringByReplacingOccurrencesOfString:@"{z}" withString:@"%ld"];
    s = [NSString stringWithFormat:s, z];
    return s;
}

@end
