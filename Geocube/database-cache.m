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

#import "Geocube-Prefix.pch"

@implementation DatabaseCache

@synthesize CacheTypes, CacheGroups, LogTypes, ContainerTypes, ContainerSizes, Attributes;
@synthesize CacheGroup_AllCaches, CacheGroup_AllCaches_Found, CacheGroup_AllCaches_NotFound, CacheGroup_LastImport,CacheGroup_LastImportAdded, CacheType_Unknown, ContainerType_Unknown, LogType_Unknown, ContainerSize_Unknown, Attribute_Unknown, CacheSymbols;

- (id)init
{
    self = [super init];
    [self loadCacheData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadCacheData
{
    CacheGroups = [dbCacheGroup dbAll];
    CacheTypes = [dbCacheType dbAll];
    ContainerTypes = [dbContainerType dbAll];
    LogTypes = [dbLogType dbAll];
    ContainerSizes = [dbContainerSize dbAll];
    Attributes = [dbAttribute dbAll];
    CacheSymbols = [NSMutableArray arrayWithArray:[dbCacheSymbol dbAll]];

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
    dbCacheGroup *cg;
    while ((cg = [e nextObject]) != nil) {
        if (cg.usergroup == 0 && [cg.name compare:@"All Caches"] == NSOrderedSame) {
            CacheGroup_AllCaches = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"All Caches - Found"] == NSOrderedSame) {
            CacheGroup_AllCaches_Found = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"All Caches - Not Found"] == NSOrderedSame) {
            CacheGroup_AllCaches_NotFound = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"Last Import"] == NSOrderedSame) {
            CacheGroup_LastImport = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"Last Import - New"] == NSOrderedSame) {
            CacheGroup_LastImportAdded = cg;
            continue;
        }
    }
    NSAssert(CacheGroup_AllCaches != nil, @"CacheGroup_AllCaches");
    NSAssert(CacheGroup_AllCaches_Found != nil, @"CacheGroup_AllCaches_Found");
    NSAssert(CacheGroup_AllCaches_NotFound != nil, @"CacheGroup_AllCaches_NotFound");
    NSAssert(CacheGroup_LastImport != nil, @"CacheGroup_LastImport");
    NSAssert(CacheGroup_LastImportAdded != nil, @"CacheGroup_LastImportAdded");

    e = [CacheTypes objectEnumerator];
    dbCacheType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([cg.name compare:@"*"] == NSOrderedSame) {
            CacheType_Unknown = ct;
            continue;
        }
    }
    NSAssert(CacheType_Unknown != nil, @"CacheType_Unknown");

    e = [ContainerTypes objectEnumerator];
    dbContainerType *containert;
    while ((containert = [e nextObject]) != nil) {
        if ([containert.size compare:@"Unknown"] == NSOrderedSame) {
            ContainerType_Unknown = containert;
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
    dbCacheType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([ct.type compare:name] == NSOrderedSame)
            return ct;
    }
    return nil;
}

- (dbCacheType *)CacheType_get:(NSId)cache_type
{
    NSEnumerator *e = [CacheTypes objectEnumerator];
    dbCacheType *ct;
    while ((ct = [e nextObject]) != nil) {
        if (ct._id == cache_type)
            return ct;
    }
    return nil;
}

- (dbCacheSymbol *)CacheSymbol_get_bysymbol:(NSString *)symbol
{
    NSEnumerator *e = [CacheSymbols objectEnumerator];
    dbCacheSymbol *lt;
    while ((lt = [e nextObject]) != nil) {
        if ([lt.symbol compare:symbol] == NSOrderedSame)
            return lt;
    }
    return nil;
}

- (dbCacheSymbol *)CacheSymbol_get:(NSId)_id
{
    NSEnumerator *e = [CacheSymbols objectEnumerator];
    dbCacheSymbol *lt;
    while ((lt = [e nextObject]) != nil) {
        if (lt._id == _id)
            return lt;
    }
    return nil;
}

- (void)CacheSymbols_add:(NSId)_id symbol:(NSString *)symbol
{
    dbCacheSymbol *cs = [[dbCacheSymbol alloc] init:_id symbol:symbol];
    [CacheSymbols addObject:cs];
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

- (dbLogType *)LogType_get:(NSId)_id
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


- (dbContainerType *)ContainerType_get:(NSId)_id
{
    NSEnumerator *e = [ContainerTypes objectEnumerator];
    dbContainerType *ct;
    while ((ct = [e nextObject]) != nil) {
        if (ct._id == _id)
            return ct;
    }
    return nil;
}

- (dbCacheGroup *)CacheGroup_get:(NSId)_id
{
    NSEnumerator *e = [CacheGroups objectEnumerator];
    dbCacheGroup *cg;
    while ((cg = [e nextObject]) != nil) {
        if (cg._id == _id)
            return cg;
    }
    return nil;
}

- (dbContainerSize *)ContainerSize_get:(NSId)_id
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

- (dbAttribute *)Attribute_get:(NSId)_id
{
    NSEnumerator *e = [Attributes objectEnumerator];
    dbAttribute *s;
    while ((s = [e nextObject]) != nil) {
        if (s._id == _id)
            return s;
    }
    return nil;
}

- (dbAttribute *)Attribute_get_bygcid:(NSId)gcid
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
