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

#import "DatabaseCache.h"

#import "DatabaseLibrary/dbProtocol.h"
#import "DatabaseLibrary/dbAccount.h"
#import "DatabaseLibrary/dbGroup.h"
#import "DatabaseLibrary/dbPin.h"
#import "DatabaseLibrary/dbType.h"
#import "DatabaseLibrary/dbContainer.h"
#import "DatabaseLibrary/dbLogString.h"
#import "DatabaseLibrary/dbAttribute.h"
#import "DatabaseLibrary/dbSymbol.h"
#import "DatabaseLibrary/dbCountry.h"
#import "DatabaseLibrary/dbState.h"
#import "DatabaseLibrary/dbLocality.h"
#import "DatabaseLibrary/dbName.h"
#import "DatabaseLibrary/dbWaypoint.h"

@interface DatabaseCache ()
{
    // In memory database information
    NSMutableArray<dbAttribute *> *attributes;
    NSMutableArray<dbSymbol *> *symbols;
    NSMutableArray<dbLogString *> *logStrings;
    NSMutableDictionary *names;
}

@end

@implementation DatabaseCache

- (instancetype)init
{
    self = [super init];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadCachableData
{
    self.protocols = [NSMutableArray arrayWithArray:[dbProtocol dbAll]];
    self.accounts = [NSMutableArray arrayWithArray:[dbAccount dbAll]];      // after protocols
    self.groups = [NSMutableArray arrayWithArray:[dbGroup dbAll]];
    self.pins = [NSMutableArray arrayWithArray:[dbPin dbAll]];
    self.types = [NSMutableArray arrayWithArray:[dbType dbAll]];            // after pins
    self.containers = [NSMutableArray arrayWithArray:[dbContainer dbAll]];
    logStrings = [NSMutableArray arrayWithArray:[dbLogString dbAll]];
    self.containers = [NSMutableArray arrayWithArray:[dbContainer dbAll]];
    attributes = [NSMutableArray arrayWithArray:[dbAttribute dbAll]];
    symbols = [NSMutableArray arrayWithArray:[dbSymbol dbAll]];
    self.countries = [NSMutableArray arrayWithArray:[dbCountry dbAll]];
    self.states = [NSMutableArray arrayWithArray:[dbState dbAll]];
    self.localities = [NSMutableArray arrayWithArray:[dbLocality dbAll]];

    [self.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull cg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints"] == YES) {
            self.groupAllWaypoints = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Found"] == YES) {
            self.groupAllWaypointsFound = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Not Found"] == YES) {
            self.groupAllWaypointsNotFound = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Manually entered"] == YES) {
            self.groupAllWaypointsManuallyAdded = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Ignored"] == YES) {
            self.groupAllWaypointsIgnored = cg;
            return;
        }
        if (cg.usergroup == YES && [cg.name isEqualToString:@"Live Import"] == YES) {
            self.groupLiveImport = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"Last Import"] == YES) {
            self.groupLastImport = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"Last Import - New"] == YES) {
            self.groupLastImportAdded = cg;
            return;
        }
        if (cg.usergroup == YES && [cg.name isEqualToString:@"Manual waypoints"] == YES) {
            self.groupManualWaypoints = cg;
            return;
        }
    }];
    NSAssert(self.groupAllWaypoints != nil, @"Group_AllWaypoints");
    NSAssert(self.groupAllWaypointsFound != nil, @"Group_AllWaypoints_Found");
    NSAssert(self.groupAllWaypointsNotFound != nil, @"Group_AllWaypoints_NotFound");
    NSAssert(self.groupAllWaypointsManuallyAdded != nil, @"Group_AllWaypoints_ManuallyAdded");
    NSAssert(self.groupAllWaypointsIgnored != nil, @"Group_AllWaypoints_Ignored");
    NSAssert(self.groupLiveImport != nil, @"Group_LiveImport");
    NSAssert(self.groupLastImport != nil, @"Group_LastImport");
    NSAssert(self.groupLastImportAdded != nil, @"Group_LastImportAdded");
    NSAssert(self.groupManualWaypoints != nil, @"Group_ManualWaypoints");

    [self.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([c.size isEqualToString:@"Unknown"] == YES) {
            self.containerUnknown = c;
            *stop = YES;
        }
    }];
    // You cannot do this until the configuration files are loaded.
    // NSAssert(Container_Unknown != nil, @"Container_Unknown");

    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull ct, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([ct.type_major isEqualToString:@"*"] == YES)
            self.typeUnknown = ct;
        if ([ct.type_major isEqualToString:@"Waypoint"] == YES && [ct.type_minor isEqualToString:@"Manually entered"] == YES)
            self.typeManuallyEntered = ct;
        if ([ct.type_major isEqualToString:@"Geocache"] == YES && [ct.type_minor isEqualToString:@"Reverse"] == YES)
            self.typeLog = ct;
    }];
    if ([self.types count] != 0) {
        NSAssert(self.typeUnknown != nil, @"Type_Unknown");
        NSAssert(self.typeLog != nil, @"Type_Log");
        if (self.typeManuallyEntered == nil)
            self.typeManuallyEntered = self.typeUnknown;
    }

    [self.pins enumerateObjectsUsingBlock:^(dbPin * _Nonnull pt, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pt.desc isEqualToString:@"*"] == YES) {
            self.pinUnknown = pt;
            *stop = YES;
        }
    }];
    if ([self.pins count] != 0)
        NSAssert(self.pinUnknown != nil, @"Pin_Unknown");

    [symbols enumerateObjectsUsingBlock:^(dbSymbol * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s.symbol isEqualToString:@"*"] == YES)
            self.symbolUnknown = s;
        if ([s.symbol isEqualToString:@"Virtual Stage"] == YES)
            self.symbolVirtualStage = s;
    }];
    if ([symbols count] != 0) {
        NSAssert(self.symbolUnknown != nil, @"Symbol_Unknown");
        NSAssert(self.symbolVirtualStage != nil, @"Symbol_VirtualStage");
    }

    [attributes enumerateObjectsUsingBlock:^(dbAttribute * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a.label isEqualToString:@"Unknown"] == YES) {
            self.attributeUnknown = a;
            *stop = YES;
        }
    }];
    if ([attributes count] != 0)
        NSAssert(self.attributeUnknown != nil, @"Attribute_Unknown");

    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a.site isEqualToString:@"My Private Collection"] == YES) {
            self.accountPrivate = a;
            *stop = YES;
        }
    }];
    if ([attributes count] != 0)
        NSAssert(self.attributeUnknown != nil, @"Attribute_Unknown");

    names = [NSMutableDictionary dictionaryWithCapacity:200];
    [[dbName dbAll] enumerateObjectsUsingBlock:^(dbName * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        [names setObject:name forKey:[NSNumber numberWithLongLong:name._id]];
    }];
}

