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

@interface ImportTemplate ()

@end

@implementation ImportTemplate

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account
{
    self = [super init];

    self.group = group;
    self.account = account;
    self.run_options = IMPORTOPTION_NONE;

    self.newWaypointsCount = 0;
    self.totalWaypointsCount = 0;
    self.newLogsCount = 0;
    self.totalLogsCount = 0;
    self.newTrackablesCount = 0;
    self.totalTrackablesCount = 0;
    self.newImagesCount = 0;

    NSLog(@"%@: Importing into %@", [self class], self.group.name);

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
    [self parseFile:filename infoItem:nil];
}
- (void)parseData:(NSData *)data
{
    [self parseData:data infoItem:nil];
}
- (void)parseString:(NSString *)string
{
    [self parseString:string infoItem:nil];
}
- (void)parseGPX:(GCStringGPX *)gpx
{
    [self parseString:[gpx _string] infoItem:nil];
}
- (void)parseDictionary:(id)dict
{
    [self parseDictionary:dict infoItem:nil];
}

- NEEDS_OVERLOADING_VOID(parseFile:(NSString *)filename infoItem:(InfoItem2 *)iii)
- NEEDS_OVERLOADING_VOID(parseData:(NSData *)data infoItem:(InfoItem2 *)iii)
- NEEDS_OVERLOADING_VOID(parseString:(NSString *)data infoItem:(InfoItem2 *)iii)
- NEEDS_OVERLOADING_VOID(parseDictionary:(id)dict infoItem:(InfoItem2 *)iii)

@end
