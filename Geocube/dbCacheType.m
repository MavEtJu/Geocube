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

#import "Geocube-Prefix.pch"

@implementation dbCacheType

@synthesize _id, type, icon, pin;

- (id)init:(NSInteger)__id type:(NSString *)_type icon:(NSInteger)_icon pin:(NSInteger)_pin
{
    self = [super init];
    _id = __id;
    type = _type;
    icon = _icon;
    pin = _pin;
    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSString *sql = @"select id, type, icon, pin from cache_types";
    sqlite3_stmt *req;
    NSMutableArray *wpts = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheType *wpt;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _type);
            INT_FETCH_AND_ASSIGN(req, 2, _icon);
            INT_FETCH_AND_ASSIGN(req, 3, _pin);
            wpt = [[dbCacheType alloc] init:__id type:_type icon:_icon pin:_pin];
            [wpts addObject:wpt];
        }
        sqlite3_finalize(req);
    }
    return wpts;



}

@end
