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

@interface dbLogString ()

@end

@implementation dbLogString

- (void)finish
{
    if (self.protocol_id == 0) {
        self.protocol = [dbProtocol dbGetByName:self.protocol_string];
        self.protocol_id = self.protocol._id;
    }
    if (self.protocol_string == nil) {
        self.protocol = [dbProtocol dbGet:self.protocol_id];
        self.protocol_string = self.protocol.name;
    }

    [super finish];
}

+ (NSArray<dbLogString *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLogString *> *lss = [[NSMutableArray alloc] initWithCapacity:20];
    NSString *sql = [NSString stringWithFormat:@"select id, text, type, logtype, protocol_id, default_note, default_found, icon, forlogs, found, default_visit, default_dropoff, default_pickup, default_discover from log_strings %@ order by id", where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);
        DB_WHILE_STEP {
            dbLogString *ls = [[dbLogString alloc] init];
            INT_FETCH ( 0, ls._id);
            TEXT_FETCH( 1, ls.text);
            TEXT_FETCH( 2, ls.type);
            INT_FETCH ( 3, ls.logtype);
            INT_FETCH ( 4, ls.protocol_id);
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

+ (NSArray<dbLogString *> *)dbAllXXX:(NSString *)where
{
    return [dbLogString dbAllXXX:where keys:nil values:nil];
}

+ (NSArray<dbLogString *> *)dbAll
{
    return [dbLogString dbAllXXX:@""];
}

+ (NSArray<dbLogString *> *)dbAllByProtocol:(dbProtocol *)protocol
{
    return [dbLogString dbAllXXX:@"where protocol_id = ?"
                            keys:@"i"
                          values:@[[NSNumber numberWithLongLong:protocol._id]]];
}

+ (NSArray<dbLogString *> *)dbAllByProtocolLogtype_All:(dbProtocol *)protocol logtype:(LogStringLogType)logtype
{
    return [dbLogString dbAllXXX:@"where protocol_id = ? and logtype = ?"
                            keys:@"ii"
                          values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:logtype]]];
}

+ (dbLogString *)dbGet_byProtocolLogtypeType:(dbProtocol *)protocol logtype:(LogStringLogType)logtype type:(NSString *)type;
{
    NSArray *lss = [dbLogString dbAllXXX:@"where protocol_id = ? and logtype = ? and type = ?"
                                    keys:@"iis"
                                  values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:logtype], type]];
    if (lss == nil)
        return nil;
    if ([lss count] == 0)
        return nil;
    return [lss objectAtIndex:0];
}

+ (NSArray<dbLogString *> *)dbAllByProtocolLogtype_LogOnly:(dbProtocol *)protocol logtype:(LogStringLogType)logtype
{
    return [dbLogString dbAllXXX:@"where protocol_id = ? and logtype = ? and forlogs = 1"
                            keys:@"ii"
                          values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:logtype]]];
}

+ (dbLogString *)dbGetByProtocolEventType:(dbProtocol *)protocol logtype:(LogStringLogType)logtype type:(NSString *)type
{
    NSArray *as = [dbLogString dbAllXXX:@"where protocol_id = ? and logtype = ? and type = ?"
                                   keys:@"iis"
                                 values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:logtype], type]];
    if (as == nil)
        return nil;
    if ([as count] == 0)
        return nil;
    return [as objectAtIndex:0];
}

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into log_strings(text, type, logtype, protocol_id, default_note, default_found, icon, forlogs, found, default_visit, default_dropoff, default_pickup, default_discover) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, self.text);
        SET_VAR_TEXT( 2, self.type);
        SET_VAR_INT ( 3, self.logtype);
        SET_VAR_INT ( 4, self.protocol_id);
        SET_VAR_BOOL( 5, self.defaultNote);
        SET_VAR_BOOL( 6, self.defaultFound);
        SET_VAR_INT ( 7, self.icon);
        SET_VAR_BOOL( 8, self.forLogs);
        SET_VAR_INT ( 9, self.found);
        SET_VAR_BOOL(10, self.defaultVisit);
        SET_VAR_BOOL(11, self.defaultDropoff);
        SET_VAR_BOOL(12, self.defaultPickup);
        SET_VAR_BOOL(13, self.defaultDiscover);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update log_strings set text = ?, type = ?, logtype = ?, protocol_id = ?, default_note = ?, default_found = ?, icon= ?, forlogs = ?, found = ?, default_visit = ?, default_dropoff = ?, default_pickup = ?, default_discover = ? where id = ?");

        SET_VAR_TEXT( 1, self.text);
        SET_VAR_TEXT( 2, self.type);
        SET_VAR_INT ( 3, self.logtype);
        SET_VAR_INT ( 4, self.protocol_id);
        SET_VAR_BOOL( 5, self.defaultNote);
        SET_VAR_BOOL( 6, self.defaultFound);
        SET_VAR_INT ( 7, self.icon);
        SET_VAR_BOOL( 8, self.forLogs);
        SET_VAR_INT ( 9, self.found);
        SET_VAR_BOOL(10, self.defaultVisit);
        SET_VAR_BOOL(11, self.defaultDropoff);
        SET_VAR_BOOL(12, self.defaultPickup);
        SET_VAR_BOOL(13, self.defaultDiscover);
        SET_VAR_INT (14, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbDeleteAll
{
    @synchronized(db) {
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

+ (dbLogString *)dbGetByProtocolLogtypeDefault:(dbProtocol *)protocol logtype:(LogStringLogType)logtype default:(NSInteger)dflt
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

    NSString *where = [NSString stringWithFormat:@"where protocol_id = ? and logtype = ? and default_%@ = 1", what];
    NSArray *as = [dbLogString dbAllXXX:where
                                   keys:@"ii"
                                 values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:logtype]]];
    if (as == nil)
        return nil;
    if ([as count] == 0)
        return nil;
    return [as objectAtIndex:0];
}

@end
