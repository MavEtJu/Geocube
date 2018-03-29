/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSMutableArray<NSString *> *items;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *item2controller;
@property (nonatomic, retain) LocalMenuItems *localMenuItems;
@property (nonatomic, retain) id localMenuTarget;

@property (nonatomic        ) BOOL buttonsEnabled;

@end

@implementation SideMenu

- (void)buttonMenuGlobal:(id)sender
{
    if (self.buttonsEnabled == YES)
        [self.menuGlobal show];
}

- (void)buttonMenuLocal:(id)sender
{
    if (self.buttonsEnabled == YES)
        [self.menuLocal show];
}

- (void)enableMenus:(BOOL)YESNO
{
    self.buttonsEnabled = YESNO;
}

- (void)defineLocalMenu:(LocalMenuItems *)lmi forVC:(id)vc
{
    self.localMenuItems = lmi;
    self.localMenuTarget = vc;

    if (self.localMenuItems == nil) {
        self.menuLocalButton.hidden = YES;
    } else {
        self.menuLocalButton.hidden = NO;
    }
}

- (instancetype)init
{
    self = [super init];

    #define MATCH(__i__, __s__) \
        case __i__: \
            [self.items addObject:__s__]; \
            [self.item2controller addObject:[NSNumber numberWithInteger:__i__]]; \
            break;

    #define SHOWORHIDE(__i__, __s__, __c__) \
        if (i == __i__) { \
            if (configManager.__c__ == YES) { \
                [self.items addObject:_(__s__)]; \
                [self.item2controller addObject:[NSNumber numberWithInteger:__i__]]; \
            } \
        }

    self.items = [NSMutableArray arrayWithCapacity:RC_MAX];
    self.item2controller = [NSMutableArray arrayWithCapacity:RC_MAX];
    for (NSInteger i = 0; i < RC_MAX; i++) {
        switch (i) {
            MATCH(RC_NAVIGATE, _(@"menu-Navigate"));
            MATCH(RC_WAYPOINTS, _(@"menu-Waypoints"));
            MATCH(RC_KEEPTRACK, _(@"menu-Keep Track"));
            MATCH(RC_NOTESANDLOGS, _(@"menu-Notes + Logs"));
            MATCH(RC_GROUPS, _(@"menu-Groups"));
            MATCH(RC_BROWSER, _(@"menu-Browser"));
            MATCH(RC_FILES, _(@"menu-Files"));
            MATCH(RC_STATISTICS, _(@"menu-Statistics"));
            MATCH(RC_SETTINGS, _(@"menu-Settings"));
            MATCH(RC_HELP, _(@"menu-Help"));
            MATCH(RC_LISTS, _(@"menu-Lists"));
            MATCH(RC_QUERIES, _(@"menu-Queries"));
            MATCH(RC_TOOLS, _(@"menu-Tools"));
            default:
                SHOWORHIDE(RC_TRACKABLES, _(@"menu-Trackables"), serviceShowTrackables)
                else SHOWORHIDE(RC_LOCATIONSLESS, _(@"menu-Locationless"), serviceShowLocationless)
                else SHOWORHIDE(RC_MOVEABLES, _(@"menu-Moveables"), serviceShowMoveables)
                else SHOWORHIDE(RC_DEVELOPER, _(@"menu-Developer"), serviceShowDeveloper)
                else NSAssert1(FALSE, @"Menu not matched: %ld", (long)i);
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

    self.buttonsEnabled = YES;

    return self;
}

- (NSInteger)numberOfSectionsInSideMenu:(VKSideMenu *)sideMenu
{
    return 1;
}

- (NSInteger)sideMenu:(VKSideMenu *)sideMenu numberOfRowsInSection:(NSInteger)section
{
    if (sideMenu == self.menuGlobal)
        return [self.items count];
    else
        return [self.localMenuItems countItems];
}

- (VKSideMenuItem *)sideMenu:(VKSideMenu *)sideMenu itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // This solution is provided for DEMO propose only
    // It's beter to store all items in separate arrays like you do it in your UITableView's. Right?
    VKSideMenuItem *item = [VKSideMenuItem new];

    if (sideMenu == self.menuGlobal) {
        item.disabled = NO;
        item.title = [self.items objectAtIndex:indexPath.row];
    } else
        item = [self.localMenuItems makeItem:indexPath.row];
    return item;
}

- (void)hideAll
{
    [self.menuLocal hide];
    [self.menuGlobal hide];
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
    if (sideMenu == self.menuGlobal) {
        NSInteger i = [[self.item2controller objectAtIndex:indexPath.row] integerValue];
        NSLog(@"Global menu action: %ld -> %ld", indexPath.row, (long)i);
        [configManager currentPageUpdate:i];
        [_AppDelegate switchController:i];
    } else {
        NSLog(@"Local menu action %ld", (long)indexPath.row);
        [self.localMenuTarget performLocalMenuAction:indexPath.row];
    }
}

@end
