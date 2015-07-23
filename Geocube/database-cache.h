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

@interface DatabaseCache : NSObject {
    // In memory database information
    NSArray *Types;
    NSArray *Groups;
    NSArray *LogTypes;
    NSArray *Containers;
    NSArray *Attributes;
    NSMutableArray *Symbols;
    NSMutableArray *Countries;
    NSMutableArray *States;

    // System Groups
    dbGroup *Group_AllWaypoints;
    dbGroup *Group_AllWaypoints_Found;
    dbGroup *Group_AllWaypoints_NotFound;
    dbGroup *Group_LastImport;
    dbGroup *Group_LastImportAdded;

    // Types
    dbType *Type_Unknown;

    // LogTypes
    dbLogType *LogType_Unknown;

    // Container
    dbContainer *Container_Unknown;

    // Attribute
    dbAttribute *Attribute_Unknown;
}

@property (nonatomic, retain) NSArray *Types;
@property (nonatomic, retain) NSArray *Groups;
@property (nonatomic, retain) NSArray *LogTypes;
@property (nonatomic, retain) NSArray *Containers;
@property (nonatomic, retain) NSArray *Attributes;
@property (nonatomic, retain) NSMutableArray *Symbols;
@property (nonatomic, retain) NSMutableArray *Countries;
@property (nonatomic, retain) NSMutableArray *States;

// System Groups
@property (nonatomic, retain) dbGroup *Group_AllWaypoints;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_Found;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_NotFound;
@property (nonatomic, retain) dbGroup *Group_LastImport;
@property (nonatomic, retain) dbGroup *Group_LastImportAdded;

// Types
@property (nonatomic, retain) dbType *Type_Unknown;

// LogTypes
@property (nonatomic, retain) dbLogType *LogType_Unknown;

// ContainerSize
@property (nonatomic, retain) dbContainer *Container_Unknown;

// Attributes
@property (nonatomic, retain) dbAttribute *Attribute_Unknown;

- (void)loadWaypointData;

- (dbType *)Type_get_byname:(NSString *)name;
- (dbType *)Type_get:(NSId)_id;

- (dbContainer *)Container_get_bysize:(NSString *)size;
- (dbContainer *)Container_get:(NSId)_id;

- (dbSymbol *)Symbol_get_bysymbol:(NSString *)size;
- (dbSymbol *)Symbol_get:(NSId)_id;
- (void)Symbols_add:(NSId)_id symbol:(NSString *)symbol;

- (dbLogType *)LogType_get_bytype:(NSString *)type;
- (dbLogType *)LogType_get:(NSId)_id;

- (dbGroup *)Group_get:(NSId)_id;

- (dbAttribute *)Attribute_get:(NSId)_id;
- (dbAttribute *)Attribute_get_bygcid:(NSId)gc_id;

- (dbCountry *)Country_get_byName:(NSString *)name;
- (void)Country_add:(dbCountry *)country;

- (dbState *)State_get_byName:(NSString *)name;
- (void)State_add:(dbState *)state;

@end
