/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface database ()
{
    NSString *dbname, *dbempty;

    NSMutableArray<NSArray <NSString *> *> *upgradeSteps;
}

@end

@implementation database

- (instancetype)init
{
    self = [super init];

    self.db = nil;

    return self;
}

- (NSString *)saveCopy
{
    NSError *error;
    NSString *toName = [NSString stringWithFormat:@"Geocube-%@.sqlite", [MyTools dateTimeString_YYYYMMDD]];
    NSString *to = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], toName];
    [fileManager removeItemAtPath:to error:&error];
    [fileManager copyItemAtPath:dbname toPath:to error:&error];
    return toName;
}

- (BOOL)restoreFromCopy:(NSString *)source
{
    NSError *error = nil;
    NSString *from = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], source];
    [fileManager removeItemAtPath:dbname error:&error];
    [fileManager copyItemAtPath:from toPath:dbname error:&error];
    return (error == nil);
}

- (void)checkVersion
{
    dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];

    // Keep a symlink to /Users/edwin/db to the database for easy access
    NSError *e;
    [fileManager removeItemAtPath:@"/Users/edwin/db" error:nil];
    [fileManager createSymbolicLinkAtPath:@"/Users/edwin/db" withDestinationPath:dbname error:&e];

    // If the database doesn't exist, create it
    [self checkAndCreateDatabase];

    // Determine version of the distribution database
    sqlite3 *tdb;
    sqlite3_open([dbempty UTF8String], &tdb);
    self.db = tdb;
    dbConfig *c_empty = [dbConfig dbGetByKey:KEY_VERSION_DB];
    sqlite3_close(tdb);
    self.db = nil;
    tdb = nil;

    // If the empty database version is 0, reinitialize.
    if ([c_empty.value isEqualToString:@"0"] == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase];
    }

    // Determine version of the active database
    sqlite3_open([dbname UTF8String], &tdb);
    self.db = tdb;
    dbConfig *c_real = [dbConfig dbGetByKey:KEY_VERSION_DB];
    sqlite3_close(tdb);
    self.db = nil;
    tdb = nil;

    // If the active version is different from the distribution version, then reinitialize.
    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value isEqualToString:c_empty.value] == NO) {
        NSLog(@"Empty database is newer, upgrading");
        sqlite3_open([dbname UTF8String], &tdb);
        self.db = tdb;

        NSInteger version = [c_real.value integerValue];
        NSLog(@"Upgrading from %ld", (long)version);
        [self performUpgrade:version to:[c_empty.value integerValue]];

        c_real.value = c_empty.value;
        [c_real dbUpdate];

        sqlite3_close(tdb);
        self.db = nil;
        tdb = nil;
    }

    sqlite3_open([dbname UTF8String], &tdb);
    self.db = tdb;
}

- (void)checkAndCreateDatabase
{
    BOOL success;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database on user request.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        [fileManager removeItemAtPath:dbname error:NULL];
    }

    success = [fileManager fileExistsAtPath:dbname];
    if (success == NO) {
        [fileManager copyItemAtPath:dbempty toPath:dbname error:nil];
        NSLog(@"Initializing database from %@ to %@.", dbempty, dbname);
    }
}

- (void)dealloc
{
    sqlite3_close(self.db);
}

