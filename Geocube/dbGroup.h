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

@interface dbGroup: dbObject {
    NSString *name;
    BOOL usergroup;

    /* Not read from the database */
    BOOL selected;
}

- (id)init:(NSId)_id name:(NSString *)name usergroup:(BOOL)usergroup;

@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL usergroup;
@property (nonatomic) BOOL selected;

- (void)dbEmpty;
+ (NSArray *)dbAllByWaypoint:(NSId)wp_id;
+ (NSMutableArray *)dbAll;
+ (dbGroup *)dbGetByName:(NSString *)name;
+ (void)dbDelete:(NSId)__id;
- (void)dbUpdateName:(NSString *)newname;
- (void)dbAddWaypoint:(NSId)__id;
- (void)dbAddWaypoints:(NSArray *)waypoints;
- (void)dbRemoveWaypoint:(NSId)__id;
- (BOOL)dbContainsWaypoint:(NSId)c_id;
- (NSInteger)dbCountWaypoints;
+ (NSId)dbCreate:(NSString *)name isUser:(BOOL)isUser;


@end
