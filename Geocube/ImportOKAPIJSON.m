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

@interface ImportOKAPIJSON ()

@end

@implementation ImportOKAPIJSON

- (void)parseDictionary:(NSDictionary *)dict
{
    if ([dict objectForKey:@"waypoints"] != nil) {
        [self parseBefore_caches];
        [self parseData_caches:[dict objectForKey:@"waypoints"]];
        [self parseAfter_caches];
    }
}

- (void)parseBefore_caches
{
    NSLog(@"%@: Parsing initializing", [self class]);
    [dbc.Group_LastImport dbEmpty];
    [dbc.Group_LastImportAdded dbEmpty];
    [db cleanupAfterDelete];
}

- (void)parseAfter_caches
{
    NSLog(@"%@: Parsing done", [self class]);
    [[dbc Group_AllWaypoints_Found] dbEmpty];
    [[dbc Group_AllWaypoints_Found] dbAddWaypoints:[dbWaypoint dbAllFound]];
    [[dbc Group_AllWaypoints_NotFound] dbEmpty];
    [[dbc Group_AllWaypoints_NotFound] dbAddWaypoints:[dbWaypoint dbAllNotFound]];
    [[dbc Group_AllWaypoints_Ignored] dbEmpty];
    [[dbc Group_AllWaypoints_Ignored] dbAddWaypoints:[dbWaypoint dbAllIgnored]];
    [db cleanupAfterDelete];
    [dbWaypoint dbUpdateLogStatus];
}

- (void)parseData_caches:(NSArray *)caches
{
    [caches enumerateObjectsUsingBlock:^(NSDictionary *cache, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseData_cache:cache];
    }];
}

- (void)parseData_cache:(NSDictionary *)dict
{
/*
 {
     "alt_wpts" =     (
     );
     "attr_acodes" =     (
         A64,
         A33,
         A21,
         A59
     );
     "attribution_note" = "This <a href='http://www.opencaching.nl/viewcache.php?cacheid=5210'>geocache</a> description comes from the <a href='http://www.opencaching.nl/'>Opencaching.NL</a> site.";
     attrnames =     (
         "Look out for ticks",
         "Parking area nearby",
         "Long walk",
         "Dangerous area"
     );
     code = OB145A;
     country = Nederland;
     "date_created" = "2011-08-29T23:35:26+02:00";
     "date_hidden" = "2011-08-29T00:00:00+02:00";
     description = "Deze cache is gemaakt[...]site.</em></p>";
     descriptions =     {
         nl = "Deze cache is gemaakt[...]site.</em></p>";
     };
     difficulty = "1.5";
     founds = 6;
     "gc_code" = "<null>";
     hint2 = "Zoek in het vierkant.";
     hints2 =     {
         nl = "Zoek in het vierkant.";
     };
     images =     (
     );
     "internal_id" = 5210;
     "is_found" = 0;
     "is_not_found" = 0;
     "last_found" = "2015-02-16T15:14:00+01:00";
     "last_modified" = "2015-05-30T23:11:01+02:00";
     "latest_logs" =     (
     );
     location = "51.301933|5.49745";
     "my_notes" = "<null>";
     name = "PMV Aniversary";
     names =     {
         nl = "PMV Aniversary";
     };
     notfounds = 0;
     owner =     {
         "profile_url" = "http://www.opencaching.nl/viewprofile.php?userid=109";
         username = hoedje;
         uuid = "2b285bd4-d98e-11e0-8a21-005056000020";
     };
     "preview_image" = "<null>";
     "protection_areas" =     (
     );
     rating = "<null>";
     "rating_votes" = 2;
     recommendations = 2;
     "req_passwd" = 1;
     "short_description" = "25 jarig huwelijks kado";
     "short_descriptions" =     {
         nl = "25 jarig huwelijks kado";
     };
     size = 3;
     size2 = regular;
     state = "Noord-Brabant";
     status = Available;
     terrain = 2;
     trackables =     (
     );
     "trackables_count" = 0;
     "trip_distance" = "11.4";
     "trip_time" = "<null>";
     type = Multi;
     url = "http://www.opencaching.nl/viewcache.php?wp=OB145A";
     willattends = 0;
 }
*/

    NSString *wpt_name;
    DICT_NSSTRING_KEY(dict, wpt_name, @"code");
    if (wpt_name == nil || [wpt_name isEqualToString:@""] == YES)
        return;

    NSInteger wpid = [dbWaypoint dbGetByName:wpt_name];
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
    DICT_NSSTRING_KEY(dict, wp.gs_long_desc, @"description");
    wp.gs_long_desc_html = YES;
    DICT_NSSTRING_KEY(dict, wp.wpt_date_placed, @"date_created");
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
    if (wp._id == 0) {
        NSLog(@"Created waypoint %@", wp.wpt_name);
        [dbWaypoint dbCreate:wp];
    } else {
        NSLog(@"Updated waypoint %@", wp.wpt_name);
        [wp dbUpdate];
    }
    if ([group dbContainsWaypoint:wp._id] == NO)
        [group dbAddWaypoint:wp._id];

    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_long_desc type:IMAGETYPE_CACHE];
    [ImagesDownloadManager findImagesInDescription:wp._id text:wp.gs_short_desc type:IMAGETYPE_CACHE];

    NSString *personal_note;
    DICT_NSSTRING_KEY(dict, personal_note, @"my_notes");
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
            pn.waypoint_id = wp._id;
            pn.note = personal_note;
            [pn dbCreate];
        }
    }

    NSArray *images = [dict objectForKey:@"images"];
    if ([images count] != 0)
        [self parseData_images:images waypoint:wp];

    NSArray *trackables = [dict objectForKey:@"trackables"];
    if ([trackables count] != 0)
        [self parseData_trackables:trackables waypoint:wp];

    NSArray *logs = [dict objectForKey:@"latest_logs"];
    if ([logs count] != 0)
        [self parseData_logs:logs waypoint:wp];

    /*
    preview_image
    rating
     */
}

