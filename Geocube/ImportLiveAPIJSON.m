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

@interface ImportLiveAPIJSON ()

@end

@implementation ImportLiveAPIJSON

- (void)parseBefore_geocaches
{
    GCLog(@"Parsing initializing");
    [dbc.Group_LastImport dbEmpty];
    [dbc.Group_LastImportAdded dbEmpty];
    [db cleanupAfterDelete];
}

- (void)parseAfter_geocaches
{
    GCLog(@"Parsing done");
    [[dbc Group_AllWaypoints_Found] dbEmpty];
    [[dbc Group_AllWaypoints_Found] dbAddWaypoints:[dbWaypoint dbAllFound]];
    [[dbc Group_AllWaypoints_NotFound] dbEmpty];
    [[dbc Group_AllWaypoints_NotFound] dbAddWaypoints:[dbWaypoint dbAllNotFound]];
    [[dbc Group_AllWaypoints_Ignored] dbEmpty];
    [[dbc Group_AllWaypoints_Ignored] dbAddWaypoints:[dbWaypoint dbAllIgnored]];
    [db cleanupAfterDelete];
    [dbWaypoint dbUpdateLogStatus];
}

- (void)parseBefore_trackables
{
}
- (void)parseAfter_trackables
{
}

- (void)parseDictionary:(NSDictionary *)dict infoViewer:(InfoViewer *)iv ivi:(InfoItemID)iii
{
    GCLog(@"Parsing data");

    infoViewer = iv;
    ivi = iii;

    if ([dict objectForKey:@"Geocaches"] != nil) {
        [self parseBefore_geocaches];
        [self parseGeocaches:[dict objectForKey:@"Geocaches"]];
        [self parseAfter_geocaches];
    }
    if ([dict objectForKey:@"Trackables"] != nil) {
        [self parseBefore_trackables];
        [self parseTrackables:[dict objectForKey:@"Trackables"] waypoint:nil];
        [self parseAfter_trackables];
    }
}

