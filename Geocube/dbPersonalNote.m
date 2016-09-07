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

@interface dbPersonalNote ()

@end

@implementation dbPersonalNote

@synthesize _id, note, wp_name, cellHeight;

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into personal_notes(wp_name, note) values(?, ?)");

        SET_VAR_TEXT(1, wp_name);
        SET_VAR_TEXT(2, note);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id)
        DB_FINISH;
    }
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update personal_notes set wp_name = ?, note = ? where id = ?");

        SET_VAR_TEXT(1, wp_name);
        SET_VAR_TEXT(2, note);
        SET_VAR_INT (3, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (dbPersonalNote *)dbGetByWaypointID:(NSId)wp_id
{
    dbPersonalNote *pn = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, wp_name, note from personal_notes where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_IF_STEP {
            pn = [[dbPersonalNote alloc] init];
            INT_FETCH (0, pn._id);
            TEXT_FETCH(1, pn.wp_name);
            TEXT_FETCH(2, pn.note);
        }
        DB_FINISH;
    }

    return pn;
}

+ (dbPersonalNote *)dbGetByWaypointName:(NSString *)wpname
{
    dbPersonalNote *pn = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, wp_name, note from personal_notes where wp_name = ?");

        SET_VAR_TEXT(1, wpname);

        DB_IF_STEP {
            pn = [[dbPersonalNote alloc] init];
            INT_FETCH (0, pn._id);
            TEXT_FETCH(1, pn.wp_name);
            TEXT_FETCH(2, pn.note);
        }
        DB_FINISH;
    }

    return pn;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, wp_name, note from personal_notes");

        DB_WHILE_STEP {
            dbPersonalNote *pn = [[dbPersonalNote alloc] init];
            INT_FETCH (0, pn._id);
            TEXT_FETCH(1, pn.wp_name);
            TEXT_FETCH(2, pn.note);
            [ss addObject:pn];
        }
        DB_FINISH;
    }

    return ss;
}

- (void)dbDelete
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from personal_notes where id = ?");

        SET_VAR_INT(1, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbPersonalNote dbCount:@"personal_notes"];
}

@end
