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

@interface dbObject ()

@end

@implementation dbObject

/*
 * Order of methods:
 *
 * - (instancetype)init
 * - (void)finish
 * + (NSInteger)dbCount
 * - (NSId)dbCreate
 * - (void)dbUpdate
 * - (void)dbUpdate...
 * + (NSArray *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
 * + (NSArray *)dbAll
 * + (NSArray *)dbAll...
 * + (instancetype)dbGet:(NSId)id
 * + (instancetype)dbGet...
 * - (void)dbDelete
 * - (void)dbDelete...
 * ... others ...
 *
 */

- NEEDS_OVERLOADING_VOID(dbUpdate)
- NEEDS_OVERLOADING_VOID(dbDelete)
- NEEDS_OVERLOADING_NSID(dbCreate)
+ NEEDS_OVERLOADING_NSARRAY_DBOBJECT(dbAll)
+ NEEDS_OVERLOADING_DBOBJECT(dbGet:(NSId)_id)
+ NEEDS_OVERLOADING_NSINTEGER(dbCount)

- (instancetype)init
{
    self = [super init];
    finished = NO;

    return self;
}

- (void)finish
{
    finished = YES;
}

+ (NSInteger)dbCount:(NSString *)table
{
    NSInteger c = -1;

    @synchronized(db) {
        NSString *sql = [NSString stringWithFormat:@"select count(id) from %@", table];
        DB_PREPARE(sql);

        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

- (BOOL)isEqual:(dbObject *)object
{
    return self._id == object._id;
}

@end