- (void)parseGeocaches:(NSArray *)as
{
    [infoViewer setLineObjectTotal:ivi total:[as count] isLines:NO];
    [as enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseGeocache:d];
        totalWaypointsCount++;

        [infoViewer setLineObjectCount:ivi count:idx];
        [infoViewer setWaypointsTotal:ivi total:totalWaypointsCount];
    }];
    [infoViewer setLineObjectCount:ivi count:[as count]];
}
- (void)parseGeocache:(NSDictionary *)dict
{
    /*
     {
         AccountID = 14593989;
         AdditionalWaypoints =     (
         );
         Archived = 0;
         Attributes =     (
         );
         Available = 1;
         CacheType =     {
             Description = "";
             GeocacheTypeId = 2;
             GeocacheTypeName = "Traditional Cache";
             ImageURL = "http://www.geocaching.com/images/wpttypes/2.gif";
             IsContainer = 0;
             IsGrandfathered = "<null>";
             ParentTypeId = 0;
             UserCount = "<null>";
         };
         CanCacheBeFavorited = 1;
         Code = GC664B5;
         ContainerType =     {
             ContainerTypeId = 8;
             ContainerTypeName = Small;
             Order = 30;
         };
         Country = Australia;
         CountryID = 3;
         CurrentDetailsCount = 107;
         DateCreated = "/Date(1446274800000-0700)/";
         DateLastUpdate = "/Date(1453114880103-0800)/";
         DateLastVisited = "/Date(1453147200000-0800)/";
         Difficulty = 2;
         EncodedHints = "don't get too stumped over this one";
         FavoritePoints = 0;
         FoundDate = "<null>";
         FoundDateOfFoundByUser = "<null>";
         GUID = "4950dde1-1688-4f3b-a817-181b19af47d5";
         GeocacheLogs =     (
         );
         GeocacheNote = "<null>";
         HasbeenFavoritedbyUser = 0;
         HasbeenFoundbyUser = 0;
         ID = 5312942;
         ImageCount = 0;
         Images =     (
         );
         IsLocked = 0;
         IsPremium = 0;
         IsPublished = 1;
         IsRecommended = 0;
         Latitude = "-33.960117";
         LongDescription = "<p>The co-ordinates are wrong!! accidentally out in the wrong co-ordinate, the correct one is S33 57.607 E150 56.343, there is also a temp image in images to help you out!! Nice, quick hide in a rural area\U00a0</p>
         \n<p>The geocache is a small Tupperware container\U00a0</p>
         \n<p>This was our first placing of our own geocache, hope it's not too easy or hard\U00a0</p>
         \n<p>\U00a0</p>
         \n
         \n";
         LongDescriptionIsHtml = 1;
         Longitude = "150.93905";
         MaxDetailCount = 6000;
         Name = "Australis I ";
         Owner =     {
             AvatarUrl = "http://www.geocaching.com/images/default_avatar.jpg";
             FindCount = 16;
             GalleryImageCount = "<null>";
             HideCount = 1;
             HomeCoordinates = "<null>";
             Id = 14593989;
             IsAdmin = 0;
             MemberType =         {
                 MemberTypeId = 1;
                 MemberTypeName = Basic;
             };
             PublicGuid = "d9cab948-5a62-46c2-9e6b-4be86a3fd083";
             UserName = imaemily27;
         };
         PlacedBy = imaemily27;
         PublishDateUtc = "/Date(1446509220000-0800)/";
         ShortDescription = "
         \n";
         ShortDescriptionIsHtml = 1;
         StagesCount = 0;
         State = "New South Wales";
         StateID = 52;
         Terrain = "1.5";
         TrackableCount = 0;
         Trackables =     (
         );
         UTCPlaceDate = "/Date(1446274800000-0700)/";
         UpgradeMessage = "<null>";
         Url = "http://coord.info/GC664B5";
         UserWaypoints =     (
         );
     }
     */

    NSString *wpt_name = nil;
    DICT_NSSTRING_KEY(dict, wpt_name, @"Code");

    dbWaypoint *wp = nil;
    NSId _id = [dbWaypoint dbGetByName:wpt_name];
    if (_id != 0)
        wp = [dbWaypoint dbGet:_id];
    else
        wp = [[dbWaypoint alloc] init];

    // Waypoint object
    DICT_NSSTRING_KEY(dict, wp.wpt_name, @"Code");
    DICT_NSSTRING_KEY(dict, wp.wpt_description, @"Name");
    DICT_NSSTRING_KEY(dict, wp.wpt_url, @"Url");
    DICT_NSSTRING_KEY(dict, wp.wpt_urlname, @"Name");

    DICT_FLOAT_KEY(dict, wp.wpt_lat_float, @"Latitude");
    wp.wpt_lat_int = wp.wpt_lat_float * 1000000;
    wp.wpt_lat = [NSString stringWithFormat:@"%f", wp.wpt_lat_float];

    DICT_FLOAT_KEY(dict, wp.wpt_lon_float, @"Longitude");
    wp.wpt_lon_int = wp.wpt_lon_float * 1000000;
    wp.wpt_lon = [NSString stringWithFormat:@"%f", wp.wpt_lon_float];

    NSString *dummy;
    DICT_NSSTRING_PATH(dict, dummy, @"UTCPlaceDate");
    wp.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromWindows:dummy];
    wp.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:wp.wpt_date_placed_epoch];

    wp.wpt_symbol_str = @"Geocache";
    DICT_NSSTRING_PATH(dict, wp.wpt_type_str, @"CacheType.GeocacheTypeName");

    wp.account_id = account._id;

    // Groundspeak object
