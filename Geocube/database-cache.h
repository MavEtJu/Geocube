//
//  CacheCachedData.h
//  Geocube
//
//  Created by Edwin Groothuis on 8/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface DatabaseCache : NSObject {
    // In memory database information
    NSArray *CacheTypes;
    NSArray *CacheGroups;
    NSArray *Caches;
    NSArray *LogTypes;
    NSArray *ContainerTypes;
    NSArray *ContainerSizes;
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
- (dbLogType *)LogType_get_bytype:(NSString *)type;
- (dbLogType *)LogType_get:(NSInteger)_id;
- (dbCache *)Cache_get:(NSInteger)_id;
- (dbCacheGroup *)CacheGroup_get:(NSInteger)_id;
- (dbContainerSize *)ContainerSize_get_bysize:(NSString *)size;
- (dbContainerSize *)ContainerSize_get:(NSInteger)_id;
- (dbAttribute *)Attribute_get:(NSInteger)_id;
- (dbAttribute *)Attribute_get_bygcid:(NSInteger)gc_id;


@end
