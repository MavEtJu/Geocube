//
//  GroupsVIewControllerViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface GroupsViewController : GCTableViewController {
    NSInteger wpgCount;
    NSArray *wpgs;
    BOOL showUsers;
}

- (id)init:(BOOL)showUsers;

@end
