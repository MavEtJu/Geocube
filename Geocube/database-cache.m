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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation DatabaseCache

@synthesize CacheTypes, CacheGroups, Caches, LogTypes, ContainerTypes, ContainerSizes, Attributes;
@synthesize CacheGroup_AllCaches, CacheGroup_AllCaches_Found, CacheGroup_AllCaches_NotFound, CacheGroup_LastImport,CacheGroup_LastImportAdded, CacheType_Unknown, ContainerType_Unknown, LogType_Unknown, ContainerSize_Unknown, Attribute_Unknown;

- (id)init
{
    self = [super init];
    [self loadCacheData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadCacheData
{
    CacheGroups = [db CacheGroups_all];
    CacheTypes = [db CacheTypes_all];
    Caches = [db Caches_all];
    ContainerTypes = [db ContainerTypes_all];
    LogTypes = [db LogTypes_all];
    ContainerSizes = [db ContainerSizes_all];
    Attributes = [db Attributes_all];

    CacheGroup_AllCaches = nil;
    CacheGroup_AllCaches_Found = nil;
    CacheGroup_AllCaches_NotFound = nil;
    CacheGroup_LastImport = nil;
    CacheGroup_LastImportAdded = nil;
    CacheType_Unknown = nil;
    ContainerType_Unknown = nil;
    LogType_Unknown = nil;
    ContainerSize_Unknown = nil;

    NSEnumerator *e = [CacheGroups objectEnumerator];
    dbCacheGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Caches"] == NSOrderedSame) {
            CacheGroup_AllCaches = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Caches - Found"] == NSOrderedSame) {
            CacheGroup_AllCaches_Found = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Caches - Not Found"] == NSOrderedSame) {
            CacheGroup_AllCaches_NotFound = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import"] == NSOrderedSame) {
            CacheGroup_LastImport = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import - New"] == NSOrderedSame) {
            CacheGroup_LastImportAdded = wpg;
            continue;
        }
    }
    NSAssert(CacheGroup_AllCaches != nil, @"CacheGroup_AllCaches");
    NSAssert(CacheGroup_AllCaches_Found != nil, @"CacheGroup_AllCaches_Found");
    NSAssert(CacheGroup_AllCaches_NotFound != nil, @"CacheGroup_AllCaches_NotFound");
    NSAssert(CacheGroup_LastImport != nil, @"CacheGroup_LastImport");
    NSAssert(CacheGroup_LastImportAdded != nil, @"CacheGroup_LastImportAdded");

    e = [CacheTypes objectEnumerator];
    dbCacheType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if ([wpg.name compare:@"*"] == NSOrderedSame) {
            CacheType_Unknown = wpt;
            continue;
        }
    }
    NSAssert(CacheType_Unknown != nil, @"CacheType_Unknown");

    e = [ContainerTypes objectEnumerator];
    dbContainerType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([ct.size compare:@"Unknown"] == NSOrderedSame) {
            ContainerType_Unknown = ct;
            continue;
        }
    }
    NSAssert(ContainerType_Unknown != nil, @"ContainerType_Unknown");

    e = [LogTypes objectEnumerator];
    dbLogType *lt;
    while ((lt = [e nextObject]) != nil) {
        if ([lt.logtype compare:@"Unknown"] == NSOrderedSame) {
            LogType_Unknown = lt;
            continue;
        }
    }
    NSAssert(LogType_Unknown != nil, @"LogType_Unknown");

    e = [ContainerSizes objectEnumerator];
    dbContainerSize *s;
    while ((s = [e nextObject]) != nil) {
        if ([s.size compare:@"Not chosen"] == NSOrderedSame) {
            ContainerSize_Unknown = s;
            continue;
        }
    }
    NSAssert(CacheType_Unknown != nil, @"LogType_Unknown");

    e = [Attributes objectEnumerator];
    dbAttribute *a;
    while ((a = [e nextObject]) != nil) {
        if ([a.label compare:@"Unknown"] == NSOrderedSame) {
            Attribute_Unknown = a;
            continue;
        }
    }
    NSAssert(Attribute_Unknown != nil, @"Attribute_Unknown");

}

- (dbCacheType *)CacheType_get_byname:(NSString *)name
{
    NSEnumerator *e = [CacheTypes objectEnumerator];
    dbCacheType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if ([wpt.type compare:name] == NSOrderedSame)
            return wpt;
    }
    return nil;
}

- (dbCacheType *)CacheType_get:(NSInteger)wp_type
{
    NSEnumerator *e = [CacheTypes objectEnumerator];
    dbCacheType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if (wpt._id == wp_type)
            return wpt;
    }
    return nil;
}

- (dbLogType *)LogType_get_bytype:(NSString *)type
{
    NSEnumerator *e = [LogTypes objectEnumerator];
    dbLogType *lt;
    while ((lt = [e nextObject]) != nil) {
        if ([lt.logtype compare:type] == NSOrderedSame)
            return lt;
    }
    return nil;
}

- (dbLogType *)LogType_get:(NSInteger)_id
{
    NSEnumerator *e = [LogTypes objectEnumerator];
    dbLogType *lt;
    while ((lt = [e nextObject]) != nil) {
        if (lt._id == _id)
            return lt;
    }
    return nil;
}

- (dbContainerType *)ContainerType_get_bysize:(NSString *)size
{
    NSEnumerator *e = [ContainerTypes objectEnumerator];
    dbContainerType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([ct.size compare:size] == NSOrderedSame)
            return ct;
    }
    return nil;
}


- (dbContainerType *)ContainerType_get:(NSInteger)_id
{
    NSEnumerator *e = [ContainerTypes objectEnumerator];
    dbContainerType *ct;
    while ((ct = [e nextObject]) != nil) {
        if (ct._id == _id)
            return ct;
    }
    return nil;
}

- (dbCache *)Cache_get:(NSInteger)_id
{
    NSEnumerator *e = [Caches objectEnumerator];
    dbCache *wp;
    while ((wp = [e nextObject]) != nil) {
        if (wp._id == _id)
            return wp;
    }
    return nil;
}

- (dbCacheGroup *)CacheGroup_get:(NSInteger)_id
{
    NSEnumerator *e = [CacheGroups objectEnumerator];
    dbCacheGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        if (wpg._id == _id)
            return wpg;
    }
    return nil;
}

- (dbContainerSize *)ContainerSize_get:(NSInteger)_id
{
    NSEnumerator *e = [ContainerSizes objectEnumerator];
    dbContainerSize *s;
    while ((s = [e nextObject]) != nil) {
        if (s._id == _id)
            return s;
    }
    return nil;
}

- (dbContainerSize *)ContainerSize_get_bysize:(NSString *)size
{
    NSEnumerator *e = [ContainerSizes objectEnumerator];
    dbContainerSize *s;
    while ((s = [e nextObject]) != nil) {
        if ([s.size compare:size] == NSOrderedSame)
            return s;
    }
    return nil;
}

- (dbAttribute *)Attribute_get:(NSInteger)_id
{
    NSEnumerator *e = [Attributes objectEnumerator];
    dbAttribute *s;
    while ((s = [e nextObject]) != nil) {
        if (s._id == _id)
            return s;
    }
    return nil;
}

- (dbAttribute *)Attribute_get_bygcid:(NSInteger)gcid
{
    NSEnumerator *e = [Attributes objectEnumerator];
    dbAttribute *s;
    while ((s = [e nextObject]) != nil) {
        if (s.gc_id == gcid)
            return s;
    }
    return nil;
}

@end
