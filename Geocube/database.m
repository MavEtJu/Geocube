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
}

@end

@implementation database

@synthesize dbaccess, db;

- (instancetype)init
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

    // If the empty database version is 0, reinitialize.
    if ([c_empty.value isEqualToString:@"0"] == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase];
    }

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
    NSLog(@"performUpgrade: from version: %ld", (long)version);
    if (version == 0) {
        [self performUpgrade_0_1];
        return;
    }
    if (version == 1) {
        [self performUpgrade_1_2];
        return;
    }
    if (version == 2) {
        [self performUpgrade_2_3];
        return;
    }
    if (version == 3) {
        [self performUpgrade_3_4];
        return;
    }

    NSAssert1(false, @"performUpgrade: Unknown source version: %ld", (long)version);
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

- (void)performUpgrade_X_Y:(NSArray *)a
{
    @synchronized(self.dbaccess) {
        __block sqlite3_stmt *req;

        DB_PREPARE(@"begin");
        DB_CHECK_OKAY;
        [a enumerateObjectsUsingBlock:^(NSString *sql, NSUInteger idx, BOOL *stop) {
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

- (void)performUpgrade_0_1
{
    NSArray *a = @[
        // Nothing
    ];
    [self performUpgrade_X_Y:a];
}

- (void)performUpgrade_1_2
{
    NSArray *a = @[
    @"update types set icon = 118 where id = 32",
    @"update types set icon = 119 where id = 31",
    ];
    [self performUpgrade_X_Y:a];
}

- (void)performUpgrade_2_3
{
    NSArray *a = @[
    @"alter table groups add column deletable bool",
    @"update groups set deletable = usergroup",
    @"insert into groups(name, usergroup, deletable) values('Live Import', 1, 0)"
    ];
    [self performUpgrade_X_Y:a];
}

- (void)performUpgrade_3_4
{
    NSArray *a = @[
    @"insert into log_types(logtype, icon) values('Moved', 417)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Virtual', 114, 17)",
    @"insert into types(type_major, type_minor, icon, pin_id) values('Geocache', 'Traditional', 112, 16)",
    ];
    [self performUpgrade_X_Y:a];
}

- (void)performUpgrade_4_5
{
    /*
    NSArray *a = @[
    @"create table tracks ( id integer primary key, name text, startedon integer, stoppedon integer)",
    @"create index tracks_idx_id on tracks(id)",
    @"create table trackelements ( id integer primary key, track_id integer, lat_int integer, lon_int integer, height integer, timestamp integer)",
    @"create index trackelements_idx_id on trackelements(id)",
    @"create index trackelements_idx_trackid on trackelements(track_id)"
    ];
    [self performUpgrade_X_Y:a];
    */
}


@end
