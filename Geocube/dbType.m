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

@implementation dbType

@synthesize type, icon, pin, selected;

- (id)init:(NSId)__id type:(NSString *)_type icon:(NSInteger)_icon pin:(NSInteger)_pin
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
    NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, type, icon, pin from types");

        DB_WHILE_STEP {
            dbType *t = [[dbType alloc] init];;
            INT_FETCH( 0, t._id);
            TEXT_FETCH(1, t.type);
            INT_FETCH( 2, t.icon);
            INT_FETCH( 3, t.pin);
            [ts addObject:t];
        }
        DB_FINISH;
    }
    return ts;
}

+ (NSInteger)dbCount
{
    return [dbType dbCount:@"types"];
}

@end
