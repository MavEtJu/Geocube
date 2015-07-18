//
//  GroupsVIewControllerViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface GCViewController : UIViewController <DOPNavbarMenuDelegate> {
    NSInteger numberOfItemsInRow;
    DOPNavbarMenu *tab_menu, *global_menu;

    NSMutableArray *menuItems;
}

@property (assign, nonatomic) NSInteger numberOfItemsInRow;
@property (strong, nonatomic) DOPNavbarMenu *tab_menu, *global_menu;

@end
