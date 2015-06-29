//
//  database.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_database_h
#define Geocube_database_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "dbObjects.h"

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"


@interface database : NSObject {   
    sqlite3 *db;
    id dbaccess;
};

- (id)init;
- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;

- (NSArray *)waypointtypes_all;

- (dbObjectWaypointGroup *)WaypointGroup_get_byName:(NSString *)name;

@end

#endif
