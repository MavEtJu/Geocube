/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface MapGoogleCache ()

@property (nonatomic, retain) NSString *shortprefix;
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *tileServerTemplate;
@property (nonatomic, retain) NSDate *now;

@end

@implementation MapGoogleCache

- (instancetype)initWithPrefix:(NSString *)cachePrefix tileServerTemplate:(NSString *)tileServerTemplate
{
    self = [super init];

    self.shortprefix = cachePrefix;
    self.prefix = [MapCache createPrefix:cachePrefix];
    self.tileServerTemplate = tileServerTemplate;
    self.hits = 0;
    self.misses = 0;
    self.saves = 0;
    self.now = [NSDate date];    // Just give them all todays date

    return self;
}

- (void)requestTileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)z receiver:(id<GMSTileReceiver>)receiver
{
    NSString *cachefile = [NSString stringWithFormat:@"%@/%d/%d/%d/tile_%ld_%ld_%ld", self.prefix, (int)z, (int)y % 10, (int)x % 10, (long)z, (long)y, (long)x];

    if (configManager.mapcacheEnable == NO) {
        [receiver receiveTileWithX:x y:y zoom:z image:kGMSTileLayerNoTile];
        return;
    }

    if ([fileManager fileExistsAtPath:cachefile] == NO) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:self.tileServerTemplate, z, x, y]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

                                   UIImage *img = [UIImage imageWithData:data];
                                   if (error != nil) {
                                       NSLog(@"Error downloading tile! \n");
                                       img = kGMSTileLayerNoTile;
                                       self.notfounds++;
                                   } else {
                                       NSLog(@"Saving %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)z, (long)y, (long)x);
                                       [data writeToFile:cachefile atomically:YES];
                                       img = [UIImage imageWithData:data];
                                       self.saves++;
                                   }
                                   self.misses++;
                                   [receiver receiveTileWithX:x y:y zoom:z image:img];
                               }];
        return;
    }

    // Mark as used
    NSDictionary *modificationDateAttr = [NSDictionary dictionaryWithObjectsAndKeys:self.now, NSFileModificationDate, nil];
    NSError *err = nil;
    [fileManager setAttributes:modificationDateAttr ofItemAtPath:cachefile error:&err];

    // Load from cache
    NSLog(@"Loading %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)z, (long)y, (long)x);
    NSData *d = [NSData dataWithContentsOfFile:cachefile];
    UIImage *img = [UIImage imageWithData:d];
    self.hits++;
    [receiver receiveTileWithX:x y:y zoom:z image:img];
}

@end
