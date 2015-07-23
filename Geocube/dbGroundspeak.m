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

@synthesize rating_difficulty, rating_terrain, favourites, country, country_id, country_str, state, state_id, state_str, short_desc_html, short_desc, long_desc_html, long_desc, hint, personal_note, container, container_str, container_id, archived, available, owner, placed_by, placed_by_id, placed_by_str, waypoint_id;

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
    self.owner = nil;
    self.placed_by_str = nil;
    self.placed_by_id = 0;
    self.placed_by = nil;

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
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            gs = [[dbGroundspeak alloc] init:_id];

            INT_FETCH(req,    1, gs.country_id);
            INT_FETCH(req,    2, gs.state_id);
            DOUBLE_FETCH(req, 3, gs.rating_difficulty);
            DOUBLE_FETCH(req, 4, gs.rating_terrain);
            INT_FETCH(req,    5, gs.favourites);
            BOOL_FETCH(req,   6, gs.long_desc_html);
            TEXT_FETCH(req,   7, gs.long_desc);
            BOOL_FETCH(req,   8, gs.short_desc_html);
            TEXT_FETCH(req,   9, gs.short_desc);
            TEXT_FETCH(req,  10, gs.hint);
            INT_FETCH(req,   11, gs.container_id);
            BOOL_FETCH(req,  12, gs.archived);
            BOOL_FETCH(req,  13, gs.available);
            TEXT_FETCH(req,  14, gs.owner);
            INT_FETCH(req,   15, gs.placed_by_id);
            INT_FETCH(req,   16, gs.waypoint_id);

            [gs finish];
            [gss addObject:gs];
        }
        DB_FINISH;
    }
    return gss;
}

+ (dbGroundspeak *)dbGet:(NSId)_id
{
    dbGroundspeak *gs;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner, placed_by_id, waypoint_id from groundspeak where id = ?");

        SET_VAR_INT(req, 1, _id);

        DB_IF_STEP {
            gs = [[dbGroundspeak alloc] init:_id];
            INT_FETCH(req,    0, gs.country_id);
            INT_FETCH(req,    1, gs.state_id);
            DOUBLE_FETCH(req, 2, gs.rating_difficulty);
            DOUBLE_FETCH(req, 3, gs.rating_terrain);
            INT_FETCH(req,    4, gs.favourites);
            BOOL_FETCH(req,   5, gs.long_desc_html);
            TEXT_FETCH(req,   6, gs.long_desc);
            BOOL_FETCH(req,   7, gs.short_desc_html);
            TEXT_FETCH(req,   8, gs.short_desc);
            TEXT_FETCH(req,   9, gs.hint);
            INT_FETCH(req,   10, gs.container_id);
            BOOL_FETCH(req,  11, gs.archived);
            BOOL_FETCH(req,  12, gs.available);
            TEXT_FETCH(req,  13, gs.owner);
            INT_FETCH(req,   14, gs.placed_by_id);
            INT_FETCH(req,   15, gs.waypoint_id);

            [gs finish];
        }
        DB_FINISH;
    }

    return gs;
}

+ (NSId)dbCreate:(dbGroundspeak *)gs
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into groundspeak(country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_size_id, archived, available, owner, placed_by_id, waypoint_id) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT(req,    1, gs.country_id);
        SET_VAR_INT(req,    2, gs.state_id);
        SET_VAR_DOUBLE(req, 3, gs.rating_difficulty);
        SET_VAR_DOUBLE(req, 4, gs.rating_terrain);
        SET_VAR_INT(req,    5, gs.favourites);
        SET_VAR_BOOL(req,   6, gs.long_desc_html);
        SET_VAR_TEXT(req,   7, gs.long_desc);
        SET_VAR_BOOL(req,   8, gs.short_desc_html);
        SET_VAR_TEXT(req,   9, gs.short_desc);
        SET_VAR_TEXT(req,  10, gs.hint);
        SET_VAR_INT(req,   11, gs.container_id);
        SET_VAR_BOOL(req,  12, gs.archived);
        SET_VAR_BOOL(req,  13, gs.available);
        SET_VAR_TEXT(req,  14, gs.owner);
        SET_VAR_INT(req,   15, gs.placed_by_id);
        SET_VAR_INT(req,   16, gs.waypoint_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update groundspeak set country_id = ?, state_id = ?, rating_difficulty = ?, rating_terrain = ?, favourites = ?, long_desc_html = ?, long_desc = ?, short_desc_html = ?, short_desc = ?, hint = ?, container_size_id = ?, archived = ?, available = ?, owner = ?, placed_by_id = ?, waypoint_id = ? where id = ?");

        SET_VAR_INT(req,    1, country_id);
        SET_VAR_INT(req,    2, state_id);
        SET_VAR_DOUBLE(req, 3, rating_difficulty);
        SET_VAR_DOUBLE(req, 4, rating_terrain);
        SET_VAR_INT(req,    5, favourites);
        SET_VAR_BOOL(req,   6, long_desc_html);
        SET_VAR_TEXT(req,   7, long_desc);
        SET_VAR_BOOL(req,   8, short_desc_html);
        SET_VAR_TEXT(req,   9, short_desc);
        SET_VAR_TEXT(req,  10, hint);
        SET_VAR_INT(req,   11, container_id);
        SET_VAR_BOOL(req,  12, archived);
        SET_VAR_BOOL(req,  13, available);
        SET_VAR_TEXT(req,  14, owner);
        SET_VAR_INT(req,   15, placed_by_id);
        SET_VAR_INT(req,   16, waypoint_id);
        SET_VAR_INT(req,   17, _id);
        
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end