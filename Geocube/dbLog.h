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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

@interface dbLog : dbObject {
    NSInteger _id;
    NSInteger gc_id;
    NSInteger cache_id;
    dbCache *cache;
    NSInteger logtype_id;
    NSString *logtype_string;
    dbLogType *logtype;
    NSString *datetime;
    NSString *logger;
    NSString *log;

    // Internal values
    NSInteger cellHeight;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger gc_id;
@property (nonatomic) NSInteger cache_id;
@property (nonatomic, retain) dbCache *cache;
@property (nonatomic) NSInteger logtype_id;
@property (nonatomic, retain) dbLogType *logtype;
@property (nonatomic, retain) NSString *logtype_string;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic) NSInteger datetime_epoch;
@property (nonatomic, retain) NSString *logger;
@property (nonatomic, retain) NSString *log;

// Internal values
@property (nonatomic) NSInteger cellHeight;

- (id)init:(NSInteger)__id gc_id:(NSInteger)gc_id cache_id:(NSInteger)_wpid logtype_id:(NSInteger)_ltid datetime:(NSString *)_datetime logger:(NSString *)_logger log:(NSString *)_log;
- (id)init:(NSInteger)gc_id;

@end
