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

@interface ImportGGCWJSON ()

@end

@implementation ImportGGCWJSON

- (void)parseDictionary:(GCDictionaryGGCW *)dict infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    infoViewer = iv;
    iiImport = iii;
    if ([dict objectForKey:@"mapwaypoints"] != nil) {
        [self parseBefore_mapwaypoints];
        [self parseData_mapwaypoints:[dict objectForKey:@"mapwaypoints"]];
        [self parseAfter_mapwaypoints];
    }
    if ([dict objectForKey:@"trackables"] != nil) {
        [self parseBefore_trackables];
        [self parseData_trackables:[dict objectForKey:@"trackables"]];
        [self parseAfter_trackables];
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
    [infoViewer setLineObjectTotal:iiImport total:[waypoints count] isLines:NO];
    __block NSInteger idx = 0;
    [waypoints enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *wp, BOOL *stop) {
        [self parseData_mapwaypoint:wp];
        ++totalWaypointsCount;
        [infoViewer setWaypointsTotal:iiImport total:totalWaypointsCount];
        [infoViewer setLineObjectCount:iiImport count:++idx];
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

    dbWaypoint *wp = [dbWaypoint dbGetByName:wpt_name];
    if (wp == nil)
        wp = [[dbWaypoint alloc] init];
    wp.wpt_name = wpt_name;

    NSString *dummy;

    DICT_INTEGER_KEY(dict, wp.gs_archived, @"archived");
    DICT_INTEGER_KEY(dict, wp.gs_available, @"available");
    DICT_INTEGER_PATH(dict, wp.gs_rating_difficulty, @"difficulty.text");
    DICT_INTEGER_PATH(dict, wp.gs_rating_terrain, @"terrain.text");
    DICT_INTEGER_PATH(dict, wp.gs_favourites, @"fp");
    DICT_NSSTRING_PATH(dict, dummy, @"container.text");
    [wp set_wpt_type_str:dummy];
    DICT_NSSTRING_PATH(dict, dummy, @"owner.text");
    [dbName makeNameExist:dummy code:nil account:account];
    [wp set_gs_owner_str:dummy];

    wp.account = account;
    [wp finish];
    wp.date_lastimport_epoch = time(NULL);

    if (wp._id == 0) {
        NSLog(@"Created waypoint %@", wp.wpt_name);
        [wp dbCreate];
        newWaypointsCount++;
        [infoViewer setWaypointsNew:iiImport new:newWaypointsCount];
    } else {
        NSLog(@"Updated waypoint %@", wp.wpt_name);
        [wp dbUpdate];
    }
    [self.delegate Import_WaypointProcessed:wp];

    [opencageManager addForProcessing:wp];

    if ([group containsWaypoint:wp] == NO)
        [group addWaypointToGroup:wp];
}

- (void)parseBefore_trackables
{
    NSLog(@"%@/parseBefore_trackables: Parsing initializing", [self class]);
}

- (void)parseAfter_trackables
{
    NSLog(@"%@/parseAfter_trackables: Parsing done", [self class]);
}

- (void)parseData_trackables:(NSArray<NSDictionary *> *)trackables
{
    [infoViewer setLineObjectTotal:iiImport total:[trackables count] isLines:NO];
    [trackables enumerateObjectsUsingBlock:^(NSDictionary *tb, NSUInteger idx, BOOL *stop) {
        [self parseData_trackable:tb];
        ++totalTrackablesCount;
        [infoViewer setWaypointsTotal:iiImport total:totalTrackablesCount];
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
    }];
}

- (void)parseData_trackable:(NSDictionary *)tbdata
{
/*
{
    "carrier_id" = 19971;
    carrier = lillieb05;
    gccode = TB72XZA;
    guid = "bc97d29d-facc-4818-8a49-4351602a37f5";
    owner = "Delta_03";
    id = 6140957;
    name = "Team MavEtJu Goes Geocaching - Try 2";
}
 */

    NSString *gccode = [tbdata objectForKey:@"gccode"];
    dbTrackable *tb = [dbTrackable dbGetByRef:gccode];
    if (tb == nil) {
        tb = [[dbTrackable alloc] init];
        tb.ref = gccode;
    }

    NSString *dummy;

    DICT_INTEGER_KEY(tbdata, tb.gc_id, @"id");
    DICT_NSSTRING_KEY(tbdata, tb.name, @"name");
    DICT_NSSTRING_KEY(tbdata, dummy, @"carrier");
    [dbName makeNameExist:dummy code:nil account:account];
    [tb set_carrier_str:dummy account:account];
    DICT_NSSTRING_KEY(tbdata, dummy, @"owner");
    [dbName makeNameExist:dummy code:nil account:account];
    [tb set_owner_str:dummy account:account];
    [tb finish];

    if (tb._id == 0) {
        NSLog(@"Created trackable %@", tb.ref);
        [tb dbCreate];
        newTrackablesCount++;
        [infoViewer setTrackablesNew:iiImport new:newTrackablesCount];
    } else {
        [tb dbUpdate];
    }
}

@end
