/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

#import "Geocube-prefix.pch"

@interface LocalMenuItems ()
{
    NSMutableArray<NSString *> *makeMenuItems;
    NSMutableArray<NSNumber *> *makeMenuDisableds;
    NSInteger makeMenuMax;
}

@end

@implementation LocalMenuItems

- (instancetype)init:(NSInteger)max
{
    self = [super init];

    makeMenuItems = [[NSMutableArray alloc] initWithCapacity:max];
    makeMenuDisableds = [[NSMutableArray alloc] initWithCapacity:max];
    makeMenuMax = max;

    for (NSInteger i = 0; i < max; i++) {
        [makeMenuItems addObject:@""];
        NSNumber *b = [NSNumber numberWithBool:FALSE];
        [makeMenuDisableds addObject:b];
    }

    return self;
}

- (void)addItem:(NSInteger)idx label:(NSString *)label
{
    if ([[makeMenuItems objectAtIndex:idx] isEqualToString:@""] == NO)
        NSAssert1(FALSE, @"Menuitem %ld already found!", (long)idx);
    NSAssert3(idx < makeMenuMax, @"Menuitem %@ (%ld) > max (%ld)!", label, (long)idx, (long)makeMenuMax);
    [makeMenuItems replaceObjectAtIndex:idx withObject:label];
}

- (void)changeItem:(NSInteger)idx label:(NSString *)label
{
    if ([[makeMenuItems objectAtIndex:idx] isEqualToString:@""] == YES)
        NSAssert1(FALSE, @"Menuitem %ld not yet defined!", (long)idx);
    NSAssert3(idx < makeMenuMax, @"Menuitem %@ (%ld) > max (%ld)!", label, (long)idx, (long)makeMenuMax);
    [makeMenuItems replaceObjectAtIndex:idx withObject:label];
}

- (void)enableItem:(NSInteger)idx
{
    NSAssert2(idx < makeMenuMax, @"Menuitem %ld > max (%ld)!", (long)idx, (long)makeMenuMax);
    NSNumber *b = [NSNumber numberWithBool:NO];
    [makeMenuDisableds replaceObjectAtIndex:idx withObject:b];
}

- (void)disableItem:(NSInteger)idx
{
    NSAssert2(idx < makeMenuMax, @"Menuitem %ld > max (%ld)!", (long)idx, (long)makeMenuMax);
    NSNumber *b = [NSNumber numberWithBool:YES];
    [makeMenuDisableds replaceObjectAtIndex:idx withObject:b];
}

- (VKSideMenuItem *)makeItem:(NSInteger)idx
{
    VKSideMenuItem *item = [[VKSideMenuItem alloc] init];
    item.title = [makeMenuItems objectAtIndex:idx];
    item.disabled = [[makeMenuDisableds objectAtIndex:idx] boolValue];
    return item;
}

- (NSInteger)countItems
{
    return makeMenuMax;
}

@end
