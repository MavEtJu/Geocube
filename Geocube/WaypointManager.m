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

@interface WaypointManager ()
{
    CLLocationCoordinate2D lastCoordinates;
    BOOL needsRefresh;
    NSMutableArray *currentWaypoints;
    dbWaypoint *currentWaypoint;

    NSMutableArray *delegates;
}

@end

@implementation WaypointManager

@synthesize currentWaypoint, currentWaypoints;

- (instancetype)init
{
    self = [super init];
    NSLog(@"%@: starting", [self class]);

    currentWaypoints = nil;
    currentWaypoint = nil;
    needsRefresh = YES;
    lastCoordinates = CLLocationCoordinate2DMake(0, 0);

    if ([myConfig.currentWaypoint isEqualToString:@""] == NO)
        currentWaypoint = [dbWaypoint dbGet:[dbWaypoint dbGetByName:myConfig.currentWaypoint]];

    [LM startDelegation:self isNavigating:NO];

    delegates = [NSMutableArray arrayWithCapacity:5];

    return self;
}

- (void)startDelegation:(id)_delegate
{
    NSLog(@"%@: starting for %@", [self class], [_delegate class]);
    if (_delegate != nil)
        [delegates addObject:_delegate];
}

- (void)stopDelegation:(id)_delegate
{
    NSLog(@"%@: stopping for %@", [self class], [_delegate class]);
    [delegates removeObject:_delegate];

    NSLog(@"%@: stopping", [self class]);
}

- (void)needsRefresh
{
    needsRefresh = YES;

    [delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL *stop) {
        // Doing this via the main queue because Google Map Service insists on it.
        NSLog(@"%@: refreshing %@", [self class], [delegate class]);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [delegate refreshWaypoints];
        }];
    }];
}

