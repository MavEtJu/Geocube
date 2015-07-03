//
//  FilesViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCTableViewController.h"

@interface FilesViewController : GCTableViewController {
    NSArray *files;
    NSInteger filesCount;
}

@end
