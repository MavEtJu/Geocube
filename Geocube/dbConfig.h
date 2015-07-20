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

#ifndef Geocube_dbConfig_h
#define Geocube_dbConfig_h

@interface dbConfig : dbObject {
    NSString *key;
    NSString *value;
    NSInteger _id;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

- (id)init:(NSInteger)_id key:(NSString *)key value:(NSString *)value;
+ (dbConfig *)dbGetByKey:(NSString *)key;

@end

#endif
