//
//  CacheAttributesViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CacheAttributesViewController : GCTableViewController {
    NSMutableArray *attrs;
    dbCache *cache;
}

- (id)init:(dbCache *)cache;

@end