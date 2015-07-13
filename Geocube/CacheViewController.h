//
//  CacheViewControllerTableViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CacheViewController : GCTableViewController {
    dbCache *wp;
    
    NSArray *cacheItems;
    NSArray *actionItems;
}

- (id)initWithStyle:(NSInteger)style cache:(dbCache *)wp;

@end
