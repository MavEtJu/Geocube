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

#import "dbObject.h"

#import "Geocube-defines.h"

@interface dbObject ()

@end

@implementation dbObject

/*
 * Order of methods:
 *
 * TABLENAME()
 *
 * - (instancetype)init
 * - (void)finish
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

+ NEEDS_OVERLOADING_NSSTRING(dbTablename)

- (instancetype)init
{
    self = [super init];
    finished = NO;

    return self;
}

- NEEDS_OVERLOADING_NSID(dbCreate)

- (void)finish
{
    finished = YES;
}

- NEEDS_OVERLOADING_VOID(dbUpdate)

+ (NSInteger)dbCount
{
    return [self dbCountXXX:nil keys:nil values:nil];
}

+ (NSInteger)dbCountXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values;
{
    NSInteger c = 0;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select count(id) from %@ ", [self dbTablename]];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)
        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

+ NEEDS_OVERLOADING_NSARRAY_DBOBJECT(dbAll)
+ NEEDS_OVERLOADING_DBOBJECT(dbGet:(NSId)_id)

+ (void)dbDeleteAll
{
    @synchronized(db) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@", [self dbTablename]];
        DB_PREPARE(sql);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbDelete
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where id = ?", [[self class] dbTablename]];

    @synchronized(db) {

        DB_PREPARE(sql);

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (BOOL)isEqual:(dbObject *)object
{
    return self._id == object._id;
}

@end
