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

#import "Geocube-Prefix.pch"

@implementation CacheFilter

@synthesize configPrefix;

+ (NSArray *)filter
{
    CacheFilter *filter = [[CacheFilter alloc] init];
    NSMutableArray *caches;
    NSMutableArray *after;

    /* Filter out by group:
     * The filter selects out the caches which belong to a certain group.
     * If a group is not defined then it will be considered not to be included.
     */

    [filter setConfigPrefix:@"groups"];
    caches = [NSMutableArray arrayWithCapacity:200];

    NSString *c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSMutableArray *groups = [NSMutableArray arrayWithCapacity:20];
        NSEnumerator *e = [[dbc Groups] objectEnumerator];
        dbGroup *group;
        while ((group = [e nextObject]) != nil) {
            c = [filter configGet:[NSString stringWithFormat:@"group_%ld", (long)group._id]];
            if (c == nil || [c boolValue] == 0)
                continue;
            [groups addObject:group];
        }
        [caches addObjectsFromArray:[dbWaypoint dbAllInGroups:groups]];
    } else {
        caches = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
    }

    /* Filter out cache types:
     * The filter selects out the caches which are of a certain type.
     * If a type is not defined then it will be considered not to be included.
     */

    [filter setConfigPrefix:@"types"];
    after = [NSMutableArray arrayWithCapacity:200];

    c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSEnumerator *eT = [[dbc Types] objectEnumerator];
        dbGroup *type;
        while ((type = [eT nextObject]) != nil) {
            c = [filter configGet:[NSString stringWithFormat:@"type_%ld", (long)type._id]];
            if (c == nil || [c boolValue] == NO)
                continue;
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.type_id == type._id)
                    [after addObject:wp];
            }];
        }

        caches = after;
    }

    /* Filter out favourites:
     * - If the min is 0 and the max is 100, then everything goes.
     * - If the min is 0 and the max is not 100, then at most max.
     * - If the min is not 0 and the max is 100, then at least min.
     * - If the min is not 0 and the max is not 100, then between min and max.
     */

    [filter setConfigPrefix:@"favourites"];
    after = [NSMutableArray arrayWithCapacity:200];

    c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger min = [[filter configGet:@"min"] integerValue];
        NSInteger max = [[filter configGet:@"max"] integerValue];

        if (min == 0 && max == 100) {
            after = caches;
        } else if (min == 0) {
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.groundspeak.favourites <= max)
                    [after addObject:wp];
            }];
        } else if (max == 100) {
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.groundspeak.favourites >= min)
                    [after addObject:wp];
            }];
        } else {
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.groundspeak.favourites >= min && wp.groundspeak.favourites <= max)
                    [after addObject:wp];
            }];
        }

        caches = after;
    }

    /* Filter out sizes:
     * The filter selects out the caches which are of a certain size.
     * If a size is not defined then it will be considered not to be included.
     */

    [filter setConfigPrefix:@"sizes"];
    after = [NSMutableArray arrayWithCapacity:200];

    c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSEnumerator *eT = [[dbc Containers] objectEnumerator];
        dbContainer *container;
        while ((container = [eT nextObject]) != nil) {
            c = [filter configGet:[NSString stringWithFormat:@"container_%ld", (long)container._id]];
            if (c == nil || [c boolValue] == NO)
                continue;
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.groundspeak.container_id == container._id)
                    [after addObject:wp];
            }];
        }

        caches = after;
    }

    /* Filter out difficulty rating
     */
    [filter setConfigPrefix:@"difficulty"];
    after = [NSMutableArray arrayWithCapacity:200];

    c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        float min = [[filter configGet:@"min"] floatValue];
        float max = [[filter configGet:@"max"] floatValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (wp.groundspeak.rating_difficulty >= min && wp.groundspeak.rating_difficulty <= max)
                [after addObject:wp];
        }];

        caches = after;
    }

    /* Filter out terrain rating
     */

    [filter setConfigPrefix:@"terrain"];
    after = [NSMutableArray arrayWithCapacity:200];

    c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        float min = [[filter configGet:@"min"] floatValue];
        float max = [[filter configGet:@"max"] floatValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (wp.groundspeak.rating_terrain >= min && wp.groundspeak.rating_terrain <= max)
                [after addObject:wp];
        }];

        caches = after;
    }

    return caches;
}

+ (BOOL)filterDistance:(dbWaypoint *)wp
{
    CacheFilter *filter = [[CacheFilter alloc] init];

    [filter setConfigPrefix:@"distance"];
    NSString *c = [filter configGet:@"enabled"];
    if (c == nil || [c boolValue] == NO)
        return YES;

    NSInteger compareDistance = [[filter configGet:@"compareDistance"] integerValue];
    NSInteger distanceM = [[filter configGet:@"distanceM"] integerValue];
    NSInteger distanceKm = [[filter configGet:@"distanceKm"] integerValue];
    NSInteger variationM = [[filter configGet:@"variationM"] integerValue];
    NSInteger variationKm = [[filter configGet:@"variationKm"] integerValue];

    if (compareDistance == 0) {         /* <= */
        if (wp.calculatedDistance <= distanceKm * 1000 + distanceM)
            return YES;
        return NO;
    } else if (compareDistance == 1) {  /* >= */
        if (wp.calculatedDistance >= distanceKm * 1000 + distanceM)
            return YES;
        return NO;
    } else {                            /* = */
        if (wp.calculatedDistance >= (distanceKm - variationKm) * 1000 + (distanceM - variationM) &&
            wp.calculatedDistance <= (distanceKm + variationKm) * 1000 + (distanceM + variationM))
            return YES;
        return NO;
    }

    return NO;
}

+ (BOOL)filterDirection:(dbWaypoint *)wp
{
    CacheFilter *filter = [[CacheFilter alloc] init];

    [filter setConfigPrefix:@"direction"];
    NSString *c = [filter configGet:@"enabled"];
    if (c == nil || [c boolValue] == NO)
        return YES;

    NSInteger direction = [[filter configGet:@"direction"] integerValue];

    if (direction == 0 && (wp.calculatedBearing <=  45 || wp.calculatedBearing >= 315)) return YES;
    if (direction == 1 &&  wp.calculatedBearing <=  90 && wp.calculatedBearing >=   0) return YES;
    if (direction == 2 &&  wp.calculatedBearing <= 135 && wp.calculatedBearing >=  45) return YES;
    if (direction == 3 &&  wp.calculatedBearing <= 180 && wp.calculatedBearing >=  90) return YES;
    if (direction == 4 &&  wp.calculatedBearing <= 225 && wp.calculatedBearing >= 135) return YES;
    if (direction == 5 &&  wp.calculatedBearing <= 270 && wp.calculatedBearing >= 180) return YES;
    if (direction == 6 &&  wp.calculatedBearing <= 315 && wp.calculatedBearing >= 225) return YES;
    if (direction == 7 &&  wp.calculatedBearing <= 360 && wp.calculatedBearing >= 270) return YES;

    return NO;
}

- (NSString *)configGet:(NSString *)_name
{
    dbFilter *c = [dbFilter dbGetByKey:[NSString stringWithFormat:@"%@_%@", configPrefix, _name]];
    if (c == nil)
        return nil;
    return c.value;
}

- (void)configSet:(NSString *)_name value:(NSString *)_value
{
    [dbFilter dbUpdateOrInsert:[NSString stringWithFormat:@"%@_%@", configPrefix, _name] value:_value];
}

@end
