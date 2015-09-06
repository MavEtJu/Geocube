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

@implementation ImportGPXJSON

- (id)init:(dbGroup *)_group account:(dbAccount *)_account;
{
    self = [super init];
    delegate = nil;

    newWaypointsCount = 0;
    totalWaypointsCount = 0;
    newLogsCount = 0;
    totalLogsCount = 0;
    percentageRead = 0;
    newTravelbugsCount = 0;
    totalTravelbugsCount = 0;
    newImagesCount = 0;

    group = _group;
    account = _account;

    NSLog(@"%@: Importing info %@", [self class], group.name);

    return self;
}

- (void)parseBefore
{
    NSLog(@"%@: Parsing initializing", [self class]);
    [dbc.Group_LastImport dbEmpty];
    [dbc.Group_LastImportAdded dbEmpty];
}

- (void)parseDictionary:(NSDictionary *)dict
{
    NSLog(@"%@: Parsing data", [self class]);

    [self parseGeocaches:[dict objectForKey:@"Geocaches"]];
}

- (void)parseGeocaches:(NSArray *)as
{
    [as enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseGeocache:d];
    }];
}
- (void)parseGeocache:(NSDictionary *)dict
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    dbGroundspeak *gs = [[dbGroundspeak alloc] init];

    // Waypoint object
    wp.name = [dict objectForKey:@"Code"];
    wp.description = [dict objectForKey:@"Name"];
    wp.url = [dict objectForKey:@"Url"];
    wp.urlname = [dict objectForKey:@"Name"];

    wp.lat_float = [[dict objectForKey:@"Latitude"] floatValue];
    wp.lat_int = [[dict objectForKey:@"Latitude"] floatValue] * 1000000;
    wp.lat = [[dict objectForKey:@"Latitude"] stringValue];

    wp.lon_float = [[dict objectForKey:@"Longitude"] floatValue];
    wp.lon_int = [[dict objectForKey:@"Longitude"] floatValue] * 1000000;
    wp.lon = [[dict objectForKey:@"Longitude"] stringValue];

    wp.date_placed_epoch = [MyTools secondsSinceEpochWindows:[dict objectForKey:@"UTCPlaceDate"]];
    wp.date_placed = [MyTools dateString:wp.date_placed_epoch];

    wp.symbol_str = @"Geocache";
    wp.type_str = [dict valueForKeyPath:@"CacheType.GeocacheTypeName"];

    wp.account_id = account._id;
    [wp finish];

    // Groundspeak object
    gs.rating_difficulty = [[dict objectForKey:@"Difficulty"] floatValue];
    gs.rating_terrain = [[dict objectForKey:@"Terrain"] floatValue];
    gs.favourites = [[dict objectForKey:@"FavoritePoints"] integerValue];
    gs.archived = [[dict objectForKey:@"Archived"] boolValue];
    gs.available = [[dict objectForKey:@"Available"] boolValue];

    gs.country_str = [dict objectForKey:@"Country"];
    gs.state_str = [dict objectForKey:@"State"];

    gs.short_desc_html = [[dict objectForKey:@"ShortDescriptionIsHtml"] boolValue];
    gs.long_desc_html = [[dict objectForKey:@"LongDescriptionIsHtml"] boolValue];
    gs.short_desc = [dict objectForKey:@"ShortDescription"];
    gs.long_desc = [dict objectForKey:@"LongDescription"];
    gs.hint = [dict objectForKey:@"EncodedHints"];
    gs.personal_note = [dict objectForKey:@"GeocacheNote"];

    gs.placed_by = [dict objectForKey:@"PlacedBy"];

    gs.owner_gsid = [[dict valueForKeyPath:@"Owner.Id"] stringValue];
    gs.owner_str = [dict valueForKeyPath:@"Owner.UserName"];

    gs.container_str = [dict valueForKeyPath:@"ContainerType.ContainerTypeName"];
    [gs finish:wp];

    // Now see what we had and what we need to change
    NSId wpid = [dbWaypoint dbGetByName:wp.name];
    if (wpid == 0) {
        [wp dbCreate];
        gs.waypoint_id = wp._id;
        [gs dbCreate];
        wp.groundspeak_id = gs._id;
        [wp dbUpdateGroundspeak];
    } else {
        dbWaypoint *wpold = [dbWaypoint dbGet:wpid];
        dbGroundspeak *gsold = [dbGroundspeak dbGet:wpold.groundspeak_id waypoint:wpold];
        wp._id = wpold._id;
        wp.groundspeak_id = gsold._id;
        gs._id = gsold._id;
        gs.waypoint_id = wp._id;
        [wp dbUpdate];
        [gs dbUpdate];
    }

    [self parseLogs:[dict objectForKey:@"GeocacheLogs"] waypoint:wp];
}

