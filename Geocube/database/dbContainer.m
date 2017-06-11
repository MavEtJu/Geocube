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

@interface dbContainer ()

@end

@implementation dbContainer

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id size:(NSString *)size icon:(NSInteger)icon
{
    self = [super init];
    self._id = _id;
    self.gc_id = gc_id;
    self.size = size;
    self.icon = icon;
    [self finish];
    return self;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update containers set size = ?, icon = ?, gc_id = ? where id = ?");

        SET_VAR_TEXT( 1, self.size);
        SET_VAR_INT ( 2, self.icon);
        SET_VAR_INT ( 3, self.gc_id);
        SET_VAR_INT ( 4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbContainer *> *)dbAll
{
    NSMutableArray<dbContainer *>*ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, size, icon, gc_id from containers");

        DB_WHILE_STEP {
            dbContainer *c = [[dbContainer alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.size);
            INT_FETCH (2, c.icon);
            INT_FETCH (3, c.gc_id);
            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSInteger)dbCount
{
    return [dbContainer dbCount:@"containers"];
}

+ (dbContainer *)dbGetByGCID:(NSInteger)gc_id
{
    dbContainer *a = nil;

    @synchronized(db) {
        DB_PREPARE(@"select id, size, icon, gc_id from containers where gc_id = ?");
        SET_VAR_INT(1, gc_id);

        DB_IF_STEP {
            a = [[dbContainer alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.size);
            INT_FETCH (2, a.icon);
            INT_FETCH (3, a.gc_id);
        }
        DB_FINISH;
    }
    return a;
}

+ (NSId)dbCreate:(dbContainer *)c
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into containers(size, icon, gc_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, c.size);
        SET_VAR_INT (2, c.icon);
        SET_VAR_INT (3, c.gc_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

@end
