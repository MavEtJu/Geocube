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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

enum {
    SHOW_ONECACHE,
    SHOW_ALLCACHES,

    SHOW_NEITHER,
    SHOW_CACHE,
    SHOW_ME,
    SHOW_BOTH,
};

@interface MapTemplateViewController : GCViewController<GCLocationManagerDelegate> {
    NSArray *caches;
    NSInteger cacheCount;

    NSInteger type;     /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */
}

- (id)init:(NSInteger)type;
- (void)refreshCachesData:(NSString *)searchString;
- (void)whichCachesToSnow:(NSInteger)type whichCache:(dbCache *)cache;

- (void)showCache;
- (void)showMe;
- (void)showCacheAndMe;
- (void)showWhom:(NSInteger)whom;
- (void)updateMe;

@end
