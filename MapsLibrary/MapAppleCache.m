/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSString *shortprefix;
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSDate *now;

@end

@implementation MapAppleCache

- (instancetype)initWithURLTemplate:(NSString *)template prefix:(NSString *)prefix
{
    self = [super initWithURLTemplate:template];

    self.shortprefix = prefix;
    self.prefix = [MapCache createPrefix:prefix];
    self.hits = 0;
    self.misses = 0;
    self.saves = 0;
    self.now = [NSDate date];    // Just give them all todays date

    return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path
{
    NSURL *url = [super URLForTilePath:path];
    return url;
}

- (void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result
{
    NSString *cachefile = [NSString stringWithFormat:@"%@/%d/%d/%d/tile_%ld_%ld_%ld", self.prefix, (int)path.z, (int)path.y % 10, (int)path.x % 10, (long)path.z, (long)path.y, (long)path.x];

    if (configManager.mapcacheEnable == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            result(tileData, error);
        }];
        return;
    }

    if ([fileManager fileExistsAtPath:cachefile] == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            if (error == nil) {
                NSString *s = [[NSString alloc] initWithData:tileData encoding:NSUTF8StringEncoding];
                if ([s containsString:@"404 Not Found"] == YES) {
                    NSLog(@"Tile (%ld, %ld, %ld) not found", (long)path.z, (long)path.y, (long)path.x);
                    tileData = nil;
                    self.notfounds++;
                } else {
                    [tileData writeToFile:cachefile atomically:NO];
                    NSLog(@"Saving %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)path.z, (long)path.y, (long)path.x);
                    self.saves++;
                }
            }
            self.misses++;
            result(tileData, error);
        }];
        return;
    }

    // Mark as used
    NSDictionary *modificationDateAttr = [NSDictionary dictionaryWithObjectsAndKeys:self.now, NSFileModificationDate, nil];
    NSError *err = nil;
    [fileManager setAttributes:modificationDateAttr ofItemAtPath:cachefile error:&err];

    // Load contents
    __block NSData *d = [NSData dataWithContentsOfFile:cachefile];
    NSLog(@"Loading %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)path.z, (long)path.y, (long)path.x);
    self.hits++;
    result(d, nil);
}

@end
