//
//  WaypointCachedData.m
//  Geocube
//
//  Created by Edwin Groothuis on 8/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation DatabaseCache

@synthesize WaypointTypes, WaypointGroups, Waypoints, WaypointGroup_AllWaypoints, WaypointGroup_AllWaypoints_Found, WaypointGroup_AllWaypoints_NotFound, WaypointGroup_LastImport,WaypointGroup_LastImportAdded, WaypointType_Unknown;

- (id)init
{
    self = [super init];
    [self loadWaypointData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadWaypointData
{
    WaypointGroups = [db WaypointGroups_all];
    WaypointTypes = [db WaypointTypes_all];
    Waypoints = [db Waypoints_all];
    
    WaypointGroup_AllWaypoints = nil;
    WaypointGroup_AllWaypoints_Found = nil;
    WaypointGroup_AllWaypoints_NotFound = nil;
    WaypointGroup_LastImport = nil;
    WaypointGroup_LastImportAdded = nil;
    WaypointType_Unknown = nil;
    
    NSEnumerator *e = [WaypointGroups objectEnumerator];
    dbObjectWaypointGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints - Found"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints_Found = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints - Not Found"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints_NotFound = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import"] == NSOrderedSame) {
            WaypointGroup_LastImport = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import - New"] == NSOrderedSame) {
            WaypointGroup_LastImportAdded = wpg;
            continue;
        }
    }
    
    e = [WaypointTypes objectEnumerator];
    dbObjectWaypointType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if ([wpg.name compare:@"*"] == NSOrderedSame) {
            WaypointType_Unknown = wpt;
            continue;
        }
    }
}

- (dbObjectWaypointType *)waypointType_get_byname:(NSString *)name
{
    NSEnumerator *e = [WaypointTypes objectEnumerator];
    dbObjectWaypointType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if ([wpt.type compare:name] == NSOrderedSame)
            return wpt;
    }
    return nil;
}

- (dbObjectWaypointType *)waypointType_get:(NSInteger)wp_type
{
    NSEnumerator *e = [WaypointTypes objectEnumerator];
    dbObjectWaypointType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if (wpt._id == wp_type)
            return wpt;
    }
    return nil;

}

@end
