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
    [dbGroup cleanupAfterDelete];
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
    [dbGroup cleanupAfterDelete];
    [dbc loadWaypointData];
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
    [dbCountry makeNameExist:wp.gs_state_str];
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

    /*
    images
    logs
    my_notes
    preview_image
    rating
    trackables
     */

}

@end
