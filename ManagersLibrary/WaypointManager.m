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

@interface WaypointManager ()

@property (nonatomic        ) CLLocationCoordinate2D lastCoordinates;
@property (nonatomic        ) BOOL needsRefresh;

@property (nonatomic, retain) NSMutableArray<id> *delegatesWaypoints;
@property (nonatomic, retain) NSMutableArray<id> *delegatesKML;

@property (nonatomic, retain, readwrite) dbWaypoint *currentWaypoint;

@end

@implementation WaypointManager

- (instancetype)init
{
    self = [super init];
    NSLog(@"%@: starting", [self class]);

    self.currentWaypoints = nil;
    self.currentWaypoint = nil;
    self.needsRefresh = NO;
    self.lastCoordinates = CLLocationCoordinate2DZero;

    if (IS_EMPTY(configManager.currentWaypoint) == NO)
        self.currentWaypoint = [dbWaypoint dbGetByName:configManager.currentWaypoint];

    [LM startDelegationLocation:self isNavigating:NO];

    self.delegatesWaypoints = [NSMutableArray arrayWithCapacity:5];
    self.delegatesKML = [NSMutableArray arrayWithCapacity:5];
    [self needsRefreshAll];
    [self updateBadges];

    return self;
}

- (void)startDelegationWaypoints:(id)_delegate
{
    NSLog(@"%@: starting for %@", [self class], [_delegate class]);
    if (_delegate != nil)
        [self.delegatesWaypoints addObject:_delegate];
}

- (void)stopDelegationWaypoints:(id)_delegate
{
    NSLog(@"%@: stopping for %@", [self class], [_delegate class]);
    [self.delegatesWaypoints removeObject:_delegate];
}

- (void)startDelegationKML:(id)_delegate
{
    NSLog(@"%@: starting for %@", [self class], [_delegate class]);
    if (_delegate != nil)
        [self.delegatesKML addObject:_delegate];
}

- (void)stopDelegationKML:(id)_delegate
{
    NSLog(@"%@: stopping for %@", [self class], [_delegate class]);
    [self.delegatesKML removeObject:_delegate];
}

- (void)updateBadges
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllByFlag:FLAGS_MARKEDFOUND];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [wps count];
}

- (void)needsRefreshAll
{
    if (self.needsRefresh == NO) {
        self.needsRefresh = YES;

        [self.delegatesWaypoints enumerateObjectsUsingBlock:^(id<WaypointManagerWaypointDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
            // Doing this via the main queue because Google Map Service insists on it.
            NSLog(@"%@: refreshing #%ld: %@", [self class], (unsigned long)idx, [delegate class]);
            MAINQUEUE(
                [delegate refreshWaypoints];
            )
        }];
    }
    [self updateBadges];
}

- (void)needsRefreshAdd:(dbWaypoint *)wp
{
    [self.currentWaypoints addObject:wp];

    [self.delegatesWaypoints enumerateObjectsUsingBlock:^(id<WaypointManagerWaypointDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        // Doing this via the main queue because Google Map Service insists on it.
        NSLog(@"%@: adding #%ld: %@", [self class], (unsigned long)idx, [delegate class]);
        MAINQUEUE(
            [delegate addWaypoint:wp];
        )
    }];
    [self updateBadges];
}

- (void)needsRefreshRemove:(dbWaypoint *)wp
{
    [self.currentWaypoints removeObject:wp];

    [self.delegatesWaypoints enumerateObjectsUsingBlock:^(id<WaypointManagerWaypointDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        // Doing this via the main queue because Google Map Service insists on it.
        NSLog(@"%@: adding #%ld: %@", [self class], (unsigned long)idx, [delegate class]);
        MAINQUEUE(
            [delegate removeWaypoint:wp];
        )
    }];
    [self updateBadges];
}

- (void)needsRefreshUpdate:(dbWaypoint *)wp
{
    NSUInteger idx = [self.currentWaypoints indexOfObject:wp];
    if (idx != NSNotFound)
        [self.currentWaypoints replaceObjectAtIndex:idx withObject:wp];

    [self.delegatesWaypoints enumerateObjectsUsingBlock:^(id<WaypointManagerWaypointDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        // Doing this via the main queue because Google Map Service insists on it.
        NSLog(@"%@: adding #%ld: %@", [self class], (unsigned long)idx, [delegate class]);
        MAINQUEUE(
            [delegate updateWaypoint:wp];
        )
    }];
    [self updateBadges];
}

