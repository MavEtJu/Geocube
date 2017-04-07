//
//  WaypointSorting.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/4/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@implementation WaypointSorter

+ (NSArray<dbWaypoint *> *)resortWaypoints:(NSArray<dbWaypoint *> *)wps sortOrder:(SortOrder)newSortOrder
{
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:LM.coords];
        wp.calculatedBearing = [Coordinates coordinates2bearing:wp.coordinates to:LM.coords];
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
        NCMP(SORTORDER_DISTANCE_ASC, obj1.calculatedDistance, obj2.calculatedDistance, >)
        NCMP(SORTORDER_DISTANCE_DESC, obj1.calculatedDistance, obj2.calculatedDistance, <)
        NCMP(SORTORDER_DIRECTION_ASC, obj1.calculatedBearing, obj2.calculatedBearing, <)
        NCMP(SORTORDER_DIRECTION_DESC, obj1.calculatedBearing, obj2.calculatedBearing, >)
        NCMP(SORTORDER_TYPE, obj1.wpt_type_id, obj2.wpt_type_id, >)
        NCMP(SORTORDER_CONTAINER, obj1.gs_container_id, obj2.gs_container_id, >)
        NCMP(SORTORDER_FAVOURITES_ASC, obj1.gs_favourites, obj2.gs_favourites, >)
        NCMP(SORTORDER_FAVOURITES_DESC, obj1.gs_favourites, obj2.gs_favourites, <)
        NCMP(SORTORDER_TERRAIN_ASC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, >)
        NCMP(SORTORDER_TERRAIN_DESC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, <)
        NCMP(SORTORDER_DIFFICULTY_ASC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, >)
        NCMP(SORTORDER_DIFFICULTY_DESC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, <)
        SCMP(SORTORDER_CODE_ASC, obj1.wpt_name, obj2.wpt_name, NSOrderedAscending)
        SCMP(SORTORDER_CODE_DESC, obj1.wpt_name, obj2.wpt_name, NSOrderedDescending)
        SCMP(SORTORDER_NAME_ASC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedAscending)
        SCMP(SORTORDER_NAME_DESC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedDescending)
        NCMP(SORTORDER_DATE_HIDDEN_OLDESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, >)
        NCMP(SORTORDER_DATE_HIDDEN_NEWESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, <)
        NCMP(SORTORDER_DATE_FOUND_OLDESTFIRST, obj1.gs_date_found, obj2.gs_date_found, >)
        NCMP(SORTORDER_DATE_FOUND_NEWESTFIRST, obj1.gs_date_found, obj2.gs_date_found, <)
        NCMP(SORTORDER_DATE_LASTLOG_OLDESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, >)
        NCMP(SORTORDER_DATE_LASTLOG_NEWESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, <)
        default:
            NSAssert(NO, @"Unknown sort order");
    }

    return wps;
}

+ (NSArray<NSString *> *)sortOrders
{
    NSMutableArray<NSString *> *orders = [NSMutableArray arrayWithCapacity:SORTORDER_MAX];
    for (SortOrder i = 0; i < SORTORDER_MAX; i++) {
#define CASE(__order__, __title__) \
    case __order__: \
        [orders addObject:__title__]; \
        break;
        switch (i) {
            CASE(SORTORDER_DISTANCE_ASC, @"Distance (ascending)")
            CASE(SORTORDER_DISTANCE_DESC, @"Distance (descending)")
            CASE(SORTORDER_DIRECTION_ASC, @"Direction (ascending)")
            CASE(SORTORDER_DIRECTION_DESC, @"Direction (descending)")
            CASE(SORTORDER_TYPE, @"Type")
            CASE(SORTORDER_CONTAINER, @"Container")
            CASE(SORTORDER_FAVOURITES_ASC, @"Favourites (ascending)")
            CASE(SORTORDER_FAVOURITES_DESC, @"Favourites (descending)")
            CASE(SORTORDER_TERRAIN_ASC, @"Terrain (ascending)")
            CASE(SORTORDER_TERRAIN_DESC, @"Terrain (descending)")
            CASE(SORTORDER_DIFFICULTY_ASC, @"Difficulty (ascending)")
            CASE(SORTORDER_DIFFICULTY_DESC, @"Difficulty (descending)")
            CASE(SORTORDER_NAME_ASC, @"Name (ascending)")
            CASE(SORTORDER_NAME_DESC, @"Name (descending)")
            CASE(SORTORDER_CODE_ASC, @"Code (ascending)")
            CASE(SORTORDER_CODE_DESC, @"Code (descending)")
            CASE(SORTORDER_DATE_LASTLOG_OLDESTFIRST, @"Last log date (oldest first)")
            CASE(SORTORDER_DATE_LASTLOG_NEWESTFIRST, @"Last log date (newest first)")
            CASE(SORTORDER_DATE_HIDDEN_OLDESTFIRST, @"Hidden date (oldest first)")
            CASE(SORTORDER_DATE_HIDDEN_NEWESTFIRST, @"Hidden date (newest first)")
            CASE(SORTORDER_DATE_FOUND_OLDESTFIRST, @"Found date (oldest first)")
            CASE(SORTORDER_DATE_FOUND_NEWESTFIRST, @"Found date (newest first)")
            default:
                NSAssert(NO, @"Unknown sort order");
        }
    }
    return orders;
}

@end
