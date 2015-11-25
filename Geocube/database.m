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
    @"alter table waypoints add column gs_hasdata bool",
    ];
    [self performUpgrade_X_Y:a];
}

- (void)performUpgrade_2_3
{
    /*
    NSArray *a = @[
    @"alter table waypoints add column ignore bool",
    @"update waypoints set ignore = 0",
    @"insert into groups(name, usergroup) values('All Waypoints - Ignored', 0)"
    ];
    [self performUpgrade_X_Y:a];
     */
}

- (void)performUpgrade_3_4
{
    /*
    NSArray *a = @[
    @"delete from types",
    @"alter table types add column pin_rgb text",
    @"alter table types add column pin_rgb_default text",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Benchmark', 100, 601, '', '230FDC')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'CITO', 101, 602, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Cache In Trash Out Event', 101, 603, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Earthcache', 102, 604, '', 'F0F0F0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Event Cache', 103, 605, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Giga', 104, 606, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Giga-Event Cache', 104, 607, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'GroundspeakHQ', 105, 608, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Groundspeak HQ', 105, 609, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Groundspeak Block Party', 105, 610, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Letterbox Hybrid', 106, 611, '', 'A52A2A')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Maze', 107, 612, '', 'FF00FF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Mega', 108, 613, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Mega-Event Cache', 108, 614, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Multi-cache', 109, 615, '', 'F5F810')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Mystery', 110, 616, '', 'FF00FF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Unknown (Mystery) Cache', 110, 617, '', 'FF00FF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Other', 111, 618, '', 'A52A2A')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Traditional Cache', 112, 619, '', '009C00')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Unknown Cache', 113, 620, '', 'FF00FF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Virtual Cache', 114, 621, '', 'F0F0F0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Waymark', 115, 622, '', '230FDC')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Webcam Cache', 116, 623, '', 'F0F0F0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Wherigo Cache', 117, 624, '', '00FFFF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Wherigo Caches', 117, 625, '', '00FFFF')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Project APE Cache', 111, 626, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Locationless (Reverse) Cache', 111, 627, '', 'A52A2A')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'GPS Adventures Exhibit', 111, 628, '', 'A52A2A')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Lost and Found Event Caches', 111, 629, '', 'FFD0D0')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', 'Groundspeak Lost and Found Celebration', 111, 630, '', 'FFD0D0')",

    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Final Location', 200, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Flag', 201, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Multi Stage', 202, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Parking Area', 203, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Physical Stage', 204, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Reference Point', 205, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Trailhead', 206, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', 'Virtual Stage', 207, 600, '', '000000')",

    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Geocache', '*', 208, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('Waypoint', '*', 208, 600, '', '000000')",
    @"insert into types(type_major, type_minor, icon, pin, pin_rgb, pin_rgb_default) values('*', '*', 208, 600, '', '000000')"
    ];
    [self performUpgrade_X_Y:a];
     */
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
