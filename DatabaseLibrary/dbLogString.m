/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

TABLENAME(@"log_strings")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(protocol);
    @synchronized(db) {
        DB_PREPARE(@"insert into log_strings(display_string, log_string, protocol_id, default_note, default_found, icon, found, default_visit, default_dropoff, default_pickup, default_discover) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, self.displayString);
        SET_VAR_TEXT( 2, self.logString);
        SET_VAR_INT ( 3, self.protocol._id);
        SET_VAR_BOOL( 4, self.defaultNote);
        SET_VAR_BOOL( 5, self.defaultFound);
        SET_VAR_INT ( 6, self.icon);
        SET_VAR_INT ( 7, self.found);
        SET_VAR_BOOL( 8, self.defaultVisit);
        SET_VAR_BOOL( 9, self.defaultDropoff);
        SET_VAR_BOOL(10, self.defaultPickup);
        SET_VAR_BOOL(11, self.defaultDiscover);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update log_strings set display_string = ?, log_string = ?, protocol_id = ?, default_note = ?, default_found = ?, icon= ?, found = ?, default_visit = ?, default_dropoff = ?, default_pickup = ?, default_discover = ? where id = ?");

        SET_VAR_TEXT( 1, self.displayString);
        SET_VAR_TEXT( 2, self.logString);
        SET_VAR_INT ( 3, self.protocol._id);
        SET_VAR_BOOL( 4, self.defaultNote);
        SET_VAR_BOOL( 5, self.defaultFound);
        SET_VAR_INT ( 6, self.icon);
        SET_VAR_INT ( 7, self.found);
        SET_VAR_BOOL( 8, self.defaultVisit);
        SET_VAR_BOOL( 9, self.defaultDropoff);
        SET_VAR_BOOL(10, self.defaultPickup);
        SET_VAR_BOOL(11, self.defaultDiscover);
        SET_VAR_INT (12, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbLogString *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLogString *> *lss = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, display_string, log_string, protocol_id, default_note, default_found, icon, found, default_visit, default_dropoff, default_pickup, default_discover from log_strings "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);
        DB_WHILE_STEP {
            dbLogString *ls = [[dbLogString alloc] init];
            INT_FETCH ( 0, ls._id);
            TEXT_FETCH( 1, ls.displayString);
            TEXT_FETCH( 2, ls.logString);
            INT_FETCH ( 3, i);
            ls.protocol = [dbc protocolGet:i];
            BOOL_FETCH( 4, ls.defaultNote);
            BOOL_FETCH( 5, ls.defaultFound);
            INT_FETCH ( 6, ls.icon);
            INT_FETCH ( 7, ls.found);
            BOOL_FETCH( 8, ls.defaultVisit);
            BOOL_FETCH( 9, ls.defaultDropoff);
            BOOL_FETCH(10, ls.defaultPickup);
            BOOL_FETCH(11, ls.defaultDiscover);
            [ls finish];
            [lss addObject:ls];
        }
        DB_FINISH;
    }
    return lss;
}

+ (dbLogString *)dbGet:(NSId)_id
{
    return [[dbLogString dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

+ (NSArray<dbLogString *> *)dbAll
{
    return [dbLogString dbAllXXX:@"order by id" keys:nil values:nil];
}

+ (NSArray<dbLogString *> *)dbAllByProtocol:(dbProtocol *)protocol
{
    return [dbLogString dbAllXXX:@"where protocol_id = ? order by id" keys:@"i" values:@[[NSNumber numberWithId:protocol._id]]];
}

+ (NSArray<dbLogString *> *)dbAllByProtocol_All:(dbProtocol *)protocol
{
    return [dbLogString dbAllXXX:@"where protocol_id = ? order by id" keys:@"i" values:@[[NSNumber numberWithId:protocol._id]]];
}

+ (NSArray<dbLogString *> *)dbAllByProtocolWPType_LogOnly:(dbProtocol *)protocol wptype:(LogStringWPType)wptype
{
    return [dbLogString dbAllXXX:@"where protocol_id = ? and id in (select log_string_id from log_string_waypoints where wptype = ?) order by id" keys:@"ii" values:@[[NSNumber numberWithId:protocol._id], [NSNumber numberWithInteger:wptype]]];
}

+ (dbLogString *)dbGetByProtocolDisplayString:(dbProtocol *)protocol displayString:(NSString *)displaystring
{
    return [[dbLogString dbAllXXX:@"where protocol_id = ? and display_string = ? order by id" keys:@"is" values:@[[NSNumber numberWithId:protocol._id], displaystring]] firstObject];
}

+ (dbLogString *)dbGetByProtocolWPTypeDefault:(dbProtocol *)protocol wptype:(LogStringWPType)wptype default:(LogStringDefault)dflt
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

    NSString *where = [NSString stringWithFormat:@"where protocol_id = ? and id in (select log_string_id from log_string_waypoints where wptype = ?) and default_%@ = 1", what];
    return [[dbLogString dbAllXXX:where
                             keys:@"ii"
                           values:@[[NSNumber numberWithLongLong:protocol._id], [NSNumber numberWithInteger:wptype]]]
            firstObject];
}

/* Other methods */

+ (LogStringWPType)stringToWPtype:(NSString *)string
{
    if ([string isEqualToString:@"Event"] == YES)
        return LOGSTRING_WPTYPE_EVENT;
    if ([string isEqualToString:@"Waypoint"] == YES)
        return LOGSTRING_WPTYPE_WAYPOINT;
    if ([string isEqualToString:@"TrackableWaypoint"] == YES)
        return LOGSTRING_WPTYPE_TRACKABLEWAYPOINT;
    if ([string isEqualToString:@"TrackablePerson"] == YES)
        return LOGSTRING_WPTYPE_TRACKABLEPERSON;
    if ([string isEqualToString:@"Moveable"] == YES)
        return LOGSTRING_WPTYPE_MOVEABLE;
    if ([string isEqualToString:@"Webcam"] == YES)
        return LOGSTRING_WPTYPE_WEBCAM;
    if ([string isEqualToString:@"LocalLog"] == YES)
        return LOGSTRING_WPTYPE_LOCALLOG;
    return LOGSTRING_WPTYPE_UNKNOWN;
}

+ (LogStringWPType)wptTypeToWPType:(NSString *)type_full
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
        return LOGSTRING_WPTYPE_EVENT;
    if ([type_full isEqualToString:@"Geocache|Moveable"] == YES)
        return LOGSTRING_WPTYPE_MOVEABLE;
    if ([type_full isEqualToString:@"Geocache|Webcam"] == YES ||
        [type_full isEqualToString:@"Geocache|Webcam Cache"] == YES)
        return LOGSTRING_WPTYPE_WEBCAM;
    return LOGSTRING_WPTYPE_WAYPOINT;
}

/*
 _(@"logstring-Announcement");
 _(@"logstring-Archive");
 _(@"logstring-Archived");
 _(@"logstring-Attended");
 _(@"logstring-Comment");
 _(@"logstring-Coords Updated");
 _(@"logstring-Did not find it");
 _(@"logstring-Didn't find it");
 _(@"logstring-Disabled");
 _(@"logstring-Discovered It");
 _(@"logstring-Dropped Off");
 _(@"logstring-Enable Listing");
 _(@"logstring-Enabled");
 _(@"logstring-Flagged as Missing");
 _(@"logstring-Found it");
 _(@"logstring-Grab It (Not from a Cache)");
 _(@"logstring-Grab it");
 _(@"logstring-Grabbed it");
 _(@"logstring-Hidden");
 _(@"logstring-Maintained");
 _(@"logstring-Maintenance performed");
 _(@"logstring-Mark Missing");
 _(@"logstring-Move To Collection");
 _(@"logstring-Move To Inventory");
 _(@"logstring-Moved");
 _(@"logstring-Needs Archived");
 _(@"logstring-Needs Maintenance");
 _(@"logstring-Needs archiving");
 _(@"logstring-Needs maintenance");
 _(@"logstring-Noted");
 _(@"logstring-OC Team comment");
 _(@"logstring-Other");
 _(@"logstring-Owner Maintenance");
 _(@"logstring-Permanently Archived");
 _(@"logstring-Photographed");
 _(@"logstring-Picked Up");
 _(@"logstring-Post Reviewer Note");
 _(@"logstring-Publish Listing");
 _(@"logstring-Post Reviewer Note");
 _(@"logstring-Publish Listing");
 _(@"logstring-Published");
 _(@"logstring-Ready to search");
 _(@"logstring-Retract Listing");
 _(@"logstring-Retracted");
 _(@"logstring-Retrieve It from a Cache");
 _(@"logstring-Spotted");
 _(@"logstring-Submit for Review");
 _(@"logstring-Temporarily Disable Listing");
 _(@"logstring-Temporarily unavailable");
 _(@"logstring-Transfer");
 _(@"logstring-Unarchive");
 _(@"logstring-Unarchived");
 _(@"logstring-Update Coordinates");
 _(@"logstring-Visited");
 _(@"logstring-Webcam Photo Taken");
 _(@"logstring-Will Attend");
 _(@"logstring-Will attend");
 _(@"logstring-Write Note");
 _(@"logstring-Write note");

*/

@end
