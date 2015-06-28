//
//  database.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <sqlite3.h>
#import <Foundation/Foundation.h>
#import "database.h"
#import "My Tools.h"

@implementation database

#define TEXT_FETCH_AND_ASSIGN(req, col, string) \
    NSString *string = nil; \
    { \
        char *s = (char *)sqlite3_column_text(req, col); \
        if (s == NULL) \
            string = nil; \
        else \
            string = [[NSString alloc] initWithUTF8String:s]]; \
    }
#define INT_FETCH_AND_ASSIGN(req, col, string) \
    NSInteger string = sqlite3_column_int(req, col);

#define SET_VAR_INT(req, col, string) \
    if (sqlite3_bind_int(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_INT: %s", sqlite3_errmsg(db));
#define SET_VAR_TEXT(req, col, string) \
    if (sqlite3_bind_text(req, col, [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_TEXT: %s", sqlite3_errmsg(db));


- (id)init:(NSString *)_dbfile
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", DocumentRoot(), DB_NAME];
    NSLog(@"Using %@ as the database", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", DocumentRoot(), DB_NAME];
    
    [self checkAndCreateDatabase:dbname empty:dbempty];
    sqlite3_open([dbname UTF8String], &db);

    return self;
}

- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty
{
    BOOL success;
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        [fm removeItemAtPath:dbname error:NULL];
    }
    
    NSString *empty = [[NSString alloc] initWithFormat:@"%@/%@", DataDistributionDirectory(), DB_EMPTY];
    success = [fm fileExistsAtPath:dbname];
    if (success == NO)
        [fm copyItemAtPath:empty toPath:dbname error:nil];
}


- (void)dealloc
{
    sqlite3_close(db);
}





@end
