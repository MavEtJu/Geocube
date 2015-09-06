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

@implementation dbGroundspeak

@synthesize rating_difficulty, rating_terrain, favourites, country, country_id, country_str, state, state_id, state_str, short_desc_html, short_desc, long_desc_html, long_desc, hint, personal_note, container, container_str, container_id, archived, available, placed_by, owner_gsid, owner, owner_id, owner_str, waypoint_id;

- (id)init:(NSId)__id
{
    self = [super init];
    _id = __id;

    self.waypoint_id = 0;
    self.archived = NO;
    self.available = YES;
    self.country = nil;
    self.state = nil;
    self.short_desc = nil;
    self.short_desc_html = NO;
    self.long_desc = nil;
    self.long_desc_html = NO;
    self.hint = nil;
    self.personal_note = nil;
    self.container = nil;
    self.favourites = 0;
    self.rating_difficulty = 0;
    self.rating_terrain = 0;
    self.placed_by = nil;
    self.owner_gsid = nil;
    self.owner_str = nil;
    self.owner_id = 0;
    self.owner = nil;

    return self;
}

- (void)finish
{
    // Adjust container size
    if (container == nil) {
        if (container_id != 0) {
            container = [dbc Container_get:container_id];
            container_str = container.size;
        }
        if (container_str != nil) {
            container = [dbc Container_get_bysize:container_str];
            container_id = container._id;
        }
    }

    dbWaypoint *waypoint = [dbWaypoint dbGet:waypoint_id]; // This can be nil when an import is happening;

    if (owner == nil) {
        if (owner_id != 0) {
            owner = [dbName dbGet:owner_id];
            owner_str = owner.name;
        }
        if (owner_str != nil) {
            if (owner_gsid == nil)
                owner = [dbName dbGetByName:owner_str account:waypoint.account];
            else
                owner = [dbName dbGetByNameCode:owner_str code:owner_gsid account:waypoint.account];
            owner_id = owner._id;
        }
    }

    if (state == nil) {
        if (state_id != 0) {
            state = [dbc State_get:state_id];
            state_str = state.name;
        }
        if (state_str != nil) {
            state = [dbc State_get_byName:state_str];
            state_id = state._id;
        }
    }

    if (country == nil) {
        if (country_id != 0) {
            country = [dbc Country_get:country_id];
            country_str = country.name;
        }
        if (country_str != nil) {
            country = [dbc Country_get_byName:country_str];
            country_id = country._id;
        }
    }

    [super finish];
}

- (NSInteger)hasLogs {
    return [dbLog dbCountByWaypoint:_id];
}

- (NSInteger)hasAttributes {
    return [dbAttribute dbCountByWaypoint:_id];
}

- (NSInteger)hasFieldNotes { return 0; }
- (NSInteger)hasWaypoints { return 0; }
- (NSInteger)hasImages { return 0; }

- (NSInteger)hasInventory {
    return [dbTravelbug dbCountByWaypoint:_id];
}

+ (NSMutableArray *)dbAll
{
    NSMutableArray *gss = [[NSMutableArray alloc] initWithCapacity:20];
    dbGroundspeak *gs;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner, placed_by_id, waypoint_id from groundspeak");

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            gs = [[dbGroundspeak alloc] init:_id];

            INT_FETCH(    1, gs.country_id);
            INT_FETCH(    2, gs.state_id);
            DOUBLE_FETCH( 3, gs.rating_difficulty);
            DOUBLE_FETCH( 4, gs.rating_terrain);
            INT_FETCH(    5, gs.favourites);
            BOOL_FETCH(   6, gs.long_desc_html);
            TEXT_FETCH(   7, gs.long_desc);
            BOOL_FETCH(   8, gs.short_desc_html);
            TEXT_FETCH(   9, gs.short_desc);
            TEXT_FETCH(  10, gs.hint);
            INT_FETCH(   11, gs.container_id);
            BOOL_FETCH(  12, gs.archived);
            BOOL_FETCH(  13, gs.available);
            INT_FETCH(   14, gs.owner_id);
            TEXT_FETCH(  15, gs.placed_by);
            INT_FETCH(   16, gs.waypoint_id);

            [gs finish];
            [gss addObject:gs];
        }
        DB_FINISH;
    }
    return gss;
}

