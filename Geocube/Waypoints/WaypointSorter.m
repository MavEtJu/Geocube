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

@interface WaypointSorter ()

@end

@implementation WaypointSorter

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps waypointsSortOrder:(SortOrderWaypoints)newSortOrder
{
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
        wp.calculatedBearing = [Coordinates coordinates2bearing:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
    }];

#define NCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedDescending; \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedAscending; \
            return (NSComparisonResult)NSOrderedSame; \
        }]]; \
    break;
#define SCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (W == NSOrderedAscending) \
                return (NSComparisonResult)[O1 compare:O2 options:NSCaseInsensitiveSearch]; \
            else \
                return (NSComparisonResult)(-[O1 compare:O2 options:NSCaseInsensitiveSearch]); \
            }]]; \
        break;
    switch (newSortOrder) {
        NCMP(SORTORDERWP_DISTANCE_ASC, obj1.calculatedDistance, obj2.calculatedDistance, >)
        NCMP(SORTORDERWP_DISTANCE_DESC, obj1.calculatedDistance, obj2.calculatedDistance, <)
        NCMP(SORTORDERWP_DIRECTION_ASC, obj1.calculatedBearing, obj2.calculatedBearing, <)
        NCMP(SORTORDERWP_DIRECTION_DESC, obj1.calculatedBearing, obj2.calculatedBearing, >)
        NCMP(SORTORDERWP_TYPE, obj1.wpt_type._id, obj2.wpt_type._id, >)
        NCMP(SORTORDERWP_CONTAINER, obj1.gs_container._id, obj2.gs_container._id, >)
        NCMP(SORTORDERWP_FAVOURITES_ASC, obj1.gs_favourites, obj2.gs_favourites, >)
        NCMP(SORTORDERWP_FAVOURITES_DESC, obj1.gs_favourites, obj2.gs_favourites, <)
        NCMP(SORTORDERWP_TERRAIN_ASC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, >)
        NCMP(SORTORDERWP_TERRAIN_DESC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, <)
        NCMP(SORTORDERWP_DIFFICULTY_ASC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, >)
        NCMP(SORTORDERWP_DIFFICULTY_DESC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, <)
        SCMP(SORTORDERWP_CODE_ASC, obj1.wpt_name, obj2.wpt_name, NSOrderedAscending)
        SCMP(SORTORDERWP_CODE_DESC, obj1.wpt_name, obj2.wpt_name, NSOrderedDescending)
        SCMP(SORTORDERWP_NAME_ASC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedAscending)
        SCMP(SORTORDERWP_NAME_DESC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedDescending)
        NCMP(SORTORDERWP_DATE_HIDDEN_OLDESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, >)
        NCMP(SORTORDERWP_DATE_HIDDEN_NEWESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, <)
        NCMP(SORTORDERWP_DATE_FOUND_OLDESTFIRST, obj1.gs_date_found, obj2.gs_date_found, >)
        NCMP(SORTORDERWP_DATE_FOUND_NEWESTFIRST, obj1.gs_date_found, obj2.gs_date_found, <)
        NCMP(SORTORDERWP_DATE_LASTLOG_OLDESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, >)
        NCMP(SORTORDERWP_DATE_LASTLOG_NEWESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, <)
        default:
            NSAssert(NO, @"Unknown sort order");
    }

    return wps;
}

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps locationlessSortOrder:(SortOrderLocationless)newSortOrder
{
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
        wp.calculatedBearing = [Coordinates coordinates2bearing:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
    }];

#define NCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedDescending; \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedAscending; \
            return (NSComparisonResult)NSOrderedSame; \
        }]]; \
    break;
