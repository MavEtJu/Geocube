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

@interface ImportGCA2JSON ()

@end

@implementation ImportGCA2JSON

- (void)parseDictionary:(GCDictionaryGCA2 *)dict infoItemImport:(InfoItemImport *)iii
{
    infoItemImport = iii;
    if ([dict objectForKey:@"waypoints"] != nil) {
        [self parseBefore_waypoints];
        [self parseData_waypoints:[dict objectForKey:@"waypoints"]];
        [self parseAfter_waypoints];
    }
}

- (void)parseBefore_waypoints
{
    NSLog(@"%@/parseBefore_caches: Parsing initializing", [self class]);
}

- (void)parseAfter_waypoints
{
    NSLog(@"%@/parseAfter_waypoints: Parsing done", [self class]);
}

- (void)parseData_waypoints:(NSArray *)waypoints
{
    [infoItemImport setLineObjectTotal:[waypoints count] isLines:NO];
    [waypoints enumerateObjectsUsingBlock:^(NSDictionary *waypoint, NSUInteger idx, BOOL *stop) {
        [self parseData_waypoint:(NSDictionary *)waypoint];
        ++totalWaypointsCount;
        [infoItemImport setWaypointsTotal:totalWaypointsCount];
        [infoItemImport setLineObjectCount:idx + 1];
    }];
}

