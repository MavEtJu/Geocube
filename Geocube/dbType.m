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

#import "Geocube-Prefix.pch"

@interface dbType ()
{
    NSString *type_major;
    NSString *type_minor;
    NSString *type_full;
    NSInteger icon;
    NSId pin_id;
    dbPin *pin;

    /* Not read from the database */
    BOOL selected;
}

@end

@implementation dbType

@synthesize type_major, type_minor, type_full, icon, pin_id, pin, selected;

- (void)finish
{
    type_full = [NSString stringWithFormat:@"%@|%@", type_major, type_minor];
    pin = [dbc Pin_get:pin_id];

    [super finish];
}

+ (NSArray *)dbAll
{
    NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, type_major, type_minor, icon, pin_id from types");

        DB_WHILE_STEP {
            dbType *t = [[dbType alloc] init];;
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.type_major);
            TEXT_FETCH(2, t.type_minor);
            INT_FETCH (3, t.icon);
            INT_FETCH (4, t.pin_id);
            [t finish];
            [ts addObject:t];
        }
        DB_FINISH;
    }
    return ts;
}

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into types(type_major, type_minor, icon, pin_id) values(?, ?, ?, ?)");

        SET_VAR_TEXT(1, type_major);
        SET_VAR_TEXT(2, type_minor);
        SET_VAR_INT (3, icon);
        SET_VAR_INT (4, pin_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }

    _id = __id;
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update types set type_major = ?, type_minor = ?, icon = ?, pin_id = ? where id = ?");

        SET_VAR_TEXT(1, type_major);
        SET_VAR_TEXT(2, type_minor);
        SET_VAR_INT (3, icon);
        SET_VAR_INT (4, pin_id);
        SET_VAR_INT (5, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbType dbCount:@"types"];
}

@end
