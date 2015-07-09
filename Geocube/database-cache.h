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
    NSArray *LogTypes;
    NSArray *ContainerTypes;
    
    // System Groups
    dbWaypointGroup *WaypointGroup_AllWaypoints;
    dbWaypointGroup *WaypointGroup_AllWaypoints_Found;
    dbWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
    dbWaypointGroup *WaypointGroup_LastImport;
    dbWaypointGroup *WaypointGroup_LastImportAdded;

    // WaypointTypes
    dbWaypointType *WaypointType_Unknown;
    
    // LogTypes
    dbLogType *LogType_Unknown;
    
    // ContainerType
    dbContainerType *ContainerType_Unknown;
}

@property (nonatomic, retain) NSArray *WaypointTypes;
@property (nonatomic, retain) NSArray *WaypointGroups;
@property (nonatomic, retain) NSArray *Waypoints;
@property (nonatomic, retain) NSArray *LogTypes;
@property (nonatomic, retain) NSArray *ContainerTypes;

// System Groups
@property (nonatomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints;
@property (nonatomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints_Found;
@property (nonatomic, retain) dbWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
@property (nonatomic, retain) dbWaypointGroup *WaypointGroup_LastImport;
@property (nonatomic, retain) dbWaypointGroup *WaypointGroup_LastImportAdded;

// WaypointTypes
@property (nonatomic, retain) dbWaypointType *WaypointType_Unknown;

// LogTypes
@property (nonatomic, retain) dbLogType *LogType_Unknown;

// ContainerType
@property (nonatomic, retain) dbContainerType *ContainerType_Unknown;

- (void)loadWaypointData;
- (dbWaypointType *)WaypointType_get_byname:(NSString *)name;
- (dbWaypointType *)WaypointType_get:(NSInteger)wp_type;
- (dbContainerType *)ContainerType_get_bysize:(NSString *)size;
- (dbContainerType *)ContainerType_get:(NSInteger)_id;
- (dbLogType *)LogType_get_bytype:(NSString *)type;
- (dbLogType *)LogType_get:(NSInteger)_id;


@end
