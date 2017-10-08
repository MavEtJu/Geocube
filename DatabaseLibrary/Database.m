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

#import "Database.h"

#import "Geocube-defines.h"
#import "Geocube-globals.h"

#import "ToolsLibrary/MyTools.h"
#import "ManagersLibrary/ConfigManager.h"
#import "DatabaseLibrary/dbConfig.h"
#import "DatabaseLibrary/dbName.h"

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
    @synchronized(db) {
        [fileManager copyItemAtPath:dbname toPath:to error:&error];
    }
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

- (void)checkForBackup
{
    if (configManager.automaticDatabaseBackup == NO)
        return;
    if (configManager.automaticDatabaseBackupLast > time(NULL) - configManager.automaticDatabaseBackupPeriod * 86400)
        return;

    [db saveCopy];
    [configManager automaticDatabaseBackupLastUpdate:time(NULL)];

    NSEnumerator *e = [fileManager enumeratorAtPath:[MyTools FilesDir]];
    NSString *fn;
    NSMutableArray<NSString *> *a = [NSMutableArray arrayWithCapacity:configManager.automaticDatabaseBackupRotate + 1];
    while ((fn = [e nextObject]) != nil) {
        if ([fn length] > 8 && [[fn substringToIndex:8] isEqualToString:@"Geocube-"] == YES)
            [a addObject:fn];
    }
    if ([a count] > configManager.automaticDatabaseBackupRotate) {
        NSEnumerator *e = [[a sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator];
        NSInteger idx = 0;
        NSString *fn;
        while ((fn = [e nextObject]) != nil) {
            if (idx > configManager.automaticDatabaseBackupRotate) {
                NSLog(@"checkForBackup: Removing %@", fn);
                [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], fn] error:nil];
            }
            idx++;
        };
    }
}

- (void)checkVersion
{
    // Check and rename
    NSString *dbold = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    if ([fileManager fileExistsAtPath:dbold] == YES) {
        NSString *dbnew = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools ApplicationSupportRoot], DB_NAME];
        [fileManager moveItemAtPath:dbold toPath:dbnew error:nil];
    }

    dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools ApplicationSupportRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];

#if TARGET_OS_SIMULATOR
    // Keep a symlink to /Users/edwin/db to the database for easy access
    NSError *e;
    [fileManager removeItemAtPath:@"/Users/edwin/db" error:nil];
    [fileManager createSymbolicLinkAtPath:@"/Users/edwin/db" withDestinationPath:dbname error:&e];
#endif

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
    NSError *error = nil;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database on user request.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        error = nil;
        [fileManager removeItemAtPath:dbname error:&error];
        if (error != nil)
            NSLog(@"Error: %@", error);
    }

    success = [fileManager fileExistsAtPath:dbname];
    if (success == NO) {
        NSLog(@"Initializing database from %@ to %@.", dbempty, dbname);
        error = nil;
        [fileManager copyItemAtPath:dbempty toPath:dbname error:&error];
        if (error != nil)
            NSLog(@"Error: %@", error);
    }
}

- (void)dealloc
{
    sqlite3_close(self.db);
}

