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

@synthesize rating_difficulty, rating_terrain, favourites, country, country_int, country_str, state, state_int, state_str, short_desc_html, short_desc, long_desc_html, long_desc, hint, personal_note, container, container_str, container_int, archived, available, owner, placed_by, placed_by_int, placed_by_str;

- (id)init:(NSId)__id
{
    self = [super init];
    _id = __id;

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
    self.placed_by_int = 0;
    self.placed_by = nil;

    return self;
}

- (void)finish
{
    // Adjust container size
    if (container == nil) {
        if (container_int != 0) {
            container = [dbc Container_get:container_int];
            container_str = container.size;
        }
        if (container_str != nil) {
            container = [dbc Container_get_bysize:container_str];
            container_int = container._id;
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
        DB_PREPARE(@"select id, country, state, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner, placed_by from caches");

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            INT_FETCH_AND_ASSIGN(req, 1, _country_id);
            INT_FETCH_AND_ASSIGN(req, 2, _state_id);
            DOUBLE_FETCH_AND_ASSIGN(req, 3, _ratingD);
            DOUBLE_FETCH_AND_ASSIGN(req, 4, _ratingT);
            INT_FETCH_AND_ASSIGN(req, 5, _favourites);
            BOOL_FETCH_AND_ASSIGN(req, 6, _long_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 7, _long_desc);
            BOOL_FETCH_AND_ASSIGN(req, 8, _short_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 9, _short_desc);
            TEXT_FETCH_AND_ASSIGN(req, 10, _hint);
            INT_FETCH_AND_ASSIGN(req, 11, _container_id);
            BOOL_FETCH_AND_ASSIGN(req, 12, _archived);
            BOOL_FETCH_AND_ASSIGN(req, 13, _available);
            TEXT_FETCH_AND_ASSIGN(req, 14, _owner);
            INT_FETCH_AND_ASSIGN(req, 15, _placed_by_int);

            gs = [[dbGroundspeak alloc] init:__id];
            [gs setCountry_int:_country_id];
            [gs setState_int:_state_id];
            [gs setRating_difficulty:_ratingD];
            [gs setRating_terrain:_ratingT];
            [gs setFavourites:_favourites];
            [gs setLong_desc_html:_long_desc_html];
            [gs setLong_desc:_long_desc];
            [gs setShort_desc_html:_short_desc_html];
            [gs setShort_desc:_short_desc];
            [gs setHint:_hint];
            [gs setContainer_int:_container_id];
            [gs setArchived:_archived];
            [gs setAvailable:_available];
            [gs setOwner:_owner];
            [gs setPlaced_by_int:_placed_by_int];
            [gs finish];
            [gss addObject:gs];
        }
        DB_FINISH;
    }
    return gss;
}

+ (NSId)dbGetByName:(NSString *)name
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from caches where name = ?");

        SET_VAR_TEXT(req, 1, name);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            _id = __id;
        }
        DB_FINISH;
    }
    return _id;
}

+ (dbGroundspeak *)dbGet:(NSId)__id
{
    dbGroundspeak *gs;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_id, archived, available, owner, placed_by_id from groundspeak where id = ?");

        SET_VAR_INT(req, 1, __id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, _country_id);
            INT_FETCH_AND_ASSIGN(req, 1, _state_id);
            DOUBLE_FETCH_AND_ASSIGN(req, 2, _ratingD);
            DOUBLE_FETCH_AND_ASSIGN(req, 3, _ratingT);
            INT_FETCH_AND_ASSIGN(req, 4, _favourites);
            BOOL_FETCH_AND_ASSIGN(req, 5, _long_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 6, _long_desc);
            BOOL_FETCH_AND_ASSIGN(req, 7, _short_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 8, _short_desc);
            TEXT_FETCH_AND_ASSIGN(req, 9, _hint);
            INT_FETCH_AND_ASSIGN(req, 10, _container_id);
            BOOL_FETCH_AND_ASSIGN(req, 11, _archived);
            BOOL_FETCH_AND_ASSIGN(req, 12, _available);
            TEXT_FETCH_AND_ASSIGN(req, 13, _owner);
            INT_FETCH_AND_ASSIGN(req, 14, _placed_by_int);

            gs = [[dbGroundspeak alloc] init:__id];
            [gs setCountry_int:_country_id];
            [gs setState_int:_state_id];
            [gs setRating_difficulty:_ratingD];
            [gs setRating_terrain:_ratingT];
            [gs setFavourites:_favourites];
            [gs setLong_desc_html:_long_desc_html];
            [gs setLong_desc:_long_desc];
            [gs setShort_desc_html:_short_desc_html];
            [gs setShort_desc:_short_desc];
            [gs setHint:_hint];
            [gs setContainer_int:_container_id];
            [gs setArchived:_archived];
            [gs setAvailable:_available];
            [gs setOwner:_owner];
            [gs setPlaced_by_int:_placed_by_int];

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
        DB_PREPARE(@"insert into groundspeak(country_id, state_id, rating_difficulty, rating_terrain, favourites, long_desc_html, long_desc, short_desc_html, short_desc, hint, container_size_id, archived, available, owner, placed_by_id) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT(req, 1, gs.country_int);
        SET_VAR_INT(req, 2, gs.state_int);
        SET_VAR_DOUBLE(req, 3, gs.rating_difficulty);
        SET_VAR_DOUBLE(req, 4, gs.rating_terrain);
        SET_VAR_INT(req, 5, gs.favourites);
        SET_VAR_BOOL(req, 6, gs.long_desc_html);
        SET_VAR_TEXT(req, 7, gs.long_desc);
        SET_VAR_BOOL(req, 8, gs.short_desc_html);
        SET_VAR_TEXT(req, 9, gs.short_desc);
        SET_VAR_TEXT(req, 10, gs.hint);
        SET_VAR_INT(req, 11, gs.container_int);
        SET_VAR_BOOL(req, 12, gs.archived);
        SET_VAR_BOOL(req, 13, gs.available);
        SET_VAR_TEXT(req, 14, gs.owner);
        SET_VAR_INT(req, 15, gs.placed_by_int);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update caches set country_id = ?, state_id = ?, rating_difficulty = ?, rating_terrain = ?, favourites = ?, long_desc_html = ?, long_desc = ?, short_desc_html = ?, short_desc = ?, hint = ?, container_size_id = ?, archived = ?, available = ?, owner = ?, placed_by_id = ? where id = ?");

        SET_VAR_INT(req, 1, country_int);
        SET_VAR_INT(req, 2, state_int);
        SET_VAR_DOUBLE(req, 3, rating_difficulty);
        SET_VAR_DOUBLE(req, 4, rating_terrain);
        SET_VAR_INT(req, 5, favourites);
        SET_VAR_BOOL(req, 6, long_desc_html);
        SET_VAR_TEXT(req, 7, long_desc);
        SET_VAR_BOOL(req, 8, short_desc_html);
        SET_VAR_TEXT(req, 9, short_desc);
        SET_VAR_TEXT(req, 10, hint);
        SET_VAR_INT(req, 11, container_int);
        SET_VAR_BOOL(req, 12, archived);
        SET_VAR_BOOL(req, 13, available);
        SET_VAR_TEXT(req, 14, owner);
        SET_VAR_INT(req, 15, placed_by_id);
        SET_VAR_INT(req, 16, _id);
        
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end