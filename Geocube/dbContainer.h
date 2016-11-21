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

@interface dbContainer : dbObject

@property (nonatomic, retain) NSString *size;
@property (nonatomic) NSInteger icon;
@property (nonatomic) NSInteger gc_id;
@property (nonatomic) BOOL selected;

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id size:(NSString *)size icon:(NSInteger)icon;
+ (dbContainer *)dbGetByGCID:(NSInteger)gc_id;
+ (NSId)dbCreate:(dbContainer *)c;

@end
