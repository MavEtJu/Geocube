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

#import "dbType.h"

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Geocube-defines.h"

#import "DatabaseLibrary/Database.h"
#import "DatabaseLibrary/DatabaseCache.h"
#import "DatabaseLibrary/dbPin.h"

@interface dbType ()

@end

@implementation dbType

TABLENAME(@"types")

- (void)finish
{
    self.type_full = [NSString stringWithFormat:@"%@|%@", self.type_major, self.type_minor];
    [super finish];
}

- (NSId)dbCreate
{
    ASSERT_FINISHED;
    ASSERT_SELF_FIELD_EXISTS(pin);
    @synchronized(db) {
        DB_PREPARE(@"insert into types(type_major, type_minor, icon, pin_id, has_boundary) values(?, ?, ?, ?, ?)");

        SET_VAR_TEXT(1, self.type_major);
        SET_VAR_TEXT(2, self.type_minor);
        SET_VAR_INT (3, self.icon);
        SET_VAR_INT (4, self.pin._id);
        SET_VAR_BOOL(5, self.hasBoundary);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update types set type_major = ?, type_minor = ?, icon = ?, pin_id = ?, has_boundary = ? where id = ?");

        SET_VAR_TEXT(1, self.type_major);
        SET_VAR_TEXT(2, self.type_minor);
        SET_VAR_INT (3, self.icon);
        SET_VAR_INT (4, self.pin._id);
        SET_VAR_INT (5, self.hasBoundary);
        SET_VAR_INT (6, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbType *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbType *> *ts = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, type_major, type_minor, icon, pin_id, has_boundary from types "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbType *t = [[dbType alloc] init];
            INT_FETCH (0, t._id);
            TEXT_FETCH(1, t.type_major);
            TEXT_FETCH(2, t.type_minor);
            INT_FETCH (3, t.icon);
            INT_FETCH (4, i);
            t.pin = [dbc pinGet:i];
            BOOL_FETCH(5, t.hasBoundary);
            [t finish];
            [ts addObject:t];
        }
        DB_FINISH;
    }
    return ts;
}

+ (NSArray<dbType *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbType *)dbGetByMajor:(NSString *)major minor:(NSString *)minor
{
    return [[self dbAllXXX:@"where type_minor = ? and type_major = ?" keys:@"ss" values:@[minor, major]] firstObject];
}

@end

/*
 _(@"type-Active station");
 _(@"type-Beacon");
 _(@"type-Benchmark");
 _(@"type-Berntsen");
 _(@"type-Block");
 _(@"type-Bolt");
 _(@"type-Brass Plate");
 _(@"type-Buried Block");
 _(@"type-Burke and Wills");
 _(@"type-CITO");
 _(@"type-Cache In Trash Out Event");
 _(@"type-Cannon");
 _(@"type-Concrete Ring");
 _(@"type-Cannon");
 _(@"type-Concrete Ring");
 _(@"type-Contest");
 _(@"type-Curry Stool");
 _(@"type-Cut");
 _(@"type-Disc");
 _(@"type-Drive-In");
 _(@"type-Earthcache");
 _(@"type-Event Cache");
 _(@"type-Event");
 _(@"type-FBM");
 _(@"type-Fenomark");
 _(@"type-Final Location");
 _(@"type-Flag");
 _(@"type-GPS Adventures Exhibit");
 _(@"type-Gadget");
 _(@"type-Giga");
 _(@"type-Giga-Event Cache");
 _(@"type-Groundspeak Block Party");
 _(@"type-Groundspeak HQ");
 _(@"type-Groundspeak Lost and Found Celebration");
 _(@"type-GroundspeakHQ");
 _(@"type-History");
 _(@"type-Intersected Station");
 _(@"type-Letterbox Hybrid");
 _(@"type-Locationless (Reverse) Cache");
 _(@"type-Locationless");
 _(@"type-Lost and Found Event Caches");
 _(@"type-Manually entered");
 _(@"type-Math/Physics");
 _(@"type-Maze");
 _(@"type-Mega");
 _(@"type-Mega-Event Cache");
 _(@"type-Moveable");
 _(@"type-Multi Stage");
 _(@"type-Multi");
 _(@"type-Multi-cache");
 _(@"type-Multistep Traditional cache");
 _(@"type-Multistep Virtual cache");
 _(@"type-Mystery");
 _(@"type-Night Cache");
 _(@"type-Other");
 _(@"type-Own");
 _(@"type-Parking Area");
 _(@"type-Physical Stage");
 _(@"type-Pillar");
 _(@"type-Pipe");
 _(@"type-Platform Bolt");
 _(@"type-Podcache");
 _(@"type-Project APE Cache");
 _(@"type-Puzzle");
 _(@"type-Quiz");
 _(@"type-Reference Point");
 _(@"type-Reverse");
 _(@"type-Rivet");
 _(@"type-Spider");
 _(@"type-Surface Block");
 _(@"type-Traditional Cache");
 _(@"type-Traditional");
 _(@"type-Trailhead");
 _(@"type-TrigPoint");
 _(@"type-Trigpoint");
 _(@"type-Unknown (Mystery) Cache");
 _(@"type-Unknown - user added");
 _(@"type-Unknown Cache");
 _(@"type-Unknown or Mystery");
 _(@"type-Virtual Cache");
 _(@"type-Virtual Stage");
 _(@"type-Virtual");
 _(@"type-Waymark");
 _(@"type-Webcam Cache");
 _(@"type-Webcam");
 _(@"type-Wherigo Cache");
 _(@"type-Wherigo Caches");
 _(@"type-benchmark");
*/
