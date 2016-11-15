/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

@interface dbType ()

@end

@implementation dbType

- (void)finish
{
    self.type_full = [NSString stringWithFormat:@"%@|%@", self.type_major, self.type_minor];
    self.pin = [dbc Pin_get:self.pin_id];

    [super finish];
}

+ (NSArray *)dbAll
{
    NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, type_major, type_minor, icon, pin_id, has_boundary from types");

        DB_WHILE_STEP {
            dbType *t = [[dbType alloc] init];
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.type_major);
            TEXT_FETCH(2, t.type_minor);
            INT_FETCH (3, t.icon);
            INT_FETCH (4, t.pin_id);
            BOOL_FETCH(5, t.hasBoundary);
            [t finish];
            [ts addObject:t];
        }
        DB_FINISH;
    }
    return ts;
}

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into types(type_major, type_minor, icon, pin_id, has_boundary) values(?, ?, ?, ?, ?)");

        SET_VAR_TEXT(1, self.type_major);
        SET_VAR_TEXT(2, self.type_minor);
        SET_VAR_INT (3, self.icon);
        SET_VAR_INT (4, self.pin_id);
        SET_VAR_BOOL(5, self.hasBoundary);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update types set type_major = ?, type_minor = ?, icon = ?, pin_id = ?, has_boundary = ? where id = ?");

        SET_VAR_TEXT(1, self.type_major);
        SET_VAR_TEXT(2, self.type_minor);
        SET_VAR_INT (3, self.icon);
        SET_VAR_INT (4, self.pin_id);
        SET_VAR_INT (5, self.hasBoundary);
        SET_VAR_INT (6, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (dbType *)dbGetByMajor:(NSString *)major minor:(NSString *)minor
{
    dbType *t = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, type_major, type_minor, icon, pin_id, has_boundary from types where type_minor = ? and type_major = ?");

        SET_VAR_TEXT(1, minor);
        SET_VAR_TEXT(2, major);

        DB_IF_STEP {
            t = [[dbType alloc] init];
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.type_major);
            TEXT_FETCH(2, t.type_minor);
            INT_FETCH (3, t.icon);
            INT_FETCH (4, t.pin_id);
            BOOL_FETCH(5, t.hasBoundary);
            [t finish];
        }
        DB_FINISH;
    }
    return t;
}

+ (NSInteger)dbCount
{
    return [dbType dbCount:@"types"];
}

@end
