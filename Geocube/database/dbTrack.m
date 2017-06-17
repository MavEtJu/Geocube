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

@interface dbTrack ()

@end

@implementation dbTrack

+ (dbTrack *)dbGet:(NSId)id
{
    dbTrack *t;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, startedon, stoppedon from tracks where id = ?");
        SET_VAR_INT(1, id);

        DB_WHILE_STEP {
            t = [[dbTrack alloc] init];
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.name);
            INT_FETCH (2, t.dateStart);
            INT_FETCH (3, t.dateStop);
            [t finish];
        }
        DB_FINISH;
    }
    return t;
}

+ (NSMutableArray<dbTrack *> *)dbAll
{
    NSMutableArray<dbTrack *> *ts = [NSMutableArray arrayWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name, startedon, stoppedon from tracks order by startedon desc");

        DB_WHILE_STEP {
            dbTrack *t = [[dbTrack alloc] init];
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.name);
            INT_FETCH (2, t.dateStart);
            INT_FETCH (3, t.dateStop);
            [t finish];
            [ts addObject:t];
        }
        DB_FINISH;
    }
    return ts;
}

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into tracks(name, startedon, stoppedon) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self.dateStart);
        SET_VAR_INT (3, self.dateStop);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update tracks set name = ?, startedon = ?, stoppedon = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self.dateStart);
        SET_VAR_INT (3, self.dateStop);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbTrack dbCount:@"tracks"];
}

- (void)dbDelete
{
    @synchronized(db) {
        DB_PREPARE(@"delete from tracks where id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
