//
//  database.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"


@interface database : NSObject {
    NSInteger version;
    
    sqlite3 *db;
    id dbaccess;
};

- (id)init:(NSString *)dbfile;

- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;

@end
