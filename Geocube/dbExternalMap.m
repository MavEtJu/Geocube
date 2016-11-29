/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface dbExternalMap ()

@end

@interface dbExternalMapURL ()

@end

@implementation dbExternalMap

- (NSId)dbCreate
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into externalmaps(geocube_id, enabled, name) values(?, ?, ?)");

        SET_VAR_INT (1, self.geocube_id);
        SET_VAR_BOOL(2, self.enabled);
        SET_VAR_TEXT(3, self.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id)
        DB_FINISH;
    }

    return _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update externalmaps set geocube_id = ?, enabled = ?, name = ? where id = ?");

        SET_VAR_INT (1, self.geocube_id);
        SET_VAR_BOOL(2, self.enabled);
        SET_VAR_TEXT(3, self.name);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
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

    @synchronized(db) {
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
    return [dbExternalMapURL dbAllByExternalMap:self._id];
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
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into externalmap_urls(externalmap_id, model, type, url) values(?, ?, ?, ?)");

        SET_VAR_INT (1, self.externalMap_id);
        SET_VAR_TEXT(2, self.model);
        SET_VAR_INT (3, self.type);
        SET_VAR_TEXT(4, self.url);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id)
        DB_FINISH;
    }

    return _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update externalmap_urls set externalmap_id = ?, model = ?, type = ?, url = ? where id = ?");

        SET_VAR_INT (1, self.externalMap_id);
        SET_VAR_TEXT(2, self.model);
        SET_VAR_INT (3, self.type);
        SET_VAR_TEXT(4, self.url);
        SET_VAR_INT( 5, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAllByExternalMap:(NSId)map_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
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
    @synchronized(db) {
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
