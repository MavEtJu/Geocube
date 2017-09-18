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

#import "dbProtocol.h"

@interface dbProtocol ()

@end

@implementation dbProtocol

TABLENAME(@"protocols")

+ (NSArray<dbProtocol *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbProtocol *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name from protocols "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbProtocol *p = [[dbProtocol alloc] init];
            INT_FETCH (0, p._id);
            TEXT_FETCH(1, p.name);
            [ss addObject:p];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbProtocol *> *)dbAll
{
    return [self dbAllXXX:@"order by id" keys:nil values:nil];
}

+ (dbProtocol *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

+ (dbProtocol *)dbGetByName:(NSString *)name
{
    return [[self dbAllXXX:@"where name = ?" keys:@"s" values:@[name]] firstObject];
}

@end