- (void)parseData_images:(NSArray *)images waypoint:(dbWaypoint *)wp
{
    NSLog(@"Image number 0-%ld", [images count] - 1);
    [images enumerateObjectsUsingBlock:^(NSDictionary *image, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Image number %ld", idx);
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
        [image dbLinkToWaypoint:wp._id type:IMAGETYPE_CACHE];

    [ImagesDownloadManager addToQueue:image];

}

- (void)parseData_logs:(NSArray *)logs waypoint:(dbWaypoint *)wp
{
    NSArray *alllogs = [dbLog dbAllByWaypoint:wp._id];
    [logs enumerateObjectsUsingBlock:^(NSDictionary *log, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseData_log:log waypoint:wp logs:alllogs];
    }];
}

- (void)parseData_log:(NSDictionary *)dict waypoint:(dbWaypoint *)wp logs:(NSArray *)logs
{
/*
 {
     comment = "<p><span [...]Tot horens: Hoedje</span></p>";
     date = "2016-01-07T16:28:00+01:00";
     type = "Maintenance performed";
     user =     {
         "profile_url" = "http://www.opencaching.nl/viewprofile.php?userid=109";
         username = hoedje;
         uuid = "2b285bd4-d98e-11e0-8a21-005056000020";
     };
     uuid = "2FC3A900-0F22-0CBE-6BA8-CA7737BB5F24";
 }
*/

    NSInteger logtype = [dbLogString wptTypeToLogType:wp.wpt_type_str];
    NSString *type;
    NSString *date;
    NSInteger dateSinceEpoch;
    NSString *loggername;
    NSString *loggerid;
    NSString *comment;
    dbName *name;
    DICT_NSSTRING_KEY(dict, type, @"type");
    dbLogString *ls = [dbLogString dbGetByAccountEventType:account logtype:logtype type:type];
    DICT_NSSTRING_KEY(dict, date, @"date");
    dateSinceEpoch = [MyTools secondsSinceEpochFromISO8601:date];
    DICT_NSSTRING_PATH(dict, loggername, @"user.username");
    DICT_NSSTRING_PATH(dict, loggerid, @"user.uuid");
    DICT_NSSTRING_PATH(dict, comment, @"comment");
    [dbName makeNameExist:loggername code:loggerid account:account];

    name = [dbName dbGetByName:loggername account:account];

    [ImagesDownloadManager findImagesInDescription:wp._id text:comment type:IMAGETYPE_LOG];

    __block BOOL found = NO;
    [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL * _Nonnull stop) {
        if (name._id == log.logger_id && dateSinceEpoch == log.datetime_epoch) {
            found = YES;
            *stop = YES;
        }
    }];

    if (found == YES)
        return;

    dbLog *l = [[dbLog alloc] init:0 gc_id:0 waypoint_id:wp._id logstring_id:ls._id datetime:date logger_id:name._id log:comment needstobelogged:NO];
    [l dbCreate];
}

- (void)parseData_trackables:(NSArray *)trackables waypoint:(dbWaypoint *)wp
{
    [trackables enumerateObjectsUsingBlock:^(NSDictionary *trackable, NSUInteger idx, BOOL * _Nonnull stop) {
        [self parseData_trackable:trackable waypoint:wp];
    }];
}

- (void)parseData_trackable:(NSDictionary *)dict waypoint:(dbWaypoint *)wp
{
    // No idea yet as I haven't found a single waypoint with trackables yet.
}

@end
