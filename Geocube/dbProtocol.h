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

typedef NS_ENUM(NSInteger, ProtocolId) {
    PROTOCOL_NONE = 0,
    PROTOCOL_LIVEAPI = 1,
    PROTOCOL_OKAPI = 2,
    PROTOCOL_GCA = 3,
    PROTOCOL_GCA2 = 4,
    PROTOCOL_GGCW = 5,
};

@interface dbProtocol : dbObject

@property (nonatomic, retain) NSString *name;

+ (dbProtocol *)dbGetByName:(NSString *)name;
+ (dbProtocol *)dbGet:(NSId)_id;

@end
