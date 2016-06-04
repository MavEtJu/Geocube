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

//#define MENU_STRING @"GC"
//
@interface GlobalMenu ()
{
    NSMutableArray *items;
    NSArray *localMenuItems;
    id localMenuTarget;
}

@end

@implementation GlobalMenu

- (void)buttonMenuLeft:(id)sender
{
    [self.menuLeft show];
}

- (void)buttonMenuRight:(id)sender
{
    [self.menuRight show];
}

- (void)defineLocalMenu:(LocalMenuItems *)lmi forVC:(id)vc
{
    localMenuItems = [lmi makeMenu];
    localMenuTarget = vc;
}

- (instancetype)init
{
    self = [super init];

    #define MATCH(__i__, __s__) \
        case __i__: [items addObject:__s__]; \
        break;
    
    items = [NSMutableArray arrayWithCapacity:RC_MAX];
    for (NSInteger i = 0; i < RC_MAX; i++) {
        switch (i) {
            MATCH(RC_NAVIGATE, @"Navigate");
            MATCH(RC_WAYPOINTS, @"Waypoints");
            MATCH(RC_KEEPTRACK, @"Keep Track");
            MATCH(RC_NOTESANDLOGS, @"Notes + Logs");
            MATCH(RC_TRACKABLES, @"Trackables");
            MATCH(RC_GROUPS, @"Groups");
            MATCH(RC_BROWSER, @"Browser");
            MATCH(RC_FILES, @"Files");
            MATCH(RC_USERPROFILE, @"User Profile");
            MATCH(RC_NOTICES, @"Notices");
            MATCH(RC_SETTINGS, @"Settings");
            MATCH(RC_HELP, @"Help");
            MATCH(RC_LISTS, @"Lists");
            MATCH(RC_QUERIES, @"Queries");
            default:
                NSAssert1(FALSE, @"Menu not matched: %ld", (long)i);
        }
    }

    self.menuLeft = [[VKSideMenu alloc] initWithWidth:220 andDirection:VKSideMenuDirectionLeftToRight];
    self.menuLeft.dataSource = self;
    self.menuLeft.delegate   = self;

    // Init custom right-side menu
    self.menuRight = [[VKSideMenu alloc] initWithWidth:180 andDirection:VKSideMenuDirectionRightToLeft];
    self.menuRight.dataSource       = self;
    self.menuRight.delegate         = self;
    self.menuRight.textColor        = [UIColor lightTextColor];
    self.menuRight.enableOverlay    = NO;
    self.menuRight.hideOnSelection  = NO;
    self.menuRight.selectionColor   = [UIColor colorWithWhite:.0 alpha:.3];
    self.menuRight.iconsColor       = nil;
    /* See more options in VKSideMenu.h */

    self.menuRight.blurEffectStyle = UIBlurEffectStyleDark;

    return self;
}

- (NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu
{
    return 1;
}

- (NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section
{
    if (sideMenu == self.menuLeft)
        return [items count];
    else
        return [localMenuItems count];
}

- (VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This solution is provided for DEMO propose only
    // It's beter to store all items in separate arrays like you do it in your UITableView's. Right?
    VKSideMenuItem *item = [VKSideMenuItem new];

    item.icon = nil;
    if (sideMenu == self.menuLeft) {
        item.title = [items objectAtIndex:indexPath.row];
        return item;
    } else {
        item.title = [localMenuItems objectAtIndex:indexPath.row];
    }
    return item;
}

#pragma mark - VKSideMenuDelegate

- (NSString *)sideMenu:(VKSideMenu *)sideMenu titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)sideMenuDidShow:(VKSideMenu *)sideMenu
{
    NSLog(@"%@ VKSideMenue did show", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}

- (void)sideMenuDidHide:(VKSideMenu *)sideMenu
{
    NSLog(@"%@ VKSideMenue did hide", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}

- (void)sideMenu:(VKSideMenu *)sideMenu didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SideMenu didSelectRow: %@", indexPath);
    if (sideMenu == self.menuLeft) {
        NSLog(@"Switching to %ld", (long)indexPath.row);
        [myConfig currentPageUpdate:indexPath.row];
        [_AppDelegate switchController:indexPath.row];
    } else {
        NSLog(@"Local menu action %ld", (long)indexPath.row);
        [localMenuTarget performLocalMenuAction:indexPath.row];
        [self.menuRight hide];
    }
}

@end

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
