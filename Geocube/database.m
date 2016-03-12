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

@interface database ()
{
    sqlite3 *db;
    NSString *dbname, *dbempty;
    id dbaccess;

    NSMutableArray *upgradeSteps;
}

@end

@implementation database

@synthesize dbaccess, db;

- (instancetype)init
{
    self = [super init];

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
    dbConfig *c_empty = [dbConfig dbGetByKey:KEY_VERSION_DB];
    sqlite3_close(db);

    // If the empty database version is 0, reinitialize.
    if ([c_empty.value isEqualToString:@"0"] == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase];
    }

    // Determine version of the active database
    sqlite3_open([dbname UTF8String], &db);
    dbConfig *c_real = [dbConfig dbGetByKey:KEY_VERSION_DB];
    sqlite3_close(db);

    // If the active version is different from the distribution version, then reinitialize.
    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value isEqualToString:c_empty.value] == NO) {
        NSLog(@"Empty database is newer, upgrading");
        sqlite3_open([dbname UTF8String], &db);

        NSInteger version = [c_real.value integerValue];
        NSLog(@"Upgrading from %ld", (long)version);
        [self performUpgrade:version to:[c_empty.value integerValue]];

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

- (void)performUpgrade:(NSInteger)fromVersion to:(NSInteger)toVersion
{
    NSLog(@"performUpgrade: from version: %ld", (long)fromVersion);
    [self upgradeInit];
    for (NSInteger i = fromVersion + 1; i <= toVersion; i++) {
        [self upgradePerform:i];
    }
}

#undef DB_ASSERT
#define DB_ASSERT(__s__) \
    NSAssert3(0, @"%s/%@: %s", __FUNCTION__, __s__, sqlite3_errmsg(self.db))

#undef DB_PREPARE
#define DB_PREPARE(__s__) \
    if (sqlite3_prepare_v2(self.db, [__s__ cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK) \
        DB_ASSERT_PREPARE;

#undef DB_GET_LAST_ID
#define DB_GET_LAST_ID(__id__) \
    __id__ = sqlite3_last_insert_rowid(self.db);

- (void)upgradePerform:(NSInteger)version
{
    NSLog(@"upgradePerform: to version: %ld", (long)version);
    if (version > [upgradeSteps count])
        NSAssert1(false, @"performUpgrade: Unknown destination version: %ld", (long)version);

    @synchronized(self.dbaccess) {
        __block sqlite3_stmt *req;

        DB_PREPARE(@"begin");
        DB_CHECK_OKAY;
        [[upgradeSteps objectAtIndex:version] enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
            DB_PREPARE(sql);
            if (sqlite3_step(req) != SQLITE_DONE) {
                NSLog(@"Failure of '%@'", sql);
                DB_ASSERT_STEP;
            }
        }];
        DB_PREPARE(@"commit");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)upgradeInit
{
    upgradeSteps = [NSMutableArray arrayWithCapacity:10];

    // Version 0
    NSArray *a = @[
        // Nothing
    ];
    [upgradeSteps addObject:a];

    // Version 1
    a = @[
        // Nothing
    ];
    [upgradeSteps addObject:a];

    // Version 2
    a = @[
    @"update types set icon = 118 where id = 32",
    @"update types set icon = 119 where id = 31",
    ];
    [upgradeSteps addObject:a];

    // Version 3
    a = @[
    @"alter table groups add column deletable bool",
    @"update groups set deletable = usergroup",
    @"insert into groups(name, usergroup, deletable) values('Live Import', 1, 0)"
    ];
    [upgradeSteps addObject:a];

    // Version 4
    a = @[
    @"insert into log_types(logtype, icon) values('Moved', 417)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Virtual', 114, 17)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Traditional', 112, 16)",
    ];
    [upgradeSteps addObject:a];

    // Version 5
    a = @[
    @"alter table waypoints add column markedfound bool",
    @"alter table waypoints add column inprogress bool",
    @"update waypoints set markedfound = 0",
    @"update waypoints set inprogress = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 6
    a = @[
    @"alter table accounts add column name_id integer",
    @"update accounts set name_id = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 7
    a = @[
    @"create index logs_idx_gc_id on logs(gc_id)",
    ];
    [upgradeSteps addObject:a];

    // Version 8
    a = @[
    @"alter table waypoints add column gs_date_found integer",
    @"update waypoints set gs_date_found = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 9
    a = @[
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'History', 120, 17)",
    ];
    [upgradeSteps addObject:a];

    // Version 10
    a = @[
    @"insert into log_types(logtype, icon) values('Published', 407)",
    @"insert into log_types(logtype, icon) values('Did not find it', 400)",
    @"insert into log_types(logtype, icon) values('Noted', 413)",
    @"insert into log_types(logtype, icon) values('Maintained', 405)",
    @"insert into log_types(logtype, icon) values('Needs maintenance', 404)"
    ];
    [upgradeSteps addObject:a];

    // Version 11
    a = @[
    @"update config set value='https://geocube.mavetju.org/geocube_sites.txt' where key='url_sites'",
    @"update config set value='https://geocube.mavetju.org/geocube_notices.txt' where key='url_notices'",
    ];
    [upgradeSteps addObject:a];

    // Version 12
    a = @[
    @"create table query_imports (id integer primary key, account_id integer, name text, filesize integer, last_import_epoch integer)",
    ];
    [upgradeSteps addObject:a];

    // Version 13
    a = @[
    @"alter table waypoints add column dnfed bool",
    @"update waypoints set dnfed = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 14
    a = @[
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_notices.geocube' where key = 'url_notices'",
    ];
    [upgradeSteps addObject:a];

    // Version 15
    a = @[
    @"alter table accounts add column enabled bool",
    @"update accounts set enabled = 1",
    ];
    [upgradeSteps addObject:a];

    // Version 16
    a = @[
    @"create table externalmaps ( id integer primary key, geocube_id integer, enabled bool, name text)",
    @"create table externalmap_urls ( id integer primary key, externalmap_id integer, model text, type integer, url text)",
    @"insert into config(key, value) values('url_externalmaps', 'https://geocube.mavetju.org/geocube_externalmaps.geocube')",
    ];
    [upgradeSteps addObject:a];

    // Version 17
    a = @[
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Multistep Traditional cache', 112, 16)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Multistep Virtual cache', 114, 17)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Contest', 103, 11)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Event', 103, 11)",
    ];
    [upgradeSteps addObject:a];

    // Version 18
    a = @[
    @"insert into config(key, value) values('url_countries', 'https://geocube.mavetju.org/geocube_countries.geocube')",
    @"insert into config(key, value) values('url_states', 'https://geocube.mavetju.org/geocube_states.geocube')",
    @"insert into config(key, value) values('url_attributes', 'https://geocube.mavetju.org/geocube_attributes.geocube')",
    @"insert into config(key, value) values('url_keys', 'https://geocube.mavetju.org/geocube_keys.geocube')",
    ];
    [upgradeSteps addObject:a];

}

@end
