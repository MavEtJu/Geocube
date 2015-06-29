//
//  Geocube.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_Geocube_h
#define Geocube_Geocube_h

#import "database.h"
#import "dbObjects.h"

extern database *db;

// In memory database information
extern NSArray *WaypointTypes;
extern NSArray *WaypointGroups;
extern NSArray *Waypoints;

// System Groups
extern dbObjectWaypointGroup *WaypointGroup_AllWaypoints;
extern dbObjectWaypointGroup *WaypointGroup_AllWaypoints_Found;
extern dbObjectWaypointGroup *WaypointGroup_AllWaypoints_NotFound;
extern dbObjectWaypointGroup *WaypointGroup_LastImport;
extern dbObjectWaypointGroup *WaypointGroup_LastImportAdded;

#endif
