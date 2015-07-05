//
//  GlobalMenu.h
//  Geocube
//
//  Created by Edwin Groothuis on 2/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOPNavbarMenu.h"

@interface GlobalMenu : NSObject<DOPNavbarMenuDelegate> {
    NSArray *items;
    DOPNavbarMenu *_global_menu;
    NSInteger numberOfItemsInRow;
    UIViewController<DOPNavbarMenuDelegate> *parent_vc, *previous_vc;
    UIBarButtonItem *button;
}

@property (nonatomic, retain) UIViewController *parent_vc, *previous_vc;

- (void)addButtons:(UIViewController<DOPNavbarMenuDelegate> *)vc numberOfItemsInRow:(NSInteger)numberOfItemsInRow;
- (void)openMenu:(id)sender;
- (void)didDismissMenu:(DOPNavbarMenu *)menu;
- (void)didShowMenu:(DOPNavbarMenu *)menu;
- (void)setTarget:(UIViewController<DOPNavbarMenuDelegate> *)vc;

@end