- (void)applyFilters:(CLLocationCoordinate2D)coords
{
    @synchronized(self) {
        NSLog(@"%@: coordinates %@", [self class], [Coordinates niceCoordinates:coords]);

        /* Do not unnecessary go through this */
        if (self.needsRefresh != YES)
            return;

        NSMutableArray<dbWaypoint *> *waypoints;
        NSMutableArray<dbWaypoint *> *after;
        MyClock *clock = [[MyClock alloc] initClock:@"filter"];
        [clock clockEnable:YES];

        /* Filter out by group:
         * The filter selects out the waypoints which belong to a certain group.
         * If a group is not defined then it will be considered not to be included.
         */

        waypoints = [NSMutableArray arrayWithCapacity:200];
        [clock clockShowAndReset:@"groups"];

        __block NSString *c_groups = [self configGet:@"groups_enabled"];
        __block NSString *c_distance = [self configGet:@"distance_enabled"];
        if (c_groups != nil && [c_groups boolValue] == YES) {
            __block NSMutableArray<dbGroup *> *groups = [NSMutableArray arrayWithCapacity:20];
            [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *c = [self configGet:[NSString stringWithFormat:@"groups_group_%ld", (long)group._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [groups addObject:group];
            }];
            [waypoints addObjectsFromArray:[dbWaypoint dbAllInGroups:groups]];
        } else if (c_distance != nil && [c_distance boolValue] == YES) {
            NSInteger compareDistance = [[self configGet:@"distance_compareDistance"] integerValue];
            NSInteger distanceM = [[self configGet:@"distance_distanceM"] integerValue];
            NSInteger distanceKm = [[self configGet:@"distance_distanceKm"] integerValue];
            NSInteger variationM = [[self configGet:@"distance_variationM"] integerValue];
            NSInteger variationKm = [[self configGet:@"distance_variationKm"] integerValue];

#define KM_IN_DEGREE 110000.0

            // On the equator there are 111 kilometers in a degrees longitude.
            // As such by filtering these distance you will be able to speed up the loading of the waypoints from the database.
            switch (compareDistance) {
                case FILTER_DISTANCE_LESSTHAN: {
                    CLLocationCoordinate2D LB = CLLocationCoordinate2DMake(coords.latitude - ((distanceKm * 1000 + distanceM) / KM_IN_DEGREE), coords.longitude - ((distanceKm * 1000 + distanceM) / KM_IN_DEGREE));
                    CLLocationCoordinate2D RT = CLLocationCoordinate2DMake(coords.latitude + ((distanceKm * 1000 + distanceM) / KM_IN_DEGREE), coords.longitude + ((distanceKm * 1000 + distanceM) / KM_IN_DEGREE));
                    waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllInRect:LB RT:RT]];
                    break;
                }
                case FILTER_DISTANCE_MORETHAN:
                    // Don't worry about these...
                    waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
                    break;
                case FILTER_DISTANCE_INBETWEEN: {
                    CLLocationCoordinate2D LB = CLLocationCoordinate2DMake(coords.latitude - (((distanceKm + variationKm) * 1000 + distanceM + variationM) / KM_IN_DEGREE), coords.longitude - (((distanceKm + variationKm) * 1000 + distanceM + variationM) / KM_IN_DEGREE));
                    CLLocationCoordinate2D RT = CLLocationCoordinate2DMake(coords.latitude + (((distanceKm + variationKm) * 1000 + distanceM + variationM) / KM_IN_DEGREE), coords.longitude + (((distanceKm + variationKm) * 1000 + distanceM + variationM) / KM_IN_DEGREE));
                    waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllInRect:LB RT:RT]];
                    break;
                }
            }

        } else {
            waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
            [clock clockShowAndReset:@"dbAll"];
        }
        NSLog(@"%@: Number of waypoints after loading: %ld", [self class], (unsigned long)[waypoints count]);

        /* Filter out accounts
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"accounts"];

        __block NSString *c = [self configGet:@"accounts_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering acounts", [self class]);

            [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *c = [self configGet:[NSString stringWithFormat:@"accounts_account_%ld", (long)account._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.account._id == account._id)
                        [after addObject:wp];
                }];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out cache types:
         * The filter selects out the waypoints which are of a certain type.
         * If a type is not defined then it will be considered not to be included.
         */

        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"types"];

        c = [self configGet:@"types_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering types", [self class]);
            [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
                c = [self configGet:[NSString stringWithFormat:@"types_type_%ld", (long)type._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.wpt_type._id == type._id)
                        [after addObject:wp];
                }];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out favourites:
         * - If the min is 0 and the max is 100, then everything goes.
         * - If the min is 0 and the max is not 100, then at most max.
         * - If the min is not 0 and the max is 100, then at least min.
         * - If the min is not 0 and the max is not 100, then between min and max.
         */

        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"favourites"];

        c = [self configGet:@"favourites_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering favourites", [self class]);
            NSInteger min = [[self configGet:@"favourites_min"] integerValue];
            NSInteger max = [[self configGet:@"favourites_max"] integerValue];

            if (min == 0 && max == 100) {
                after = waypoints;
            } else if (min == 0) {
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.gs_favourites <= max)
                        [after addObject:wp];
                }];
            } else if (max == 100) {
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.gs_favourites >= min)
                        [after addObject:wp];
                }];
            } else {
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.gs_favourites >= min && wp.gs_favourites <= max)
                        [after addObject:wp];
                }];
            }

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out pins:
         * The filter selects out the waypoints which are of a certain pin.
         * If a pin is not defined then it will be considered not to be included.
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"sizes"];

        c = [self configGet:@"pins_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering pins", [self class]);
            [dbc.pins enumerateObjectsUsingBlock:^(dbPin * _Nonnull pin, NSUInteger idx, BOOL * _Nonnull stop) {
                c = [self configGet:[NSString stringWithFormat:@"pins_pin_%ld", (long)pin._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.wpt_type.pin._id == pin._id)
                        [after addObject:wp];
                }];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out typeicons:
         * The filter selects out the waypoints which are of a certain typeicon.
         * If a typeicon is not defined then it will be considered not to be included.
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"sizes"];

        c = [self configGet:@"typeicons_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering typeicons", [self class]);
            [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull icon, NSUInteger idx, BOOL * _Nonnull stop) {
                c = [self configGet:[NSString stringWithFormat:@"typeicons_icon_%ld", (long)icon.icon]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.wpt_type.icon == icon.icon && [after containsObject:wp] == NO)
                        [after addObject:wp];
                }];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out sizes:
         * The filter selects out the waypoints which are of a certain size.
         * If a size is not defined then it will be considered not to be included.
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"sizes"];
        NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);

        c = [self configGet:@"sizes_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering sizes", [self class]);
            [dbc.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull container, NSUInteger idx, BOOL * _Nonnull stop) {
                c = [self configGet:[NSString stringWithFormat:@"sizes_container_%ld", (long)container._id]];
                if (c == nil || [c boolValue] == NO)
                    return;
                [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (wp.gs_container._id == container._id)
                        [after addObject:wp];
                }];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out difficulty rating
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"difficulty"];

        c = [self configGet:@"difficulty_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering difficulty", [self class]);
            float min = [[self configGet:@"difficulty_min"] floatValue];
            float max = [[self configGet:@"difficulty_max"] floatValue];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                if (wp.gs_rating_difficulty >= min && wp.gs_rating_difficulty <= max)
                    [after addObject:wp];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter out terrain rating
         */

        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"terrain"];

        c = [self configGet:@"terrain_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering terrain", [self class]);
            float min = [[self configGet:@"terrain_min"] floatValue];
            float max = [[self configGet:@"terrain_max"] floatValue];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                if (wp.gs_rating_terrain >= min && wp.gs_rating_terrain <= max)
                    [after addObject:wp];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }
        NSLog(@"%@: Number of waypoints after filtering terrain: %ld", [self class], (unsigned long)[waypoints count]);

        /* Filter out dates
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"dates"];

        c = [self configGet:@"dates_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering dates", [self class]);
            NSInteger placedEpoch = [[self configGet:@"dates_placed_epoch"] integerValue];
            NSInteger lastLogEpoch = [[self configGet:@"dates_lastlog_epoch"] integerValue];
            NSInteger placedCompare = [[self configGet:@"dates_placed_compare"] integerValue];
            NSInteger lastLogCompare = [[self configGet:@"dates_lastlog_compare"] integerValue];

            switch (placedCompare) {
                case FILTER_DATE_BEFORE: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (wp.wpt_date_placed_epoch <= placedEpoch)
                            [after addObject:wp];
                    }];
                    break;
                }
                case FILTER_DATE_AFTER: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (wp.wpt_date_placed_epoch >= placedEpoch)
                            [after addObject:wp];
                    }];
                    break;
                }
                case FILTER_DATE_ON: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (wp.wpt_date_placed_epoch >= placedEpoch - 86400 && wp.wpt_date_placed_epoch <= placedEpoch + 86400)
                            [after addObject:wp];
                    }];
                    break;
                }
            }

            switch (lastLogCompare) {
                case FILTER_DATE_BEFORE: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray<dbLog *> *logs = [dbLog dbAllByWaypoint:wp];
                        __block BOOL rv = YES;
                        [logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (log.datetime_epoch > lastLogEpoch) {
                                rv = NO;
                                *stop = YES;
                            }
                        }];
                        if (rv == YES)
                            [after addObject:wp];
                    }];
                    break;
                }
                case FILTER_DATE_AFTER: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray<dbLog *> *logs = [dbLog dbAllByWaypoint:wp];
                        __block BOOL rv = NO;
                        [logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (log.datetime_epoch > lastLogEpoch) {
                                rv = YES;
                                *stop = YES;
                            }
                        }];
                        if (rv == YES)
                            [after addObject:wp];
                    }];
                    break;
                }
                case FILTER_DATE_ON: {
                    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSArray<dbLog *> *logs = [dbLog dbAllByWaypoint:wp];
                        __block BOOL rv = NO;
                        [logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
                            if (log.datetime_epoch > lastLogEpoch - 86400 && log.datetime_epoch < lastLogEpoch + 86400) {
                                rv = YES;
                                *stop = YES;
                            }
                        }];
                        if (rv == YES)
                            [after addObject:wp];
                    }];
                    break;
                }
            }

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Text self
         * An empty entry means that it matches.
         */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"text"];

        c = [self configGet:@"text_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering text", [self class]);
            NSString *cachename = [self configGet:@"text_waypointname"];
            NSString *placedby = [self configGet:@"text_placedby"];
            NSString *locality = [self configGet:@"text_locale"];
            NSString *state = [self configGet:@"text_state"];
            NSString *country = [self configGet:@"text_country"];
            NSString *description = [self configGet:@"text_description"];
            NSString *logs = [self configGet:@"text_logs"];

            __block NSMutableArray<dbCountry *> *countries = nil;
            __block NSMutableArray<dbState *> *states = nil;
            __block NSMutableArray<dbLocality *> *localities = nil;
            __block NSMutableArray<dbName *> *owners = nil;

            if (IS_EMPTY(country) == NO) {
                countries = [NSMutableArray arrayWithCapacity:20];
                [dbc.countries enumerateObjectsUsingBlock:^(dbCountry * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([c.name localizedCaseInsensitiveContainsString:country] ||
                        [c.code localizedCaseInsensitiveContainsString:country])
                        [countries addObject:c];
                }];
            }

            if (IS_EMPTY(state) == NO) {
                states = [NSMutableArray arrayWithCapacity:20];
                [dbc.states enumerateObjectsUsingBlock:^(dbState * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([c.name localizedCaseInsensitiveContainsString:state] ||
                        [c.code localizedCaseInsensitiveContainsString:state])
                        [states addObject:c];
                }];
            }

            if (IS_EMPTY(locality) == NO) {
                localities = [NSMutableArray arrayWithCapacity:20];
                [dbc.localities enumerateObjectsUsingBlock:^(dbLocality * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([c.name localizedCaseInsensitiveContainsString:locality])
                        [localities addObject:c];
                }];
            }

            if (IS_EMPTY(placedby) == NO) {
                owners = [NSMutableArray arrayWithCapacity:20];
                [[dbName dbAll] enumerateObjectsUsingBlock:^(dbName * _Nonnull n, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([n.name localizedCaseInsensitiveContainsString:placedby])
                        [owners addObject:n];
                }];
            }

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                __block BOOL rv = YES;

                if (IS_EMPTY(cachename) == NO &&
                    [wp.wpt_name localizedCaseInsensitiveContainsString:cachename] == NO &&
                    [wp.wpt_urlname localizedCaseInsensitiveContainsString:cachename] == NO) {
                    rv = NO;
                }

                if (IS_EMPTY(description) == NO &&
                    [wp.description localizedCaseInsensitiveContainsString:description] == NO &&
                    [wp.gs_long_desc localizedCaseInsensitiveContainsString:description] == NO &&
                    [wp.gs_short_desc localizedCaseInsensitiveContainsString:description] == NO) {
                    rv = NO;
                }

                if (localities != nil) {
                    __block BOOL matched = NO;
                    [localities enumerateObjectsUsingBlock:^(dbLocality * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (s._id == wp.gca_locality._id) {
                            matched = YES;
                            *stop = YES;
                        }
                    }];
                    if (matched == NO)
                        rv = NO;
                }

                if (states != nil) {
                    __block BOOL matched = NO;
                    [states enumerateObjectsUsingBlock:^(dbState * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (s._id == wp.gs_state._id) {
                            matched = YES;
                            *stop = YES;
                        }
                    }];
                    if (matched == NO)
                        rv = NO;
                }

                if (countries != nil) {
                    __block BOOL matched = NO;
                    [countries enumerateObjectsUsingBlock:^(dbCountry * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (c._id == wp.gs_country._id) {
                            matched = YES;
                            *stop = YES;
                        }
                    }];
                    if (matched == NO)
                        rv = NO;
                }

                if (owners != nil) {
                    __block BOOL matched = NO;
                    [owners enumerateObjectsUsingBlock:^(dbName * _Nonnull o, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (o._id == wp.gs_owner._id) {
                            matched = YES;
                            *stop = YES;
                        }
                    }];
                    if (matched == NO)
                        rv = NO;
                }

                if (IS_EMPTY(logs) == NO) {
                    if ([dbLog dbCountByWaypointLogString:wp LogString:logs] == 0)
                        rv = NO;
                }

                if (rv == YES)
                    [after addObject:wp];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter by flags */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"flags"];

        c = [self configGet:@"flags_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSInteger flagHighlight = [[self configGet:@"flags_highlighted"] integerValue];
            NSInteger flagInProgress = [[self configGet:@"flags_inprogress"] integerValue];
            NSInteger flagIgnored = [[self configGet:@"flags_ignored"] integerValue];
            NSInteger flagMarkedFound = [[self configGet:@"flags_markedfound"] integerValue];
            NSInteger flagMarkedDNF = [[self configGet:@"flags_markeddnf"] integerValue];
            NSInteger flagMine = [[self configGet:@"flags_owner"] integerValue];
            NSInteger flagLoggedAsFound = [[self configGet:@"flags_loggedasfound"] integerValue];
            NSInteger flagLoggedAsDNF = [[self configGet:@"flags_loggedasdnf"] integerValue];
            NSInteger flagEnabled = [[self configGet:@"flags_isenabled"] integerValue];
            NSInteger flagArchived = [[self configGet:@"flags_isarchived"] integerValue];

            NSMutableArray<dbWaypoint *> *filtered = [NSMutableArray arrayWithCapacity:[waypoints count]];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL keep = YES;

                if (keep == YES && flagHighlight != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.flag_highlight == NO && flagHighlight == FILTER_FLAGS_NOTSET) || (wp.flag_highlight == YES && flagHighlight == FILTER_FLAGS_SET);
                if (keep == YES && flagInProgress != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.flag_inprogress == NO && flagInProgress == FILTER_FLAGS_NOTSET) || (wp.flag_inprogress == YES && flagInProgress == FILTER_FLAGS_SET);
                if (keep == YES && flagIgnored != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.flag_ignore == NO && flagIgnored == FILTER_FLAGS_NOTSET) || (wp.flag_ignore == YES && flagIgnored == FILTER_FLAGS_SET);
                if (keep == YES && flagMarkedFound != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.flag_markedfound == NO && flagMarkedFound == FILTER_FLAGS_NOTSET) || (wp.flag_markedfound == YES && flagMarkedFound == FILTER_FLAGS_SET);
                if (keep == YES && flagMarkedDNF != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.flag_dnf == NO && flagMarkedDNF == FILTER_FLAGS_NOTSET) || (wp.flag_dnf == YES && flagMarkedDNF == FILTER_FLAGS_SET);
                if (keep == YES && flagMine != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.account.accountname._id != wp.gs_owner._id && flagMine == FILTER_FLAGS_NOTSET) || (wp.account.accountname._id == wp.gs_owner._id && flagMine == FILTER_FLAGS_SET);
                if (keep == YES && flagLoggedAsFound != LOGSTATUS_NOTLOGGED)
                    keep = (wp.logStatus == LOGSTATUS_FOUND && flagLoggedAsFound == FILTER_FLAGS_SET) || (wp.logStatus != LOGSTATUS_FOUND && flagLoggedAsFound == FILTER_FLAGS_NOTSET);
                if (keep == YES && flagLoggedAsDNF != LOGSTATUS_NOTLOGGED)
                    keep = (wp.logStatus == LOGSTATUS_NOTFOUND && flagLoggedAsDNF == FILTER_FLAGS_SET) || (wp.logStatus != LOGSTATUS_NOTFOUND && flagLoggedAsDNF == FILTER_FLAGS_NOTSET);
                if (keep == YES && flagEnabled != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.gs_available == YES && flagEnabled == FILTER_FLAGS_SET) || (wp.gs_available == NO && flagEnabled == FILTER_FLAGS_NOTSET);
                if (keep == YES && flagArchived != FILTER_FLAGS_NOTCHECKED)
                    keep = (wp.gs_archived == YES && flagArchived == FILTER_FLAGS_SET) || (wp.gs_archived == NO && flagArchived == FILTER_FLAGS_NOTSET);

                if (keep == YES)
                    [after addObject:wp];
                else
                    [filtered addObject:wp];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);

            // Now filter out any related waypoints

            after = [NSMutableArray arrayWithCapacity:[waypoints count]];
            [clock clockShowAndReset:@"flags2"];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *suffix = [wp.wpt_name substringFromIndex:2];
                __block BOOL filterout = NO;
                [filtered enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wpf, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *fsuffix = [wpf.wpt_name substringFromIndex:2];
                    if ([fsuffix isEqualToString:suffix] == YES) {
                        filterout = YES;
                        *stop = YES;
                    }
                }];
                if (filterout == YES)
                    return;
                [after addObject:wp];
            }];

            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        } else {

            /* Filter out ignored ones
             */

            after = [NSMutableArray arrayWithCapacity:[waypoints count]];
            [clock clockShowAndReset:@"ignored"];

            NSLog(@"%@ - Filtering ignored", [self class]);
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                if (wp.flag_ignore == NO)
                    [after addObject:wp];
            }];
            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Calculate the distance and the bearing */
        NSLog(@"Coordinates: %@", [Coordinates niceCoordinates:coords]);
        [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
            wp.calculatedDistance = [Coordinates coordinates2distance:coords toLatitude:wp.wpt_latitude toLongitude:wp.wpt_longitude];
            wp.calculatedBearing = [Coordinates coordinates2bearing:coords toLatitude:wp.wpt_latitude toLongitude:wp.wpt_longitude];
        }];

        /* Filter by distance */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"distance"];

        c = [self configGet:@"distance_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering distance", [self class]);
            NSInteger compareDistance = [[self configGet:@"distance_compareDistance"] integerValue];
            NSInteger distanceM = [[self configGet:@"distance_distanceM"] integerValue];
            NSInteger distanceKm = [[self configGet:@"distance_distanceKm"] integerValue];
            NSInteger variationM = [[self configGet:@"distance_variationM"] integerValue];
            NSInteger variationKm = [[self configGet:@"distance_variationKm"] integerValue];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL fine = NO;
                switch (compareDistance) {
                    case FILTER_DISTANCE_LESSTHAN:
                        if (wp.calculatedDistance <= distanceKm * 1000 + distanceM)
                            fine = YES;
                        break;
                    case FILTER_DISTANCE_MORETHAN:
                        if (wp.calculatedDistance >= distanceKm * 1000 + distanceM)
                            fine = YES;
                        break;
                    case FILTER_DISTANCE_INBETWEEN:
                        if (wp.calculatedDistance >= (distanceKm - variationKm) * 1000 + (distanceM - variationM) &&
                            wp.calculatedDistance <= (distanceKm + variationKm) * 1000 + (distanceM + variationM))
                            fine = YES;
                }
                if (fine == YES)
                    [after addObject:wp];
            }];
            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        /* Filter by direction */
        after = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [clock clockShowAndReset:@"direction"];

        c = [self configGet:@"direction_enabled"];
        if (c != nil && [c boolValue] == YES) {
            NSLog(@"%@ - Filtering direction", [self class]);
            NSInteger direction = [[self configGet:@"direction_direction"] integerValue];

            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL fine = NO;

                if (direction == FILTER_DIRECTIONS_NORTH     && (wp.calculatedBearing <=  45 || wp.calculatedBearing >= 315)) fine = YES;
                if (direction == FILTER_DIRECTIONS_NORTHEAST &&  wp.calculatedBearing <=  90 && wp.calculatedBearing >=   0) fine = YES;
                if (direction == FILTER_DIRECTIONS_EAST      &&  wp.calculatedBearing <= 135 && wp.calculatedBearing >=  45) fine = YES;
                if (direction == FILTER_DIRECTIONS_SOUTHEAST &&  wp.calculatedBearing <= 180 && wp.calculatedBearing >=  90) fine = YES;
                if (direction == FILTER_DIRECTIONS_SOUTH     &&  wp.calculatedBearing <= 225 && wp.calculatedBearing >= 135) fine = YES;
                if (direction == FILTER_DIRECTIONS_SOUTHWEST &&  wp.calculatedBearing <= 270 && wp.calculatedBearing >= 180) fine = YES;
                if (direction == FILTER_DIRECTIONS_WEST      &&  wp.calculatedBearing <= 315 && wp.calculatedBearing >= 225) fine = YES;
                if (direction == FILTER_DIRECTIONS_NORTHWEST &&  wp.calculatedBearing <= 360 && wp.calculatedBearing >= 270) fine = YES;

                if (fine == YES)
                    [after addObject:wp];
            }];
            waypoints = after;
            NSLog(@"%@: Number of waypoints after filtering: %ld", [self class], (unsigned long)[waypoints count]);
        }

        // Make sure there is always the current waypoint
        if (self.currentWaypoint != nil) {
            __block BOOL found = NO;
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull db, NSUInteger idx, BOOL * _Nonnull stop) {
                if (db._id == self.currentWaypoint._id) {
                    found = YES;
                    *stop = YES;
                }
            }];
            if (found == NO)
                [waypoints addObject:self.currentWaypoint];
        }

        NSLog(@"%@: Number of waypoints at the end: %ld", [self class], (unsigned long)[waypoints count]);
        self.currentWaypoints = waypoints;
        self.needsRefresh = NO;
    }
}

