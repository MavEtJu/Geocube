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

@synthesize text, type, logtype, account, account_id, defaultNote, defaultFound, icon, found, forLogs;

- (void)finish
{
    if (account == nil)
        account = [dbc Account_get:account_id];
    if (account_id == 0)
        account_id = account._id;
}

+ (NSArray *)dbAllXXX:(NSString *)where
{
    NSMutableArray *lss = [[NSMutableArray alloc] initWithCapacity:20];
    NSString *sql = [NSString stringWithFormat:@"select id, text, type, logtype, account_id, default_note, default_found from log_strings %@ order by id", where];

    @synchronized(db.dbaccess) {
        DB_PREPARE(sql);

        DB_WHILE_STEP {
            dbLogString *ls = [[dbLogString alloc] init];
            INT_FETCH (0, ls._id);
            TEXT_FETCH(1, ls.text);
            TEXT_FETCH(2, ls.type);
            INT_FETCH (3, ls.logtype);
            INT_FETCH (4, ls.account_id);
            BOOL_FETCH(5, ls.defaultNote);
            BOOL_FETCH(6, ls.defaultFound);
            [ls finish];
            [lss addObject:ls];
        }
        DB_FINISH;
    }
    return lss;
}

+ (NSArray *)dbAll
{
    return [dbLogString dbAllXXX:@""];
}

+ (NSArray *)dbAllByAccountLogtype_All:(dbAccount *)account logtype:(NSInteger)logtype
{
    NSString *where = [NSString stringWithFormat:@"where account_id = %ld and logtype = %ld", (long)account._id, logtype];
    return [dbLogString dbAllXXX:where];
}

+ (NSArray *)dbAllByAccountLogtype_LogOnly:(dbAccount *)account logtype:(NSInteger)logtype
{
    NSString *where = [NSString stringWithFormat:@"where account_id = %ld and logtype = %ld and forlogs = 1", (long)account._id, logtype];
    return [dbLogString dbAllXXX:where];
}

+ (dbLogString *)dbGetByAccountEventType:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type
{
    NSString *where = [NSString stringWithFormat:@"where account_id = %ld and logtype = %ld and type = '%@'", (long)account._id, logtype, type];
    NSArray *as = [dbLogString dbAllXXX:where];
    if (as == nil)
        return nil;
    if ([as count] == 0)
        return nil;
    return [as objectAtIndex:0];
}

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into log_strings(text, type, logtype, account_id, default_note, default_found, icon, forlogs, found) values(?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT(1, text);
        SET_VAR_TEXT(2, type);
        SET_VAR_INT (3, logtype);
        SET_VAR_INT (4, account_id);
        SET_VAR_BOOL(5, defaultNote);
        SET_VAR_BOOL(6, defaultFound);
        SET_VAR_INT (7, icon);
        SET_VAR_BOOL(8, forLogs);
        SET_VAR_INT (9, found);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update log_strings set text = ?, type = ?, logtype = ?, account_id = ?, default_note = ?, default_found = ?, icon= ?, forlogs = ?, found = ? where id = ?");

        SET_VAR_TEXT( 1, text);
        SET_VAR_TEXT( 2, type);
        SET_VAR_INT ( 3, logtype);
        SET_VAR_INT ( 4, account_id);
        SET_VAR_BOOL( 5, defaultNote);
        SET_VAR_BOOL( 6, defaultFound);
        SET_VAR_INT ( 7, icon);
        SET_VAR_BOOL( 8, forLogs);
        SET_VAR_INT ( 9, found);
        SET_VAR_INT (10, _id);

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

+ (NSInteger)wptTypeToLogType:(NSString *)type_full
{
    if ([type_full isEqualToString:@"Geocache|Event Cache"] == YES ||
        [type_full isEqualToString:@"Geocache|Event"] == YES ||
        [type_full isEqualToString:@"Geocache|CITO"] == YES ||
        [type_full isEqualToString:@"Geocache|Cache In Trash Out Event"] == YES ||
        [type_full isEqualToString:@"Geocache|Giga"] == YES ||
        [type_full isEqualToString:@"Geocache|Giga-Event Cache"] == YES ||
        [type_full isEqualToString:@"Geocache|Mega-Event Cache"] == YES ||
        [type_full isEqualToString:@"Geocache|Groundspeak Block Party"] == YES ||
        [type_full isEqualToString:@"Lost and Found Event Caches"] == YES ||
        [type_full isEqualToString:@"Geocache|Mega"] == YES)
        return LOGSTRING_LOGTYPE_EVENT;
    return LOGSTRING_LOGTYPE_WAYPOINT;
}

@end
