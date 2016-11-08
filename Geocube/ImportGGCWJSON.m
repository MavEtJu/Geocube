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

@interface ImportGGCWJSON ()

@end

@implementation ImportGGCWJSON

- (void)parseDictionary:(GCDictionaryGGCW *)dict infoItemImport:(InfoItemImport *)iii
{
    infoItemImport = iii;
    if ([dict objectForKey:@"mapwaypoints"] != nil) {
        [self parseBefore_mapwaypoints];
        [self parseData_mapwaypoints:[dict objectForKey:@"mapwaypoints"]];
        [self parseAfter_mapwaypoints];
    }
}

- (void)parseBefore_mapwaypoints
{
    NSLog(@"%@/parseBefore_mapwaypoints: Parsing initializing", [self class]);
}

- (void)parseAfter_mapwaypoints
{
    NSLog(@"%@/parseAfter_mapwaypoints: Parsing done", [self class]);
}

- (void)parseData_mapwaypoints:(NSDictionary *)waypoints
{
    [infoItemImport setLineObjectTotal:[waypoints count] isLines:NO];
    __block NSInteger idx = 0;
    [waypoints enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *wp, BOOL *stop) {
        [self parseData_mapwaypoint:wp];
        ++totalWaypointsCount;
        [infoItemImport setWaypointsTotal:totalWaypointsCount];
        [infoItemImport setLineObjectCount:++idx];
    }];
}

- (void)parseData_mapwaypoint:(NSDictionary *)dict
{
    NSLog(@"%@/parseData_mapwaypoint: parsing", [self class]);
/*
 {
     archived = 0;
     available = 1;
     container =     {
         text = Small;
         value = "small.gif";
     };
     difficulty =     {
         text = 1;
         value = 1;
     };
     fp = 0;
     g = "af5d5f2a-d37d-482e-89ee-2fe03a1f8e06";
     gc = GC5F521;
     hidden = "2014-10-19";
     li = 1;
     name = "Caringbah Girl Guides Hall - Shanti";
     owner =     {
         text = "Team MavEtJu";
         value = "7d657fb4-351b-4321-8f39-a96fe85309a6";
     };
     subrOnly = 0;
     terrain =     {
         text = "1.5";
         value = "1_5";
     };
     type =     {
         text = "Traditional Cache";
         value = 2;
     };
 }
 */

    NSString *wpt_name;
    DICT_NSSTRING_KEY(dict, wpt_name, @"gc");

    NSId wpid = [dbWaypoint dbGetByName:wpt_name];
    dbWaypoint *wp;
    if (wpid == 0)
        wp = [[dbWaypoint alloc] init];
    else
        wp = [dbWaypoint dbGet:wpid];
    wp.wpt_name = wpt_name;

    DICT_INTEGER_KEY(dict, wp.gs_archived, @"archived");
    DICT_INTEGER_KEY(dict, wp.gs_available, @"available");
    DICT_INTEGER_PATH(dict, wp.gs_rating_difficulty, @"difficulty.text");
    DICT_INTEGER_PATH(dict, wp.gs_rating_terrain, @"terrain.text");
    DICT_INTEGER_PATH(dict, wp.gs_favourites, @"fp");
    wp.wpt_type_id = 0;
    wp.wpt_type = nil;
    DICT_NSSTRING_PATH(dict, wp.wpt_type_str, @"container.text");
    wp.gs_owner_id = 0;
    wp.gs_owner = nil;
    DICT_NSSTRING_PATH(dict, wp.gs_owner_str, @"owner.text");
    [dbName makeNameExist:wp.gs_owner_str code:nil account:account];

    wp.account = account;
    [wp finish];
    wp.date_lastimport_epoch = time(NULL);

    if (wp._id == 0) {
        NSLog(@"Created waypoint %@", wp.wpt_name);
        [dbWaypoint dbCreate:wp];
        newWaypointsCount++;
        [infoItemImport setWaypointsNew:newWaypointsCount];
    } else {
        NSLog(@"Updated waypoint %@", wp.wpt_name);
        [wp dbUpdate];
    }
    if ([group dbContainsWaypoint:wp._id] == NO)
        [group dbAddWaypoint:wp._id];
}

@end