- (dbType *)typeGetByName:(NSString *)major minor:(NSString *)minor
{
    NSAssert([self.types count] != 0, @"Types");
    __block dbType *_ct = nil;
    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull ct, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([ct.type_major isEqualToString:major] == YES &&
            [ct.type_minor isEqualToString:minor] == YES) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return self.typeUnknown;
    return _ct;
}

- (dbType *)typeGetByMinor:(NSString *)minor
{
    NSAssert([self.types count] != 0, @"Types");
    __block dbType *_ct = nil;
    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull ct, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([ct.type_minor isEqualToString:minor] == YES) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return self.typeUnknown;
    return _ct;
}

- (dbType *)typeGet:(NSId)_id
{
    NSAssert([self.types count] != 0, @"Types");
    __block dbType *_ct = nil;
    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull ct, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ct._id == _id) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return self.typeUnknown;
    return _ct;
}

- (void)typeAdd:(dbType *)type
{
    NSMutableArray<dbType *> *as = [NSMutableArray arrayWithArray:self.types];
    [as addObject:type];
    self.types = as;
}

- (dbPin *)pinGet:(NSId)_id
{
    NSAssert([self.pins count] != 0, @"Pins");
    __block dbPin *_pt = nil;
    [self.pins enumerateObjectsUsingBlock:^(dbPin * _Nonnull pt, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pt._id == _id) {
            _pt = pt;
            *stop = YES;
        }
    }];
    if (_pt == nil)
        return self.pinUnknown;
    return _pt;
}

- (dbPin *)pinGet_nilOkay:(NSId)_id
{
    NSAssert([self.pins count] != 0, @"Pins");
    __block dbPin *_pt = nil;
    [self.pins enumerateObjectsUsingBlock:^(dbPin * _Nonnull pt, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pt._id == _id) {
            _pt = pt;
            *stop = YES;
        }
    }];
    return _pt;
}

