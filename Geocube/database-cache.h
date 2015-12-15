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

@interface DatabaseCache : NSObject

@property (nonatomic, retain) NSArray *Accounts;
@property (nonatomic, retain) NSArray *Pins;
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
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_Attended;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_ManuallyAdded;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_Ignored;
@property (nonatomic, retain) dbGroup *Group_LastImport;
@property (nonatomic, retain) dbGroup *Group_LastImportAdded;

// Types
@property (nonatomic, retain) dbType *Type_Unknown;

// Pins
@property (nonatomic, retain) dbPin *Pin_Unknown;

// Symbols
@property (nonatomic, retain) dbSymbol *Symbol_Unknown;

// LogTypes
@property (nonatomic, retain) dbLogType *LogType_Unknown;
@property (nonatomic, retain) dbLogType *LogType_Found;
@property (nonatomic, retain) dbLogType *LogType_Attended;
@property (nonatomic, retain) dbLogType *LogType_NotFound;

// ContainerSize
@property (nonatomic, retain) dbContainer *Container_Unknown;

// Attributes
@property (nonatomic, retain) dbAttribute *Attribute_Unknown;

- (void)loadWaypointData;

- (dbType *)Type_get_byname:(NSString *)name minor:(NSString *)minor;
- (dbType *)Type_get:(NSId)_id;

- (dbPin *)Pin_get:(NSId)_id;

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
- (dbCountry *)Country_get:(NSId)_id;

- (dbState *)State_get_byName:(NSString *)name;
- (void)State_add:(dbState *)state;
- (dbState *)State_get:(NSId)_id;

- (void)AccountsReload;
- (dbAccount *)Account_get:(NSId)_id;

@end