+ (NSInteger)dbCount
{
    return [dbGroundspeak dbCount:@"groundspeak"];
}

+ (dbGroundspeak *)dbGet:(NSId)_id
{
    dbGroundspeak *gs;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner_id, placed_by, waypoint_id from groundspeak where id = ?");

        SET_VAR_INT( 1, _id);

        DB_IF_STEP {
            gs = [[dbGroundspeak alloc] init:_id];
            INT_FETCH(    0, gs.country_id);
            INT_FETCH(    1, gs.state_id);
            DOUBLE_FETCH( 2, gs.rating_difficulty);
            DOUBLE_FETCH( 3, gs.rating_terrain);
            INT_FETCH(    4, gs.favourites);
            BOOL_FETCH(   5, gs.long_desc_html);
            TEXT_FETCH(   6, gs.long_desc);
            BOOL_FETCH(   7, gs.short_desc_html);
            TEXT_FETCH(   8, gs.short_desc);
            TEXT_FETCH(   9, gs.hint);
            INT_FETCH(   10, gs.container_id);
            BOOL_FETCH(  11, gs.archived);
            BOOL_FETCH(  12, gs.available);
            INT_FETCH(   13, gs.owner_id);
            TEXT_FETCH(  14, gs.placed_by);
            INT_FETCH(   15, gs.waypoint_id);

            [gs finish];
        }
        DB_FINISH;
    }

    return gs;
}

+ (void)dbCreate:(dbGroundspeak *)gs
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into groundspeak(country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner_id, placed_by, waypoint_id) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT(    1, gs.country_id);
        SET_VAR_INT(    2, gs.state_id);
        SET_VAR_DOUBLE( 3, gs.rating_difficulty);
        SET_VAR_DOUBLE( 4, gs.rating_terrain);
        SET_VAR_INT(    5, gs.favourites);
        SET_VAR_BOOL(   6, gs.long_desc_html);
        SET_VAR_TEXT(   7, gs.long_desc);
        SET_VAR_BOOL(   8, gs.short_desc_html);
        SET_VAR_TEXT(   9, gs.short_desc);
        SET_VAR_TEXT(  10, gs.hint);
        SET_VAR_INT(   11, gs.container_id);
        SET_VAR_BOOL(  12, gs.archived);
        SET_VAR_BOOL(  13, gs.available);
        SET_VAR_INT(   14, gs.owner_id);
        SET_VAR_TEXT(  15, gs.placed_by);
        SET_VAR_INT(   16, gs.waypoint_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    gs._id = _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update groundspeak set country_id = ?, state_id = ?, rating_difficulty = ?, rating_terrain = ?, favourites = ?, long_desc_html = ?, long_desc = ?, short_desc_html = ?, short_desc = ?, hint = ?, container_id = ?, archived = ?, available = ?, owner_id = ?, placed_by = ?, waypoint_id = ? where id = ?");

        SET_VAR_INT(    1, country_id);
        SET_VAR_INT(    2, state_id);
        SET_VAR_DOUBLE( 3, rating_difficulty);
        SET_VAR_DOUBLE( 4, rating_terrain);
        SET_VAR_INT(    5, favourites);
        SET_VAR_BOOL(   6, long_desc_html);
        SET_VAR_TEXT(   7, long_desc);
        SET_VAR_BOOL(   8, short_desc_html);
        SET_VAR_TEXT(   9, short_desc);
        SET_VAR_TEXT(  10, hint);
        SET_VAR_INT(   11, container_id);
        SET_VAR_BOOL(  12, archived);
        SET_VAR_BOOL(  13, available);
        SET_VAR_INT(   14, owner_id);
        SET_VAR_TEXT(  15, placed_by);
        SET_VAR_INT(   16, waypoint_id);
        SET_VAR_INT(   17, _id);
        
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end