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

@implementation ImportLiveAPIJSON

- (instancetype)init:(dbGroup *)_group account:(dbAccount *)_account;
{
    self = [super init];
    delegate = nil;

    newWaypointsCount = 0;
    totalWaypointsCount = 0;
    newLogsCount = 0;
    totalLogsCount = 0;
    percentageRead = 0;
    newTrackablesCount = 0;
    totalTrackablesCount = 0;
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

    gs.placed_by = [dict objectForKey:@"PlacedBy"];

    gs.owner_gsid = [[dict valueForKeyPath:@"Owner.Id"] stringValue];
    gs.owner_str = [dict valueForKeyPath:@"Owner.UserName"];

    gs.container_str = [dict valueForKeyPath:@"ContainerType.ContainerTypeName"];
    [gs finish:wp];

    // Now see what we had and what we need to change
    NSId wpid = [dbWaypoint dbGetByName:wp.name];
    if (wpid == 0) {
        [dbWaypoint dbCreate:wp];
        gs.waypoint_id = wp._id;
        [gs dbCreate];
        wp.groundspeak_id = gs._id;
        [wp dbUpdateGroundspeak];
        [group dbAddWaypoint:wp._id];
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

    NSString *personal_note = [dict objectForKey:@"GeocacheNote"];
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:wp.name];
    if (pn != nil) {
        if (personal_note == nil || [personal_note isKindOfClass:[NSNull class]] == YES || [personal_note isEqualToString:@""] == YES) {
            [pn dbDelete];
            pn = nil;
        } else {
            pn.note = personal_note;
            [pn dbUpdate];
        }
    } else {
        if (personal_note != nil && [personal_note isKindOfClass:[NSNull class]] == NO && [personal_note isEqualToString:@""] == NO) {
            pn = [[dbPersonalNote alloc] init];
            pn.wp_name = wp.name;
            pn.waypoint_id = wp._id;
            pn.note = personal_note;
            [pn dbCreate];
        }
    }

    [self parseLogs:[dict objectForKey:@"GeocacheLogs"] waypoint:wp];
    [self parseAttributes:[dict objectForKey:@"Attributes"] waypoint:wp];
    [self parseAdditionalWaypoints:[dict objectForKey:@"AdditionalWaypoints"] waypoint:wp];
    [self parseTrackables:[dict objectForKey:@"Trackables"] waypoint:wp];
    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGETYPE_CACHE];
}

- (void)parseTrackables:(NSArray *)trackables waypoint:(dbWaypoint *)wp
{
    [dbTrackable dbUnlinkAllFromWaypoint:wp._id];
    [trackables enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseTrackable:d waypoint:wp];
    }];
}

