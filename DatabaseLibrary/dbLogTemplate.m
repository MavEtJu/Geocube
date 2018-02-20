/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface dbLogTemplate ()

@end

@implementation dbLogTemplate

TABLENAME(@"log_templates")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into log_templates(name, text) values(?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.text);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update log_templates set name = ?, text = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.text);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbLogTemplate *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLogTemplate *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, text from log_templates "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbLogTemplate *s = [[dbLogTemplate alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.text);
            [s finish];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbLogTemplate *> *)dbAll
{
    return [self dbAllXXX:@"order by name" keys:nil values:nil];
}

+ (dbLogTemplate *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

/* Other methods */

@end
