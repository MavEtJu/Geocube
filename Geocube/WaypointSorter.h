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

typedef NS_ENUM(NSInteger, SortOrderWaypoints) {
    SORTORDERWP_DISTANCE_ASC = 0,
    SORTORDERWP_DISTANCE_DESC,
    SORTORDERWP_DIRECTION_ASC,
    SORTORDERWP_DIRECTION_DESC,
    SORTORDERWP_TYPE,
    SORTORDERWP_CONTAINER,
    SORTORDERWP_FAVOURITES_ASC,
    SORTORDERWP_FAVOURITES_DESC,
    SORTORDERWP_TERRAIN_ASC,
    SORTORDERWP_TERRAIN_DESC,
    SORTORDERWP_DIFFICULTY_ASC,
    SORTORDERWP_DIFFICULTY_DESC,
    SORTORDERWP_NAME_ASC,
    SORTORDERWP_NAME_DESC,
    SORTORDERWP_CODE_ASC,
    SORTORDERWP_CODE_DESC,
    SORTORDERWP_DATE_FOUND_OLDESTFIRST,
    SORTORDERWP_DATE_FOUND_NEWESTFIRST,
    SORTORDERWP_DATE_LASTLOG_OLDESTFIRST,
    SORTORDERWP_DATE_LASTLOG_NEWESTFIRST,
    SORTORDERWP_DATE_HIDDEN_OLDESTFIRST,
    SORTORDERWP_DATE_HIDDEN_NEWESTFIRST,
    SORTORDERWP_MAX,
};

typedef NS_ENUM(NSInteger, SortOrderList) {
    SORTORDERLIST_TIMEADDED_ASC = 0,
    SORTORDERLIST_TIMEADDED_DESC,
    SORTORDERLIST_DISTANCE_ASC,
    SORTORDERLIST_DISTANCE_DESC,
    SORTORDERLIST_DIRECTION_ASC,
    SORTORDERLIST_DIRECTION_DESC,
    SORTORDERLIST_TYPE,
    SORTORDERLIST_CONTAINER,
    SORTORDERLIST_FAVOURITES_ASC,
    SORTORDERLIST_FAVOURITES_DESC,
    SORTORDERLIST_TERRAIN_ASC,
    SORTORDERLIST_TERRAIN_DESC,
    SORTORDERLIST_DIFFICULTY_ASC,
    SORTORDERLIST_DIFFICULTY_DESC,
    SORTORDERLIST_NAME_ASC,
    SORTORDERLIST_NAME_DESC,
    SORTORDERLIST_CODE_ASC,
    SORTORDERLIST_CODE_DESC,
    SORTORDERLIST_DATE_FOUND_OLDESTFIRST,
    SORTORDERLIST_DATE_FOUND_NEWESTFIRST,
    SORTORDERLIST_DATE_LASTLOG_OLDESTFIRST,
    SORTORDERLIST_DATE_LASTLOG_NEWESTFIRST,
    SORTORDERLIST_DATE_HIDDEN_OLDESTFIRST,
    SORTORDERLIST_DATE_HIDDEN_NEWESTFIRST,
    SORTORDERLIST_MAX,
};

@interface WaypointSorter : NSObject

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps waypointsSortOrder:(SortOrderWaypoints)newSortOrder;
+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps listSortOrder:(SortOrderList)newSortOrder flag:(Flag)flag;
+ (NSArray<NSString *> *)waypointsSortOrders;
+ (NSArray<NSString *> *)listSortOrders;

@end
