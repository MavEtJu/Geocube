//
//  MapTemplateViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

enum {
    SHOW_ONECACHE,
    SHOW_ALLCACHES
};

@interface MapTemplateViewController : GCViewController {
    NSArray *caches;
    dbCache *thatCache;
    NSInteger cacheCount;

    NSInteger type;     /* SHOW_ONECACHE | SHOW_ALLCACHES */
}

- (id)init:(NSInteger)type;
- (void)refreshCachesData:(NSString *)searchString;
- (void)whichCachesToSnow:(NSInteger)type whichCache:(dbCache *)cache;

- (void)showCache;
- (void)showMe;
- (void)showCacheAndMe;

@end
