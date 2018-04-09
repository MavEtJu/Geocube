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

@interface ImportLiveAPIJSON ()

@end

@implementation ImportLiveAPIJSON

- (void)parseBefore_geocaches
{
}

- (void)parseAfter_geocaches
{
}

- (void)parseBefore_trackables
{
}
- (void)parseAfter_trackables
{
}

- (void)parseDictionary:(NSDictionary *)dict infoItem:(InfoItem *)iii
{
    GCLog(@"Parsing data");

    self.iiImport = iii;

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

- (void)parseGeocaches:(NSArray<NSDictionary *> *)geocaches
{
    if ([geocaches isKindOfClass:[NSNull class]] == YES)
        return;
    [self.iiImport changeLineObjectTotal:[geocaches count] isLines:NO];
    [geocaches enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseGeocache:d];
        self.totalWaypointsCount++;

        [self.iiImport changeLineObjectCount:idx];
        [self.iiImport changeWaypointsTotal:self.totalWaypointsCount];
    }];
    [self.iiImport changeLineObjectCount:[geocaches count]];
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
         "UserWaypoints": [
             {
                 "AssociatedAdditionalWaypoint": null,
                 "CacheCode": "GC24P7X",
                 "Description": null,
                 "ID": 27115469,
                 "IsCorrectedCoordinate": true,
                 "IsUserCompleted": false,
                 "Latitude": -12.576116666666667,
                 "Longitude": 12.576116666666667,
                 "UTCDate": "/Date(1497591719360-0700)/",
                 "UserID": 8305738
             }
         ]

     }
     */

    NSString *wpt_name = nil;
    DICT_NSSTRING_KEY(dict, wpt_name, @"Code");

    dbWaypoint *wp = [dbWaypoint dbGetByName:wpt_name];
    if (wp == nil)
        wp = [[dbWaypoint alloc] init];

    // Waypoint object
    DICT_NSSTRING_KEY(dict, wp.wpt_name, @"Code");
    DICT_NSSTRING_KEY(dict, wp.wpt_description, @"Name");
    DICT_NSSTRING_KEY(dict, wp.wpt_url, @"Url");
    DICT_NSSTRING_KEY(dict, wp.wpt_urlname, @"Name");

    DICT_FLOAT_KEY(dict, wp.wpt_latitude, @"Latitude");
    DICT_FLOAT_KEY(dict, wp.wpt_longitude, @"Longitude");

    NSString *dummy;
    DICT_NSSTRING_PATH(dict, dummy, @"UTCPlaceDate");
    wp.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromWindows:dummy];

    DICT_NSSTRING_PATH(dict, dummy, @"CacheType.GeocacheTypeName");
    [wp set_wpt_type_str:dummy];
    [wp set_wpt_symbol_str:@"Geocache"];

    wp.account = self.account;

    // Groundspeak object
    DICT_FLOAT_KEY(dict, wp.gs_rating_difficulty, @"Difficulty");
    DICT_FLOAT_KEY(dict, wp.gs_rating_terrain, @"Terrain");
    DICT_FLOAT_KEY(dict, wp.gs_favourites, @"FavoritePoints");
    DICT_BOOL_KEY(dict, wp.gs_archived, @"Archived");
    DICT_BOOL_KEY(dict, wp.gs_available, @"Available");

    DICT_NSSTRING_KEY(dict, dummy, @"Country");
    [dbCountry makeNameExist:dummy];
    [wp set_gs_country_str:dummy];
    DICT_NSSTRING_KEY(dict, dummy, @"State");
    [dbState makeNameExist:dummy];
    [wp set_gs_state_str:dummy];

    DICT_BOOL_KEY(dict, wp.gs_short_desc_html, @"ShortDescriptionIsHtml");
    DICT_BOOL_KEY(dict, wp.gs_long_desc_html, @"LongDescriptionIsHtml");
    DICT_NSSTRING_KEY(dict, wp.gs_short_desc, @"ShortDescription");
    DICT_NSSTRING_KEY(dict, wp.gs_long_desc, @"LongDescription");
    DICT_NSSTRING_KEY(dict, wp.gs_hint, @"EncodedHints");

    DICT_NSSTRING_KEY(dict, wp.gs_placed_by, @"PlacedBy");

    DICT_NSSTRING_PATH(dict, wp.gs_owner_gsid, @"Owner.Id");
    DICT_NSSTRING_PATH(dict, dummy, @"Owner.UserName");
    if (IS_EMPTY(dummy) == NO)
        [dbName makeNameExist:dummy code:wp.gs_owner_gsid account:self.account];
    [wp set_gs_owner_str:dummy];

    DICT_NSSTRING_PATH(dict, dummy, @"ContainerType.ContainerTypeName");
    [wp set_gs_container_str:dummy];

    /* "FoundDate": "/Date(1439017200000-0700)/", */
    DICT_NSSTRING_KEY(dict, dummy, @"FoundDate");
    wp.gs_date_found = 0;
    if (IS_EMPTY(dummy) == NO)
        wp.gs_date_found = [[dummy substringWithRange:NSMakeRange(6, 10)] integerValue];

    // Now see what we had and what we need to change
    [wp finish];
    wp.date_lastimport_epoch = time(NULL);
    wp.dirty_logs = YES;

    if (wp._id == 0) {
        GCLog(@"Creating %@", wp.wpt_name);
        [wp dbCreate];
        self.newWaypointsCount++;
        [self.iiImport changeWaypointsNew:self.newWaypointsCount];
    } else {
        GCLog(@"Updating %@", wp.wpt_name);
        dbWaypoint *wpold = [dbWaypoint dbGet:wp._id];
        wp._id = wpold._id;
        if ([self.group containsWaypoint:wp] == NO)
            [self.group addWaypointToGroup:wp];
        [wp dbUpdate];
    }
    if ([self.group containsWaypoint:wp] == NO)
        [self.group addWaypointToGroup:wp];

    [opencageManager addForProcessing:wp];

    // Images
    [ImagesDownloadManager findImagesInDescription:wp text:wp.gs_long_desc type:IMAGECATEGORY_CACHE];
    [ImagesDownloadManager findImagesInDescription:wp text:wp.gs_short_desc type:IMAGECATEGORY_CACHE];

    NSString *personal_note;
    DICT_NSSTRING_KEY(dict, personal_note, @"GeocacheNote");
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:wp.wpt_name];
    if (pn != nil) {
        if (IS_EMPTY(personal_note) == YES) {
            [pn dbDelete];
            pn = nil;
        } else {
            pn.note = personal_note;
            [pn dbUpdate];
        }
    } else {
        if (IS_EMPTY(personal_note) == NO) {
            pn = [[dbPersonalNote alloc] init];
            pn.wp_name = wp.wpt_name;
            pn.note = personal_note;
            [pn dbCreate];
        }
    }

    [self.delegate Import_WaypointProcessed:wp];

    [self parseLogs:[dict objectForKey:@"GeocacheLogs"] waypoint:wp];
    [self parseAttributes:[dict objectForKey:@"Attributes"] waypoint:wp];
    [self parseUserWaypoints:[dict objectForKey:@"UserWaypoints"] waypoint:wp];
    [self parseAdditionalWaypoints:[dict objectForKey:@"AdditionalWaypoints"] waypoint:wp];
    [self parseTrackables:[dict objectForKey:@"Trackables"] waypoint:wp];
    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGECATEGORY_CACHE];
}

