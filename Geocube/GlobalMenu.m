//
//  GlobalMenu.m
//  Geocube
//
//  Created by Edwin Groothuis on 2/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define MENU_STRING @"GC"

@implementation GlobalMenu

@synthesize parent_vc, previous_vc;

- (id)init
{
    self = [super init];
    items = [NSArray arrayWithObjects:@"XNavigate", @"XCaches Online", @"Caches Offline", @"XNotes and Logs", @"XTrackables", @"Groups", @"XBookmarks", @"Files", @"XUser Profile", @"XNotices", @"XSettings", @"XHelp", nil];

//    NSString *imgfile = [NSString stringWithFormat:@"%@/global menu icon.png", [MyTools DataDistributionDirectory]];
//    UIImage *img = [UIImage imageNamed:imgfile];

    button = [[UIBarButtonItem alloc] initWithTitle:MENU_STRING style:UIBarButtonItemStylePlain target:nil action:@selector(openMenu:)];
    button.tintColor = [UIColor whiteColor];
    
    return self;
}

- (void)addButtons:(UIViewController<DOPNavbarMenuDelegate> *)_vc numberOfItemsInRow:(NSInteger)_numberOfItemsInRow
{
    // NSLog(@"GlobalMenu/addButtons: From %p to %p", parent_vc, _vc);
    numberOfItemsInRow = _numberOfItemsInRow;
    //parent_vc = _vc;

//    NSString *imgfile = [NSString stringWithFormat:@"%@/global menu icon.png", [MyTools DataDistributionDirectory]];
//    UIImage *img = [UIImage imageNamed:imgfile];
                                         
    _vc.navigationItem.leftBarButtonItem = button;
}

- (void)setTarget:(UIViewController<DOPNavbarMenuDelegate> *)_vc
{
    // NSLog(@"GlobalMenu/setTarget: from %p to %p", parent_vc, _vc);
    previous_vc = parent_vc;
    parent_vc.navigationItem.leftBarButtonItem = nil;
    parent_vc = _vc;
    button.target = _vc;
    parent_vc.navigationItem.leftBarButtonItem = button;
}

- (DOPNavbarMenu *)global_menu
{
    if (_global_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];
        
        NSEnumerator *e = [items objectEnumerator];
        NSString *menuitem;
        while ((menuitem = [e nextObject]) != nil) {
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:menuitem icon:[UIImage imageNamed:@"Image"]];
            [menuoptions addObject:item];
        }
        
        _global_menu = [[DOPNavbarMenu alloc] initWithItems:menuoptions width:parent_vc.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        _global_menu.backgroundColor = [UIColor blackColor];
        _global_menu.separatarColor = [UIColor whiteColor];
        _global_menu.menuName = MENU_STRING;
        _global_menu.delegate = parent_vc;
    }
    return _global_menu;
}

- (void)openMenu:(id)sender
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
 
    NSLog(@"Switching to %ld", index);
    [_AppDelegate switchController:index];
}

@end
