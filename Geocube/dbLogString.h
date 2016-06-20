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

typedef enum {
    LOGSTRING_LOGTYPE_UNKNOWN = 0,
    LOGSTRING_LOGTYPE_EVENT,
    LOGSTRING_LOGTYPE_WAYPOINT,
    LOGSTRING_LOGTYPE_TRACKABLEPERSON,
    LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT,
} LogString_LogTypes;

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) dbAccount *account;
@property (nonatomic) NSId account_id;
@property (nonatomic) BOOL defaultNote;
@property (nonatomic) BOOL defaultFound;
@property (nonatomic) NSInteger logtype;

+ (NSInteger)stringToLogtype:(NSString *)string;
+ (void)dbDeleteAll;
+ (NSArray *)dbAllByAccountLogtype:(dbAccount *)account logtype:(NSInteger)logtype;

@end