- (void)parseTrackables:(NSArray<NSDictionary *> *)trackables waypoint:(dbWaypoint *)wp
{
    if ([trackables isKindOfClass:[NSNull class]] == YES)
        return;
    if (wp != nil)
        [dbTrackable dbUnlinkAllFromWaypoint:wp];
    [trackables enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseTrackable:d waypoint:wp];
        self.totalTrackablesCount++;
        [self.iiImport changeTrackablesTotal:self.totalTrackablesCount];
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

    NSString *dummy;

    dbTrackable *tb = [[dbTrackable alloc] init];
    DICT_NSSTRING_KEY(dict, tb.name, @"Name");
    DICT_INTEGER_KEY(dict, tb.gc_id, @"Id");
    DICT_NSSTRING_KEY(dict, tb.tbcode, @"Code");
    DICT_NSSTRING_KEY(dict, tb.waypoint_name, @"CurrentGeocacheCode");
    DICT_NSSTRING_PATH(dict, dummy, @"OriginalOwner.UserName");
    [dbName makeNameExist:dummy code:0 account:self.account];
    [tb set_owner_str:dummy account:self.account];
    DICT_NSSTRING_PATH(dict, dummy, @"CurrentOwner.UserName");
    [dbName makeNameExist:dummy code:0 account:self.account];
    [tb set_carrier_str:dummy account:self.account];
    DICT_NSSTRING_KEY(dict, tb.pin, @"TrackingCode");

    [tb finish];

    NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
    if (_id == 0) {
        [tb dbCreate];
        self.newTrackablesCount++;
        [self.iiImport changeTrackablesNew:self.newTrackablesCount];
    } else {
        // The code isn't always updated while we do have it.
        // In that case save it from the previous one.
        if (IS_EMPTY(tb.pin) == YES) {
            dbTrackable *prevtb = [dbTrackable dbGet:_id];
            tb.pin = prevtb.pin;
        }
        tb._id = _id;
        [tb dbUpdate];
    }

    if (wp != nil)
        [tb dbLinkToWaypoint:wp];
}