- (void)pinAdd:(dbPin *)pin
{
    NSMutableArray<dbPin *> *as = [NSMutableArray arrayWithArray:self.pins];
    [as addObject:pin];
    self.pins = as;
}

- (dbSymbol *)symbolGetBySymbol:(NSString *)symbol
{
    NSAssert([symbols count] != 0, @"Symbol");
    __block dbSymbol *_lt = nil;
    [symbols enumerateObjectsUsingBlock:^(dbSymbol * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([lt.symbol isEqualToString:symbol] == YES) {
            _lt = lt;
            *stop = YES;
        }
    }];
    if (_lt == nil)
        return self.symbolUnknown;
    return _lt;
}

- (dbSymbol *)symbolGet:(NSId)_id
{
    NSAssert([symbols count] != 0, @"Symbol");
    __block dbSymbol *_lt = nil;
    [symbols enumerateObjectsUsingBlock:^(dbSymbol * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lt._id == _id) {
            _lt = lt;
            *stop = YES;
        }
    }];
    if (_lt == nil)
        return self.symbolUnknown;
    return _lt;
}

- (void)symbolsAdd:(dbSymbol *)s
{
    [symbols addObject:s];
}

- (dbLogString *)logStringGetByDisplayString:(dbAccount *)account displayString:(NSString *)displayString
{
    NSAssert([logStrings count] != 0, @"LogStrings");
    __block dbLogString *_ls = nil;
    [logStrings enumerateObjectsUsingBlock:^(dbLogString * _Nonnull ls, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ls.protocol._id == account.protocol._id &&
            [ls.displayString compare:displayString options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _ls = ls;
            *stop = YES;
        }
    }];
    return _ls;
}

- (dbLogString *)logStringGet:(NSId)_id
{
    NSAssert([logStrings count] != 0, @"LogStrings");
    __block dbLogString *_ls = nil;
    [logStrings enumerateObjectsUsingBlock:^(dbLogString * _Nonnull ls, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ls._id == _id) {
            _ls = ls;
            *stop = YES;
        }
    }];
    return _ls;
}

- (void)logStringAdd:(dbLogString *)logstring
{
    NSMutableArray<dbLogString *> *as = [NSMutableArray arrayWithArray:logStrings];
    [as addObject:logstring];
    logStrings = as;
}

- (dbGroup *)groupGet:(NSId)_id
{
    NSAssert([self.groups count] != 0, @"Groups");
    __block dbGroup *_g = nil;
    [self.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        if (g._id == _id) {
            _g = g;
            *stop = YES;
        }
    }];
    return _g;
}

- (void)groupAdd:(dbGroup *)group
{
    [self.groups addObject:group];
}

- (void)groupDelete:(dbGroup *)group
{
    [self.groups removeObject:group];
}

