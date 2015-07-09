//
//  WaypointCachedData.h
//  Geocube
//
//  Created by Edwin Groothuis on 8/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface DatabaseCache : NSObject {
    // In memory database information
    NSArray *WaypointTypes;
    NSArray *WaypointGroups;
    NSArray *Waypoints;
    
    // System Groups
    dbWaypointGroup *WaypointGroup_AllWaypoints;
    dbWaypointGroup *WaypointGroup_AllWaypoints_Found;
    dbWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
    dbWaypointGroup *WaypointGroup_LastImport;
    dbWaypointGroup *WaypointGroup_LastImportAdded;

    // WaypointTypes
    dbWaypointType *WaypointType_Unknown;
}

@property (atomic, retain) NSArray *WaypointTypes;
@property (atomic, retain) NSArray *WaypointGroups;
@property (atomic, retain) NSArray *Waypoints;

// System Groups
@property (atomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints;
@property (atomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints_Found;
@property (atomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
@property (atomic, retain) dbWaypointGroup *WaypointGroup_LastImport;
@property (atomic, retain) dbWaypointGroup *WaypointGroup_LastImportAdded;

// WaypointTypes
@property (atomic, retain) dbWaypointType *WaypointType_Unknown;

- (void)loadWaypointData;
- (dbWaypointType *)waypointType_get_byname:(NSString *)name;
- (dbWaypointType *)waypointType_get:(NSInteger)wp_type;


@end
