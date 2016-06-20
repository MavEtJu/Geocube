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

@implementation dbLogString

@synthesize text, type, logtype, account, account_id;

- (void)finish
{
    if (account == nil)
        account = [dbc Account_get:account_id];
    if (account_id == 0)
        account_id = account._id;
}

+ (NSArray *)dbAll
{
    NSMutableArray *lss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, text, type, logtype, account_id from log_strings order by id");

        DB_WHILE_STEP {
            dbLogString *ls = [[dbLogString alloc] init];
            INT_FETCH (0, ls._id);
            TEXT_FETCH(1, ls.text);
            TEXT_FETCH(2, ls.type);
            INT_FETCH (3, ls.logtype);
            INT_FETCH (4, ls.account_id);
            [ls finish];
            [lss addObject:ls];
        }
        DB_FINISH;
    }
    return lss;
}

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into log_strings(text, type, logtype, account_id) values(?, ?, ?, ?)");

        SET_VAR_TEXT(1, text);
        SET_VAR_TEXT(2, type);
        SET_VAR_INT (3, logtype);
        SET_VAR_INT (4, account_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update log_strings set text = ?, type = ?, logtype = ?, account_id = ? where id = ?");

        SET_VAR_TEXT(1, text);
        SET_VAR_TEXT(2, type);
        SET_VAR_INT (3, logtype);
        SET_VAR_INT (4, account_id);
        SET_VAR_INT (5, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbDeleteAll
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from log_strings");

        DB_CHECK_OKAY;
        DB_FINISH;
    }

}

+ (NSInteger)dbCount
{
    return [dbLogString dbCount:@"log_strings"];
}

+ (NSInteger)stringToLogtype:(NSString *)string
{
    if ([string isEqualToString:@"Event"] == YES)
        return LOGSTRING_LOGTYPE_EVENT;
    if ([string isEqualToString:@"Waypoint"] == YES)
        return LOGSTRING_LOGTYPE_WAYPOINT;
    if ([string isEqualToString:@"TrackableWaypoint"] == YES)
        return LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT;
    if ([string isEqualToString:@"TrackablePerson"] == YES)
        return LOGSTRING_LOGTYPE_TRACKABLEPERSON;
    return LOGSTRING_LOGTYPE_UNKNOWN;
}

@end