- (NSString *)configGet:(NSString *)name
{
    dbFilter *c = [dbFilter dbGetByKey:name];
    if (c == nil)
        return nil;
    return c.value;
}

- (void)configSet:(NSString *)name value:(NSString *)value
{
    [waypointManager needsRefreshAll];
    [dbFilter dbUpdateOrInsert:name value:value];
}

/* Receive data from the location manager */
- (void)updateLocationManagerLocation
{
    // If a distance filter is enabled, and the current location is more than a quarter of the way that distance from the lastCoordinates, refresh the filter.
    NSString *c = [self configGet:@"distance_enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSInteger filterDistanceM = [[self configGet:@"distance_distanceM"] integerValue] + 1000 * [[self configGet:@"distance_distanceKm"] integerValue];
        NSInteger realDistanceM = [Coordinates coordinates2distance:self.lastCoordinates to:LM.coords];
        if (realDistanceM > filterDistanceM / 4) {
            NSLog(@"WaypointManager:updateLocationManagerLocation: Updating filter: %ld meters > %ld meters", (long)realDistanceM, (long)filterDistanceM);
            [self needsRefreshAll];
            self.lastCoordinates = LM.coords;
        }
    }
}

- (void)setTheCurrentWaypoint:(dbWaypoint *)wp
{
    self.currentWaypoint = wp;
    [configManager currentWaypointUpdate:wp.wpt_name];
}

- (dbWaypoint *)waypoint_byId:(NSId)_id
{
    __block dbWaypoint *cwp = nil;
    [self.currentWaypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.currentWaypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([wp.wpt_name isEqualToString:name] == YES) {
            cwp = wp;
            *stop = YES;
        }
    }];
    return cwp;
}

- (void)refreshKMLs
{
    [self.delegatesKML enumerateObjectsUsingBlock:^(id<WaypointManagerKMLDelegate> delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        // Doing this via the main queue because Google Map Service insists on it.
        MAINQUEUE(
            [delegate reloadKMLFiles];
        )
    }];
}

@end