- (void)parseTrackable:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
         "AllowedToBeCollected": null,
         "Archived": false,
         "BugTypeID": 1302,
         "Code": "TB1TE1B",
         "CurrentGeocacheCode": "GC1DTJC",
         "CurrentGoal": "My mission is to visit Banks and see other Piggy banks all over the world",
         "CurrentOwner": {
             "AvatarUrl": "http://www.geocaching.com/images/default_avatar.jpg",
             "FindCount": null,
             "GalleryImageCount": null,
             "HideCount": null,
             "HomeCoordinates": null,
             "Id": null,
             "IsAdmin": false,
             "MemberType": null,
             "PublicGuid": "00000000-0000-0000-0000-000000000000",
             "UserName": null
         },
         "DateCreated": "/Date(1180571341627-0700)/",
         "Description": "",
         "IconUrl": "http://www.geocaching.com/images/wpttypes/1302.gif",
         "Id": 1270672,
         "Images": [],
         "InCollection": false,
         "Name": "Piggy Bank Geocoin",
         "OriginalOwner": {
             "AvatarUrl": "http://img.geocaching.com/user/avatar/fb986d53-5701-4f12-ab5f-fba83de4d033.jpg",
             "FindCount": null,
             "GalleryImageCount": null,
             "HideCount": null,
             "HomeCoordinates": null,
             "Id": 131247,
             "IsAdmin": false,
             "MemberType": null,
             "PublicGuid": "8b746a92-d5c8-4141-b391-c85d7427d119",
             "UserName": "Skippy."
         },
         "TBTypeName": "Piggy Bank Geocoins",
         "TBTypeNameSingular": "Piggy Bank Geocoin",
         "TrackableLogs": [
             {
                 "CacheID": null,
                 "Code": "TL671TXR",
                 "ID": 177883141,
                 "Images": [],
                 "IsArchived": false,
                 "LogGuid": "1797c8a0-206b-4f8a-9124-e42d4096acaf",
                 "LogIsEncoded": false,
                 "LogText": "This trackable was not in cache shire's treasure #3",
                 "LogType": {
                     "AdminActionable": false,
                     "ImageName": "icon_note",
                     "ImageURL": "http://www.geocaching.com/images/icons/icon_note.gif",
                     "OwnerActionable": false,
                     "WptLogTypeId": 4,
                     "WptLogTypeName": "Write note"
                 },
                 "LoggedBy": {
                     "AvatarUrl": "http://img.geocaching.com/user/avatar/3426232f-a633-4022-91d9-bedf12c7e45d.jpg",
                     "FindCount": 51,
                     "GalleryImageCount": null,
                     "HideCount": 0,
                     "HomeCoordinates": null,
                     "Id": 7752632,
                     "IsAdmin": false,
                     "MemberType": null,
                     "PublicGuid": "1f0e45ae-9211-4237-9156-4d884ec8d526",
                     "UserName": "surf_storm"
                 },
                 "UTCCreateDate": "/Date(1375079795000)/",
                 "UpdatedLatitude": null,
                 "UpdatedLongitude": null,
                 "Url": "http://coord.info/TL671TXR",
                 "VisitDate": "/Date(1375079798004-0700)/"
             }
         ],
         "TrackingCode": null,
         "Url": "http://coord.info/TB1TE1B",
         "UserCount": null,
         "WptTypeID": 1302
     },
     */

    dbTrackable *tb = [[dbTrackable alloc] init];
    tb.name = [dict objectForKey:@"Name"];
    tb.gc_id = [[dict objectForKey:@"Id"] integerValue];
    tb.ref = [dict objectForKey:@"Code"];

    NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
    if (_id == 0) {
        [dbTrackable dbCreate:tb];
    } else {
        tb._id = _id;
        [tb dbUpdate];
    }

    [tb dbLinkToWaypoint:wp._id];
}

- (void)parseImages:(NSArray *)attributes waypoint:(dbWaypoint *)wp imageSource:(NSInteger)imageSource
{
    [attributes enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseImage:d waypoint:wp imageSource:imageSource];
    }];
}

- (void)parseImage:(NSDictionary *)dict waypoint:(dbWaypoint *)wp imageSource:(NSInteger)imageSource
{
    /*
     {
        "DateCreated": "/Date(1415357658767-0800)/",
        "Description": "",
        "ImageGuid": "bef09faf-6c1d-42e7-98f9-f52bfe84f872",
        "MobileUrl": "http://img.geocaching.com/cache/large/bef09faf-6c1d-42e7-98f9-f52bfe84f872.jpg",
        "Name": "Shanti",
        "ThumbUrl": "http://img.geocaching.com/cache/thumb/bef09faf-6c1d-42e7-98f9-f52bfe84f872.jpg",
        "Url": "http://img.geocaching.com/cache/bef09faf-6c1d-42e7-98f9-f52bfe84f872.jpg"
     }
     */

    NSString *url = [dict objectForKey:@"Url"];
    NSString *name = [dict objectForKey:@"Name"];
    NSString *df = [dbImage createDataFilename:url];

    dbImage *img = [dbImage dbGetByURL:url];
    if (img == nil) {
        img = [[dbImage alloc] init:url name:name datafile:df];
        [dbImage dbCreate:img];
    }
    [ImagesDownloadManager addToQueue:img];

    if ([img dbLinkedtoWaypoint:wp._id] == NO)
        [img dbLinkToWaypoint:wp._id type:imageSource];
}

