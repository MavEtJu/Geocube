//
//  GroupsVIewControllerViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTableViewController.h"
#import "DOPNavbarMenu.h"

@interface GroupsViewController : GCTableViewController {
    NSInteger wpgCount;
    NSArray *wpgs;
}

- (id)init:(BOOL)showUsers;

@end
