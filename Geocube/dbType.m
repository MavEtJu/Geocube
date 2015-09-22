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

@synthesize type_major, type_minor, type_full, icon, pin, selected;

- (instancetype)init:(NSId)__id type_major:(NSString *)_type_major type_minor:(NSString *)_type_minor icon:(NSInteger)_icon pin:(NSInteger)_pin
{
    self = [super init];
    _id = __id;
    type_major = _type_major;
    type_minor = _type_minor;
    icon = _icon;
    pin = _pin;
    [self finish];
    return self;
}

- (void)finish
{
    type_full = [NSString stringWithFormat:@"%@|%@", type_major, type_minor];
    [super finish];
}

+ (NSArray *)dbAll
{
    NSMutableArray *ts = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, type_major, type_minor, icon, pin from types");

        DB_WHILE_STEP {
            dbType *t = [[dbType alloc] init];;
            INT_FETCH( 0, t._id);
            TEXT_FETCH(1, t.type_major);
            TEXT_FETCH(2, t.type_minor);
            INT_FETCH( 3, t.icon);
            INT_FETCH( 4, t.pin);
            [t finish];
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