- (void)parseLogs:(NSArray *)logs waypoint:(dbWaypoint *)wp
{
    [logs enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseLog:d waypoint:wp];
    }];
}

- (void)parseLog:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
        "CacheCode": "GC5F521",
        "CannotDelete": false,
        "Code": "GLJRQDY1",
        "Finder": {
            "AvatarUrl": "http://www.geocaching.com/images/default_avatar.jpg",
            "FindCount": 61,
            "GalleryImageCount": null,
            "HideCount": 0,
            "HomeCoordinates": null,
            "Id": 1695430,
            "IsAdmin": false,
            "MemberType": {
                "MemberTypeId": 1,
                "MemberTypeName": "Basic"
            },
            "PublicGuid": "5daf4cbb-f070-42cb-9e99-fb2c741d0dad",
            "UserName": "lellyelly"
        },
        "Guid": "8d2aca04-334d-449b-9591-f210c4af008c",
        "ID": 537776688,
        "Images": [],
        "IsApproved": false,
        "IsArchived": false,
        "LogIsEncoded": false,
        "LogText": "Haha felt like a creep looking under here! Lucky theres a place to hide to wait for the muggles to disappear!",
        "LogType": {
            "AdminActionable": false,
            "ImageName": "icon_smile",
            "ImageURL": "http://www.geocaching.com/images/icons/icon_smile.gif",
            "OwnerActionable": false,
            "WptLogTypeId": 2,
            "WptLogTypeName": "Found it"
        },
        "UTCCreateDate": "/Date(1441334756497)/",
        "UpdatedLatitude": null,
        "UpdatedLongitude": null,
        "Url": "http://coord.info/GLJRQDY1",
        "VisitDate": "/Date(1441334712280-0700)/"
    },
     */

    dbLog *l = [[dbLog alloc] init];
    l.waypoint_id = wp._id;
    l.gc_id = [[dict objectForKey:@"ID"] integerValue];
    l.datetime_epoch = [MyTools secondsSinceEpochWindows:[dict objectForKey:@"UTCCreateDate"]];
    l.datetime = [MyTools dateString:l.datetime_epoch];
    l.needstobelogged = NO;
    l.log = [dict objectForKey:@"LogText"];
    l.logtype_string = [dict valueForKeyPath:@"LogType.WptLogTypeName"];

    dbName *name = [[dbName alloc] init];
    name.name = [dict valueForKeyPath:@"Finder.UserName"];
    name.account_id = wp.account_id;
    name.account = wp.account;
    name.code = [[dict valueForKeyPath:@"Finder.Id"] stringValue];
    [name finish];
    dbName *n = [dbName dbGetByNameCode:name.name code:name.code account:wp.account];
    if (n != nil) {
        name = n;
    } else {
        [name dbCreate];
    }
    l.logger_id = name._id;
    [l finish];

    NSInteger l_id = [dbLog dbGetIdByGC:l.gc_id account:wp.account];
    if (l_id == 0) {
        [l dbCreate];
    }
}

- (void)parseAfter
{
    NSLog(@"%@: Parsing done", [self class]);
    [[dbc Group_AllWaypoints_Found] dbEmpty];
    [[dbc Group_AllWaypoints_Found] dbAddWaypoints:[dbWaypoint dbAllFound]];
    [[dbc Group_AllWaypoints_Attended] dbEmpty];
    [[dbc Group_AllWaypoints_Attended] dbAddWaypoints:[dbWaypoint dbAllAttended]];
    [[dbc Group_AllWaypoints_NotFound] dbEmpty];
    [[dbc Group_AllWaypoints_NotFound] dbAddWaypoints:[dbWaypoint dbAllNotFound]];
    [dbc loadWaypointData];
    [dbWaypoint dbUpdateLogStatus];
}

@end
