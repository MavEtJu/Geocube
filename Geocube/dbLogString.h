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

@interface dbLogString : dbObject

enum {
    LOGSTRING_LOGTYPE_UNKNOWN = 0,
    LOGSTRING_LOGTYPE_EVENT,
    LOGSTRING_LOGTYPE_WAYPOINT,
    LOGSTRING_LOGTYPE_TRACKABLEPERSON,
    LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT,

    LOGSTRING_FOUND_NO = 0,
    LOGSTRING_FOUND_YES,
    LOGSTRING_FOUND_NA,
};

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) dbAccount *account;
@property (nonatomic) NSId account_id;
@property (nonatomic) BOOL defaultNote;
@property (nonatomic) BOOL defaultFound;
@property (nonatomic) BOOL forLogs;
@property (nonatomic) NSInteger logtype;
@property (nonatomic) NSInteger found;
@property (nonatomic) NSInteger icon;

+ (NSInteger)stringToLogtype:(NSString *)string;
+ (NSInteger)wptTypeToLogType:(NSString *)type_full;
+ (void)dbDeleteAll;
+ (NSArray *)dbAllByAccount:(dbAccount *)account;
+ (dbLogString *)dbGet_byAccountLogtypeType:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type;
+ (NSArray *)dbAllByAccountLogtype_All:(dbAccount *)account logtype:(NSInteger)logtype;
+ (NSArray *)dbAllByAccountLogtype_LogOnly:(dbAccount *)account logtype:(NSInteger)logtype;
+ (dbLogString *)dbGetByAccountEventType:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type;

@end
