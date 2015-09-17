/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation database

@synthesize dbaccess, db;

- (id)init
{
    dbaccess = self;
    db = nil;
    return self;
}

- (void)checkVersion
{
    dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];

    // Keep a symlink to /Users/edwin/db to the database for easy access
    NSError *e;
    [fm removeItemAtPath:@"/Users/edwin/db" error:nil];
    [fm createSymbolicLinkAtPath:@"/Users/edwin/db" withDestinationPath:dbname error:&e];

    // If the database doesn't exist, create it
    [self checkAndCreateDatabase];

    // Determine version of the distribution database
    sqlite3_open([dbempty UTF8String], &db);
    dbConfig *c_empty = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    // Determine version of the active database
    sqlite3_open([dbname UTF8String], &db);
    dbConfig *c_real = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    // If the active version is different from the distribution version, then reinitialize.
    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value isEqualToString:c_empty.value] == NO) {
        NSLog(@"Empty database is newer, upgrading");
        sqlite3_open([dbname UTF8String], &db);

        for (NSInteger version = [c_real.value integerValue]; version < [c_empty.value integerValue]; version++) {
            NSLog(@"Upgrading from %ld", (long)version);
            [self performUpgrade:version];
        }
        c_real.value = c_empty.value;
        [c_real dbUpdate];

        sqlite3_close(db);
    }

    sqlite3_open([dbname UTF8String], &db);
}

- (void)checkAndCreateDatabase
{
    BOOL success;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database on user request.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        [fm removeItemAtPath:dbname error:NULL];
    }

    success = [fm fileExistsAtPath:dbname];
    if (success == NO) {
        [fm copyItemAtPath:dbempty toPath:dbname error:nil];
        NSLog(@"Initializing database from %@ to %@.", dbempty, dbname);
    }
}

- (void)dealloc
{
    sqlite3_close(db);
}

- (NSInteger)getDatabaseSize
{
    NSError *e = nil;
    NSDictionary *as = [fm attributesOfItemAtPath:dbname error:&e];
    if (e != nil)
        return -1;
    NSNumber *n = [as valueForKey:@"NSFileSize"];
    return [n integerValue];
}

- (void)performUpgrade:(NSInteger)version
{
    if (version == 0) {
        [self performUpgrade_0_1];
        return;
    }
    if (version == 1) {
        [self performUpgrade_1_2];
        return;
    }
    NSAssert1(false, @"performUpgrade: Unknown source version: %ld", (long)version);
}

#undef DB_ASSERT
#define DB_ASSERT(__s__) \
    NSAssert3(0, @"%s/%@: %s", __FUNCTION__, __s__, sqlite3_errmsg(self.db))

#undef DB_PREPARE
#define DB_PREPARE(__s__) \
    sqlite3_stmt *req; \
    if (sqlite3_prepare_v2(self.db, [__s__ cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK) \
        DB_ASSERT_PREPARE;

#undef DB_GET_LAST_ID
#define DB_GET_LAST_ID(__id__) \
    __id__ = sqlite3_last_insert_rowid(self.db);

- (void)performUpgrade_0_1
{
    NSArray *a = @[
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Cache In Trash Out Event', 101, 608)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Giga-Event Cache', 104, 608)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Groundspeak HQ', 105, 600)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Groundspeak Block Party', 105, 600)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Mega-Event Cache', 108, 608)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Unknown (Mystery) Cache', 110, 604)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Wherigo Caches', 117, 603)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Project APE Cache', 111, 601)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Locationless (Reverse) Cache', 111, 601)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'GPS Adventures Exhibit', 111, 601)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Lost and Found Event Caches', 111, 601)",
    @"insert into types(type_major, type_minor, icon, pin) values('Geocache', 'Groundspeak Lost and Found Celebration', 111, 601)"
    ];

    @synchronized(self.dbaccess) {
        [a enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
            DB_PREPARE(sql);
            DB_CHECK_OKAY;
            DB_FINISH;
        }];
    }
}

- (void)performUpgrade_1_2
{
    NSArray *a = @[
    @"insert into symbols(symbol) values('*')"
    ];

    @synchronized(self.dbaccess) {
        [a enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
            DB_PREPARE(sql);
            DB_CHECK_OKAY;
            DB_FINISH;
        }];
    }
}



@end