- (void)parseAttributes:(NSArray *)attributes waypoint:(dbWaypoint *)wp
{
    [dbAttribute dbUnlinkAllFromWaypoint:wp._id];
    [attributes enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseAttribute:d waypoint:wp];
    }];
}

- (void)parseAttribute:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
        "AttributeTypeID": 1,
        "IsOn": true
     },
     */
    NSInteger gc_id = [[dict objectForKey:@"AttributeTypeID"] integerValue];
    dbAttribute *a = [dbc Attribute_get_bygcid:gc_id];
    BOOL yesNo = [[dict objectForKey:@"IsON"] boolValue];
    [a dbLinkToWaypoint:wp._id YesNo:yesNo];
}

- (void)parseAdditionalWaypoints:(NSArray *)wps waypoint:(dbWaypoint *)wp
{
    [wps enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseAdditionalWaypoint:d waypoint:wp];
    }];
}

- (void)parseAdditionalWaypoint:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
        "Code": "PK5F521",
        "Comment": "",
        "Description": "GC5F521 Parking",
        "GUID": "f97fbfac-22f8-41db-a71c-2a8f472e5738",
        "GeocacheCode": "GC5F521",
        "Latitude": -34.04566666666667,
        "Longitude": 151.12505,
        "Name": "Parking Area",
        "Type": "Waypoint|Parking Area",
        "UTCEnteredDate": "/Date(1441523969270-0700)/",
        "Url": "http://www.geocaching.com/seek/wpt.aspx?WID=f97fbfac-22f8-41db-a71c-2a8f472e5738",
        UrlName": "GC5F521 Parking",
        "WptTypeID": 217
     }
    */

    dbWaypoint *awp = [[dbWaypoint alloc] init];

    // Waypoint object
    awp.name = [dict objectForKey:@"Code"];
    awp.description = [dict objectForKey:@"Description"];
    awp.url = [dict objectForKey:@"Url"];
    awp.urlname = [dict objectForKey:@"UrlName"];

    if ([[dict objectForKey:@"Latitude"] isKindOfClass:[NSNumber class]] == NO) {
        awp.lat_float = 0;
        awp.lat_int = 0;
        awp.lat = @"0";
    } else {
        awp.lat_float = [[dict objectForKey:@"Latitude"] floatValue];
        awp.lat_int = awp.lat_float * 1000000;
        awp.lat = [[dict objectForKey:@"Latitude"] stringValue];
    }

    if ([[dict objectForKey:@"Longitude"] isKindOfClass:[NSNumber class]] == NO) {
        awp.lon_float = 0;
        awp.lon_int = 0;
        awp.lon = @"0";
    } else {
        awp.lon_float = [[dict objectForKey:@"Latitude"] floatValue];
        awp.lon_int = awp.lon_float * 1000000;
        awp.lon = [[dict objectForKey:@"Latitude"] stringValue];
    }

    awp.date_placed_epoch = [MyTools secondsSinceEpochWindows:[dict objectForKey:@"UTCEnteredDate"]];
    awp.date_placed = [MyTools dateString:awp.date_placed_epoch];

    awp.symbol_str = [dict objectForKey:@"Name"];
    awp.type_str = [dict objectForKey:@"Type"];

    awp.account_id = account._id;
    [awp finish];

    NSId wpid = [dbWaypoint dbGetByName:awp.name];
    if (wpid == 0) {
        [dbWaypoint dbCreate:awp];
        [group dbAddWaypoint:awp._id];
    } else {
        dbWaypoint *wpold = [dbWaypoint dbGet:wpid];
        awp._id = wpold._id;
        [awp dbUpdate];
    }
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

    NSId l_id = [dbLog dbGetIdByGC:l.gc_id account:wp.account];
    if (l_id == 0) {
        [l dbCreate];
    }

    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGETYPE_LOG];
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
