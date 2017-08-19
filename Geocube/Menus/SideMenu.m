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

@interface SideMenu ()
{
    NSMutableArray<NSString *> *items;
    LocalMenuItems *localMenuItems;
    id localMenuTarget;

    BOOL buttonsEnabled;
}

@end

@implementation SideMenu

- (void)buttonMenuGlobal:(id)sender
{
    if (buttonsEnabled == YES)
        [self.menuGlobal show];
}

- (void)buttonMenuLocal:(id)sender
{
    if (buttonsEnabled == YES)
        [self.menuLocal show];
}

- (void)enableMenus:(BOOL)YESNO
{
    buttonsEnabled = YESNO;
}

- (void)defineLocalMenu:(LocalMenuItems *)lmi forVC:(id)vc
{
    localMenuItems = lmi;
    localMenuTarget = vc;

    if (localMenuItems == nil) {
        self.menuLocalButton.hidden = YES;
    } else {
        self.menuLocalButton.hidden = NO;
    }
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
            MATCH(RC_NAVIGATE, _(@"menu-Navigate"));
            MATCH(RC_WAYPOINTS, _(@"menu-Waypoints"));
            MATCH(RC_KEEPTRACK, _(@"menu-Keep Track"));
            MATCH(RC_NOTESANDLOGS, _(@"menu-Notes + Logs"));
            MATCH(RC_TRACKABLES, _(@"menu-Trackables"));
            MATCH(RC_GROUPS, _(@"menu-Groups"));
            MATCH(RC_BROWSER, _(@"menu-Browser"));
            MATCH(RC_FILES, _(@"menu-Files"));
            MATCH(RC_STATISTICS, _(@"menu-Statistics"));
            MATCH(RC_SETTINGS, _(@"menu-Settings"));
            MATCH(RC_HELP, _(@"menu-Help"));
            MATCH(RC_LISTS, _(@"menu-Lists"));
            MATCH(RC_QUERIES, _(@"menu-Queries"));
            MATCH(RC_TOOLS, _(@"menu-Tools"));
            MATCH(RC_LOCATIONSLESS, _(@"menu-Locationless"));
            MATCH(RC_DEVELOPER, _(@"menu-Developer"));
            default:
                NSAssert1(FALSE, @"Menu not matched: %ld", (long)i);
        }
    }

    self.menuGlobal = [[VKSideMenu alloc] initWithWidth:220 andDirection:VKSideMenuDirectionLeftToRight];
    self.menuGlobal.dataSource       = self;
    self.menuGlobal.delegate         = self;
    self.menuGlobal.textColor        = [UIColor lightTextColor];
    self.menuGlobal.enableOverlay    = NO;
    self.menuGlobal.hideOnSelection  = YES;
    self.menuGlobal.selectionColor   = [UIColor colorWithWhite:.0 alpha:.3];
    self.menuGlobal.iconsColor       = nil;
    self.menuGlobal.blurEffectStyle  = UIBlurEffectStyleDark;

    // Init custom right-side menu
    self.menuLocal = [[VKSideMenu alloc] initWithWidth:180 andDirection:VKSideMenuDirectionRightToLeft];
    self.menuLocal.dataSource       = self;
    self.menuLocal.delegate         = self;
    self.menuLocal.textColor        = [UIColor lightTextColor];
    self.menuLocal.enableOverlay    = NO;
    self.menuLocal.hideOnSelection  = YES;
    self.menuLocal.selectionColor   = [UIColor colorWithWhite:.0 alpha:.3];
    self.menuLocal.iconsColor       = nil;
    self.menuLocal.blurEffectStyle  = UIBlurEffectStyleDark;
    /* See more options in VKSideMenu.h */

    buttonsEnabled = YES;

    return self;
}

- (NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu
{
    return 1;
}

- (NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section
{
    if (sideMenu == self.menuGlobal)
        return [items count];
    else
        return [localMenuItems countItems];
}

- (VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This solution is provided for DEMO propose only
    // It's beter to store all items in separate arrays like you do it in your UITableView's. Right?
    VKSideMenuItem *item = [VKSideMenuItem new];

    if (sideMenu == self.menuGlobal) {
        item.disabled = NO;
        item.title = [items objectAtIndex:indexPath.row];
    } else
        item = [localMenuItems makeItem:indexPath.row];
    return item;
}

- (void)hideAll
{
    [_menuLocal hide];
    [_menuGlobal hide];
}

#pragma mark - VKSideMenuDelegate

- (NSString *)sideMenu:(VKSideMenu *)sideMenu titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)sideMenuDidShow:(VKSideMenu *)sideMenu
{
//    NSLog(@"%@ VKSideMenue did show", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}

- (void)sideMenuDidHide:(VKSideMenu *)sideMenu
{
//    NSLog(@"%@ VKSideMenue did hide", sideMenu == self.menuLeft ? @"LEFT" : @"RIGHT");
}

- (void)sideMenu:(VKSideMenu *)sideMenu didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"globalMenu didSelectRow: %@", indexPath);
    if (sideMenu == self.menuGlobal) {
        NSLog(@"Switching to %ld", (long)indexPath.row);
        [configManager currentPageUpdate:indexPath.row];
        [_AppDelegate switchController:indexPath.row];
    } else {
        NSLog(@"Local menu action %ld", (long)indexPath.row);
        [localMenuTarget performLocalMenuAction:indexPath.row];
    }
}

@end