- (void)parseImages:(NSArray<NSDictionary *> *)images waypoint:(dbWaypoint *)wp imageSource:(ImageCategory)imageSource
{
    if ([images isKindOfClass:[NSNull class]] == YES)
        return;
    [images enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseImage:d waypoint:wp imageSource:imageSource];
    }];
}

- (void)parseImage:(NSDictionary *)dict waypoint:(dbWaypoint *)wp imageSource:(ImageCategory)imageSource
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
        img = [[dbImage alloc] init];
        img.url = url;
        img.name = name;
        img.datafile = df;
        [img dbCreate];
    }

    [ImagesDownloadManager addToQueue:img imageType:imageSource];

    if ([img dbLinkedtoWaypoint:wp] == NO)
        [img dbLinkToWaypoint:wp type:imageSource];
}

- (void)parseAttributes:(NSArray<NSDictionary *> *)attributes waypoint:(dbWaypoint *)wp
{
    if ([attributes isKindOfClass:[NSNull class]] == YES)
        return;
    [dbAttribute dbUnlinkAllFromWaypoint:wp];
    [attributes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
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
    dbAttribute *a = [dbc attributeGetByGCId:gc_id];
    BOOL yesNo;
    DICT_BOOL_KEY(dict, yesNo, @"IsOn");
    [a dbLinkToWaypoint:wp YesNo:yesNo];
}

- (void)parseUserWaypoints:(NSArray<NSDictionary *> *)wps waypoint:(dbWaypoint *)wp
{
    if ([wps isKindOfClass:[NSNull class]] == YES)
        return;
    [wps enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseUserWaypoint:d waypoint:wp];
        self.totalWaypointsCount++;
        [self.iiImport changeWaypointsTotal:self.totalWaypointsCount];
    }];
}

- (void)parseUserWaypoint:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
         "AssociatedAdditionalWaypoint": null,
         "CacheCode": "GC24P7X",
         "Description": null,
         "ID": 27115469,
         "IsCorrectedCoordinate": true,
         "IsUserCompleted": false,
         "Latitude": -12.576116666666667,
         "Longitude": 12.576116666666667,
         "UTCDate": "/Date(1497591719360-0700)/",
         "UserID": 8305738
     }
    */

    dbWaypoint *awp = [[dbWaypoint alloc] init];

    // Waypoint object
    awp.wpt_name = [NSString stringWithFormat:@"CC%@", [wp.wpt_name substringFromIndex:2]];
    awp.wpt_description = [NSString stringWithFormat:@"Correct Coordinates for %@", wp.wpt_name];
    awp.wpt_urlname = [NSString stringWithFormat:@"%@ Correct Coordinates", wp.wpt_name];

    awp.wpt_latitude = 0;
    if ([[dict objectForKey:@"Latitude"] isKindOfClass:[NSNumber class]] == YES)
        DICT_FLOAT_KEY(dict, awp.wpt_latitude, @"Latitude");

    awp.wpt_longitude = 0;
    if ([[dict objectForKey:@"Longitude"] isKindOfClass:[NSNumber class]] == YES)
        DICT_FLOAT_KEY(dict, awp.wpt_longitude, @"Longitude");

    NSString *dummy;
    DICT_NSSTRING_KEY(dict, dummy, @"UTCDate");
    awp.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromWindows:dummy];

    awp.wpt_type = dbc.typeManuallyEntered;
    awp.wpt_symbol = dbc.symbolVirtualStage;

    awp.account = self.account;
    awp.date_lastimport_epoch = time(NULL);

    [awp finish];
    awp.dirty_logs = YES;

    dbWaypoint *wpold = [dbWaypoint dbGetByName:awp.wpt_name];
    if (wpold == nil) {
        [awp dbCreate];
        [self.group addWaypointToGroup:awp];
        self.newWaypointsCount++;
        [self.iiImport changeWaypointsNew:self.newWaypointsCount];
    } else {
        awp._id = wpold._id;
        [awp dbUpdate];
    }

    [self.delegate Import_WaypointProcessed:awp];
}

