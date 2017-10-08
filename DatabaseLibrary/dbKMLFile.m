/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

#import "dbKMLFile.h"

@interface dbKMLFile ()

@end

@implementation dbKMLFile

TABLENAME(@"kml_files")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into kml_files(filename, enabled) values(?, ?)");

        SET_VAR_TEXT(1, self.filename);
        SET_VAR_BOOL(2, self.enabled);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update kml_files set filename = ?, enabled = ? where id = ?");

        SET_VAR_TEXT(1, self.filename);
        SET_VAR_BOOL(2, self.enabled);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbKMLFile *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbKMLFile *> *kfs = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithFormat:@"select id, filename, enabled from kml_files "];
    if (where != nil)
        [sql appendString:where];

    @synchronized (db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbKMLFile *kf = [[dbKMLFile alloc] init];
            INT_FETCH (0, kf._id);
            TEXT_FETCH(1, kf.filename);
            BOOL_FETCH(2, kf.enabled);
            [kf finish];
            [kfs addObject:kf];
        }
        DB_FINISH;
    }
    return kfs;
}

+ (NSArray<dbKMLFile *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbKMLFile *)dbGetByFilename:(NSString *)filename
{
    return [[self dbAllXXX:@"where filename = ?" keys:@"s" values:@[filename]] firstObject];
}

@end
