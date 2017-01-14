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

@interface dbProtocol ()

@end

@implementation dbProtocol

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name from protocols order by id");

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

+ (NSInteger)dbCount
{
    return [dbProtocol dbCount:@"protocols"];
}

+ (dbProtocol *)dbGet:(NSId)_id
{
    dbProtocol *p;

    @synchronized(db) {
        DB_PREPARE(@"select id, name from protocols where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            p = [[dbProtocol alloc] init];
            INT_FETCH (0, p._id);
            TEXT_FETCH(1, p.name);
        }
        DB_FINISH;
    }
    return p;
}

+ (dbProtocol *)dbGetByName:(NSString *)name
{
    dbProtocol *p;

    @synchronized(db) {
        DB_PREPARE(@"select id, name from protocols where name = ?");

        SET_VAR_TEXT(1, name);

        DB_IF_STEP {
            p = [[dbProtocol alloc] init];
            INT_FETCH (0, p._id);
            TEXT_FETCH(1, p.name);
        }
        DB_FINISH;
    }
    return p;
}

@end
