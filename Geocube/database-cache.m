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

@synthesize Types, Groups, LogTypes, Containers, Attributes, Countries, States, Accounts;
@synthesize Group_AllWaypoints, Group_AllWaypoints_Found, Group_AllWaypoints_NotFound, Group_LastImport,Group_LastImportAdded, Type_Unknown, LogType_Unknown, Container_Unknown, Attribute_Unknown, Symbols;

- (id)init
{
    self = [super init];
    [self loadWaypointData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadWaypointData
{
    Groups = [dbGroup dbAll];
    Types = [dbType dbAll];
    Containers = [dbContainer dbAll];
    LogTypes = [dbLogType dbAll];
    Containers = [dbContainer dbAll];
    Attributes = [dbAttribute dbAll];
    Accounts = [dbAccount dbAll];
    Symbols = [NSMutableArray arrayWithArray:[dbSymbol dbAll]];
    Countries = [NSMutableArray arrayWithArray:[dbCountry dbAll]];
    States = [NSMutableArray arrayWithArray:[dbState dbAll]];

    Group_AllWaypoints = nil;
    Group_AllWaypoints_Found = nil;
    Group_AllWaypoints_NotFound = nil;
    Group_LastImport = nil;
    Group_LastImportAdded = nil;
    Type_Unknown = nil;
    Container_Unknown = nil;
    LogType_Unknown = nil;

    NSEnumerator *e = [Groups objectEnumerator];
    dbGroup *cg;
    while ((cg = [e nextObject]) != nil) {
        if (cg.usergroup == 0 && [cg.name compare:@"All Waypoints"] == NSOrderedSame) {
            Group_AllWaypoints = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"All Waypoints - Found"] == NSOrderedSame) {
            Group_AllWaypoints_Found = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"All Waypoints - Not Found"] == NSOrderedSame) {
            Group_AllWaypoints_NotFound = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"Last Import"] == NSOrderedSame) {
            Group_LastImport = cg;
            continue;
        }
        if (cg.usergroup == 0 && [cg.name compare:@"Last Import - New"] == NSOrderedSame) {
            Group_LastImportAdded = cg;
            continue;
        }
    }
    NSAssert(Group_AllWaypoints != nil, @"Group_AllWaypoints");
    NSAssert(Group_AllWaypoints_Found != nil, @"Group_AllWaypoints_Found");
    NSAssert(Group_AllWaypoints_NotFound != nil, @"Group_AllWaypoints_NotFound");
    NSAssert(Group_LastImport != nil, @"Group_LastImport");
    NSAssert(Group_LastImportAdded != nil, @"Group_LastImportAdded");

    e = [Types objectEnumerator];
    dbType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([ct.type compare:@"*"] == NSOrderedSame) {
            Type_Unknown = ct;
            continue;
        }
    }
    NSAssert(Type_Unknown != nil, @"Type_Unknown");

    e = [Types objectEnumerator];
    dbType *type;
    while ((type = [e nextObject]) != nil) {
        if ([type.type compare:@"Unknown"] == NSOrderedSame) {
            Type_Unknown = type;
            continue;
        }
    }
    NSAssert(Type_Unknown != nil, @"Type_Unknown");

    e = [LogTypes objectEnumerator];
    dbLogType *lt;
    while ((lt = [e nextObject]) != nil) {
        if ([lt.logtype compare:@"Unknown"] == NSOrderedSame) {
            LogType_Unknown = lt;
            continue;
        }
    }
    NSAssert(LogType_Unknown != nil, @"LogType_Unknown");

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

- (dbType *)Type_get_byname:(NSString *)name
{
    NSEnumerator *e = [Types objectEnumerator];
    dbType *ct;
    while ((ct = [e nextObject]) != nil) {
        if ([ct.type compare:name] == NSOrderedSame)
            return ct;
    }
    return nil;
}

- (dbType *)Type_get:(NSId)_id
{
    NSEnumerator *e = [Types objectEnumerator];
    dbType *ct;
    while ((ct = [e nextObject]) != nil) {
        if (ct._id == _id)
            return ct;
    }
    return nil;
}

- (dbSymbol *)Symbol_get_bysymbol:(NSString *)symbol
{
    NSEnumerator *e = [Symbols objectEnumerator];
    dbSymbol *lt;
    while ((lt = [e nextObject]) != nil) {
        if ([lt.symbol compare:symbol] == NSOrderedSame)
            return lt;
    }
    return nil;
}

- (dbSymbol *)Symbol_get:(NSId)_id
{
    NSEnumerator *e = [Symbols objectEnumerator];
    dbSymbol *lt;
    while ((lt = [e nextObject]) != nil) {
        if (lt._id == _id)
            return lt;
    }
    return nil;
}

- (void)Symbols_add:(NSId)_id symbol:(NSString *)symbol
{
    dbSymbol *cs = [[dbSymbol alloc] init:_id symbol:symbol];
    [Symbols addObject:cs];
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

- (dbGroup *)Group_get:(NSId)_id
{
    NSEnumerator *e = [Groups objectEnumerator];
    dbGroup *cg;
    while ((cg = [e nextObject]) != nil) {
        if (cg._id == _id)
            return cg;
    }
    return nil;
}

- (dbContainer *)Container_get:(NSId)_id
{
    NSEnumerator *e = [Containers objectEnumerator];
    dbContainer *s;
    while ((s = [e nextObject]) != nil) {
        if (s._id == _id)
            return s;
    }
    return nil;
}

- (dbContainer *)Container_get_bysize:(NSString *)size
{
    NSEnumerator *e = [Containers objectEnumerator];
    dbContainer *s;
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

- (dbCountry *)Country_get_byName:(NSString *)name
{
    NSEnumerator *e = [Countries objectEnumerator];
    dbCountry *s;
    while ((s = [e nextObject]) != nil) {
        if ([s.name compare:name] == NSOrderedSame)
            return s;
    }
    return nil;
}

- (void)Country_add:(dbCountry *)country
{
    [Countries addObject:country];
}

- (dbState *)State_get_byName:(NSString *)name
{
    NSEnumerator *e = [States objectEnumerator];
    dbState *s;
    while ((s = [e nextObject]) != nil) {
        if ([s.name compare:name] == NSOrderedSame)
            return s;
    }
    return nil;
}

- (void)State_add:(dbState *)state
{
    [States addObject:state];
}

@end
