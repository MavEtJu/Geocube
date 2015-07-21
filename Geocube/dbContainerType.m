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

@implementation dbContainerType

@synthesize size, icon;

- (id)init:(NSId)__id size:(NSString *)_size icon:(NSInteger)_icon
{
    self = [super init];
    _id = __id;
    size = _size;
    icon = _icon;
    [self finish];
    return self;
}

+ (NSMutableArray *)dbAll
{
    NSMutableArray *cts = [[NSMutableArray alloc] initWithCapacity:20];
    dbContainerType *ct;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, size, icon from container_types");

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, size);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            ct = [[dbContainerType alloc] init:_id size:size icon:icon];
            [cts addObject:ct];
        }
        DB_FINISH;
    }
    return cts;
}

@end
