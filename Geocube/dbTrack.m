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

@implementation dbTrack

@synthesize name, dateStart, dateStop;

+ (NSMutableArray *)dbAll
{
    NSMutableArray *ts = [NSMutableArray arrayWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, startedon, stoppedon from tracks");

        DB_WHILE_STEP {
            dbTrack *t = [[dbTrack alloc] init];;
            INT_FETCH( 0, t._id);
            TEXT_FETCH(1, t.name);
            INT_FETCH( 2, t.dateStart);
            INT_FETCH( 3, t.dateStop);
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
        DB_PREPARE(@"insert into tracks(name, startedon, stoppedon) values(?, ?, ?)");

        SET_VAR_TEXT(1, name);
        SET_VAR_INT( 2, dateStart);
        SET_VAR_INT( 3, dateStop);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update tracks set name = ?, startedon = ?, stoppedon = ? where id = ?");

        SET_VAR_TEXT(1, name);
        SET_VAR_INT( 2, dateStart);
        SET_VAR_INT( 3, dateStop);
        SET_VAR_INT( 4, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
