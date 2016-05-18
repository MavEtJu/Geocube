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

@interface dbName : dbObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *code;
@property (nonatomic) NSId account_id;
@property (nonatomic, retain) dbAccount *account;

- (instancetype)init:(NSId)_id name:(NSString *)name code:(NSString *)code account:(dbAccount *)account;
+ (void)makeNameExist:(NSString *)name code:(NSString *)code account:(dbAccount *)account;
+ (NSId)dbCreate:(NSString *)name code:(NSString *)code account:(dbAccount *)account;
- (NSId)dbCreate;
+ (dbName *)dbGet:(NSId)_id;
+ (dbName *)dbGetByNameCode:(NSString *)name code:(NSString *)code account:(dbAccount *)account;
+ (dbName *)dbGetByCode:(NSString *)code account:(dbAccount *)account;
+ (dbName *)dbGetByName:(NSString *)name account:(dbAccount *)account;

@end
