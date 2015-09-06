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

    NSArray *as = [dict objectForKey:@"Geocaches"];
    [as enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseGeocaches:d];
    }];

}

- (void)parseGeocaches:(NSDictionary *)dict
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

    wp.symbol_str = [dict valueForKeyPath:@"ContainerType.ContainerTypeName"];
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
    [gs finish];
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