- (void)applyFilters:(CLLocationCoordinate2D)coords
{
    @synchronized(self) {
        NSLog(@"%@: coordinates %@", [self class], [Coordinates NiceCoordinates:coords]);

        /* Do not unnecessary go through this */
        if (needsRefresh != YES)
            return;

        NSMutableArray *caches;
        NSMutableArray *after;
        MyTools *clock = [[MyTools alloc] initClock:@"filter"];
        [clock clockEnable:YES];

        /* Filter out by group:
         * The filter selects out the caches which belong to a certain group.
         * If a group is not defined then it will be considered not to be included.
         */

        caches = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"groups"];

        __block NSString *c = [self configGet:@"groups_enabled"];
        if (c != nil && [c boolValue] == YES) {
            __block NSMutableArray *groups = [NSMutableArray arrayWithCapacity:20];
            [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *group, NSUInteger idx, BOOL *stop) {
                NSString *c = [self configGet:[NSString stringWithFormat:@"groups_group_%ld", (long)group._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [groups addObject:group];
            }];
            [caches addObjectsFromArray:[dbWaypoint dbAllInGroups:groups]];
        } else {
            caches = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
            [clock clockShowAndReset:@"dbAll"];
        }

        NSLog(@"%@: Number of waypoints before filtering: %ld", [self class], (unsigned long)[caches count]);

        /* Filter out cache types:
         * The filter selects out the caches which are of a certain type.
         * If a type is not defined then it will be considered not to be included.
         */

        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"types"];

        c = [self configGet:@"types_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering types", [self class]);
            [[dbc Types] enumerateObjectsUsingBlock:^(dbType *type, NSUInteger idx, BOOL *stop) {
                c = [self configGet:[NSString stringWithFormat:@"types_type_%ld", (long)type._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.wpt_type_id == type._id)
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

        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"favourites"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"favourites_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering favourites", [self class]);
            NSInteger min = [[self configGet:@"favourites_min"] integerValue];
            NSInteger max = [[self configGet:@"favourites_max"] integerValue];

            if (min == 0 && max == 100) {
                after = caches;
            } else if (min == 0) {
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.gs_favourites <= max)
                        [after addObject:wp];
                }];
            } else if (max == 100) {
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.gs_favourites >= min)
                        [after addObject:wp];
                }];
            } else {
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.gs_favourites >= min && wp.gs_favourites <= max)
                        [after addObject:wp];
                }];
            }

            caches = after;
        }

        /* Filter out sizes:
         * The filter selects out the caches which are of a certain size.
         * If a size is not defined then it will be considered not to be included.
         */

        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"sizes"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"sizes_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering sizes", [self class]);
            [[dbc Containers] enumerateObjectsUsingBlock:^(dbContainer *container, NSUInteger idx, BOOL *stop) {
                c = [self configGet:[NSString stringWithFormat:@"sizes_container_%ld", (long)container._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.gs_container_id == container._id)
                        [after addObject:wp];
                }];
            }];

            caches = after;
        }

        /* Filter out difficulty rating
         */
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"difficulty"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"difficulty_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering difficulty", [self class]);
            float min = [[self configGet:@"difficulty_min"] floatValue];
            float max = [[self configGet:@"difficulty_max"] floatValue];

            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.gs_rating_difficulty >= min && wp.gs_rating_difficulty <= max)
                    [after addObject:wp];
            }];

            caches = after;
        }

        /* Filter out terrain rating
         */

        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"terrain"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"terrain_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering terrain", [self class]);
            float min = [[self configGet:@"terrain_min"] floatValue];
            float max = [[self configGet:@"terrain_max"] floatValue];

            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.gs_rating_terrain >= min && wp.gs_rating_terrain <= max)
                    [after addObject:wp];
            }];

            caches = after;
        }
        NSLog(@"%@: Number of waypoints after filtering terrain: %ld", [self class], (unsigned long)[caches count]);

        /* Filter out dates
         */
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"dates"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"dates_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering dates", [self class]);
            NSInteger placedEpoch = [[self configGet:@"dates_placed_epoch"] integerValue];
            NSInteger lastLogEpoch = [[self configGet:@"dates_lastlog_epoch"] integerValue];
            NSInteger placedCompare = [[self configGet:@"dates_placed_compare"] integerValue];
            NSInteger lastLogCompare = [[self configGet:@"dates_lastlog_compare"] integerValue];

            if (placedCompare == 0) {           // before
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.wpt_date_placed_epoch <= placedEpoch)
                        [after addObject:wp];
                }];
            } else if (placedCompare == 1) {    // after
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.wpt_date_placed_epoch >= placedEpoch)
                        [after addObject:wp];
                }];
            } else {                            // on
                [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                    if (wp.wpt_date_placed_epoch >= placedEpoch - 86400 && wp.wpt_date_placed_epoch <= placedEpoch + 86400)
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
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"text"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"text_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering text", [self class]);
            NSString *cachename = [self configGet:@"text_cachename"];
            NSString *owner = [self configGet:@"text_owner"];
            NSString *state = [self configGet:@"text_state"];
            NSString *country = [self configGet:@"text_country"];
            NSString *description = [self configGet:@"text_description"];
            NSString *logs = [self configGet:@"text_logs"];

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
                    [wp.wpt_name localizedCaseInsensitiveContainsString:cachename] == NO &&
                    [wp.wpt_urlname localizedCaseInsensitiveContainsString:cachename] == NO) {
                    rv = NO;
                }

                if (description != nil && [description isEqualToString:@""] == NO &&
                    [wp.description localizedCaseInsensitiveContainsString:description] == NO &&
                    [wp.gs_long_desc localizedCaseInsensitiveContainsString:description] == NO &&
                    [wp.gs_short_desc localizedCaseInsensitiveContainsString:description] == NO) {
                    rv = NO;
                }

                if (states != nil) {
                    __block BOOL matched = NO;
                    [states enumerateObjectsUsingBlock:^(dbState *s, NSUInteger idx, BOOL *stop) {
                        if (s._id == wp.gs_state_id) {
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
                        if (c._id == wp.gs_country_id) {
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
                        if (o._id == wp.gs_owner_id) {
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

        /* Filter by flags */
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"flags"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"flags_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSInteger flagHighlight = [[self configGet:@"flags_highlighted"] integerValue];
            NSInteger flagInProgress = [[self configGet:@"flags_inprogress"] integerValue];
            NSInteger flagIgnored = [[self configGet:@"flags_ignored"] integerValue];
            NSInteger flagMarkedFound = [[self configGet:@"flags_markedfound"] integerValue];
            NSInteger flagMine = [[self configGet:@"flags_owner"] integerValue];
            NSInteger flagLogStatus = [[self configGet:@"flags_logstatus"] integerValue];

            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                BOOL keep = YES;

                if (keep == YES && flagHighlight != 0)
                    keep = (wp.flag_highlight == NO && flagHighlight == 2) || (wp.flag_highlight == YES && flagHighlight == 1);
                if (keep == YES && flagInProgress != 0)
                    keep = (wp.flag_inprogress == NO && flagInProgress == 2) || (wp.flag_inprogress == YES && flagInProgress == 1);
                if (keep == YES && flagIgnored != 0)
                    keep = (wp.flag_ignore == NO && flagIgnored == 2) || (wp.flag_ignore == YES && flagIgnored == 1);
                if (keep == YES && flagMarkedFound != 0)
                    keep = (wp.flag_markedfound == NO && flagMarkedFound == 2) || (wp.flag_markedfound == YES && flagMarkedFound == 1);
                if (keep == YES && flagMine != 0)
                    keep = (wp.account.accountname_id != wp.gs_owner_id && flagMine == 2) || (wp.account.accountname_id == wp.gs_owner_id && flagMine == 1);
                if (keep == YES && flagLogStatus != 0)
                    keep = (wp.logStatus == LOGSTATUS_FOUND && flagLogStatus == 3) || (wp.logStatus == LOGSTATUS_NOTFOUND && flagLogStatus == 2) || (wp.logStatus == LOGSTATUS_NOTLOGGED && flagLogStatus == 1);

                if (keep == YES)
                    [after addObject:wp];
            }];

            caches = after;
        } else {

            /* Filter out ignored ones
             */

            after = [NSMutableArray arrayWithCapacity:200];
            [clock clockShowAndReset:@"ignored"];

            NSLog(@"%@ - Filtering ignored", [self class]);
            [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.flag_ignore == NO)
                    [after addObject:wp];
            }];
            caches = after;
        }

        /* Calculate the distance and the bearing */
        NSLog(@"Coordinates: %@", [Coordinates NiceCoordinates:coords]);
        [caches enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:coords];
            wp.calculatedBearing = [Coordinates coordinates2bearing:coords to:wp.coordinates];
        }];

        /* Filter by distance */
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"distance"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"distance_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering distance", [self class]);
            NSInteger compareDistance = [[self configGet:@"distance_compareDistance"] integerValue];
            NSInteger distanceM = [[self configGet:@"distance_distanceM"] integerValue];
            NSInteger distanceKm = [[self configGet:@"distance_distanceKm"] integerValue];
            NSInteger variationM = [[self configGet:@"distance_variationM"] integerValue];
            NSInteger variationKm = [[self configGet:@"distance_variationKm"] integerValue];

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
        after = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"direction"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);

        c = [self configGet:@"direction_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering direction", [self class]);
            NSInteger direction = [[self configGet:@"direction_direction"] integerValue];

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

        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[caches count]);
        currentWaypoints = caches;
        needsRefresh = NO;
    }
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
    [waypointManager needsRefresh];
    [dbFilter dbUpdateOrInsert:_name value:_value];
}