//  wp.gs_hasdata = YES;
    DICT_FLOAT_KEY(dict, wp.gs_rating_difficulty, @"Difficulty");
    DICT_FLOAT_KEY(dict, wp.gs_rating_terrain, @"Terrain");
    DICT_FLOAT_KEY(dict, wp.gs_favourites, @"FavoritePoints");
    DICT_BOOL_KEY(dict, wp.gs_archived, @"Archived");
    DICT_BOOL_KEY(dict, wp.gs_available, @"Available");

    DICT_NSSTRING_KEY(dict, wp.gs_country_str, @"Country");
    DICT_NSSTRING_KEY(dict, wp.gs_state_str, @"State");
    [dbCountry makeNameExist:wp.gs_country_str];
    [dbState makeNameExist:wp.gs_state_str];

    DICT_BOOL_KEY(dict, wp.gs_short_desc_html, @"ShortDescriptionIsHtml");
    DICT_BOOL_KEY(dict, wp.gs_long_desc_html, @"LongDescriptionIsHtml");
    DICT_NSSTRING_KEY(dict, wp.gs_short_desc, @"ShortDescription");
    DICT_NSSTRING_KEY(dict, wp.gs_long_desc, @"LongDescription");
    DICT_NSSTRING_KEY(dict, wp.gs_hint, @"EncodedHints");

    DICT_NSSTRING_KEY(dict, wp.gs_placed_by, @"PlacedBy");

    DICT_NSSTRING_PATH(dict, wp.gs_owner_gsid, @"Owner.Id");
    DICT_NSSTRING_PATH(dict, wp.gs_owner_gsid, @"Owner.Id");
    DICT_NSSTRING_PATH(dict, wp.gs_owner_str, @"Owner.UserName");
    if ([wp.gs_owner_str isEqualToString:@""] == NO)
        [dbName makeNameExist:wp.gs_owner_str code:wp.gs_owner_gsid account:account];

    DICT_NSSTRING_PATH(dict, wp.gs_container_str, @"ContainerType.ContainerTypeName");

    /* "FoundDate": "/Date(1439017200000-0700)/", */
    DICT_NSSTRING_KEY(dict, dummy, @"FoundDate");
    wp.gs_date_found = 0;
    if ([dummy isEqualToString:@""] == NO)
        wp.gs_date_found = [[dummy substringWithRange:NSMakeRange(6, 10)] integerValue];

    // Now see what we had and what we need to change
    [wp finish];
    wp.date_lastimport_epoch = time(NULL);

    if (wp._id == 0) {
        GCLog(@"Creating %@", wp.wpt_name);
        [dbWaypoint dbCreate:wp];
        newWaypointsCount++;
        [infoViewer setWaypointsNew:ivi new:newWaypointsCount];
    } else {
        GCLog(@"Updating %@", wp.wpt_name);
        dbWaypoint *wpold = [dbWaypoint dbGet:wp._id];
        wp._id = wpold._id;
        [wp dbUpdate];
    }
    if ([group dbContainsWaypoint:wp._id] == NO)
        [group dbAddWaypoint:wp._id];

    // Images
    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_long_desc type:IMAGECATEGORY_CACHE];
    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_short_desc type:IMAGECATEGORY_CACHE];

    NSString *personal_note;
    DICT_NSSTRING_KEY(dict, personal_note, @"GeocacheNote");
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:wp.wpt_name];
    if (pn != nil) {
        if (personal_note == nil || [personal_note isEqualToString:@""] == YES) {
            [pn dbDelete];
            pn = nil;
        } else {
            pn.note = personal_note;
            [pn dbUpdate];
        }
    } else {
        if (personal_note != nil && [personal_note isEqualToString:@""] == NO) {
            pn = [[dbPersonalNote alloc] init];
            pn.wp_name = wp.wpt_name;
            pn.note = personal_note;
            [pn dbCreate];
        }
    }

    [self parseLogs:[dict objectForKey:@"GeocacheLogs"] waypoint:wp];
    [self parseAttributes:[dict objectForKey:@"Attributes"] waypoint:wp];
    [self parseAdditionalWaypoints:[dict objectForKey:@"AdditionalWaypoints"] waypoint:wp];
    [self parseTrackables:[dict objectForKey:@"Trackables"] waypoint:wp];
    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGECATEGORY_CACHE];
}

- (void)parseTrackables:(NSArray *)trackables waypoint:(dbWaypoint *)wp
{
    if (wp != nil)
        [dbTrackable dbUnlinkAllFromWaypoint:wp._id];
    [trackables enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseTrackable:d waypoint:wp];
        totalTrackablesCount++;
        [infoViewer setTrackablesTotal:ivi total:totalTrackablesCount];
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
    DICT_NSSTRING_KEY(dict, tb.name, @"Name");
    DICT_INTEGER_KEY(dict, tb.gc_id, @"Id");
    DICT_NSSTRING_KEY(dict, tb.ref, @"Code");
    DICT_NSSTRING_KEY(dict, tb.waypoint_name, @"CurrentGeocacheCode");
    DICT_NSSTRING_PATH(dict, tb.owner_str, @"OriginalOwner.UserName");
    DICT_NSSTRING_PATH(dict, tb.carrier_str, @"CurrentOwner.UserName");
    DICT_NSSTRING_KEY(dict, tb.code, @"TrackingCode");

    NSString *owner_id, *carrier_id;
    DICT_NSSTRING_PATH(dict, carrier_id, @"CurrentOwner.Id");
    DICT_NSSTRING_PATH(dict, owner_id, @"OriginalOwner.Id");

    if ([tb.owner_str isEqualToString:@""] == NO)
        [dbName makeNameExist:tb.owner_str code:owner_id account:account];
    else
        tb.owner_str = nil;
    if ([tb.carrier_str isEqualToString:@""] == NO)
        [dbName makeNameExist:tb.carrier_str code:carrier_id account:account];
    else
        tb.carrier_str = nil;

    [tb finish:account];

    NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
    if (_id == 0) {
        [dbTrackable dbCreate:tb];
        newTrackablesCount++;
        [infoViewer setTrackablesNew:ivi new:newTrackablesCount];
    } else {
        // The code isn't always updated while we do have it.
        // In that case save it from the previous one.
        if ([tb.code isEqualToString:@""] == YES) {
            dbTrackable *prevtb = [dbTrackable dbGet:_id];
            tb.code = prevtb.code;
        }
        tb._id = _id;
        [tb dbUpdate];
    }

    if (wp != nil)
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

    NSString *url;
    NSString *name;
    DICT_NSSTRING_KEY(dict, url, @"Url");
    DICT_NSSTRING_KEY(dict, name, @"Name");
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
    NSInteger gc_id;
    DICT_INTEGER_KEY(dict, gc_id, @"AttributeTypeID");
    dbAttribute *a = [dbc Attribute_get_bygcid:gc_id];
    BOOL yesNo;
    DICT_BOOL_KEY(dict, yesNo, @"IsOn");
    [a dbLinkToWaypoint:wp._id YesNo:yesNo];
}