- (dbContainer *)containerGet:(NSId)_id
{
    NSAssert([self.containers count] != 0, @"Containers");
    __block dbContainer *_c = nil;
    [self.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if (c._id == _id) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbContainer *)containerGetBySize:(NSString *)size
{
    NSAssert([self.containers count] != 0, @"Containers");
    __block dbContainer *_c = nil;
    [self.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([c.size isEqualToString:size] == YES) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbAttribute *)attributeGet:(NSId)_id
{
    NSAssert([attributes count] != 0, @"Attributes");
    __block dbAttribute *_a = nil;
    [attributes enumerateObjectsUsingBlock:^(dbAttribute * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a._id == _id) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (dbAttribute *)attributeGetByGCId:(NSId)gcid
{
    NSAssert([attributes count] != 0, @"Attributes");
    __block dbAttribute *_a = nil;
    [attributes enumerateObjectsUsingBlock:^(dbAttribute * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.gc_id == gcid) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (void)attributeAdd:(dbAttribute *)attr
{
    NSMutableArray<dbAttribute *> *as = [NSMutableArray arrayWithArray:attributes];
    [as addObject:attr];
    attributes = as;
}

- (dbCountry *)countryGetByNameCode:(NSString *)name
{
    __block dbCountry *_c = nil;
    [self.countries enumerateObjectsUsingBlock:^(dbCountry * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([c.name isEqualToString:name] == YES || [c.code isEqualToString:name] == YES) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbCountry *)countryGet:(NSId)_id
{
    __block dbCountry *_c = nil;
    [self.countries enumerateObjectsUsingBlock:^(dbCountry * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if (c._id == _id) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (void)countryAdd:(dbCountry *)country
{
    [self.countries addObject:country];
}

- (dbState *)stateGetByNameCode:(NSString *)name
{
    __block dbState *_s = nil;
    [self.states enumerateObjectsUsingBlock:^(dbState * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s.name isEqualToString:name] == YES || [s.code isEqualToString:name] == YES) {
            _s = s;
            *stop = YES;
        }
    }];
    return _s;
}

- (dbState *)stateGet:(NSId)_id
{
    __block dbState *_s = nil;
    [self.states enumerateObjectsUsingBlock:^(dbState * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if (s._id == _id) {
            _s = s;
            *stop = YES;
        }
    }];
    return _s;
}

- (void)stateAdd:(dbState *)state
{
    [self.states addObject:state];
}

- (dbLocality *)localityGetByName:(NSString *)name
{
    __block dbLocality *_l = nil;
    [self.localities enumerateObjectsUsingBlock:^(dbLocality * _Nonnull l, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([l.name isEqualToString:name] == YES) {
            _l = l;
            *stop = YES;
        }
    }];
    return _l;
}

- (dbLocality *)localityGet:(NSId)_id
{
    __block dbLocality *_l = nil;
    [self.localities enumerateObjectsUsingBlock:^(dbLocality * _Nonnull l, NSUInteger idx, BOOL * _Nonnull stop) {
        if (l._id == _id) {
            _l = l;
            *stop = YES;
        }
    }];
    return _l;
}

- (void)localityAdd:(dbLocality *)l
{
    [self.localities addObject:l];
}

- (dbProtocol *)protocolGet:(NSId)_id
{
    NSAssert([self.protocols count] != 0, @"Protocols");
    __block dbProtocol *_p = nil;
    [self.protocols enumerateObjectsUsingBlock:^(dbProtocol * _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
        if (p._id == _id) {
            _p = p;
            *stop = YES;
        }
    }];
    return _p;
}

- (void)accountsReload
{
    NSMutableArray<dbAccount *> *newAccounts = [NSMutableArray arrayWithArray:[dbAccount dbAll]];

    [newAccounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull newAccount, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL found = NO;
        [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull oldAccount, NSUInteger idx, BOOL * _Nonnull stop) {
            if (newAccount.geocube_id == oldAccount.geocube_id) {
                oldAccount.gca_cookie_name = newAccount.gca_cookie_name;
                oldAccount.gca_cookie_value = newAccount.gca_cookie_value;
                oldAccount.gca_callback_url = newAccount.gca_callback_url;
                oldAccount.gca_authenticate_url = newAccount.gca_authenticate_url;

                oldAccount.oauth_consumer_public = newAccount.oauth_consumer_public;
                oldAccount.oauth_consumer_private = newAccount.oauth_consumer_private;
                oldAccount.oauth_request_url = newAccount.oauth_request_url;
                oldAccount.oauth_access_url = newAccount.oauth_access_url;
                oldAccount.oauth_authorize_url = newAccount.oauth_authorize_url;
                oldAccount.oauth_token = newAccount.oauth_token;
                oldAccount.oauth_token_secret = newAccount.oauth_token_secret;

                oldAccount.revision = newAccount.revision;
                oldAccount.site = newAccount.site;
                oldAccount.url_site = newAccount.url_site;
                oldAccount.url_queries = newAccount.url_queries;
                oldAccount.accountname = newAccount.accountname;
                oldAccount.protocol = newAccount.protocol;
                oldAccount.enabled = newAccount.enabled;

                *stop = YES;
                found = YES;
            }
        }];
        if (found == NO)
            [self.accounts addObject:newAccount];
    }];
}

- (dbAccount *)accountGet:(NSId)_id
{
    __block dbAccount *_a;
    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a._id == _id) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (BOOL)accountIsOwner:(dbWaypoint *)wp
{
    __block BOOL found = NO;
    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp.gs_owner._id == 0)
            return;
        if (a.accountname._id == wp.gs_owner._id) {
            found = YES;
            *stop = YES;
        }
    }];
    return found;
}

- (dbName *)nameGet:(NSId)_id
{
    NSAssert([names count] != 0, @"Names");
    NSNumber *n = [NSNumber numberWithLongLong:_id];
    dbName *name = [names objectForKey:n];
    return name;
}

- (void)nameAdd:(dbName *)name
{
    NSNumber *n = [NSNumber numberWithLongLong:name._id];
    [names setObject:name forKey:n];
}

@end
