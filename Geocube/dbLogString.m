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

@interface dbLogString ()

@end

@implementation dbLogString

@synthesize _id, text, type, logtype, account, account_id, defaultNote, defaultFound, icon, found, forLogs, defaultVisit, defaultDropoff, defaultPickup, defaultDiscover;

- (void)finish
{
    if (account == nil)
        account = [dbc Account_get:account_id];
    if (account_id == 0)
        account_id = account._id;
    [super finish];
}

+ (NSArray *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray *)values
{
    NSMutableArray *lss = [[NSMutableArray alloc] initWithCapacity:20];
    NSString *sql = [NSString stringWithFormat:@"select id, text, type, logtype, account_id, default_note, default_found, icon, forlogs, found, default_visit, default_dropoff, default_pickup, default_discover from log_strings %@ order by id", where];

    @synchronized(db.dbaccess) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);
        DB_WHILE_STEP {
            dbLogString *ls = [[dbLogString alloc] init];
            INT_FETCH ( 0, ls._id);
            TEXT_FETCH( 1, ls.text);
            TEXT_FETCH( 2, ls.type);
            INT_FETCH ( 3, ls.logtype);
            INT_FETCH ( 4, ls.account_id);
            BOOL_FETCH( 5, ls.defaultNote);
            BOOL_FETCH( 6, ls.defaultFound);
            INT_FETCH ( 7, ls.icon);
            BOOL_FETCH( 8, ls.forLogs);
            INT_FETCH ( 9, ls.found);
            BOOL_FETCH(10, ls.defaultVisit);
            BOOL_FETCH(11, ls.defaultDropoff);
            BOOL_FETCH(12, ls.defaultPickup);
            BOOL_FETCH(13, ls.defaultDiscover);
            [ls finish];
            [lss addObject:ls];
        }
        DB_FINISH;
    }
    return lss;
}

+ (NSArray *)dbAllXXX:(NSString *)where
{
    return [dbLogString dbAllXXX:where keys:nil values:nil];
}

+ (NSArray *)dbAll
{
    return [dbLogString dbAllXXX:@""];
}

+ (NSArray *)dbAllByAccount:(dbAccount *)account
{
    return [dbLogString dbAllXXX:@"where account_id = ?"
                            keys:@"i"
                          values:@[[NSNumber numberWithLongLong:account._id]]];
}

+ (NSArray *)dbAllByAccountLogtype_All:(dbAccount *)account logtype:(NSInteger)logtype
{
    return [dbLogString dbAllXXX:@"where account_id = ? and logtype = ?"
                            keys:@"ii"
                          values:@[[NSNumber numberWithLongLong:account._id], [NSNumber numberWithInteger:logtype]]];
}

+ (dbLogString *)dbGet_byAccountLogtypeType:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type;
{
    NSArray *lss = [dbLogString dbAllXXX:@"where account_id = ? and logtype = ? and type = ?"
                                    keys:@"iis"
                                  values:@[[NSNumber numberWithLongLong:account._id], [NSNumber numberWithInteger:logtype], type]];
    if (lss == nil)
        return nil;
    if ([lss count] == 0)
        return nil;
    return [lss objectAtIndex:0];
}

+ (NSArray *)dbAllByAccountLogtype_LogOnly:(dbAccount *)account logtype:(NSInteger)logtype
{
    return [dbLogString dbAllXXX:@"where account_id = ? and logtype = ? and forlogs = 1"
                            keys:@"ii"
                          values:@[[NSNumber numberWithLongLong:account._id], [NSNumber numberWithInteger:logtype]]];
}

+ (dbLogString *)dbGetByAccountEventType:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type
{
    NSArray *as = [dbLogString dbAllXXX:@"where account_id = ? and logtype = ? and type = ?"
                                   keys:@"iis"
                                 values:@[[NSNumber numberWithLongLong:account._id], [NSNumber numberWithInteger:logtype], type]];
    if (as == nil)
        return nil;
    if ([as count] == 0)
        return nil;
    return [as objectAtIndex:0];
}

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into log_strings(text, type, logtype, account_id, default_note, default_found, icon, forlogs, found, default_visit, default_dropoff, default_pickup, default_discover) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, text);
        SET_VAR_TEXT( 2, type);
        SET_VAR_INT ( 3, logtype);
        SET_VAR_INT ( 4, account_id);
        SET_VAR_BOOL( 5, defaultNote);
        SET_VAR_BOOL( 6, defaultFound);
        SET_VAR_INT ( 7, icon);
        SET_VAR_BOOL( 8, forLogs);
        SET_VAR_INT ( 9, found);
        SET_VAR_BOOL(10, defaultVisit);
        SET_VAR_BOOL(11, defaultDropoff);
        SET_VAR_BOOL(12, defaultPickup);
        SET_VAR_BOOL(13, defaultDiscover);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update log_strings set text = ?, type = ?, logtype = ?, account_id = ?, default_note = ?, default_found = ?, icon= ?, forlogs = ?, found = ?, default_visit = ?, default_dropoff = ?, default_pickup = ?, default_discover = ? where id = ?");

        SET_VAR_TEXT( 1, text);
        SET_VAR_TEXT( 2, type);
        SET_VAR_INT ( 3, logtype);
        SET_VAR_INT ( 4, account_id);
        SET_VAR_BOOL( 5, defaultNote);
        SET_VAR_BOOL( 6, defaultFound);
        SET_VAR_INT ( 7, icon);
        SET_VAR_BOOL( 8, forLogs);
        SET_VAR_INT ( 9, found);
        SET_VAR_BOOL(10, defaultVisit);
        SET_VAR_BOOL(11, defaultDropoff);
        SET_VAR_BOOL(12, defaultPickup);
        SET_VAR_BOOL(13, defaultDiscover);
        SET_VAR_INT (14, _id);

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

+ (dbLogString *)dbGetByAccountLogtypeDefault:(dbAccount *)account logtype:(NSInteger)logtype default:(NSInteger)dflt
{
    NSString *what = nil;
    switch (dflt) {
        case LOGSTRING_DEFAULT_NOTE:
            what = @"note";
            break;
        case LOGSTRING_DEFAULT_FOUND:
            what = @"found";
            break;
        case LOGSTRING_DEFAULT_VISIT:
            what = @"visit";
            break;
        case LOGSTRING_DEFAULT_DROPOFF:
            what = @"dropoff";
            break;
        case LOGSTRING_DEFAULT_PICKUP:
            what = @"pickup";
            break;
        case LOGSTRING_DEFAULT_DISCOVER:
            what = @"discover";
            break;
        default:
            NSAssert1(NO, @"Unknown default field: %ld", (long)dflt);
    }

    NSString *where = [NSString stringWithFormat:@"where account_id = ? and logtype = ? and default_%@ = 1", what];
    NSArray *as = [dbLogString dbAllXXX:where
                                   keys:@"ii"
                                 values:@[[NSNumber numberWithLongLong:account._id], [NSNumber numberWithInteger:logtype]]];
    if (as == nil)
        return nil;
    if ([as count] == 0)
        return nil;
    return [as objectAtIndex:0];
}

@end
