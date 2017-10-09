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

@interface dbLogString : dbObject

@property (nonatomic, retain) NSString *displayString;
@property (nonatomic, retain) NSString *logString;
@property (nonatomic) dbProtocol *protocol;
@property (nonatomic) BOOL defaultNote;
@property (nonatomic) BOOL defaultFound;
@property (nonatomic) BOOL defaultVisit;
@property (nonatomic) BOOL defaultDropoff;
@property (nonatomic) BOOL defaultPickup;
@property (nonatomic) BOOL defaultDiscover;
@property (nonatomic) BOOL defaultDNF;
//@property (nonatomic) BOOL forLogs;
//@property (nonatomic) LogStringWPType wptype;
@property (nonatomic) LogStringFound found;
@property (nonatomic) NSInteger icon;

+ (dbLogString *)dbGet:(NSId)_id;
+ (NSArray<dbLogString *> *)dbAll;
+ (LogStringWPType)stringToWPtype:(NSString *)string;
+ (LogStringWPType)wptTypeToWPType:(NSString *)type_full;
+ (NSArray<dbLogString *> *)dbAllByProtocol:(dbProtocol *)protocol;
+ (dbLogString *)dbGetByProtocolDisplayString:(dbProtocol *)protocol displayString:(NSString *)displayString;
+ (NSArray<dbLogString *> *)dbAllByProtocolWPType_LogOnly:(dbProtocol *)protocol wptype:(LogStringWPType)wptype;
+ (dbLogString *)dbGetByProtocolWPTypeDefault:(dbProtocol *)protocol wptype:(LogStringWPType)wptype default:(LogStringDefault)dflt;

@end
