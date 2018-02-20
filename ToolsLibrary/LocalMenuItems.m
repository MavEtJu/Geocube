/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@interface LocalMenuItems ()

@property (nonatomic, retain) NSMutableArray<NSString *> *makeMenuItems;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *makeMenuDisableds;
@property (nonatomic        ) NSInteger makeMenuMax;

@end

@implementation LocalMenuItems

- (instancetype)init:(NSInteger)max
{
    self = [super init];

    self.makeMenuItems = [[NSMutableArray alloc] initWithCapacity:max];
    self.makeMenuDisableds = [[NSMutableArray alloc] initWithCapacity:max];
    self.makeMenuMax = max;

    for (NSInteger i = 0; i < max; i++) {
        [self.makeMenuItems addObject:@""];
        NSNumber *b = [NSNumber numberWithBool:FALSE];
        [self.makeMenuDisableds addObject:b];
    }

    return self;
}

- (void)addItem:(NSInteger)idx label:(NSString *)label
{
    if ([[self.makeMenuItems objectAtIndex:idx] isEqualToString:@""] == NO)
        NSAssert1(FALSE, @"Menuitem %ld already found!", (long)idx);
    NSAssert3(idx < self.makeMenuMax, @"Menuitem %@ (%ld) > max (%ld)!", label, (long)idx, (long)self.makeMenuMax);
    [self.makeMenuItems replaceObjectAtIndex:idx withObject:label];
}

- (void)changeItem:(NSInteger)idx label:(NSString *)label
{
    if ([[self.makeMenuItems objectAtIndex:idx] isEqualToString:@""] == YES)
        NSAssert1(FALSE, @"Menuitem %ld not yet defined!", (long)idx);
    NSAssert3(idx < self.makeMenuMax, @"Menuitem %@ (%ld) > max (%ld)!", label, (long)idx, (long)self.makeMenuMax);
    [self.makeMenuItems replaceObjectAtIndex:idx withObject:label];
}

- (void)enableItem:(NSInteger)idx
{
    NSAssert2(idx < self.makeMenuMax, @"Menuitem %ld > max (%ld)!", (long)idx, (long)self.makeMenuMax);
    NSNumber *b = [NSNumber numberWithBool:NO];
    [self.makeMenuDisableds replaceObjectAtIndex:idx withObject:b];
}

- (void)disableItem:(NSInteger)idx
{
    NSAssert2(idx < self.makeMenuMax, @"Menuitem %ld > max (%ld)!", (long)idx, (long)self.makeMenuMax);
    NSNumber *b = [NSNumber numberWithBool:YES];
    [self.makeMenuDisableds replaceObjectAtIndex:idx withObject:b];
}

- (VKSideMenuItem *)makeItem:(NSInteger)idx
{
    VKSideMenuItem *item = [[VKSideMenuItem alloc] init];
    item.title = [self.makeMenuItems objectAtIndex:idx];
    item.disabled = [[self.makeMenuDisableds objectAtIndex:idx] boolValue];
    return item;
}

- (NSInteger)countItems
{
    return self.makeMenuMax;
}

@end
