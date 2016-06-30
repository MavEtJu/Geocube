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

@interface dbFileImport ()
{
    NSString *filename;
    NSInteger lastimport;
    NSInteger filesize;
}

@end

@implementation dbFileImport

@synthesize filename, filesize, lastimport;

+ (NSId)dbCreate:(dbFileImport *)fi
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into file_imports(filename, filesize, last_import_epoch) values(?, ?, ?)");

        SET_VAR_TEXT(1, fi.filename);
        SET_VAR_INT (2, fi.filesize);
        SET_VAR_INT (3, fi.lastimport);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    fi._id = _id;
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update file_imports set filename = ?, filesize = ?, last_import_epoch = ? where id = ?");

        SET_VAR_TEXT(1, filename);
        SET_VAR_INT (2, filesize);
        SET_VAR_INT (3, lastimport);
        SET_VAR_INT (4, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAll
{
    NSMutableArray *is = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, filename, filesize, last_import_epoch from file_imports");

        DB_WHILE_STEP {
            dbFileImport *i = [[dbFileImport alloc] init];
            INT_FETCH (0, i._id);
            TEXT_FETCH(1, i.filename);
            INT_FETCH (2, i.filesize);
            INT_FETCH (3, i.lastimport);
            [i finish];
            [is addObject:i];
        }
        DB_FINISH;
    }
    return is;
}

+ (NSInteger)dbCount
{
    return [dbImage dbCount:@"file_imports"];
}

@end
