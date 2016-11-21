/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface dbLogString : dbObject

typedef NS_ENUM(NSInteger, LogStringLogType) {
    LOGSTRING_LOGTYPE_UNKNOWN = 0,
    LOGSTRING_LOGTYPE_EVENT,
    LOGSTRING_LOGTYPE_WAYPOINT,
    LOGSTRING_LOGTYPE_TRACKABLEPERSON,
    LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT,

    LOGSTRING_FOUND_NO = 0,
    LOGSTRING_FOUND_YES,
    LOGSTRING_FOUND_NA,

    LOGSTRING_DEFAULT_NOTE = 0,
    LOGSTRING_DEFAULT_FOUND,
    LOGSTRING_DEFAULT_VISIT,
    LOGSTRING_DEFAULT_DROPOFF,
    LOGSTRING_DEFAULT_PICKUP,
    LOGSTRING_DEFAULT_DISCOVER,
};

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *type;
@property (nonatomic) dbProtocol *protocol;
@property (nonatomic) NSString *protocol_string;
@property (nonatomic) NSId protocol_id;
@property (nonatomic) BOOL defaultNote;
@property (nonatomic) BOOL defaultFound;
@property (nonatomic) BOOL defaultVisit;
@property (nonatomic) BOOL defaultDropoff;
@property (nonatomic) BOOL defaultPickup;
@property (nonatomic) BOOL defaultDiscover;
@property (nonatomic) BOOL forLogs;
@property (nonatomic) LogStringLogType logtype;
@property (nonatomic) NSInteger found;
@property (nonatomic) NSInteger icon;

+ (NSInteger)stringToLogtype:(NSString *)string;
+ (NSInteger)wptTypeToLogType:(NSString *)type_full;
+ (void)dbDeleteAll;
+ (NSArray *)dbAllByProtocol:(dbProtocol *)protocol;
+ (dbLogString *)dbGet_byProtocolLogtypeType:(dbProtocol *)protocl logtype:(LogStringLogType)logtype type:(NSString *)type;
+ (NSArray *)dbAllByProtocolLogtype_All:(dbProtocol *)protocl logtype:(LogStringLogType)logtype;
+ (NSArray *)dbAllByProtocolLogtype_LogOnly:(dbProtocol *)protocl logtype:(LogStringLogType)logtype;
+ (dbLogString *)dbGetByProtocolEventType:(dbProtocol *)protocl logtype:(LogStringLogType)logtype type:(NSString *)type;
+ (dbLogString *)dbGetByProtocolLogtypeDefault:(dbProtocol *)protocl logtype:(LogStringLogType)logtype default:(NSInteger)dflt;

@end
