/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

- (instancetype)init:(dbGroup *)_group account:(dbAccount *)_account
{
    self = [super init];

    group = _group;
    account = _account;
    self.run_options = RUN_OPTION_NONE;

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
    [dbc.Group_LastImport dbEmpty];
    [dbc.Group_LastImportAdded dbEmpty];
    [db cleanupAfterDelete];
}

- (void)parseAfter
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

- (void)parseFile:(NSString *)filename
{
    [self parseFile:filename infoItemImport:nil];
}
- (void)parseData:(NSData *)data
{
    [self parseData:data infoItemImport:nil];
}
- (void)parseString:(NSString *)string
{
    [self parseString:string infoItemImport:nil];
}
- (void)parseGPX:(GCStringGPX *)gpx
{
    [self parseString:[gpx _string] infoItemImport:nil];
}
- (void)parseDictionary:(id)dict
{
    [self parseDictionary:dict infoItemImport:nil];
}

NEEDS_OVERLOADING(parseFile:(NSString *)filename infoItemImport:(InfoItemImport *)iii)
NEEDS_OVERLOADING(parseData:(NSData *)data infoItemImport:(InfoItemImport *)iii)
NEEDS_OVERLOADING(parseString:(NSString *)data infoItemImport:(InfoItemImport *)iii)
NEEDS_OVERLOADING(parseDictionary:(id)dict infoItemImport:(InfoItemImport *)iii)

@end
