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

#ifndef Geocube_dbWaypointGroup_h
#define Geocube_dbWaypointGroup_h

@interface dbCacheGroup: dbObject {
    NSString *name;
    BOOL usergroup;
}

- (id)init:(NSId)_id name:(NSString *)name usergroup:(BOOL)usergroup;

@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL usergroup;

- (void)dbEmpty;
+ (NSArray *)dbAllByCache:(NSId)wp_id;
+ (NSMutableArray *)dbAll;
+ (dbCacheGroup *)dbGetByName:(NSString *)name;
- (void)dbDelete;
+ (void)dbDelete:(NSId)__id;
- (void)dbUpdateName:(NSString *)newname;
- (void)dbAddCache:(NSId)__id;
- (BOOL)dbContainsCache:(NSId)c_id;
- (NSInteger)dbCountCaches;
+ (NSId)dbCreate:(NSString *)name isUser:(BOOL)isUser;


@end

#endif
