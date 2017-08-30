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

@interface dbExternalMapURL ()

@end

@implementation dbExternalMapURL

TABLENAME(@"externalmap_urls")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(externalMap);
    @synchronized(db) {
        DB_PREPARE(@"insert into externalmap_urls(externalmap_id, model, type, url) values(?, ?, ?, ?)");

        SET_VAR_INT (1, self.externalMap._id);
        SET_VAR_TEXT(2, self.model);
        SET_VAR_INT (3, self.type);
        SET_VAR_TEXT(4, self.url);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update externalmap_urls set externalmap_id = ?, model = ?, type = ?, url = ? where id = ?");

        SET_VAR_INT (1, self.externalMap._id);
        SET_VAR_TEXT(2, self.model);
        SET_VAR_INT (3, self.type);
        SET_VAR_TEXT(4, self.url);
        SET_VAR_INT( 5, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbExternalMapURL *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbExternalMapURL *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, externalmap_id, model, type, url from externalmap_urls "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbExternalMapURL *emu = [[dbExternalMapURL alloc] init];
            INT_FETCH (0, emu._id);
            INT_FETCH (1, emu.externalMap._id);
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

+ (NSArray<dbExternalMapURL *> *)dbAllByExternalMap:(dbExternalMap *)map
{
    return [self dbAllXXX:@"where externalmap_id = ?" keys:@"i" values:@[[NSNumber numberWithId:map._id]]];
}

+ (void)dbDeleteByExternalMap:(dbExternalMap *)map
{
    @synchronized(db) {
        DB_PREPARE(@"delete from externalmap_urls where externalmap_id = ?")

        SET_VAR_INT(1, map._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
