//
//  CacheLogsViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CacheLogsViewController : GCTableViewController {
    dbWaypoint *wp;
    NSArray *logs;
}

- (id)init:(dbWaypoint *)wp;

@end
