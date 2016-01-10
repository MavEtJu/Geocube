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
}

@end

@implementation MapCache

- (instancetype)initWithURLTemplate:(NSString *)template prefix:(NSString *)_prefix
{
    self = [super initWithURLTemplate:template];

    shortprefix = _prefix;
    prefix = [NSString stringWithFormat:@"%@/MapCache/%@", [MyTools FilesDir], _prefix];
    if ([fm fileExistsAtPath:prefix] == NO)
        [fm createDirectoryAtPath:prefix withIntermediateDirectories:YES attributes:nil error:nil];

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
    __block NSData *d;
    __block NSError *e = nil;

    if ([fm fileExistsAtPath:cachefile] == NO) {
        [super loadTileAtPath:path result:^(NSData *tileData, NSError *error) {
            [tileData writeToFile:cachefile atomically:NO];
            d = [NSData dataWithData:tileData];
            e = error;
            NSLog(@"Saving %@ tile (%ld, %ld, %ld)", shortprefix, path.z, path.y, path.x);
            result(tileData, error);
        }];
        return;
    }

    d = [NSData dataWithContentsOfFile:cachefile];
    NSLog(@"Loading %@ tile (%ld, %ld, %ld)", shortprefix, path.z, path.y, path.x);
    result(d, e);
}

@end