- (void)parseAdditionalWaypoints:(NSArray<NSDictionary *> *)wps waypoint:(dbWaypoint *)wp
{
    if ([wps isKindOfClass:[NSNull class]] == YES)
        return;
    [wps enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseAdditionalWaypoint:d waypoint:wp];
        self.totalWaypointsCount++;
        [self.iiImport changeWaypointsTotal:self.totalWaypointsCount];
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

     or

     {
         "Code": "P0",
         "Comment": "Balls Head Reserve Parking",
         "Description": null,
         "GUID": "6fbe1058-fb8c-41bb-b5dc-f1198e6f768e",
         "GeocacheCode": "GC768WB",
         "Latitude": -33.846833333333336,
         "Longitude": 151.19598333333334,
         "Name": "Parking Area",
         "Type": "Waypoint|Parking Area",
         "UTCEnteredDate": "/Date(1495859206590-0700)/",
         "Url": "http://www.geocaching.com/seek/wpt.aspx?WID=6fbe1058-fb8c-41bb-b5dc-f1198e6f768e",
         "UrlName": "Balls Head Reserve Parking",
         "WptTypeID": 0
     },

    */

    dbWaypoint *awp = [[dbWaypoint alloc] init];

    // Waypoint object
    DICT_NSSTRING_KEY(dict, awp.wpt_name, @"Code");
    DICT_NSSTRING_KEY(dict, awp.wpt_description, @"Description");
    DICT_NSSTRING_KEY(dict, awp.wpt_url, @"Url");
    DICT_NSSTRING_KEY(dict, awp.wpt_urlname, @"UrlName");

    if ([awp.wpt_name length] == 2) {
        NSString *s;
        DICT_NSSTRING_KEY(dict, s, @"GeocacheCode");
        awp.wpt_name = [NSString stringWithFormat:@"%@%@", awp.wpt_name, [s substringFromIndex:2]];
    }

    if ([[dict objectForKey:@"Latitude"] isKindOfClass:[NSNumber class]] == YES)
        DICT_FLOAT_KEY(dict, awp.wpt_latitude, @"Latitude");
    if ([[dict objectForKey:@"Longitude"] isKindOfClass:[NSNumber class]] == YES)
        DICT_FLOAT_KEY(dict, awp.wpt_longitude, @"Longitude");

    NSString *dummy;
    DICT_NSSTRING_KEY(dict, dummy, @"UTCEnteredDate");
    awp.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromWindows:dummy];

    DICT_NSSTRING_KEY(dict, dummy, @"Name");
    [awp set_wpt_symbol_str:dummy];
    DICT_NSSTRING_KEY(dict, dummy, @"Type");
    [awp set_wpt_type_str:dummy];

    awp.account = self.account;
    [awp finish];
    awp.dirty_logs = YES;

    dbWaypoint *wpold = [dbWaypoint dbGetByName:awp.wpt_name];
    if (wpold == nil) {
        [awp dbCreate];
        [self.group addWaypointToGroup:awp];
        self.newWaypointsCount++;
        [self.iiImport changeWaypointsNew:self.newWaypointsCount];
    } else {
        awp._id = wpold._id;
        if ([self.group containsWaypoint:awp] == NO)
            [self.group addWaypointToGroup:awp];
        [awp dbUpdate];
    }
    [opencageManager addForProcessing:awp];

    [self.delegate Import_WaypointProcessed:awp];
}

- (void)parseLogs:(NSArray<NSDictionary *> *)logs waypoint:(dbWaypoint *)wp
{
    if ([logs isKindOfClass:[NSNull class]] == YES)
        return;
    [logs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseLog:d waypoint:wp];
        self.totalLogsCount++;
        [self.iiImport changeLogsTotal:self.totalLogsCount];
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

    NSString *dummy;

    dbLog *l = [[dbLog alloc] init];
    l.waypoint = wp;
    DICT_INTEGER_KEY(dict, l.gc_id, @"ID");
    DICT_NSSTRING_KEY(dict, dummy, @"UTCCreateDate");
    l.datetime_epoch = [MyTools secondsSinceEpochFromWindows:dummy];
    l.needstobelogged = NO;
    DICT_NSSTRING_KEY(dict, l.log, @"LogText");
    DICT_NSSTRING_PATH(dict, dummy, @"LogType.WptLogTypeName");
    l.logstring = [dbc logStringGetByDisplayString:self.account displayString:dummy];

    [ImagesDownloadManager findImagesInDescription:wp text:l.log type:IMAGECATEGORY_LOG];

    dbName *name = [[dbName alloc] init];
    DICT_NSSTRING_PATH(dict, name.name, @"Finder.UserName");
    name.account = wp.account;
    DICT_NSSTRING_PATH(dict, name.code, @"Finder.Id");
    [name finish];
    dbName *n = [dbName dbGetByNameCode:name.name code:name.code account:wp.account];
    if (n != nil) {
        name = n;
    } else {
        [name dbCreate];
    }
    l.logger = name;
    [l finish];

    dbWaypoint *ll = [dbLog dbGetIdByGC:l.gc_id account:wp.account];
    if (ll == nil) {
        [l dbCreate];
        self.newLogsCount++;
        [self.iiImport changeLogsNew:self.newLogsCount];
    }

    [self parseImages:[dict objectForKey:@"Images"] waypoint:wp imageSource:IMAGECATEGORY_LOG];
}

@end
