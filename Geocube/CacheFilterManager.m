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

@implementation CacheFilterManager

@synthesize configPrefix, currentWaypoint, currentWaypoints;

- (instancetype)init
{
    self = [super init];

    currentWaypoints = nil;
    currentWaypoint = nil;
    needsRefresh = YES;
    lastCoordinates.latitude = 0;
    lastCoordinates.longitude = 0;

    if ([myConfig.currentWaypoint isEqualToString:@""] == NO)
        currentWaypoint = [dbWaypoint dbGet:[dbWaypoint dbGetByName:myConfig.currentWaypoint]];

    [LM startDelegation:self isNavigating:NO];

    return self;
}

- (void)needsRefresh
{
    needsRefresh = YES;
}

- (void)applyFilters:(CLLocationCoordinate2D)coords
{
    /* Do not unnecessary go through this */
    if (needsRefresh != YES)
        return;

//    CacheFilterManager *filter = [[CacheFilterManager alloc] init];
    NSMutableArray *caches;
    NSMutableArray *after;
    MyTools *clock = [[MyTools alloc] initClock:@"filter"];
    [clock clockEnable:YES];

    /* Filter out by group:
     * The filter selects out the caches which belong to a certain group.
     * If a group is not defined then it will be considered not to be included.
     */

    [self configPrefix:@"groups"];
    caches = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"groups"];


    __block NSString *c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        __block NSMutableArray *groups = [NSMutableArray arrayWithCapacity:20];
        [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *group, NSUInteger idx, BOOL *stop) {
            NSString *c = [self _configGet:[NSString stringWithFormat:@"group_%ld", (long)group._id]];
            if (c == nil || [c boolValue] == NO)
                return;
            [groups addObject:group];
        }];
        [caches addObjectsFromArray:[dbWaypoint dbAllInGroups:groups]];
    } else {
        caches = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
        [clock clockShowAndReset:@"dbAll"];
    }

    NSLog(@"%@: Number of waypoints before filtering: %ld", [self class], [caches count]);

    /* Filter out cache types:
     * The filter selects out the caches which are of a certain type.
     * If a type is not defined then it will be considered not to be included.
     */

    [self configPrefix:@"types"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"types"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        [[dbc Types] enumerateObjectsUsingBlock:^(dbType *type, NSUInteger idx, BOOL *stop) {
            c = [self _configGet:[NSString stringWithFormat:@"type_%ld", (long)type._id]];
            if (c == nil || [c boolValue] == NO)
                return;
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.type_id == type._id)
                    [after addObject:wp];
            }];
        }];

        caches = after;
    }

    /* Filter out favourites:
     * - If the min is 0 and the max is 100, then everything goes.
     * - If the min is 0 and the max is not 100, then at most max.
     * - If the min is not 0 and the max is 100, then at least min.
     * - If the min is not 0 and the max is not 100, then between min and max.
     */

    [self configPrefix:@"favourites"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"favourites"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger min = [[self _configGet:@"min"] integerValue];
        NSInteger max = [[self _configGet:@"max"] integerValue];

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

    [self configPrefix:@"sizes"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"sizes"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        [[dbc Containers] enumerateObjectsUsingBlock:^(dbContainer *container, NSUInteger idx, BOOL *stop) {
            c = [self _configGet:[NSString stringWithFormat:@"container_%ld", (long)container._id]];
            if (c == nil || [c boolValue] == NO)
                return;
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.groundspeak.container_id == container._id)
                    [after addObject:wp];
            }];
        }];

        caches = after;
    }

    /* Filter out difficulty rating
     */
    [self configPrefix:@"difficulty"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"difficulty"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        float min = [[self _configGet:@"min"] floatValue];
        float max = [[self _configGet:@"max"] floatValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (wp.groundspeak.rating_difficulty >= min && wp.groundspeak.rating_difficulty <= max)
                [after addObject:wp];
        }];

        caches = after;
    }

    /* Filter out terrain rating
     */

    [self configPrefix:@"terrain"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"terrain"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        float min = [[self _configGet:@"min"] floatValue];
        float max = [[self _configGet:@"max"] floatValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (wp.groundspeak.rating_terrain >= min && wp.groundspeak.rating_terrain <= max)
                [after addObject:wp];
        }];

        caches = after;
    }

    /* Filter out ignored ones
     */

    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"ignored"];

    [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        if (wp.ignore == NO)
            [after addObject:wp];
    }];
    caches = after;

    /* Filter out dates
     */
    [self configPrefix:@"dates"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"dates"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger placedEpoch = [[self _configGet:@"placed_epoch"] integerValue];
        NSInteger lastLogEpoch = [[self _configGet:@"lastlog_epoch"] integerValue];
        NSInteger placedCompare = [[self _configGet:@"placed_compare"] integerValue];
        NSInteger lastLogCompare = [[self _configGet:@"lastlog_compare"] integerValue];

        if (placedCompare == 0) {           // before
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.date_placed_epoch <= placedEpoch)
                    [after addObject:wp];
            }];
        } else if (placedCompare == 1) {    // after
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.date_placed_epoch >= placedEpoch)
                    [after addObject:wp];
            }];
        } else {                            // on
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.date_placed_epoch >= placedEpoch - 86400 && wp.date_placed_epoch <= placedEpoch + 86400)
                    [after addObject:wp];
            }];
        }

        if (lastLogCompare == 0) {           // before
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                NSArray *logs = [dbLog dbAllByWaypoint:wp._id];
                __block BOOL rv = YES;
                [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL *stop) {
                    if (log.datetime_epoch > lastLogEpoch) {
                        rv = NO;
                        *stop = YES;
                    }
                }];
                if (rv == YES)
                    [after addObject:wp];
            }];
        } else if (lastLogCompare == 1) {    // after
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                NSArray *logs = [dbLog dbAllByWaypoint:wp._id];
                __block BOOL rv = NO;
                [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL *stop) {
                    if (log.datetime_epoch > lastLogEpoch) {
                        rv = YES;
                        *stop = YES;
                    }
                }];
                if (rv == YES)
                    [after addObject:wp];
            }];
        } else {                            // on
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                NSArray *logs = [dbLog dbAllByWaypoint:wp._id];
                __block BOOL rv = NO;
                [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL *stop) {
                    if (log.datetime_epoch > lastLogEpoch - 86400 && log.datetime_epoch < lastLogEpoch + 86400) {
                        rv = YES;
                        *stop = YES;
                    }
                }];
                if (rv == YES)
                    [after addObject:wp];
            }];
        }

        caches = after;
    }

    /* Text self
     * An empty entry means that it matches.
     */
    [self configPrefix:@"text"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"text"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSString *cachename = [self _configGet:@"cachename"];
        NSString *owner = [self _configGet:@"owner"];
        NSString *state = [self _configGet:@"state"];
        NSString *country = [self _configGet:@"country"];
        NSString *description = [self _configGet:@"description"];
        NSString *logs = [self _configGet:@"logs"];

        __block NSMutableArray *countries = nil;
        __block NSMutableArray *states = nil;
        __block NSMutableArray *owners = nil;

        if (country != nil && [country isEqualToString:@""] == NO) {
            countries = [NSMutableArray arrayWithCapacity:20];
            [[dbc Countries] enumerateObjectsUsingBlock:^(dbCountry *c, NSUInteger idx, BOOL *stop) {
                if ([c.name localizedCaseInsensitiveContainsString:country] ||
                    [c.code localizedCaseInsensitiveContainsString:country])
                    [countries addObject:c];
            }];
        }

        if (state != nil && [state isEqualToString:@""] == NO) {
            states = [NSMutableArray arrayWithCapacity:20];
            [[dbc States] enumerateObjectsUsingBlock:^(dbState *c, NSUInteger idx, BOOL *stop) {
                if ([c.name localizedCaseInsensitiveContainsString:state] ||
                    [c.code localizedCaseInsensitiveContainsString:state])
                    [states addObject:c];
            }];
        }

        if (owner != nil && [owner isEqualToString:@""] == NO) {
            owners = [NSMutableArray arrayWithCapacity:20];
            [[dbName dbAll] enumerateObjectsUsingBlock:^(dbName *n, NSUInteger idx, BOOL *stop) {
                if ([n.name localizedCaseInsensitiveContainsString:owner])
                    [owners addObject:n];
            }];
        }

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            __block BOOL rv = YES;

            if (cachename != nil && [cachename isEqualToString:@""] == NO &&
                [wp.name localizedCaseInsensitiveContainsString:cachename] == NO &&
                [wp.urlname localizedCaseInsensitiveContainsString:cachename] == NO) {
                rv = NO;
            }

            if (description != nil && [description isEqualToString:@""] == NO &&
                [wp.description localizedCaseInsensitiveContainsString:description] == NO &&
                [wp.groundspeak.long_desc localizedCaseInsensitiveContainsString:description] == NO &&
                [wp.groundspeak.short_desc localizedCaseInsensitiveContainsString:description] == NO) {
                rv = NO;
            }

            if (states != nil) {
                __block BOOL matched = NO;
                [states enumerateObjectsUsingBlock:^(dbState *s, NSUInteger idx, BOOL *stop) {
                    if (s._id == wp.groundspeak.state_id) {
                        matched = YES;
                        *stop = YES;
                    }
                }];
                if (matched == NO)
                    rv = NO;
            }

            if (countries != nil) {
                __block BOOL matched = NO;
                [countries enumerateObjectsUsingBlock:^(dbCountry *c, NSUInteger idx, BOOL *stop) {
                    if (c._id == wp.groundspeak.country_id) {
                        matched = YES;
                        *stop = YES;
                    }
                }];
                if (matched == NO)
                    rv = NO;
            }

            if (owners != nil) {
                __block BOOL matched = NO;
                [owners enumerateObjectsUsingBlock:^(dbName *o, NSUInteger idx, BOOL *stop) {
                    if (o._id == wp.groundspeak.owner_id) {
                        matched = YES;
                        *stop = YES;
                    }
                }];
                if (matched == NO)
                    rv = NO;
            }

            if (logs != nil && [logs isEqualToString:@""] == NO) {
                if ([dbLog dbCountByWaypointLogString:wp LogString:logs] == 0)
                    rv = NO;
            }

            if (rv == YES)
                [after addObject:wp];
        }];

        caches = after;
    }

    /* Calculate the distance and the bearing */
    [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:coords];
        wp.calculatedBearing = [Coordinates coordinates2distance:coords to:wp.coordinates];
    }];

    /* Filter by distance */
    [self configPrefix:@"distance"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"distance"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {

        NSInteger compareDistance = [[self _configGet:@"compareDistance"] integerValue];
        NSInteger distanceM = [[self _configGet:@"distanceM"] integerValue];
        NSInteger distanceKm = [[self _configGet:@"distanceKm"] integerValue];
        NSInteger variationM = [[self _configGet:@"variationM"] integerValue];
        NSInteger variationKm = [[self _configGet:@"variationKm"] integerValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            BOOL fine = NO;
            if (compareDistance == 0) {         /* <= */
                if (wp.calculatedDistance <= distanceKm * 1000 + distanceM)
                    fine = YES;
            } else if (compareDistance == 1) {  /* >= */
                if (wp.calculatedDistance >= distanceKm * 1000 + distanceM)
                    fine = YES;
            } else {                            /* = */
                if (wp.calculatedDistance >= (distanceKm - variationKm) * 1000 + (distanceM - variationM) &&
                    wp.calculatedDistance <= (distanceKm + variationKm) * 1000 + (distanceM + variationM))
                    fine = YES;
            }
            if (fine == YES)
                [after addObject:wp];
        }];
        caches = after;
    }

    /* Filter by direction */
    [self configPrefix:@"direction"];
    after = [NSMutableArray arrayWithCapacity:200];
    [clock clockShowAndReset:@"direction"];

    c = [self _configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger direction = [[self _configGet:@"direction"] integerValue];

        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            BOOL fine = NO;

            if (direction == 0 && (wp.calculatedBearing <=  45 || wp.calculatedBearing >= 315)) fine = YES;
            if (direction == 1 &&  wp.calculatedBearing <=  90 && wp.calculatedBearing >=   0) fine = YES;
            if (direction == 2 &&  wp.calculatedBearing <= 135 && wp.calculatedBearing >=  45) fine = YES;
            if (direction == 3 &&  wp.calculatedBearing <= 180 && wp.calculatedBearing >=  90) fine = YES;
            if (direction == 4 &&  wp.calculatedBearing <= 225 && wp.calculatedBearing >= 135) fine = YES;
            if (direction == 5 &&  wp.calculatedBearing <= 270 && wp.calculatedBearing >= 180) fine = YES;
            if (direction == 6 &&  wp.calculatedBearing <= 315 && wp.calculatedBearing >= 225) fine = YES;
            if (direction == 7 &&  wp.calculatedBearing <= 360 && wp.calculatedBearing >= 270) fine = YES;

            if (fine == YES)
                [after addObject:wp];
        }];
        caches = after;
    }

    NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], [caches count]);
    currentWaypoints = caches;
    needsRefresh = NO;
}

- (NSString *)_configGet:(NSString *)_name
{
    return [self configGet:[NSString stringWithFormat:@"%@_%@", configPrefix, _name]];
}

- (NSString *)configGet:(NSString *)_name
{
    dbFilter *c = [dbFilter dbGetByKey:_name];
    if (c == nil)
        return nil;
    return c.value;
}

- (void)configSet:(NSString *)_name value:(NSString *)_value
{
    needsRefresh = YES;
    [dbFilter dbUpdateOrInsert:_name value:_value];
}

- (void)configPrefix:(NSString *)_prefix
{
    configPrefix = _prefix;
}

/* Receive data from the location manager */
- (void)updateData
{
    NSLog(@"Coordinates: %@ - Direction: %ld", [Coordinates NiceCoordinates:LM.coords], (long)LM.direction);
    if ([Coordinates coordinates2distance:lastCoordinates to:LM.coords] > 1000)
        needsRefresh = YES;
    lastCoordinates = LM.coords;
}

- (void)setCurrentWaypoint:(dbWaypoint *)wp
{
    currentWaypoint = wp;
    [myConfig currentWaypointUpdate:wp.name];
}
@end
