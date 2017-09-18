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

#import "ImportTemplate.h"

#import "Geocube-Defines.h"

#import "DatabaseLibrary/database-cache.h"
#import "DatabaseLibrary/database.h"
#import "DatabaseLibrary/dbGroup.h"
#import "DatabaseLibrary/dbWaypoint.h"
#import "BaseObjectsLibrary/GCStringObjects.h"

@interface ImportTemplate ()

@end

@implementation ImportTemplate

- (instancetype)init:(dbGroup *)_group account:(dbAccount *)_account
{
    self = [super init];

    group = _group;
    account = _account;
    self.run_options = IMPORTOPTION_NONE;

    newWaypointsCount = 0;
    totalWaypointsCount = 0;
    newLogsCount = 0;
    totalLogsCount = 0;
    newTrackablesCount = 0;
    totalTrackablesCount = 0;
    newImagesCount = 0;

    NSLog(@"%@: Importing into %@", [self class], group.name);

    return self;
}

/* ************************************ */

- (void)parseBefore
{
    NSLog(@"%@: Parsing initializing", [self class]);

    [dbc.groupLastImport emptyGroup];
    [dbc.groupLastImportAdded emptyGroup];
    [db cleanupAfterDelete];
}

- (void)parseAfter
{
    NSLog(@"%@: Parsing done", [self class]);

    [dbc.groupAllWaypointsFound emptyGroup];
    [dbc.groupAllWaypointsFound addWaypointsToGroup:[dbWaypoint dbAllFound]];
    [dbc.groupAllWaypointsNotFound emptyGroup];
    [dbc.groupAllWaypointsNotFound addWaypointsToGroup:[dbWaypoint dbAllNotFound]];
    [dbc.groupAllWaypointsIgnored emptyGroup];
    [dbc.groupAllWaypointsIgnored addWaypointsToGroup:[dbWaypoint dbAllIgnored]];
    [db cleanupAfterDelete];
    [dbWaypoint dbUpdateLogStatus];
}

- (void)parseFile:(NSString *)filename
{
    [self parseFile:filename infoViewer:nil iiImport:0];
}
- (void)parseData:(NSData *)data
{
    [self parseData:data infoViewer:nil iiImport:0];
}
- (void)parseString:(NSString *)string
{
    [self parseString:string infoViewer:nil iiImport:0];
}
- (void)parseGPX:(GCStringGPX *)gpx
{
    [self parseString:[gpx _string] infoViewer:nil iiImport:0];
}
- (void)parseDictionary:(id)dict
{
    [self parseDictionary:dict infoViewer:nil iiImport:0];
}

- NEEDS_OVERLOADING_VOID(parseFile:(NSString *)filename infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii)
- NEEDS_OVERLOADING_VOID(parseData:(NSData *)data infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii)
- NEEDS_OVERLOADING_VOID(parseString:(NSString *)data infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii)
- NEEDS_OVERLOADING_VOID(parseDictionary:(id)dict infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii)

@end