- (void)parseData_waypoint:(NSDictionary *)dict
{
/*
 {
     "alt_wpts" =     (
     );
     "attr_acodes" =     (
     );
     "attribution_note" = "Geocache information licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 2.5 deed.";
     attrnames =     (
     );
     bearing = "102.7";
     bearing2 = E;
     bearing3 = "n/a";
     code = GA8354;
     country = Australia;
     "date_created" = "2016-08-12T14:00:00+1000";
     "date_hidden" = "2016-08-12T14:00:00+1000";
     description = "<p>This cache is located on the grounds of the Glenn McGrath Oval, formerly known as the Caringbah Oval. It hosts both the Sutherlan>
         \n";
     descriptions =     {
         en = "<p>This cache is located on the grounds of the Glenn McGrath Oval, formerly known as the Caringbah Oval. It hosts both the Sutherland District Cricket Club and the Lilli Pilli Football Club.</p>
             \n";
     };
     difficulty = "1.5";
     distance = "15196.3360195";
     founds = 2;
     "gc_code" = "<null>";
     hint2 = "Same colour as the water pipe.";
     hints2 =     {
         en = "Same colour as the water pipe.";
     };
     images =     (
     );
     "internal_id" = ga8354;
     "is_found" = 0;
     "is_ignored" = 0;
     "is_not_found" = 0;
     "is_watched" = 0;
     "last_found" = "2016-10-22T13:00:00+1100";
     "last_modified" = "2016-08-13T06:54:59+1000";
     "latest_logs" =     (
         {
             comment = "Find #45 - 2 for today. Found on 23/10/2016 01:01pm<br />
                 \nThought I may not find it as there was a cricket match in progress, but the location of the cache was away from muggles.  A quick find, sign and put back.  TNSLLN.  Thanks for the cache.";
             date = "2016-10-22T13:00:00+1100";
             type = "Found it";
             user =             {
                 "profile_url" = "http://geocaching.com.au/cacher/redbackspider";
                 username = redbackspider;
                 uuid = redbackspider;
             };
             uuid = 14525342;
         },
         {
             comment = "FTF!  <img src=\"http://geocaching.com.au/pics/smilies/icon_biggrin.gif\" alt=\"Very Happy\" title=\"Very Happy\" /> <br />
                 \nA nice &amp; easy find this afternoon after finding the nearby GC cache, and 50 points towards the GeosportZ challenge! Thankfully the place was nice and quiet making it an easy search. TFTC!<br />
                 \nCheers,<br />
                 \nThe Hancock Clan";
             date = "2016-08-13T14:00:00+1000";
             type = "Found it";
             user =             {
                 "profile_url" = "http://geocaching.com.au/cacher/The+Hancock+Clan";
                 username = "The Hancock Clan";
                 uuid = "The Hancock Clan";
             };
             uuid = 14150145;
         },
         {
             comment = "Published!";
             date = "2016-08-12T14:00:00+1000";
             type = "Publish Listing";
             user =             {
                 "profile_url" = "http://geocaching.com.au/cacher/Team+MavEtJu";
                 username = "Team MavEtJu";
                 uuid = "Team MavEtJu";
             };
             uuid = 14150006;
         }
     );
     location = "-34.045367|151.119567";
     "my_notes" = "<null>";
     name = "Lynvale house, Caringbah";
     names =     {
         en = "Lynvale house, Caringbah";
     };
     notfounds = 0;
     owner =     {
         "profile_url" = "http://geocaching.com.au/cacher/Team+MavEtJu";
         username = "Team MavEtJu";
         uuid = "Team MavEtJu";
     };
     oxsize = "<null>";
     "preview_image" = "<null>";
     "protection_areas" =     (
     );
     qanda =     (
     );
     rating = "<null>";
     "rating_votes" = 0;
     recommendations = 0;
     "req_passwd" = 0;
     "short_description" = "Lynvale house, Caringbah";
     "short_descriptions" =     {
     en = "Lynvale house, Caringbah";
     };
     size2 = Micro;
     state = "New South Wales";
     status = Available;
     terrain = "1.5";
     trackables =     (
     );
     "trackables_count" = 0;
     "trip_distance" = "<null>";
     "trip_time" = "<null>";
     type = Traditional;
     url = "http://geocaching.com.au/cache/ga8354";
     willattends = 0;
 }

 */

    NSString *wpt_name;
    DICT_NSSTRING_KEY(dict, wpt_name, @"code");
    if (wpt_name == nil || [wpt_name isEqualToString:@""] == YES)
        return;

    NSId wpid = [dbWaypoint dbGetByName:wpt_name];
    dbWaypoint *wp;
    if (wpid == 0)
        wp = [[dbWaypoint alloc] init];
    else
        wp = [dbWaypoint dbGet:wpid];
    wp.wpt_name = wpt_name;

    DICT_NSSTRING_KEY(dict, wp.gs_state_str, @"state");
    [dbState makeNameExist:wp.gs_state_str];
    wp.gs_state_id = 0;
    wp.gs_state = nil;
    DICT_NSSTRING_KEY(dict, wp.gs_country_str, @"country");
    [dbCountry makeNameExist:wp.gs_country_str];
    wp.gs_country_id = 0;
    wp.gs_country = nil;
    DICT_NSSTRING_KEY(dict, wp.gca_locale_str, @"locale");
    [dbLocale makeNameExist:wp.gca_locale_str];
    wp.gca_locale_id = 0;
    wp.gca_locale = nil;
    DICT_NSSTRING_KEY(dict, wp.gs_long_desc, @"description");
    wp.gs_long_desc_html = YES;
    DICT_NSSTRING_KEY(dict, wp.wpt_date_placed, @"date_hidden");
    DICT_FLOAT_KEY(dict, wp.gs_rating_difficulty, @"difficulty");
    DICT_FLOAT_KEY(dict, wp.gs_rating_terrain, @"terrain");
    DICT_NSSTRING_KEY(dict, wp.gs_hint, @"hint2");
    DICT_NSSTRING_KEY(dict, wp.wpt_urlname, @"name");
    DICT_NSSTRING_PATH(dict, wp.gs_owner_str, @"owner.username");
    DICT_NSSTRING_PATH(dict, wp.gs_owner_gsid, @"owner.uuid");
    [dbName makeNameExist:wp.gs_owner_str code:wp.gs_owner_gsid account:account];
    DICT_INTEGER_KEY(dict, wp.gs_favourites, @"recommendations");
    DICT_NSSTRING_KEY(dict, wp.gs_short_desc, @"short_description");
    wp.gs_short_desc_html = YES;

    NSString *status;
    DICT_NSSTRING_KEY(dict, status, @"status");
    wp.gs_archived = NO;
    wp.gs_available = YES;
    if ([status isEqualToString:@"Available"] == YES) {
        wp.gs_archived = NO;
        wp.gs_available = YES;
    } else if ([status isEqualToString:@"Archived"] == YES) {
        wp.gs_archived = YES;
        wp.gs_available = NO;
    } else if ([status isEqualToString:@"Temporarily unavailable"] == YES) {
        wp.gs_archived = NO;
        wp.gs_available = NO;
    }

    DICT_NSSTRING_KEY(dict, wp.gs_container_str, @"size2");
    wp.gs_container_id = 0;
    wp.gs_container = nil;
    DICT_NSSTRING_KEY(dict, wp.wpt_type_str, @"type");
    wp.wpt_type_id = 0;
    wp.wpt_type = nil;
    DICT_NSSTRING_KEY(dict, wp.wpt_url, @"url");

    NSString *location;
    DICT_NSSTRING_KEY(dict, location, @"location");
    NSArray *cs = [location componentsSeparatedByString:@"|"];
    wp.wpt_lat = [cs objectAtIndex:0];
    wp.wpt_lon = [cs objectAtIndex:1];

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

    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_long_desc type:IMAGECATEGORY_CACHE];
    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_short_desc type:IMAGECATEGORY_CACHE];

    NSArray *images = [dict objectForKey:@"images"];
    if ([images count] != 0)
        [self parseData_images:images waypoint:wp];

    NSArray *trackables = [dict objectForKey:@"trackables"];
    if ([trackables count] != 0)
        [self parseData_trackables:trackables waypoint:wp];

    NSArray *logs = [dict objectForKey:@"latest_logs"];
    if ([logs count] != 0)
        [self parseData_logs:logs waypoint:wp];
}

