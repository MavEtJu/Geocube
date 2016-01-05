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

@interface ImportGCAJSON ()
{
    dbAccount *account;
    dbGroup *group;

    NSMutableArray *namesImported;
}

@end

@implementation ImportGCAJSON

@synthesize namesImported;

- (instancetype)init:(dbGroup *)_group account:(dbAccount *)_account
{
    self = [super init];

    group = _group;
    account = _account;

    NSLog(@"%@: Importing into %@", [self class], group.name);

    return self;
}

- (void)parseBefore
{
    NSLog(@"%@: Parsing initializing", [self class]);
    namesImported = [NSMutableArray arrayWithCapacity:50];
}

- (void)parseData:(NSDictionary *)dict
{
    NSLog(@"%@: Parsing data", [self class]);

    /*
     {
         "datetime" : "2015-12-10T08:37:41Z",
         "msg" : "Caches",
         "actionstatus" : "1",
         "geocaches" : [
         ]`
     }
     */

    [self parseGeocaches:[dict objectForKey:@"geocaches"]];
    [waypointManager needsRefresh];
}

- (void)parseGeocaches:(NSArray *)as
{
    [as enumerateObjectsUsingBlock:^(NSDictionary *d, NSUInteger idx, BOOL *stop) {
        [self parseGeocache:d];
    }];
}

- (void)parseGeocache:(NSDictionary *)dict
{
    dbWaypoint *wp = [[dbWaypoint alloc] init:0];
    /*
    {
        "terrain" : "1.5",
        "coords" : {
            "lon" : 151.12445,
            "lat" : -34.048867
        },
        "type" : "B",
        "state" : "NSW",
        "placedby" : "Richary",
        "short_description" : "A gnome for the latest race",
        "name" : "Golden [Genome]",
        "direction" : null,
        "country" : "AU",
        "archived" : "f",
        "available" : "t",
        "log1" : "Moved",
        "log3" : "Found it",
        "difficulty" : "1.5",
        "waypoint" : "GA7854",
        "type_text" : "Moveable",
        "hidden" : "2015-12-01",
        "log2" : "Found it",
        "recommended" : "0",
        "long_description" : "&lt;p&gt;Golden gnome is a ....",
        "locale" : "Caringbah South",
        "distance" : 1.11,
        "log4" : "Moved",
        "owner" : "richary",
        "container" : "R",
        "container_text" : "Regular",
        "hints" : "",
        "icon" : "cacheicon_moveable.png",
        "rating" : 4
    }
     */

    NSDictionary *coords = [dict objectForKey:@"coords"];

    NSString *wpname = [dict objectForKey:@"waypoint"];
    NSId old = [dbWaypoint dbGetByName:wpname];
    if (old != 0)
        wp = [dbWaypoint dbGet:old];

    wp.gs_rating_terrain = [[dict objectForKey:@"terrain"] floatValue];
    wp.wpt_lat = [[coords objectForKey:@"lat"] stringValue];
    wp.wpt_lon = [[coords objectForKey:@"lon"] stringValue];
    wp.wpt_type_str = [dict objectForKey:@"type"];
    wp.gs_state_str = [dict objectForKey:@"state"];
    wp.gs_placed_by = [dict objectForKey:@"placedby"];
    wp.gs_short_desc = [dict objectForKey:@"short_description"];
    wp.gs_short_desc_html = YES;
    wp.wpt_urlname = [dict objectForKey:@"name"];
    wp.gs_country_str = [dict objectForKey:@"country"];
    wp.gs_archived = [[dict objectForKey:@"archived"] isEqualToString:@"t"];
    wp.gs_available = [[dict objectForKey:@"available"] isEqualToString:@"t"];
    wp.gs_rating_difficulty = [[dict objectForKey:@"difficulty"] floatValue];
    wp.wpt_name = [dict objectForKey:@"waypoint"];
    wp.wpt_type_str = [dict objectForKey:@"type_text"];
    wp.wpt_date_placed = [dict objectForKey:@"hidden"];
    wp.gs_long_desc = [dict objectForKey:@"long_description"];
    wp.gs_long_desc_html = YES;
    wp.gs_owner_str = [dict objectForKey:@"owner"];
    wp.gs_container_str = [dict objectForKey:@"container_text"];
    wp.gs_hint = [dict objectForKey:@"hints"];

    wp.account = account;
    wp.account_id = account._id;

    if (wp.wpt_symbol_str == nil)
        wp.wpt_symbol_str = @"Geocache";

    [wp finish];

    if (old == 0) {
        NSLog(@"%@: Creating %@", [self class], wpname);
        [dbWaypoint dbCreate:wp];
        [group dbAddWaypoint:wp._id];
    } else {
        NSLog(@"%@: Updating %@", [self class], wpname);
        [wp dbUpdate];
        if ([group dbContainsWaypoint:wp._id] == NO)
            [group dbAddWaypoint:wp._id];
    }

    [namesImported addObject:wpname];
}

- (void)parseAfter
{
    NSLog(@"%@: Parsing done", [self class]);
}

@end
