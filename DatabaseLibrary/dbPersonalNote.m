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

@interface dbPersonalNote ()

@end

@implementation dbPersonalNote

TABLENAME(@"personal_notes")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into personal_notes(wp_name, note) values(?, ?)");

        SET_VAR_TEXT(1, self.wp_name);
        SET_VAR_TEXT(2, self.note);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update personal_notes set wp_name = ?, note = ? where id = ?");

        SET_VAR_TEXT(1, self.wp_name);
        SET_VAR_TEXT(2, self.note);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbPersonalNote *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbPersonalNote *>*ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, wp_name, note from personal_notes "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbPersonalNote *pn = [[dbPersonalNote alloc] init];
            INT_FETCH (0, pn._id);
            TEXT_FETCH(1, pn.wp_name);
            TEXT_FETCH(2, pn.note);
            [ss addObject:pn];
        }
        DB_FINISH;
    }

    return ss;
}

+ (NSArray<dbPersonalNote *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbPersonalNote *)dbGetByWaypointID:(NSId)wp_id
{
    return [[self dbAllXXX:@"where waypoint_id = ?" keys:@"i" values:@[[NSNumber numberWithId:wp_id]]] firstObject];
}

+ (dbPersonalNote *)dbGetByWaypointName:(NSString *)wpname
{
    return [[self dbAllXXX:@"where wp_name = ?" keys:@"s" values:@[wpname]] firstObject];
}

@end
