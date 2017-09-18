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

#import "dbAttribute.h"

#import "DatabaseLibrary/Database.h"
#import "DatabaseLibrary/dbWaypoint.h"

@interface dbAttribute ()

@end

@implementation dbAttribute

TABLENAME(@"attributes")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into attributes(label, gc_id, icon) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.label);
        SET_VAR_INT (2, self.gc_id);
        SET_VAR_INT (3, self.icon);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update attributes set label = ?, icon = ? where id = ?");

        SET_VAR_TEXT(1, self.label);
        SET_VAR_INT (2, self.icon);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbAttribute *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbAttribute *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, label, gc_id, icon from attributes "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH (2, a.gc_id);
            INT_FETCH (3, a.icon);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbAttribute *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbAttribute *> *)dbAllByWaypoint:(dbWaypoint *)wp
{
    NSMutableArray<dbAttribute *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select a.id, a.label, a.icon, a.gc_id, b.yes from attributes a inner join attribute2waypoints b on a.id = b.attribute_id where b.waypoint_id = ?");

        SET_VAR_INT( 1, wp._id);

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH (2, a.icon);
            INT_FETCH (3, a.gc_id);
            INT_FETCH (4, a._YesNo);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (dbAttribute *)dbGetByGCId:(NSInteger)gc_id
{
    return [[self dbAllXXX:@"where gc_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:gc_id]]] firstObject];
}

/* Other methods */

+ (void)dbUnlinkAllFromWaypoint:(dbWaypoint *)wp
{
    NSId __id = 0;

    @synchronized(db) {
        DB_PREPARE(@"delete from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(dbWaypoint *)wp YesNo:(BOOL)YesNo
{
    @synchronized(db) {
        DB_PREPARE(@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values(?, ?, ?)");

        SET_VAR_INT (1, self._id);
        SET_VAR_INT (2, wp._id);
        SET_VAR_BOOL(3, YesNo);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbAllLinkToWaypoint:(dbWaypoint *)wp attributes:(NSArray<dbAttribute *> *)attrs YesNo:(BOOL)YesNo
{
    if ([attrs count] == 0)
        return;

    __block NSMutableString *sql = [NSMutableString stringWithString:@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values "];
    [attrs enumerateObjectsUsingBlock:^(dbAttribute * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != 0)
            [sql appendString:@","];
        [sql appendFormat:@"(%ld, %ld, %d)", (long)attr._id, (long)wp._id, YesNo];
    }];
    @synchronized(db) {
        DB_PREPARE(sql);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_IF_STEP {
            INT_FETCH(0, count);
        }
        DB_FINISH;
    }
    return count;
}

@end

/*
_(@"attributes-Unknown");
_(@"attributes-Dogs Allowed");
_(@"attributes-Access or parking fee");
_(@"attributes-Rock Climbing");
_(@"attributes-Boat");
_(@"attributes-Scuba Gear");
_(@"attributes-Recommended for kids");
_(@"attributes-Takes less than an hour");
_(@"attributes-Scenic view");
_(@"attributes-Significant Hike");
_(@"attributes-Difficult climbing");
_(@"attributes-May require wading");
_(@"attributes-May require swimming");
_(@"attributes-Available at all times");
_(@"attributes-Recommended at night");
_(@"attributes-Available during winter");
_(@"attributes-?");
_(@"attributes-Poison plants");
_(@"attributes-Dangerous Animals");
_(@"attributes-Ticks");
_(@"attributes-Abandoned mines");
_(@"attributes-Cliff / falling rocks");
_(@"attributes-Hunting");
_(@"attributes-Dangerous area");
_(@"attributes-Wheelchair accessible");
_(@"attributes-Parking available");
_(@"attributes-Public transportation");
_(@"attributes-Drinking water nearby");
_(@"attributes-Public restrooms nearby");
_(@"attributes-Telephone nearby");
_(@"attributes-Picnic tables nearby");
_(@"attributes-Camping available");
_(@"attributes-Campfires");
_(@"attributes-Bicycles");
_(@"attributes-Motorcycles");
_(@"attributes-Quads");
_(@"attributes-Off-road vehicles");
_(@"attributes-Snowmobiles");
_(@"attributes-Horses");
_(@"attributes-Thorns");
_(@"attributes-Stealth required");
_(@"attributes-Stroller accessible");
_(@"attributes-Needs maintenance");
_(@"attributes-Watch for livestock");
_(@"attributes-Flashlight required");
_(@"attributes-Lost And Found Tour");
_(@"attributes-Truck Driver/RV");
_(@"attributes-Field Puzzle");
_(@"attributes-UV Torch required");
_(@"attributes-Snowshoes");
_(@"attributes-Cross Country Skies");
_(@"attributes-Special Tool Required");
_(@"attributes-Night Cache");
_(@"attributes-Park and Grab");
_(@"attributes-Abandoned Structure");
_(@"attributes-Short hike (less than 1km)");
_(@"attributes-Medium hike (1km-10km)");
_(@"attributes-Long Hike (+10km)");
_(@"attributes-Fuel Nearby");
_(@"attributes-Food Nearby");
_(@"attributes-WirelessBeacon");
_(@"attributes-Partnership Cache");
_(@"attributes-Seasonal Access");
_(@"attributes-Tourist Friendly");
_(@"attributes-Tree Climbing");
_(@"attributes-Front Yard");
_(@"attributes-Teamwork Required");
_(@"attributes-Part of a GeoTour");
*/
