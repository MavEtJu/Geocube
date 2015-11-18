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

#define MENU_STRING @"GC"

@interface GlobalMenu ()
{
    NSArray *items;
    DOPNavbarMenu *_global_menu;
    NSInteger numberOfItemsInRow;
    UIViewController<DOPNavbarMenuDelegate> *parent_vc, *previous_vc;
    UIBarButtonItem *button;
    id localMenuDelegate;
    UIButton *localMenuButton;

    CGSize currentFrameSize;
}

@end

@implementation GlobalMenu

@synthesize parent_vc, previous_vc, localMenuDelegate, localMenuButton;

- (instancetype)init
{
    self = [super init];
    items = [NSArray arrayWithObjects:@"Navigate", @"Waypoints", @"Keep Track", @"Notes + Logs", @"Trackables", @"Groups", @"Browser", @"Files", @"User Profile", @"Notices", @"Settings", @"Help", nil];

    //    NSString *imgfile = [NSString stringWithFormat:@"%@/global menu icon.png", [MyTools DataDistributionDirectory]];
    //    UIImage *img = [UIImage imageNamed:imgfile];

    button = [[UIBarButtonItem alloc] initWithTitle:MENU_STRING style:UIBarButtonItemStylePlain target:nil action:@selector(openGlobalMenu:)];
    button.tintColor = [UIColor whiteColor];

    numberOfItemsInRow = 3;

    currentFrameSize = [[UIScreen mainScreen] applicationFrame].size;

    return self;
}

- (void)transitionToSize:(CGSize)newSize
{
    if (newSize.width == currentFrameSize.width && newSize.height == currentFrameSize.height)
        return;

    _global_menu = nil;
    currentFrameSize = newSize;
    UIImage *imgMenu = [imageLibrary get:ImageIcon_LocalMenu];
    localMenuButton.frame = CGRectMake(newSize.width - 2 - imgMenu.size.width, localMenuButton.frame.origin.y, localMenuButton.frame.size.width, localMenuButton.frame.size.height);
}

- (void)setLocalMenuTarget:(UIViewController<DOPNavbarMenuDelegate> *)_vc
{
    // NSLog(@"GlobalMenu/setTarget: from %p to %p", parent_vc, _vc);
    previous_vc = parent_vc;
    parent_vc = _vc;
    button.target = _vc;
    localMenuDelegate = _vc;
}

- (DOPNavbarMenu *)global_menu
{
    if (_global_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];

        [items enumerateObjectsUsingBlock:^(NSString *menuitem, NSUInteger idx, BOOL *stop) {
            BOOL enabled = YES;
            if ([[menuitem substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"X"] == YES) {
                enabled = NO;
                menuitem = [menuitem substringFromIndex:1];
            }
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:menuitem icon:[UIImage imageNamed:@"Image"] enabled:enabled];
            [menuoptions addObject:item];
        }];

        _global_menu = [[DOPNavbarMenu alloc] initWithItems:menuoptions width:parent_vc.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        _global_menu.backgroundColor = [UIColor blackColor];
        _global_menu.separatarColor = [UIColor whiteColor];
        _global_menu.menuName = MENU_STRING;
        _global_menu.delegate = self;
    }
    return _global_menu;
}

- (void)openLocalMenu:(id)sender
{
    if (localMenuDelegate != nil)
        [localMenuDelegate openLocalMenu:sender];
}

- (void)openGlobalMenu:(id)sender
{
    // NSLog(@"GlobalMenu/openMenu: self.vc:%p", self.parent_vc);

    button.enabled = NO;
    if (self.global_menu.isOpen) {
        [self.global_menu dismissWithAnimation:YES];
    } else {
        [self.global_menu showInNavigationController:parent_vc.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
    // NSLog(@"GlobalMenu/didShowMenu: self.vc:%p", self.parent_vc);

    [button setTitle:MENU_STRING];
    button.enabled = NO;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    // NSLog(@"GlobalMenu/didDismissMenu: self.vc:%p", self.parent_vc);

    [button setTitle:MENU_STRING];
    button.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // NSLog(@"GlobalMenu/didSelectedMenu: self.vc:%p", self.parent_vc);

    NSLog(@"Switching to %ld", (long)index);
    [myConfig currentPageUpdate:index];
    [_AppDelegate switchController:index];
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
    NSString *key = [NSString stringWithFormat:@"%ld", idx];
    __block BOOL found = NO;
    [makeMenuItems enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        if ([key integerValue] == idx) {
            found = YES;
            *stop = YES;
        }
    }];
    NSAssert1(found == NO, @"Menuitem %ld already found!", idx);
    [makeMenuItems setValue:label forKey:key];
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
        NSAssert1(found == YES, @"Menuitem %ld not found!", i);
    }
    return menuItems;
}

@end
