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

@interface MapCacheGoogle ()

@property (nonatomic, retain) NSString *shortprefix;
@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *tileServerTemplate;
@property (nonatomic, retain) NSDate *now;

@end

@implementation MapCacheGoogle

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

- (UIImage *)loadURL:(NSString *)URLString cacheFile:(NSString *)cachefile receiver:(id<GMSTileReceiver>)receiver x:(NSInteger)x y:(NSInteger)y z:(NSInteger)z cache:(BOOL)cache
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    __block UIImage *img;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {

                               NSHTTPURLResponse *response = (NSHTTPURLResponse *)resp;
                               if (error != nil) {
                                   NSLog(@"Error downloading %@ tile (%ld, %ld, %ld) (%@)\n", self.shortprefix, (long)z, (long)y, (long)x, error.description);
                                   img = kGMSTileLayerNoTile;
                                   self.notfounds++;
                               } else if (response.statusCode != 200) {
                                   NSLog(@"Error downloading %@ tile (%ld, %ld, %ld) (HTTP %ld)\n", self.shortprefix, (long)z, (long)y, (long)x, response.statusCode);
                                   img = kGMSTileLayerNoTile;
                                   self.notfounds++;
                               } else {
                                   img = [UIImage imageWithData:data];
                                   if (img == nil) {
                                       NSLog(@"Error parsing data for %@ tile (%ld, %ld, %ld)\n", self.shortprefix, (long)z, (long)y, (long)x);
                                       img = kGMSTileLayerNoTile;
                                       self.notfounds++;
                                   } else {
                                       if (cache == YES) {
                                           NSLog(@"Saving %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)z, (long)y, (long)x);
                                           [data writeToFile:cachefile atomically:YES];
                                           self.saves++;
                                       } else {
                                           NSLog(@"Serving %@ tile (%ld, %ld, %ld)", self.shortprefix, (long)z, (long)y, (long)x);
                                       }
                                   };
                               }
                               self.misses++;
                               [receiver receiveTileWithX:x y:y zoom:z image:img];
                           }];
    return img;
}

- (void)requestTileForX:(NSUInteger)x y:(NSUInteger)y zoom:(NSUInteger)z receiver:(id<GMSTileReceiver>)receiver
{
    NSString *cachefile = [MapCache cacheFileForTile:self.prefix z:z x:x y:y];

    if (configManager.mapcacheEnable == NO) {
        NSString *URLString = [MapCache templateToString:self.tileServerTemplate z:z x:x y:y];
        [self loadURL:URLString cacheFile:cachefile receiver:receiver x:x y:y z:z cache:NO];
        return;
    }

    if ([fileManager fileExistsAtPath:cachefile] == NO) {
        NSString *URLString = [MapCache templateToString:self.tileServerTemplate z:z x:x y:y];
        [self loadURL:URLString cacheFile:cachefile receiver:receiver x:x y:y z:z cache:YES];
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
