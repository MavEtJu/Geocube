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

#import "MapLogsViewController.h"

#import "Geocube-defines.h"

#import "MapsLibrary/MapTemplate.h"
#import "DatabaseLibrary/dbLog.h"
#import "DatabaseLibrary/dbWaypoint.h"
#import "DatabaseLibrary/dbName.h"
#import "DatabaseLibrary/DatabaseCache.h"
#import "ToolsLibrary/MyTools.h"

@interface MapLogsViewController ()
{
    dbWaypoint *waypoint;
}

@end

@implementation MapLogsViewController

- (instancetype)init
{
    self = [super init:YES];
    self.followWhom = SHOW_NEITHER;

    [lmi disableItem:MVCmenuLoadWaypoints];
    [lmi disableItem:MVCmenuExportVisible];

    [lmi disableItem:MVCmenuLoadWaypoints];
    [lmi disableItem:MVCmenuDirections];
    [lmi disableItem:MVCmenuAutoZoom];
    [lmi disableItem:MVCmenuRecenter];
    [lmi disableItem:MVCmenuUseGNSS];
    [lmi disableItem:MVCmenuRemoveTarget];
    [lmi disableItem:MVCmenuShowBoundaries];
    [lmi disableItem:MVCmenuExportVisible];
    [lmi disableItem:MVCmenuRemoveHistory];

    return self;
}

- (void)showLogLocations:(dbWaypoint *)_wp
{
    waypoint = _wp;
    NSArray<dbLog *> *logs = [dbLog dbAllByWaypoint:waypoint];
    self.waypointsArray = [NSMutableArray arrayWithCapacity:[logs count]];
    [logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
        dbWaypoint *wp = [[dbWaypoint alloc] init];
        wp.wpt_name = [NSString stringWithFormat:@"LOG%ld", (long)log._id];
        wp.wpt_urlname = [NSString stringWithFormat:@"%@ on %@", log.logger.name, [MyTools dateTimeString_YYYY_MM_DD:log.datetime_epoch]];
        wp.wpt_latitude = log.latitude;
        wp.wpt_longitude = log.longitude;
        wp.wpt_type = dbc.typeLog;
        [wp finish];
        [self.waypointsArray addObject:wp];
    }];

    MAINQUEUE(
        [self.map removeMarkers];
        [self.map placeMarkers];
        [self.map moveCameraToAll];
    )
}

- (void)refreshWaypointsData
{
    // Nothing
}

- (void)menuChangeMapbrand:(MapBrand *)mapBrand
{
    [super menuChangeMapbrand:mapBrand];
    [self showLogLocations:waypoint];
}

@end
