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
@property (nonatomic, retain) NSMutableArray<dbAccount *> *accounts;
@property (nonatomic, retain) NSMutableArray<dbProtocol *> *protocols;
@property (nonatomic, retain) NSMutableArray<dbPin *> *pins;
@property (nonatomic, retain) NSMutableArray<dbType *> *types;
@property (nonatomic, retain) NSMutableArray<dbGroup *> *groups;
@property (nonatomic, retain) NSMutableArray<dbContainer *> *containers;
@property (nonatomic, retain) NSMutableArray<dbCountry *> *countries;
@property (nonatomic, retain) NSMutableArray<dbState *> *states;
@property (nonatomic, retain) NSMutableArray<dbLocality *> *localities;

// System Groups
@property (nonatomic, retain) dbGroup *groupAllWaypoints;
@property (nonatomic, retain) dbGroup *groupAllWaypointsFound;
@property (nonatomic, retain) dbGroup *groupAllWaypointsNotFound;
@property (nonatomic, retain) dbGroup *groupAllWaypointsManuallyAdded;
@property (nonatomic, retain) dbGroup *groupAllWaypointsIgnored;
@property (nonatomic, retain) dbGroup *groupLiveImport;
@property (nonatomic, retain) dbGroup *groupLastImport;
@property (nonatomic, retain) dbGroup *groupLastImportAdded;
@property (nonatomic, retain) dbGroup *groupManualWaypoints;

// Types
@property (nonatomic, retain) dbType *typeUnknown;
@property (nonatomic, retain) dbType *typeManuallyEntered;
@property (nonatomic, retain) dbType *typeLog;

// Pins
@property (nonatomic, retain) dbPin *pinUnknown;

// Symbols
@property (nonatomic, retain) dbSymbol *symbolUnknown;
@property (nonatomic, retain) dbSymbol *symbolVirtualStage;

// ContainerSize
@property (nonatomic, retain) dbContainer *containerUnknown;

// Attributes
@property (nonatomic, retain) dbAttribute *attributeUnknown;

// Accounts
@property (nonatomic, retain) dbAccount *accountPrivate;

- (void)loadCachableData;

- (dbType *)typeGetByName:(NSString *)name minor:(NSString *)minor;
- (dbType *)typeGetByMinor:(NSString *)minor;
- (dbType *)typeGet:(NSId)_id;
- (void)typeAdd:(dbType *)type;

- (dbPin *)pinGet:(NSId)_id;
- (dbPin *)pinGet_nilOkay:(NSId)_id;
- (void)pinAdd:(dbPin *)pin;

- (dbContainer *)containerGetBySize:(NSString *)size;
- (dbContainer *)containerGet:(NSId)_id;

- (dbSymbol *)symbolGetBySymbol:(NSString *)size;
- (dbSymbol *)symbolGet:(NSId)_id;
- (void)symbolsAdd:(dbSymbol *)s;

- (dbLogString *)logStringGetByDisplayString:(dbAccount *)account displayString:(NSString *)displayString;
- (dbLogString *)logStringGet:(NSId)_id;
- (void)logStringAdd:(dbLogString *)logstring;

- (dbGroup *)groupGet:(NSId)_id;
- (void)groupAdd:(dbGroup *)group;
- (void)groupDelete:(dbGroup *)group;

- (dbAttribute *)attributeGet:(NSId)_id;
- (dbAttribute *)attributeGetByGCId:(NSId)gc_id;
- (void)attributeAdd:(dbAttribute *)attr;

- (dbCountry *)countryGetByNameCode:(NSString *)name;
- (dbCountry *)countryGet:(NSId)_id;
- (void)countryAdd:(dbCountry *)country;

- (dbState *)stateGetByNameCode:(NSString *)name;
- (dbState *)stateGet:(NSId)_id;
- (void)stateAdd:(dbState *)state;

- (dbLocality *)localityGetByName:(NSString *)name;
- (dbLocality *)localityGet:(NSId)_id;
- (void)localityAdd:(dbLocality *)state;

- (void)accountsReload;
- (dbAccount *)accountGet:(NSId)_id;
- (BOOL)accountIsOwner:(dbWaypoint *)wp;

- (dbName *)nameGet:(NSId)_id;
- (void)nameAdd:(dbName *)name;
- (dbName *)nameGetNoName:(dbAccount *)account;

- (dbProtocol *)protocolGet:(NSId)_id;

@end

extern DatabaseCache *dbc;
