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

@interface DatabaseCache : NSObject

// In memory database information
@property (nonatomic, retain) NSMutableArray *Accounts;
@property (nonatomic, retain) NSMutableArray *Protocols;
@property (nonatomic, retain) NSMutableArray *Pins;
@property (nonatomic, retain) NSMutableArray *Types;
@property (nonatomic, retain) NSMutableArray *Groups;
@property (nonatomic, retain) NSMutableArray *Containers;
@property (nonatomic, retain) NSMutableArray *Countries;
@property (nonatomic, retain) NSMutableArray *States;
@property (nonatomic, retain) NSMutableArray *Locales;

// System Groups
@property (nonatomic, retain) dbGroup *Group_AllWaypoints;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_Found;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_NotFound;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_ManuallyAdded;
@property (nonatomic, retain) dbGroup *Group_AllWaypoints_Ignored;
@property (nonatomic, retain) dbGroup *Group_LiveImport;
@property (nonatomic, retain) dbGroup *Group_LastImport;
@property (nonatomic, retain) dbGroup *Group_LastImportAdded;
@property (nonatomic, retain) dbGroup *Group_ManualWaypoints;

// Types
@property (nonatomic, retain) dbType *Type_Unknown;
@property (nonatomic, retain) dbType *Type_ManuallyEntered;

// Pins
@property (nonatomic, retain) dbPin *Pin_Unknown;

// Symbols
@property (nonatomic, retain) dbSymbol *Symbol_Unknown;

// ContainerSize
@property (nonatomic, retain) dbContainer *Container_Unknown;

// Attributes
@property (nonatomic, retain) dbAttribute *Attribute_Unknown;

- (void)loadCachableData;

- (dbType *)Type_get_byname:(NSString *)name minor:(NSString *)minor;
- (dbType *)Type_get_byminor:(NSString *)minor;
- (dbType *)Type_get:(NSId)_id;
- (void)Type_add:(dbType *)type;

- (dbPin *)Pin_get:(NSId)_id;
- (dbPin *)Pin_get_nilokay:(NSId)_id;
- (void)Pin_add:(dbPin *)pin;

- (dbContainer *)Container_get_bysize:(NSString *)size;
- (dbContainer *)Container_get:(NSId)_id;

- (dbSymbol *)Symbol_get_bysymbol:(NSString *)size;
- (dbSymbol *)Symbol_get:(NSId)_id;
- (void)Symbols_add:(NSId)_id symbol:(NSString *)symbol;

- (dbLogString *)LogString_get_bytype:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type;
- (dbLogString *)LogString_get:(NSId)_id;
- (void)LogString_add:(dbLogString *)logstring;

- (dbGroup *)Group_get:(NSId)_id;
- (void)Group_add:(dbGroup *)group;
- (void)Group_delete:(dbGroup *)group;

- (dbAttribute *)Attribute_get:(NSId)_id;
- (dbAttribute *)Attribute_get_bygcid:(NSId)gc_id;
- (void)Attribute_add:(dbAttribute *)attr;

- (dbCountry *)Country_get_byNameCode:(NSString *)name;
- (dbCountry *)Country_get:(NSId)_id;
- (void)Country_add:(dbCountry *)country;

- (dbState *)State_get_byNameCode:(NSString *)name;
- (dbState *)State_get:(NSId)_id;
- (void)State_add:(dbState *)state;

- (dbLocale *)Locale_get_byName:(NSString *)name;
- (dbLocale *)Locale_get:(NSId)_id;
- (void)Locale_add:(dbLocale *)state;

- (void)AccountsReload;
- (dbAccount *)Account_get:(NSId)_id;
- (BOOL)Account_isOwner:(dbWaypoint *)wp;

- (dbName *)Name_get:(NSId)_id;
- (void)Name_add:(dbName *)name;

@end
