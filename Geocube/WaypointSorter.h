/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

typedef NS_ENUM(NSInteger, SortOrder) {
    SORTORDER_DISTANCE_ASC = 0,
    SORTORDER_DISTANCE_DESC,
    SORTORDER_DIRECTION_ASC,
    SORTORDER_DIRECTION_DESC,
    SORTORDER_TYPE,
    SORTORDER_CONTAINER,
    SORTORDER_FAVOURITES_ASC,
    SORTORDER_FAVOURITES_DESC,
    SORTORDER_TERRAIN_ASC,
    SORTORDER_TERRAIN_DESC,
    SORTORDER_DIFFICULTY_ASC,
    SORTORDER_DIFFICULTY_DESC,
    SORTORDER_NAME_ASC,
    SORTORDER_NAME_DESC,
    SORTORDER_CODE_ASC,
    SORTORDER_CODE_DESC,
    SORTORDER_DATE_FOUND_OLDESTFIRST,
    SORTORDER_DATE_FOUND_NEWESTFIRST,
    SORTORDER_DATE_LASTLOG_OLDESTFIRST,
    SORTORDER_DATE_LASTLOG_NEWESTFIRST,
    SORTORDER_DATE_HIDDEN_OLDESTFIRST,
    SORTORDER_DATE_HIDDEN_NEWESTFIRST,
    SORTORDER_MAX,
};

@interface WaypointSorter : NSObject

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps sortOrder:(SortOrder)newSortOrder;
+ (NSArray<NSString *> *)sortOrders;

@end