- (NSInteger)getDatabaseSize
{
    NSError *e = nil;
    NSLog(@"getDatabaseSize");
    NSDictionary *as = [fileManager attributesOfItemAtPath:dbname error:&e];
    if (e != nil) {
        NSLog(@"Error: %@", e);
        return -1;
    }
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
        [[upgradeSteps objectAtIndex:version] enumerateObjectsUsingBlock:^(NSString * _Nonnull sql, NSUInteger idx, BOOL * _Nonnull stop) {
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

    // Version 40
    a = @[
    @"create table listdata(id integer primary key, waypoint_id integer, type integer, datetime integer)",
    @"create index listdata_idx_id  on listdata(id)",
    @"insert into listdata(waypoint_id, type, datetime) select id, 0, id from waypoints where highlight = 1",
    @"insert into listdata(waypoint_id, type, datetime) select id, 1, id from waypoints where ignore = 1",
    @"insert into listdata(waypoint_id, type, datetime) select id, 2, id from waypoints where markedfound = 1",
    @"insert into listdata(waypoint_id, type, datetime) select id, 3, id from waypoints where inprogress = 1",
    @"insert into listdata(waypoint_id, type, datetime) select id, 4, id from waypoints where dnfed = 1",
    ];
    [upgradeSteps addObject:a];

    // Version 41
    a = @[
    @"alter table logs add column locallog bool",
    @"update logs set locallog = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 42
    a = @[
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.3.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.3.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_notices.3.geocube' where key = 'url_notices'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_externalmaps.3.geocube' where key = 'url_externalmaps'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_countries.3.geocube' where key = 'url_countries'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_states.3.geocube' where key = 'url_states'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_attributes.3.geocube' where key = 'url_attributes'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_keys.3.geocube' where key = 'url_keys'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_types.3.geocube' where key = 'url_types'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_pins.3.geocube' where key = 'url_pins'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_bookmarks.3.geocube' where key = 'url_bookmarks'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_containers.3.geocube' where key = 'url_containers'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_logstrings.3.geocube' where key = 'url_logstrings'",
    ];
    [upgradeSteps addObject:a];

    // Version 43
    a = @[
    @"create table log_templates (id integer primary key, name text, text text)",
    @"create index log_templates_idx on log_templates(id)",
    ];
    [upgradeSteps addObject:a];

    // Version 44
    a = @[
    @"create table log_macros (id integer primary key, name text, text text)",
    @"create index log_macros_idx on log_macros(id)",
    ];
    [upgradeSteps addObject:a];

    // Version 45
    a = @[
    @"delete from config where key = 'url_keys'",
    @"delete from config where key = 'key_gms'",
    @"delete from config where key = 'key_mapbox'",
    @"delete from config where key = 'key_gca-api'",
    ];
    [upgradeSteps addObject:a];

    // Version 46
    a = @[
    @"alter table accounts add column oauth_consumer_public_sharedsecret text",
    @"alter table accounts add column oauth_consumer_private_sharedsecret text",
    @"update accounts set oauth_consumer_public_sharedsecret = ''",
    @"update accounts set oauth_consumer_private_sharedsecret = ''",
    ];
    [upgradeSteps addObject:a];

    // Version 47
    a = @[
    @"create table locationless (id integer primary key, waypoint_id integer, planned bool)",
    @"create index locationless_idx_waypoint  on locationless(waypoint_id)",
    @"create index locationless_idx_id on locationless(id)",
    ];
    [upgradeSteps addObject:a];

    // Version 48
    a = @[
    @"drop table locationless",
    @"alter table waypoints add column planned integer",
    @"update waypoints set planned = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 49
    a = @[
    @"alter table logs add column lat text",
    @"alter table logs add column lon text",
    @"alter table logs add column lat_int integer",
    @"alter table logs add column lon_int integer",
    @"update logs set lat = '', lon = '', lat_int = 0, lon_int = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 50
    a = @[
    @"insert into config(key, value) values('url_versions', 'https://geocube.mavetju.org/geocube_versions.geocube')"
    ];
    [upgradeSteps addObject:a];

    // Version 51
    a = @[
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.4.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.4.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_notices.4.geocube' where key = 'url_notices'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_externalmaps.4.geocube' where key = 'url_externalmaps'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_countries.4.geocube' where key = 'url_countries'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_states.4.geocube' where key = 'url_states'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_attributes.4.geocube' where key = 'url_attributes'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_keys.4.geocube' where key = 'url_keys'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_types.4.geocube' where key = 'url_types'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_pins.4.geocube' where key = 'url_pins'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_bookmarks.4.geocube' where key = 'url_bookmarks'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_containers.4.geocube' where key = 'url_containers'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_logstrings.4.geocube' where key = 'url_logstrings'",
    ];
    [upgradeSteps addObject:a];

    // Version 52
    a = @[
    // Fix trackelements table
    @"drop index trackelements_idx_id",
    @"drop index trackelements_idx_trackid",
    @"alter table trackelements rename to trackelements_old",
    @"create table trackelements(id integer primary key, track_id integer, lat float, lon float, height integer, timestamp integer, restart bool)",
    @"create index trackelements_idx_id on trackelements(id)",
    @"create index trackelements_idx_trackid on trackelements(track_id)",
    @"insert into trackelements select id, track_id, lat_int / 1000000.0, lon_int / 1000000.0, height, timestamp, restart from trackelements_old",
    @"drop table trackelements_old",

    // Fix accounts table
    @"alter table accounts rename to accounts_old",
    @"create table accounts(id integer primary key, geocube_id integer, revision integer, enabled bool, site text, url_site text, url_queries text, accountname_id integer, protocol_id integer, distance_minimum integer, authentication_name text, authentication_password text, gca_cookie_name text, gca_cookie_value text, gca_authenticate_url text, gca_callback_url text, oauth_consumer_public text, oauth_consumer_public_sharedsecret text, oauth_consumer_private text, oauth_consumer_private_sharedsecret text, oauth_request_url text, oauth_access_url text, oauth_authorize_url text, oauth_token text, oauth_token_secret text)",
    @"insert into accounts select id, geocube_id, revision, enabled, site, url_site, url_queries, name_id, protocol_id, distance_minimum, authentication_name, authentication_password, gca_cookie_name, gca_cookie_value, gca_authenticate_url, gca_callback_url, oauth_consumer_public, oauth_consumer_public_sharedsecret, oauth_consumer_private, oauth_consumer_private_sharedsecret, oauth_request_url, oauth_access_url, oauth_authorize_url, oauth_token, oauth_token_secret from accounts_old",
    @"drop table accounts_old",

    // Fix waypoints table
    @"drop index waypoint_idx_name",
    @"drop index waypoint_idx_id",
    @"alter table waypoints rename to waypoints_old",
    @"create table waypoints(id integer primary key, wpt_lat float, wpt_lon float, wpt_name text, wpt_description text, wpt_date_placed_epoch integer, wpt_url text, wpt_urlname text, wpt_symbol_id integer, wpt_type_id integer, account_id integer, log_status integer, highlight bool, ignore bool, markedfound bool, inprogress bool, dnfed bool, planned bool, date_lastlog_epoch integer, date_lastimport_epoch integer, gs_enabled bool, gs_archived bool, gs_available bool, gs_country_id integer, gca_locale_id integer, gs_state_id integer, gs_rating_difficulty float, gs_rating_terrain float, gs_date_found integer, gs_favourites integer, gs_long_desc_html bool, gs_long_desc text, gs_short_desc_html bool, gs_short_desc text, gs_hint text, gs_container_id integer, gs_placed_by text, gs_owner_id integer)",
    @"insert into waypoints select id, wpt_lat_int / 1000000.0, wpt_lon_int / 1000000.0, wpt_name, wpt_description, wpt_date_placed_epoch, wpt_url, wpt_urlname, wpt_symbol_id, wpt_type_id, account_id, log_status, highlight, ignore, markedfound, inprogress, dnfed, planned, date_lastlog_epoch, date_lastimport_epoch, gs_enabled, gs_archived, gs_available, gs_country_id, gca_locale_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_date_found, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_placed_by, gs_owner_id from waypoints_old",
    @"create index waypoint_idx_name on waypoints(wpt_name)",
    @"create index waypoint_idx_id on waypoints(id)",
    @"drop table waypoints_old",
    ];
    [upgradeSteps addObject:a];

    // Version 53
    a = @[
    @"create table languages(id integer primary key, language text, country text)",
    @"create index languages_idx on languages(id)",
    @"insert into languages(language, country) values('en', '')",
    @"insert into languages(language, country) values('en', 'US')",
    @"insert into languages(language, country) values('nl', '')",
    ];
    [upgradeSteps addObject:a];

    // Version 54
    a = @[
    @"alter table log_strings add column display_string text",
    @"alter table log_strings add column log_string text",
    @"update log_strings set display_string = text, log_string = type",
    @"update log_strings set text = text, type = type",
    ];
    [upgradeSteps addObject:a];

    // Version 55
    a = @[
    @"alter table log_strings add column wptype integer",
    @"update log_strings set wptype = logtype",
    @"update log_strings set logtype = -1",
    ];
    [upgradeSteps addObject:a];

    // Version 56
    a = @[
    @"create table log_string_waypoints (id integer primary key, wptype integer, log_string_id integer)",
    @"create index log_string_waypoints_idx  on log_string_waypoints(id)",
    @"delete from log_strings where id not in (select distinct log_string_id from logs)",
    ];
    [upgradeSteps addObject:a];

    // Version 57
    // Fix duplicate travelbugs
    a = @[
    @"delete from travelbugs where gc_id in (select gc_id from travelbugs group by gc_id having count(gc_id) > 1) and (carrier_id is null or carrier_id = 0) and (waypoint_name is null or waypoint_name = 0)",
    @"delete from travelbugs where not (owner_id in (select accountname_id from accounts where accountname_id != 0)) and not (carrier_id in (select accountname_id from accounts where accountname_id != 0))",
    ];
    [upgradeSteps addObject:a];

    // Version 58
    a = @[
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.5.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_sites.5.geocube' where key = 'url_sites'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_notices.5.geocube' where key = 'url_notices'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_externalmaps.5.geocube' where key = 'url_externalmaps'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_countries.5.geocube' where key = 'url_countries'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_states.5.geocube' where key = 'url_states'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_attributes.5.geocube' where key = 'url_attributes'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_keys.5.geocube' where key = 'url_keys'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_types.5.geocube' where key = 'url_types'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_pins.5.geocube' where key = 'url_pins'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_bookmarks.5.geocube' where key = 'url_bookmarks'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_containers.5.geocube' where key = 'url_containers'",
    @"update config set value = 'https://geocube.mavetju.org/geocube_logstrings.5.geocube' where key = 'url_logstrings'",
    ];
    [upgradeSteps addObject:a];

    // Version 59
    a = @[
    @"insert into protocols(id, name) values(8, 'Geocube')",
    ];
    [upgradeSteps addObject:a];

    // Version 60
    a = @[
    @"create table kml_files (id integer primary key, filename text, enabled bool)",
    ];
    [upgradeSteps addObject:a];

    // Version 61
    a = @[
    @"alter table images add column lat float",
    @"alter table images add column lon float",
    @"update images set lat = 0, lon = 0",
    ];
    [upgradeSteps addObject:a];

    // Version 62
    a = @[
          [NSString stringWithFormat:@"insert into names(account_id, name, code) select id, '%@', '' from accounts", NAME_NONAMESUPPLIED],
    ];
    [upgradeSteps addObject:a];

    // Version 63
    a = @[
    @"alter table travelbugs add column guid text",
    ];
    [upgradeSteps addObject:a];

    // Version 64
    a = @[
    @"alter table travelbugs add column pin text",
    @"alter table travelbugs add column tbcode text",
    @"update travelbugs set pin = code, tbcode = ref",
    @"update travelbugs set code = '', ref = ''",
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

        // Delete all group combinations from non-existing waypoints
        DB_PREPARE(@"delete from group2waypoints where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all logs from non-existing waypoints
        DB_PREPARE(@"delete from logs where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all trackables from non-existing waypoints
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all attributes from non-existing waypoints
        DB_PREPARE(@"delete from attribute2waypoints where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all trackables from non-existing waypoints
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all images from non-existing waypoints
        DB_PREPARE(@"delete from image2waypoint where waypoint_id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;

        // Delete all waypoints which are not longer in a usergroup
        DB_PREPARE(@"delete from waypoints where id not in (select id from waypoints)");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