- (NSInteger)getDatabaseSize
{
    NSError *e = nil;
    NSDictionary *as = [fileManager attributesOfItemAtPath:dbname error:&e];
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

    @synchronized(db) {
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
    NSArray<NSString *> *a = @[
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

    // Version 19
    a = @[
    @"insert into config(key, value) values('url_logtypes', 'https://geocube.mavetju.org/geocube_logtypes.geocube')",
    @"insert into config(key, value) values('url_types', 'https://geocube.mavetju.org/geocube_types.geocube')",
    @"insert into config(key, value) values('url_pins', 'https://geocube.mavetju.org/geocube_pins.geocube')",
    ];
    [upgradeSteps addObject:a];

    // Version 20
    a = @[
    @"alter table bookmarks add column import_id integer",
    @"delete from bookmarks",
    @"insert into config(key, value) values('url_bookmarks', 'https://geocube.mavetju.org/geocube_bookmarks.geocube')",
    ];
    [upgradeSteps addObject:a];

    // Version 21
    a = @[
    @"alter table notices add column url string",
    @"update notices set url = ''",
    ];
    [upgradeSteps addObject:a];

    // Version 22
    a = @[
    @"insert into config(key, value) values('url_containers', 'https://geocube.mavetju.org/geocube_containers.geocube')",
    @"alter table containers add column gc_id integer"
    ];
    [upgradeSteps addObject:a];

    // Version 23
    a = @[
    @"alter table travelbugs add column owner_id integer",
    @"alter table travelbugs add column carrier_id integer",
    @"alter table travelbugs add waypoint_name text",
    ];
    [upgradeSteps addObject:a];

    // Version 24
    a = @[
    @"alter table waypoints add column date_lastlog_epoch integer",
    @"update waypoints set date_lastlog_epoch = 0"
    ];
    [upgradeSteps addObject:a];

    // Version 25
    a = @[
    @"insert into groups(name, usergroup, deletable) values('Manual waypoints', 1, 0)",
    ];
    [upgradeSteps addObject:a];

    // Version 26
    a = @[
    @"alter table accounts add column distance_minimum integer",
    @"update accounts set distance_minimum = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 27
    a = @[
    @"alter table travelbugs add column log_type integer",
    @"update travelbugs set log_type = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 28
    a = @[
    @"alter table travelbugs add column code text",
    @"update travelbugs set code = ''",
    ];
    [upgradeSteps addObject:a];

    // Version 29
    a = @[
    @"insert into config(key, value) values('url_logstrings', 'https://geocube.mavetju.org/geocube_logstrings.geocube')",
    ];
    [upgradeSteps addObject:a];

    // Version 30
    a = @[
    @"delete from logs",
    @"create table log_strings (id integer primary key, text text, type text, logtype integer, default_note bool, default_found bool, account_id integer, icon integer, found integer, forlogs bool)",
    ];
    [upgradeSteps addObject:a];

    // Version 31
    a = @[
    @"drop table log_types",
    @"alter table logs add column log_string_id integer",
    @"update logs set log_string_id = 0",
    @"delete from groups where name ='All Waypoints - Attended'",
    ];
    [upgradeSteps addObject:a];

    // Version 32
    a = @[
    @"alter table log_strings add column default_visit bool",
    @"alter table log_strings add column default_dropoff bool",
    @"alter table log_strings add column default_pickup bool",
    @"alter table log_strings add column default_discover bool",
    @"update log_strings set default_visit = 0, default_dropoff = 0, default_pickup = 0, default_discover = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 33
    a = @[
    @"alter table types add column has_boundary bool",
    @"update types set has_boundary = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 34
    a = @[
    @"alter table waypoints add column gca_locale_id integer",
    @"update waypoints set gca_locale_id = 0",
    @"create table locales(id integer primary key, name text)",
    @"create index locales_idx_id on locales(id)",
    @"create index locales_idx_name on locales(name)",
    ];
    [upgradeSteps addObject:a];

    // Version 35
    a = @[
    @"alter table waypoints add column date_lastimport_epoch integer",
    @"update waypoints set date_lastimport_epoch = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 36
    a = @[
    @"alter table waypoints add column related_id integer",
    @"update waypoints set related_id = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 37
    a = @[
    @"alter table accounts add column authentication_name text",
    @"alter table accounts add column authentication_password text",
    @"update accounts set authentication_name = '', authentication_password = ''",
    ];
    [upgradeSteps addObject:a];

    // Version 38
    a = @[
    // Create new protocols table
    @"create table protocols ( id integer primary key, name text )",
    @"insert into protocols(id, name) values(1, 'LiveAPI')",
    @"insert into protocols(id, name) values(2, 'OKAPI')",
    @"insert into protocols(id, name) values(3, 'GCA')",
    @"insert into protocols(id, name) values(4, 'GCA2')",
    @"insert into protocols(id, name) values(5, 'GGCW')",
    @"insert into protocols(id, name) values(6, 'Geocaching.su')",
    @"insert into protocols(id, name) values(7, 'TrigpointingUK')",
    // Adjust accounts table
    @"alter table accounts add column protocol_id integer",
    @"update accounts set protocol_id = protocol",
    // Adjust log_strings table
    @"alter table log_strings add column protocol_id integer",
    @"update log_strings set protocol_id = (select protocol_id from accounts where id = account_id)",
    @"delete from log_strings where protocol_id = 2",
    ];
    [upgradeSteps addObject:a];

    // Version 39
    a = @[
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.2.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.2.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_notices.2.geocube' where key = 'url_notices'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_externalmaps.2.geocube' where key = 'url_externalmaps'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_countries.2.geocube' where key = 'url_countries'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_states.2.geocube' where key = 'url_states'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_attributes.2.geocube' where key = 'url_attributes'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_keys.2.geocube' where key = 'url_keys'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_types.2.geocube' where key = 'url_types'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_pins.2.geocube' where key = 'url_pins'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_bookmarks.2.geocube' where key = 'url_bookmarks'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_containers.2.geocube' where key = 'url_containers'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_logstrings.2.geocube' where key = 'url_logstrings'",
    ];
    [upgradeSteps addObject:a];

}

- (void)singleStatement:(NSString *)sql
{
    @synchronized(db) {
        sqlite3_stmt *req;

        DB_PREPARE(@"begin");
        DB_CHECK_OKAY;
        DB_PREPARE(sql);
        if (sqlite3_step(req) != SQLITE_DONE) {
            NSLog(@"Failure of '%@'", sql);
            DB_ASSERT_STEP;
        }
        DB_PREPARE(@"commit");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)cleanupAfterDelete
{
    @synchronized(db) {
        sqlite3_stmt *req;

        // Delete all logs from caches not longer in an usergroup (should be zero)
        DB_PREPARE(@"delete from group2waypoints where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all logs from caches not longer in an usergroup
        DB_PREPARE(@"delete from logs where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all trackables from caches not longer in an usergroup
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all attributes from caches not longer in an usergroup
        DB_PREPARE(@"delete from attribute2waypoints where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all trackables from caches not longer in an usergroup
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all images from caches not longer in an usergroup
        DB_PREPARE(@"delete from image2waypoint where waypoint_id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all caches which are not longer in a usergroup
        DB_PREPARE(@"delete from waypoints where id not in (select waypoint_id from group2waypoints where group_id in (select id from groups where usergroup != 0))");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