- (void)parseData_images:(NSArray *)images waypoint:(dbWaypoint *)wp
{
    NSLog(@"Image number 0-%lu", (unsigned long)([images count] - 1));
    [images enumerateObjectsUsingBlock:^(NSDictionary *image, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Image number %ld", (unsigned long)idx);
        [self parseData_image:image waypoint:wp];
    }];
}

- (void)parseData_image:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    /*
     {
     caption = vierhoek;
     "is_spoiler" = 1;
     "thumb_url" = "http://www.opencaching.nl/thumbs.php?uuid=45AB31E2-D287-11E0-8A21-005056000020";
     "unique_caption" = 1;
     url = "http://www.opencaching.nl/images/uploads/45AB31E2-D287-11E0-8A21-005056000020.jpg";
     uuid = "45AB31E2-D287-11E0-8A21-005056000020";
     }
     */

    dbImage *image;

    NSString *url;
    NSString *desc;
    DICT_NSSTRING_KEY(dict, url, @"url");
    DICT_NSSTRING_KEY(dict, desc, @"caption");
    NSString *df = [dbImage createDataFilename:url];
    NSLog(@"Image: %@ - %@", desc, df);

    image = [dbImage dbGetByURL:url];
    if (image == nil) {
        image = [[dbImage alloc] init:url name:desc datafile:df];
        [dbImage dbCreate:image];
    }

    if ([image dbLinkedtoWaypoint:wp._id] == NO)
        [image dbLinkToWaypoint:wp._id type:IMAGECATEGORY_CACHE];

    [ImagesDownloadManager addToQueue:image];
}

- (void)parseData_logs:(NSArray *)logs waypoint:(dbWaypoint *)wp
{
    NSArray *alllogs = [dbLog dbAllByWaypoint:wp._id];
    [infoItemImport setLogsTotal:[alllogs count]];
    [logs enumerateObjectsUsingBlock:^(NSDictionary *log, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseData_log:log waypoint:wp logs:alllogs];
        totalLogsCount++;
        [infoItemImport setLogsTotal:totalLogsCount];
    }];
}

- (void)parseData_log:(NSDictionary *)dict waypoint:(dbWaypoint *)wp logs:(NSArray *)logs
{
/*
 {
     comment = "Find #45 - 2 for today. Found on 23/10/2016 01:01pm<br />
        \nThought I may not find it as there was a cricket match in progress, but the location of the cache was away from muggles.  A quick find, sign and put back.  TNSLLN.  Thanks for the cache.";
     date = "2016-10-22T13:00:00+1100";
     type = "Found it";
     user =     {
         "profile_url" = "http://geocaching.com.au/cacher/redbackspider";
         username = redbackspider;
         uuid = redbackspider;
     };
     uuid = 14525342;
 }
     */

    NSString *type;
    NSString *date;
    NSInteger dateSinceEpoch;
    NSString *loggername;
    NSString *loggerid;
    NSString *comment;
    dbName *name;
    DICT_NSSTRING_KEY(dict, type, @"type");
    dbLogString *logstring = [dbc LogString_get_bytype:wp.account logtype:wp.logstring_logtype type:type];
    DICT_NSSTRING_KEY(dict, date, @"date");
    dateSinceEpoch = [MyTools secondsSinceEpochFromISO8601:date];
    DICT_NSSTRING_PATH(dict, loggername, @"user.username");
    DICT_NSSTRING_PATH(dict, loggerid, @"user.uuid");
    DICT_NSSTRING_PATH(dict, comment, @"comment");
    [dbName makeNameExist:loggername code:loggerid account:account];

    name = [dbName dbGetByName:loggername account:account];

    [ImagesDownloadManager findImagesInDescription:wp._id text:comment type:IMAGECATEGORY_LOG];

    __block BOOL found = NO;
    [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL * _Nonnull stop) {
        if (name._id == log.logger_id && dateSinceEpoch == log.datetime_epoch) {
            found = YES;
            *stop = YES;
        }
    }];

    if (found == YES)
        return;

    dbLog *l = [[dbLog alloc] init:0 gc_id:0 waypoint_id:wp._id logstring_id:logstring._id datetime:date logger_id:name._id log:comment needstobelogged:NO];
    [l dbCreate];
    newLogsCount++;
    [infoItemImport setLogsNew:newLogsCount];
}

- (void)parseData_trackables:(NSArray *)trackables waypoint:(dbWaypoint *)wp
{
    [infoItemImport setTrackablesTotal:[trackables count]];
    [trackables enumerateObjectsUsingBlock:^(NSDictionary *trackable, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseData_trackable:trackable waypoint:wp];
        totalTrackablesCount++;
        [infoItemImport setTrackablesTotal:totalTrackablesCount];
    }];
}

- (void)parseData_trackable:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    // No idea yet as I haven't found a single waypoint with trackables yet.
}

@end