#define SCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (W == NSOrderedAscending) \
                return (NSComparisonResult)[O1 compare:O2 options:NSCaseInsensitiveSearch]; \
            else \
                return (NSComparisonResult)(-[O1 compare:O2 options:NSCaseInsensitiveSearch]); \
            }]]; \
        break;
    switch (newSortOrder) {
        SCMP(SORTORDERLOCATIONLESS_CODE_ASC, obj1.wpt_name, obj2.wpt_name, NSOrderedAscending)
        SCMP(SORTORDERLOCATIONLESS_CODE_DESC, obj1.wpt_name, obj2.wpt_name, NSOrderedDescending)
        SCMP(SORTORDERLOCATIONLESS_NAME_ASC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedAscending)
        SCMP(SORTORDERLOCATIONLESS_NAME_DESC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedDescending)
        NCMP(SORTORDERLOCATIONLESS_DATE_HIDDEN_OLDESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, >)
        NCMP(SORTORDERLOCATIONLESS_DATE_HIDDEN_NEWESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, <)
        NCMP(SORTORDERLOCATIONLESS_DATE_FOUND_OLDESTFIRST, obj1.gs_date_found, obj2.gs_date_found, >)
        NCMP(SORTORDERLOCATIONLESS_DATE_FOUND_NEWESTFIRST, obj1.gs_date_found, obj2.gs_date_found, <)
        NCMP(SORTORDERLOCATIONLESS_DATE_LASTLOG_OLDESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, >)
        NCMP(SORTORDERLOCATIONLESS_DATE_LASTLOG_NEWESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, <)
        default:
            NSAssert(NO, @"Unknown sort order");
    }

    return wps;
}

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps listSortOrder:(SortOrderList)newSortOrder flag:(Flag)flag
{
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
        wp.calculatedBearing = [Coordinates coordinates2bearing:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords];
    }];

#define NCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedDescending; \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedAscending; \
            return (NSComparisonResult)NSOrderedSame; \
        }]]; \
    break;
#define SCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (W == NSOrderedAscending) \
                return (NSComparisonResult)[O1 compare:O2 options:NSCaseInsensitiveSearch]; \
            else \
                return (NSComparisonResult)(-[O1 compare:O2 options:NSCaseInsensitiveSearch]); \
            }]]; \
        break;
    switch (newSortOrder) {
        NCMP(SORTORDERLIST_DISTANCE_ASC, obj1.calculatedDistance, obj2.calculatedDistance, >)
        NCMP(SORTORDERLIST_DISTANCE_DESC, obj1.calculatedDistance, obj2.calculatedDistance, <)
        NCMP(SORTORDERLIST_DIRECTION_ASC, obj1.calculatedBearing, obj2.calculatedBearing, <)
        NCMP(SORTORDERLIST_DIRECTION_DESC, obj1.calculatedBearing, obj2.calculatedBearing, >)
        NCMP(SORTORDERLIST_TYPE, obj1.wpt_type._id, obj2.wpt_type._id, >)
        NCMP(SORTORDERLIST_CONTAINER, obj1.gs_container._id, obj2.gs_container._id, >)
        NCMP(SORTORDERLIST_FAVOURITES_ASC, obj1.gs_favourites, obj2.gs_favourites, >)
        NCMP(SORTORDERLIST_FAVOURITES_DESC, obj1.gs_favourites, obj2.gs_favourites, <)
        NCMP(SORTORDERLIST_TERRAIN_ASC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, >)
        NCMP(SORTORDERLIST_TERRAIN_DESC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, <)
        NCMP(SORTORDERLIST_DIFFICULTY_ASC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, >)
        NCMP(SORTORDERLIST_DIFFICULTY_DESC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, <)
        SCMP(SORTORDERLIST_CODE_ASC, obj1.wpt_name, obj2.wpt_name, NSOrderedAscending)
        SCMP(SORTORDERLIST_CODE_DESC, obj1.wpt_name, obj2.wpt_name, NSOrderedDescending)
        SCMP(SORTORDERLIST_NAME_ASC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedAscending)
        SCMP(SORTORDERLIST_NAME_DESC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedDescending)
        NCMP(SORTORDERLIST_DATE_HIDDEN_OLDESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, >)
        NCMP(SORTORDERLIST_DATE_HIDDEN_NEWESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, <)
        NCMP(SORTORDERLIST_DATE_FOUND_OLDESTFIRST, obj1.gs_date_found, obj2.gs_date_found, >)
        NCMP(SORTORDERLIST_DATE_FOUND_NEWESTFIRST, obj1.gs_date_found, obj2.gs_date_found, <)
        NCMP(SORTORDERLIST_DATE_LASTLOG_OLDESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, >)
        NCMP(SORTORDERLIST_DATE_LASTLOG_NEWESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, <)
        case SORTORDERLIST_TIMEADDED_ASC:
        case SORTORDERLIST_TIMEADDED_DESC:
        {
            NSArray<dbListData *> *lds = [dbListData dbAllByType:flag ascending:(newSortOrder == SORTORDERLIST_TIMEADDED_ASC)];

            NSMutableArray<dbWaypoint *> *new = [NSMutableArray arrayWithCapacity:[wps count]];
            NSMutableArray<dbWaypoint *> *old = [NSMutableArray arrayWithArray:wps];

            [lds enumerateObjectsUsingBlock:^(dbListData * _Nonnull ld, NSUInteger idx, BOOL * _Nonnull stop) {
                [old enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp._id == ld.waypoint._id) {
                        [new addObject:wp];
                        *stop = YES;
                    }
                }];
            }];
            wps = new;
            break;
        }
        default:
            NSAssert(NO, @"Unknown sort order");
    }

    return wps;
}

