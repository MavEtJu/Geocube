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

@interface dbExternalMap ()

@end

@implementation dbExternalMap

TABLENAME(@"externalmaps")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into externalmaps(geocube_id, enabled, name) values(?, ?, ?)");

        SET_VAR_INT (1, self.geocube_id);
        SET_VAR_BOOL(2, self.enabled);
        SET_VAR_TEXT(3, self.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
    return self._id;
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

+ (NSArray<dbExternalMap *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbExternalMap *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, geocube_id, enabled, name from externalmaps "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

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

+ (NSArray<dbExternalMap *> *)dbAll
{
    return [self dbAllXXX:@"order by geocube_id" keys:nil values:nil];
}

+ (dbExternalMap *)dbGetByGeocubeID:(NSInteger)geocube_id
{
    return [[self dbAllXXX:@"where geocube_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:geocube_id]]] firstObject];
}

@end
