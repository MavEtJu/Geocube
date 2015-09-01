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

@implementation dbNotice

@synthesize note, sender, seen, date, cellHeight, geocube_id;

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into notices(note, sender, date, seen, geocube_id) values(?, ?, ?, ?, ?)");

        SET_VAR_TEXT(1, note);
        SET_VAR_TEXT(2, sender);
        SET_VAR_TEXT(3, date);
        SET_VAR_BOOL(4, seen);
        SET_VAR_INT (5, geocube_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id)
        DB_FINISH;
    }
    return _id;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:5];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, note, sender, date, seen, geocube_id from notices order by seen, date, id");

        DB_WHILE_STEP {
            dbNotice *n = [[dbNotice alloc] init];
            INT_FETCH( 0, n._id);
            TEXT_FETCH(1, n.note);
            TEXT_FETCH(2, n.sender);
            TEXT_FETCH(3, n.date);
            BOOL_FETCH(4, n.seen);
            INT_FETCH (5, n.geocube_id);
            [n finish];
            [ss addObject:n];
        }
        DB_FINISH;
    }

    return ss;
}

+ (dbNotice *)dbGetByGCId:(NSInteger)geocube_id
{
    dbNotice *n = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, note, sender, date, seen, geocube_id from notices where geocube_id = ? order by seen, geocube_id desc");

        SET_VAR_INT(1, geocube_id);

        DB_IF_STEP {
            n = [[dbNotice alloc] init];
            INT_FETCH( 0, n._id);
            TEXT_FETCH(1, n.note);
            TEXT_FETCH(2, n.sender);
            TEXT_FETCH(3, n.date);
            BOOL_FETCH(4, n.seen);
            INT_FETCH (5, n.geocube_id);
            [n finish];
        }
        DB_FINISH;
    }
    return n;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update notices set seen = ? where id = ?");

        SET_VAR_BOOL(1, self.seen);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    NSInteger c = 0;
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(*) from notices");
        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

+ (NSInteger)countUnread
{
    NSInteger c = 0;
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(*) from notices set seen = 0");
        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

@end
