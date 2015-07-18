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

#import "Geocube-Prefix.pch"

@implementation dbAttribute

@synthesize _id, icon, label, gc_id, _YesNo;

- (id)init:(NSInteger)__id gc_id:(NSInteger)_gc_id label:(NSString *)_label icon:(NSInteger)_icon
{
    self = [super init];

    icon = _icon;
    label = _label;
    gc_id = _gc_id;
    _id = __id;

    [self finish];
    return self;
}

@end
