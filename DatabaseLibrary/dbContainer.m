/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface dbContainer ()

@end

@implementation dbContainer

TABLENAME(@"containers")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into containers(size, icon, gc_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.size);
        SET_VAR_INT (2, self.icon);
        SET_VAR_INT (3, self.gc_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update containers set size = ?, icon = ?, gc_id = ? where id = ?");

        SET_VAR_TEXT( 1, self.size);
        SET_VAR_INT ( 2, self.icon);
        SET_VAR_INT ( 3, self.gc_id);
        SET_VAR_INT ( 4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbContainer *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbContainer *>*ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, size, icon, gc_id from containers "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbContainer *c = [[dbContainer alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.size);
            INT_FETCH (2, c.icon);
            INT_FETCH (3, c.gc_id);
            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbContainer *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbContainer *)dbGetByGCID:(NSInteger)gc_id
{
    return [[self dbAllXXX:@"where gc_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:gc_id]]] firstObject];
}

/*
_(@"container-Bolt");
_(@"container-Buried Block");
_(@"container-Cannon");
_(@"container-Cut");
_(@"container-Disc");
_(@"container-FBM");
_(@"container-Intersected Station");
_(@"container-Pillar");
_(@"container-Rivet");
_(@"container-Spider");
_(@"container-Micro");
_(@"container-Surface Block");
_(@"container-Berntsen");
_(@"container-Brass Plate");
_(@"container-Concrete Ring");
_(@"container-Curry Stool");
_(@"container-Fenomark");
_(@"container-Pipe");
_(@"container-Platform Bolt");
_(@"container-Unknown - user added");
_(@"container-Unknown");
_(@"container-Nano");
_(@"container-Not chosen");
_(@"container-nano");
_(@"container-micro");
_(@"container-small");
_(@"container-regular");
_(@"container-large");
_(@"container-none");
_(@"container-other");
_(@"container-xlarge");
_(@"container-Other");
_(@"container-Regular");
_(@"container-Small");
_(@"container-Virtual");
_(@"container-Active station");
_(@"container-Block");
_(@"container-Large");
*/

@end
