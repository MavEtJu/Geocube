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

@interface dbExternalMap ()

@end

@interface dbExternalMapURL ()

@end

@implementation dbExternalMap

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into externalmaps(geocube_id, enabled, name) values(?, ?, ?)");

        SET_VAR_INT (1, _geocube_id);
        SET_VAR_BOOL(2, _enabled);
        SET_VAR_TEXT(3, _name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id)
        DB_FINISH;
    }

    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update externalmaps set geocube_id = ?, enabled = ?, name = ? where id = ?");

        SET_VAR_INT (1, _geocube_id);
        SET_VAR_BOOL(2, _enabled);
        SET_VAR_TEXT(3, _name);
        SET_VAR_INT (4, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, geocube_id, enabled, name from externalmaps order by geocube_id");

        DB_WHILE_STEP {
            dbExternalMap *em = [[dbExternalMap alloc] init];
            INT_FETCH (0, em._id);
            INT_FETCH (1, em.geocube_id);
            BOOL_FETCH(2, em.enabled);
            TEXT_FETCH(3, em.name);
            [ss addObject:em];
        }
        DB_FINISH;
    }
    return ss;
}

+ (dbExternalMap *)dbGetByGeocubeID:(NSId)geocube_id
{
    dbExternalMap *em;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, geocube_id, enabled, name from externalmaps where geocube_id = ?");

        SET_VAR_INT (1, geocube_id);

        DB_WHILE_STEP {
            em = [[dbExternalMap alloc] init];
            INT_FETCH (0, em._id);
            INT_FETCH (1, em.geocube_id);
            BOOL_FETCH(2, em.enabled);
            TEXT_FETCH(3, em.name);
            break;
        }
        DB_FINISH;
    }

    return em;
}

- (NSArray *)getURLs
{
    return [dbExternalMapURL dbAllByExternalMap:_id];
}

+ (NSInteger)dbCount
{
    return [dbContainer dbCount:@"externalmaps"];
}

@end

@implementation dbExternalMapURL

- (void)finish
{
    [super finish];
}

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into externalmap_urls(externalmap_id, model, type, url) values(?, ?, ?, ?)");

        SET_VAR_INT (1, _externalMap_id);
        SET_VAR_TEXT(2, _model);
        SET_VAR_INT (3, _type);
        SET_VAR_TEXT(4, _url);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id)
        DB_FINISH;
    }

    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update externalmap_urls set externalmap_id = ?, model = ?, type = ?, url = ? where id = ?");

        SET_VAR_INT (1, _externalMap_id);
        SET_VAR_TEXT(2, _model);
        SET_VAR_INT (3, _type);
        SET_VAR_TEXT(4, _url);
        SET_VAR_INT( 5, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAllByExternalMap:(NSId)map_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, externalmap_id, model, type, url from externalmap_urls where externalmap_id = ?");

        SET_VAR_INT(1, map_id);

        DB_WHILE_STEP {
            dbExternalMapURL *emu = [[dbExternalMapURL alloc] init];
            INT_FETCH (0, emu._id);
            INT_FETCH (1, emu.externalMap_id);
            TEXT_FETCH(2, emu.model);
            INT_FETCH (3, emu.type);
            TEXT_FETCH(4, emu.url);
            [emu finish];
            [ss addObject:emu];
        }
        DB_FINISH;
    }
    return ss;
}

+ (void)dbDeleteByExternalMap:(NSId)map_id
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from externalmap_urls where externalmap_id = ?")

        SET_VAR_INT(1, map_id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbContainer dbCount:@"externalmap_urls"];
}

@end