- (void)parseAdditionalWaypoints:(NSArray *)wps waypoint:(dbWaypoint *)wp
{
    [wps enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseAdditionalWaypoint:d waypoint:wp];
        totalWaypointsCount++;
        [infoViewer setWaypointsTotal:ivi total:totalWaypointsCount];
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
    DICT_NSSTRING_KEY(dict, awp.wpt_name, @"Code");
    DICT_NSSTRING_KEY(dict, awp.wpt_description, @"Description");
    DICT_NSSTRING_KEY(dict, awp.wpt_url, @"Url");
    DICT_NSSTRING_KEY(dict, awp.wpt_urlname, @"UrlName");

    if ([[dict objectForKey:@"Latitude"] isKindOfClass:[NSNumber class]] == NO) {
        awp.wpt_lat_float = 0;
        awp.wpt_lat_int = 0;
        awp.wpt_lat = @"0";
    } else {
        DICT_FLOAT_KEY(dict, awp.wpt_lat_float, @"Latitude");
        awp.wpt_lat_int = awp.wpt_lat_float * 1000000;
        awp.wpt_lat = [NSString stringWithFormat:@"%f", awp.wpt_lat_float];
    }

    if ([[dict objectForKey:@"Longitude"] isKindOfClass:[NSNumber class]] == NO) {
        awp.wpt_lon_float = 0;
        awp.wpt_lon_int = 0;
        awp.wpt_lon = @"0";
    } else {
        DICT_FLOAT_KEY(dict, awp.wpt_lon_float, @"Longitude");
        awp.wpt_lon_int = awp.wpt_lon_float * 1000000;
        awp.wpt_lon = [NSString stringWithFormat:@"%f", awp.wpt_lon_float];
    }

    NSString *dummy;
    DICT_NSSTRING_KEY(dict, dummy, @"UTCEnteredDate");
    awp.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromWindows:dummy];
    awp.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:awp.wpt_date_placed_epoch];

    DICT_NSSTRING_KEY(dict, awp.wpt_symbol_str, @"Name");
    DICT_NSSTRING_KEY(dict, awp.wpt_type_str, @"Type");

    awp.account_id = account._id;
    awp.related_id = wp._id;
    [awp finish];

    NSId wpid = [dbWaypoint dbGetByName:awp.wpt_name];
    if (wpid == 0) {
        [dbWaypoint dbCreate:awp];
        [group dbAddWaypoint:awp._id];
        newWaypointsCount++;
        [infoViewer setWaypointsNew:ivi new:newWaypointsCount];
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
        totalLogsCount++;
        [infoViewer setLogsTotal:ivi total:totalLogsCount];
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
    DICT_INTEGER_KEY(dict, l.gc_id, @"ID");
    NSString *dummy;
    DICT_NSSTRING_KEY(dict, dummy, @"UTCCreateDate");
    l.datetime_epoch = [MyTools secondsSinceEpochFromWindows:dummy];
    l.datetime = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:l.datetime_epoch];
    l.needstobelogged = NO;
    DICT_NSSTRING_KEY(dict, l.log, @"LogText");
    DICT_NSSTRING_PATH(dict, l.logstring_string, @"LogType.WptLogTypeName");

    [ImagesDownloadManager findImagesInDescription:wp._id text:l.log type:IMAGECATEGORY_LOG];

    dbName *name = [[dbName alloc] init];
    DICT_NSSTRING_PATH(dict, name.name, @"Finder.UserName");
    name.account_id = wp.account_id;
    name.account = wp.account;
    DICT_NSSTRING_PATH(dict, name.code, @"Finder.Id");
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
        newLogsCount++;
        [infoViewer setLogsNew:ivi new:newLogsCount];
    }

    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGECATEGORY_LOG];
}

@end
