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
    NSArray *CacheTypes;
    NSArray *CacheGroups;
    NSArray *Caches;
    NSArray *LogTypes;
    NSArray *ContainerTypes;
    NSArray *ContainerSizes;
    NSMutableArray *CacheSymbols;
    NSArray *Attributes;

    // System Groups
    dbCacheGroup *CacheGroup_AllCaches;
    dbCacheGroup *CacheGroup_AllCaches_Found;
    dbCacheGroup *CacheGroup_AllCaches_NotFound;
    dbCacheGroup *CacheGroup_LastImport;
    dbCacheGroup *CacheGroup_LastImportAdded;

    // CacheTypes
    dbCacheType *CacheType_Unknown;

    // LogTypes
    dbLogType *LogType_Unknown;

    // ContainerType
    dbContainerType *ContainerType_Unknown;

    // Size
    dbContainerSize *ContainerSize_Unknown;

    // Attribute
    dbAttribute *Attribute_Unknown;
}

@property (nonatomic, retain) NSArray *CacheTypes;
@property (nonatomic, retain) NSArray *CacheGroups;
@property (nonatomic, retain) NSArray *Caches;
@property (nonatomic, retain) NSArray *LogTypes;
@property (nonatomic, retain) NSArray *ContainerTypes;
@property (nonatomic, retain) NSArray *ContainerSizes;
@property (nonatomic, retain) NSArray *Attributes;
@property (nonatomic, retain) NSMutableArray *CacheSymbols;

// System Groups
@property (nonatomic, retain) dbCacheGroup *CacheGroup_AllCaches;
@property (nonatomic, retain) dbCacheGroup *CacheGroup_AllCaches_Found;
@property (nonatomic, retain) dbCacheGroup *CacheGroup_AllCaches_NotFound;
@property (nonatomic, retain) dbCacheGroup *CacheGroup_LastImport;
@property (nonatomic, retain) dbCacheGroup *CacheGroup_LastImportAdded;

// CacheTypes
@property (nonatomic, retain) dbCacheType *CacheType_Unknown;

// LogTypes
@property (nonatomic, retain) dbLogType *LogType_Unknown;

// ContainerType
@property (nonatomic, retain) dbContainerType *ContainerType_Unknown;

// ContainerSize
@property (nonatomic, retain) dbContainerSize *ContainerSize_Unknown;

// Attributes
@property (nonatomic, retain) dbAttribute *Attribute_Unknown;

- (void)loadCacheData;

- (dbCacheType *)CacheType_get_byname:(NSString *)name;
- (dbCacheType *)CacheType_get:(NSInteger)wp_type;

- (dbContainerType *)ContainerType_get_bysize:(NSString *)size;
- (dbContainerType *)ContainerType_get:(NSInteger)_id;

- (dbCacheSymbol *)CacheSymbol_get_bysymbol:(NSString *)size;
- (dbCacheSymbol *)CacheSymbol_get:(NSInteger)_id;
- (void)CacheSymbols_add:(NSInteger)_id symbol:(NSString *)symbol;

- (dbLogType *)LogType_get_bytype:(NSString *)type;
- (dbLogType *)LogType_get:(NSInteger)_id;

- (dbCache *)Cache_get:(NSInteger)_id;

- (dbCacheGroup *)CacheGroup_get:(NSInteger)_id;

- (dbContainerSize *)ContainerSize_get_bysize:(NSString *)size;
- (dbContainerSize *)ContainerSize_get:(NSInteger)_id;

- (dbAttribute *)Attribute_get:(NSInteger)_id;
- (dbAttribute *)Attribute_get_bygcid:(NSInteger)gc_id;


@end
