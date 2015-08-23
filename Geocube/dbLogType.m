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

@implementation dbLogType

@synthesize logtype, icon;

- (id)init:(NSId)__id logtype:(NSString *)_logtype icon:(NSInteger)_icon
{
    self = [super init];
    _id = __id;
    logtype = _logtype;
    icon = _icon;
    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *lts = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, logtype, icon from log_types");

        DB_WHILE_STEP {
            dbLogType *lt = [[dbLogType alloc] init];
            INT_FETCH( 0, lt._id);
            TEXT_FETCH(1, lt.logtype);
            INT_FETCH( 2, lt.icon);
            [lts addObject:lt];
        }
        DB_FINISH;
    }
    return lts;
}

+ (NSInteger)dbCount
{
    return [dbLogType dbCount:@"log_types"];
}

@end
