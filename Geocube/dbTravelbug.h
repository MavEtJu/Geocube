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

@interface dbTravelbug : dbObject {
    NSInteger _id;
    NSString *name;
    NSString *ref;
    NSInteger gc_id;
};

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *ref;
@property (nonatomic) NSInteger gc_id;

+ (void)dbUnlinkAllFromCache:(NSInteger)wp_id;
- (void)dbLinkToCache:(NSInteger)wp_id;
+ (NSInteger)dbGetIdByGC:(NSInteger)_gc_id;
+ (NSInteger)dbCreate:(dbTravelbug *)tb;
- (NSInteger)dbCreate;
+ (NSInteger)dbCountByCache:(NSInteger)wp_id;

@end