/* Receive data from the location manager */
- (void)updateLocationManagerLocation
{
    // If a distance filter is enabled, and the current location is more than a quarter of the way that distance from the lastCoordinates, refresh the filter.
    NSString *c = [self configGet:@"distance_enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger filterDistanceM = [[self configGet:@"distance_distanceM"] integerValue] + 1000 * [[self configGet:@"distance_distanceKm"] integerValue];
        NSInteger realDistanceM = [Coordinates coordinates2distance:lastCoordinates to:LM.coords];
        if (realDistanceM > filterDistanceM / 4) {
            NSLog(@"Updating filter: %ld - %ld", (long)realDistanceM, (long)filterDistanceM);
            [self needsRefresh];
            lastCoordinates = LM.coords;
        }
    }
}

- (void)setCurrentWaypoint:(dbWaypoint *)wp
{
    currentWaypoint = wp;
    [myConfig currentWaypointUpdate:wp.wpt_name];
}

- (dbWaypoint *)waypoint_byId:(NSId)_id
{
    __block dbWaypoint *cwp = nil;
    [currentWaypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp._id == _id) {
            cwp = wp;
            *stop = YES;
        }
    }];
    return cwp;
}

- (dbWaypoint *)waypoint_byName:(NSString *)name
{
    __block dbWaypoint *cwp = nil;
    [currentWaypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([wp.wpt_name isEqualToString:name] == YES) {
            cwp = wp;
            *stop = YES;
        }
    }];
    return cwp;
}

@end
