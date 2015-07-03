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
    UIViewController<DOPNavbarMenuDelegate> *parent_vc;
    UIView *parent_view;
}

@property (nonatomic, retain) UIViewController *parent_vc;
@property (nonatomic, retain) UIView *parent_view;

- (void)addButtons:(UIViewController<DOPNavbarMenuDelegate> *)vc view:(UIView *)view numberOfItemsInRow:(NSInteger)numberOfItemsInRow;
- (void)openMenu:(id)sender;
- (void)didDismissMenu:(DOPNavbarMenu *)menu;
- (void)didShowMenu:(DOPNavbarMenu *)menu;

@end
