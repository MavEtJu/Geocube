//
//  GlobalMenu.m
//  Geocube
//
//  Created by Edwin Groothuis on 2/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geocube.h"
#import "GlobalMenu.h"
#import "DOPNavbarMenu.h"
#import "My Tools.h"


@implementation GlobalMenu

@synthesize parent_vc, parent_view;

- (id)init
{
    self = [super init];
    items = [NSArray arrayWithObjects:@"XNavigate", @"XCaches Online", @"XCaches Offline", @"XNotes and Logs", @"XTrackables", @"Groups", @"XBookmarks", @"Files", @"XUser Profile", @"XNotices", @"XSettings", @"XHelp", nil];
    
    return self;
}

- (void)addButtons:(UIViewController<DOPNavbarMenuDelegate> *)_vc view:(UIView *)_view numberOfItemsInRow:(NSInteger)_numberOfItemsInRow
{
    numberOfItemsInRow = _numberOfItemsInRow;
    parent_vc = _vc;
    parent_view = _view;

//    NSString *imgfile = [NSString stringWithFormat:@"%@/global menu icon.png", [MyTools DataDistributionDirectory]];
//    UIImage *img = [UIImage imageNamed:imgfile];
                                         
    parent_vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"G" style:UIBarButtonItemStylePlain target:parent_vc action:@selector(openMenu:)];
    parent_vc.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
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
        _global_menu.menuName = @"G";
        _global_menu.delegate = parent_vc;
    }
    return _global_menu;
}

- (void)openMenu:(id)sender
{
    parent_vc.navigationItem.leftBarButtonItem.enabled = NO;
    if (self.global_menu.isOpen) {
        [self.global_menu dismissWithAnimation:YES];
    } else {
        [self.global_menu showInNavigationController:parent_vc.navigationController];
    }
}

/*
- (void)openLocalMenu:(id)sender
{
    parent_vc.navigationItem.leftBarButtonItem.enabled = NO;
    if (self.global_menu.isOpen) {
        [self.global_menu dismissWithAnimation:YES];
    } else {
        [self.global_menu showInNavigationController:parent_vc.navigationController];
    }
}*/

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
    [parent_vc.navigationItem.leftBarButtonItem setTitle:@"dismiss"];
    parent_vc.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    [parent_vc.navigationItem.leftBarButtonItem setTitle:menu.menuName];
    parent_vc.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    NSLog(@"Switching to %ld", index);
    [_AppDelegate switchController:index];
}

@end
