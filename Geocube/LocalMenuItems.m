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

#import "Geocube-prefix.pch"

@interface LocalMenuItems ()
{
    NSMutableDictionary *makeMenuItems;
    NSInteger makeMenuMax;
}

@end

@implementation LocalMenuItems

- (instancetype)init:(NSInteger)max
{
    self = [super init];

    makeMenuItems = [[NSMutableDictionary alloc] initWithCapacity:max];
    makeMenuMax = max;

    return self;
}

- (void)addItem:(NSInteger)idx label:(NSString *)label
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
    __block BOOL found = NO;
    [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key integerValue] == idx) {
            found = YES;
            *stop = YES;
        }
    }];
    NSAssert1(found == NO, @"Menuitem %ld already found!", (long)idx);

    NSAssert3(idx < makeMenuMax, @"Menuitem %@ (%ld) > max (%ld)!", label, (long)idx, (long)makeMenuMax);
    [makeMenuItems setValue:label forKey:key];
}

- (void)changeItem:(NSInteger)idx label:(NSString *)label
{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)idx];
    __block BOOL found = NO;
    [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key integerValue] == idx) {
            found = YES;
            *stop = YES;
        }
    }];
    NSAssert1(found == YES, @"Menuitem %ld not yet found!", (long)idx);
    [makeMenuItems setValue:label forKey:key];
}

- (void)enableItem:(NSInteger)idx
{
    __block NSString *keyfound = nil;
    [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key integerValue] == idx) {
            keyfound = key;
            *stop = YES;
        }
    }];
    NSAssert1(keyfound != nil, @"Menuitem %ld not found!", (long)idx);
    NSString *value = [makeMenuItems objectForKey:keyfound];
    if ([[value substringToIndex:1] isEqualToString:@"X"] == YES) {
        value = [value substringFromIndex:1];
        [makeMenuItems setValue:value forKey:keyfound];
    }
}

- (void)disableItem:(NSInteger)idx
{
    __block NSString *keyfound = nil;
    [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key integerValue] == idx) {
            keyfound = key;
            *stop = YES;
        }
    }];
    NSAssert1(keyfound != nil, @"Menuitem %ld not found!", (long)idx);
    NSString *value = [makeMenuItems objectForKey:keyfound];
    if ([[value substringToIndex:1] isEqualToString:@"X"] == NO) {
        value = [NSString stringWithFormat:@"X%@", value];
        [makeMenuItems setValue:value forKey:keyfound];
    }
}

- (NSMutableArray *)makeMenu
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:makeMenuMax];
    for (NSInteger i = 0; i < makeMenuMax; i++) {
        __block BOOL found = NO;
        [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
            if ([key integerValue] == i) {
                *stop = YES;
                found = YES;
                [menuItems addObject:obj];
            }
        }];
        NSAssert1(found == YES, @"Menuitem %ld not found!", (long)i);
    }
    return menuItems;
}

@end