+ (NSArray<NSString *> *)waypointsSortOrders
{
    NSMutableArray<NSString *> *orders = [NSMutableArray arrayWithCapacity:SORTORDERWP_MAX];
    for (SortOrderWaypoints i = 0; i < SORTORDERWP_MAX; i++) {
#define CASE(__order__, __title__) \
    case __order__: \
        [orders addObject:__title__]; \
        break;
        switch (i) {
            CASE(SORTORDERWP_DISTANCE_ASC, @"Distance (ascending)")
            CASE(SORTORDERWP_DISTANCE_DESC, @"Distance (descending)")
            CASE(SORTORDERWP_DIRECTION_ASC, @"Direction (ascending)")
            CASE(SORTORDERWP_DIRECTION_DESC, @"Direction (descending)")
            CASE(SORTORDERWP_TYPE, @"Type")
            CASE(SORTORDERWP_CONTAINER, @"Container")
            CASE(SORTORDERWP_FAVOURITES_ASC, @"Favourites (ascending)")
            CASE(SORTORDERWP_FAVOURITES_DESC, @"Favourites (descending)")
            CASE(SORTORDERWP_TERRAIN_ASC, @"Terrain (ascending)")
            CASE(SORTORDERWP_TERRAIN_DESC, @"Terrain (descending)")
            CASE(SORTORDERWP_DIFFICULTY_ASC, @"Difficulty (ascending)")
            CASE(SORTORDERWP_DIFFICULTY_DESC, @"Difficulty (descending)")
            CASE(SORTORDERWP_NAME_ASC, @"Name (ascending)")
            CASE(SORTORDERWP_NAME_DESC, @"Name (descending)")
            CASE(SORTORDERWP_CODE_ASC, @"Code (ascending)")
            CASE(SORTORDERWP_CODE_DESC, @"Code (descending)")
            CASE(SORTORDERWP_DATE_LASTLOG_OLDESTFIRST, @"Last log date (oldest first)")
            CASE(SORTORDERWP_DATE_LASTLOG_NEWESTFIRST, @"Last log date (newest first)")
            CASE(SORTORDERWP_DATE_HIDDEN_OLDESTFIRST, @"Hidden date (oldest first)")
            CASE(SORTORDERWP_DATE_HIDDEN_NEWESTFIRST, @"Hidden date (newest first)")
            CASE(SORTORDERWP_DATE_FOUND_OLDESTFIRST, @"Found date (oldest first)")
            CASE(SORTORDERWP_DATE_FOUND_NEWESTFIRST, @"Found date (newest first)")
            default:
                NSAssert(NO, @"Unknown sort order");
        }
    }
    return orders;
}

