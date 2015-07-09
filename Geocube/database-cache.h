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
    dbObjectWaypointGroup *WaypointGroup_AllWaypoints;
    dbObjectWaypointGroup *WaypointGroup_AllWaypoints_Found;
    dbObjectWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
    dbObjectWaypointGroup *WaypointGroup_LastImport;
    dbObjectWaypointGroup *WaypointGroup_LastImportAdded;

    // WaypointTypes
    dbObjectWaypointType *WaypointType_Unknown;
}

@property (atomic, retain) NSArray *WaypointTypes;
@property (atomic, retain) NSArray *WaypointGroups;
@property (atomic, retain) NSArray *Waypoints;

// System Groups
@property (atomic, retain) dbObjectWaypointGroup *WaypointGroup_AllWaypoints;
@property (atomic, retain) dbObjectWaypointGroup *WaypointGroup_AllWaypoints_Found;
@property (atomic, retain) dbObjectWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
@property (atomic, retain) dbObjectWaypointGroup *WaypointGroup_LastImport;
@property (atomic, retain) dbObjectWaypointGroup *WaypointGroup_LastImportAdded;

// WaypointTypes
@property (atomic, retain) dbObjectWaypointType *WaypointType_Unknown;

- (void)loadWaypointData;
- (dbObjectWaypointType *)waypointType_get_byname:(NSString *)name;
- (dbObjectWaypointType *)waypointType_get:(NSInteger)wp_type;


@end