+ (NSArray<NSString *> *)locationlessSortOrders
{
    NSMutableArray<NSString *> *orders = [NSMutableArray arrayWithCapacity:SORTORDERWP_MAX];
    for (SortOrderLocationless i = 0; i < SORTORDERLOCATIONLESS_MAX; i++) {
#define CASE(__order__, __title__) \
    case __order__: \
        [orders addObject:__title__]; \
        break;
        switch (i) {
            CASE(SORTORDERLOCATIONLESS_NAME_ASC, @"Name (ascending)")
            CASE(SORTORDERLOCATIONLESS_NAME_DESC, @"Name (descending)")
            CASE(SORTORDERLOCATIONLESS_CODE_ASC, @"Code (ascending)")
            CASE(SORTORDERLOCATIONLESS_CODE_DESC, @"Code (descending)")
            CASE(SORTORDERLOCATIONLESS_DATE_LASTLOG_OLDESTFIRST, @"Last log date (oldest first)")
            CASE(SORTORDERLOCATIONLESS_DATE_LASTLOG_NEWESTFIRST, @"Last log date (newest first)")
            CASE(SORTORDERLOCATIONLESS_DATE_HIDDEN_OLDESTFIRST, @"Hidden date (oldest first)")
            CASE(SORTORDERLOCATIONLESS_DATE_HIDDEN_NEWESTFIRST, @"Hidden date (newest first)")
            CASE(SORTORDERLOCATIONLESS_DATE_FOUND_OLDESTFIRST, @"Found date (oldest first)")
            CASE(SORTORDERLOCATIONLESS_DATE_FOUND_NEWESTFIRST, @"Found date (newest first)")
            default:
                NSAssert(NO, @"Unknown sort order");
        }
    }
    return orders;
}

+ (NSArray<NSString *> *)listSortOrders
{
    NSMutableArray<NSString *> *orders = [NSMutableArray arrayWithCapacity:SORTORDERLIST_MAX];
    for (SortOrderList i = 0; i < SORTORDERLIST_MAX; i++) {
#define CASE(__order__, __title__) \
    case __order__: \
        [orders addObject:__title__]; \
        break;
        switch (i) {
            CASE(SORTORDERLIST_TIMEADDED_ASC, @"Time added (ascending)")
            CASE(SORTORDERLIST_TIMEADDED_DESC, @"Time added (descending)")
            CASE(SORTORDERLIST_DISTANCE_ASC, @"Distance (ascending)")
            CASE(SORTORDERLIST_DISTANCE_DESC, @"Distance (descending)")
            CASE(SORTORDERLIST_DIRECTION_ASC, @"Direction (ascending)")
            CASE(SORTORDERLIST_DIRECTION_DESC, @"Direction (descending)")
            CASE(SORTORDERLIST_TYPE, @"Type")
            CASE(SORTORDERLIST_CONTAINER, @"Container")
            CASE(SORTORDERLIST_FAVOURITES_ASC, @"Favourites (ascending)")
            CASE(SORTORDERLIST_FAVOURITES_DESC, @"Favourites (descending)")
            CASE(SORTORDERLIST_TERRAIN_ASC, @"Terrain (ascending)")
            CASE(SORTORDERLIST_TERRAIN_DESC, @"Terrain (descending)")
            CASE(SORTORDERLIST_DIFFICULTY_ASC, @"Difficulty (ascending)")
            CASE(SORTORDERLIST_DIFFICULTY_DESC, @"Difficulty (descending)")
            CASE(SORTORDERLIST_NAME_ASC, @"Name (ascending)")
            CASE(SORTORDERLIST_NAME_DESC, @"Name (descending)")
            CASE(SORTORDERLIST_CODE_ASC, @"Code (ascending)")
            CASE(SORTORDERLIST_CODE_DESC, @"Code (descending)")
            CASE(SORTORDERLIST_DATE_LASTLOG_OLDESTFIRST, @"Last log date (oldest first)")
            CASE(SORTORDERLIST_DATE_LASTLOG_NEWESTFIRST, @"Last log date (newest first)")
            CASE(SORTORDERLIST_DATE_HIDDEN_OLDESTFIRST, @"Hidden date (oldest first)")
            CASE(SORTORDERLIST_DATE_HIDDEN_NEWESTFIRST, @"Hidden date (newest first)")
            CASE(SORTORDERLIST_DATE_FOUND_OLDESTFIRST, @"Found date (oldest first)")
            CASE(SORTORDERLIST_DATE_FOUND_NEWESTFIRST, @"Found date (newest first)")
            default:
                NSAssert(NO, @"Unknown sort order");
        }
    }
    return orders;
}

@end
