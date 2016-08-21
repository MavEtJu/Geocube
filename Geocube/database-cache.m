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

@interface DatabaseCache ()
{
    // In memory database information
    NSMutableArray *LogTypes;
    NSMutableArray *Attributes;
    NSMutableArray *Symbols;
    NSMutableArray *LogStrings;
    NSMutableDictionary *Names;
}

@end

@implementation DatabaseCache

@synthesize Accounts, Containers, Countries, Groups, Pins, States, Types, Locales;
@synthesize Group_AllWaypoints, Group_AllWaypoints_Found, Group_AllWaypoints_NotFound, Group_AllWaypoints_ManuallyAdded, Group_AllWaypoints_Ignored, Group_LiveImport, Group_LastImport, Group_LastImportAdded, Group_ManualWaypoints;
@synthesize Pin_Unknown, Type_Unknown, Container_Unknown, Attribute_Unknown, Symbol_Unknown;

- (instancetype)init
{
    self = [super init];
    [self loadCachableData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadCachableData
{
    Accounts = [NSMutableArray arrayWithArray:[dbAccount dbAll]];
    Groups = [NSMutableArray arrayWithArray:[dbGroup dbAll]];
    Pins = [NSMutableArray arrayWithArray:[dbPin dbAll]];
    Types = [NSMutableArray arrayWithArray:[dbType dbAll]];
    Containers = [NSMutableArray arrayWithArray:[dbContainer dbAll]];
    LogStrings = [NSMutableArray arrayWithArray:[dbLogString dbAll]];
    Containers = [NSMutableArray arrayWithArray:[dbContainer dbAll]];
    Attributes = [NSMutableArray arrayWithArray:[dbAttribute dbAll]];
    Symbols = [NSMutableArray arrayWithArray:[dbSymbol dbAll]];
    Countries = [NSMutableArray arrayWithArray:[dbCountry dbAll]];
    States = [NSMutableArray arrayWithArray:[dbState dbAll]];
    Locales = [NSMutableArray arrayWithArray:[dbLocale dbAll]];

    Group_AllWaypoints = nil;
    Group_AllWaypoints_Found = nil;
    Group_AllWaypoints_NotFound = nil;
    Group_AllWaypoints_ManuallyAdded = nil;
    Group_AllWaypoints_Ignored = nil;
    Group_LastImport = nil;
    Group_LastImportAdded = nil;
    Type_Unknown = nil;
    Container_Unknown = nil;

    [Groups enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints"] == YES) {
            Group_AllWaypoints = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Found"] == YES) {
            Group_AllWaypoints_Found = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Not Found"] == YES) {
            Group_AllWaypoints_NotFound = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Manually entered"] == YES) {
            Group_AllWaypoints_ManuallyAdded = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"All Waypoints - Ignored"] == YES) {
            Group_AllWaypoints_Ignored = cg;
            return;
        }
        if (cg.usergroup == YES && [cg.name isEqualToString:@"Live Import"] == YES) {
            Group_LiveImport = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"Last Import"] == YES) {
            Group_LastImport = cg;
            return;
        }
        if (cg.usergroup == NO && [cg.name isEqualToString:@"Last Import - New"] == YES) {
            Group_LastImportAdded = cg;
            return;
        }
        if (cg.usergroup == YES && [cg.name isEqualToString:@"Manual waypoints"] == YES) {
            Group_ManualWaypoints = cg;
            return;
        }
    }];
    NSAssert(Group_AllWaypoints != nil, @"Group_AllWaypoints");
    NSAssert(Group_AllWaypoints_Found != nil, @"Group_AllWaypoints_Found");
    NSAssert(Group_AllWaypoints_NotFound != nil, @"Group_AllWaypoints_NotFound");
    NSAssert(Group_AllWaypoints_ManuallyAdded != nil, @"Group_AllWaypoints_ManuallyAdded");
    NSAssert(Group_AllWaypoints_Ignored != nil, @"Group_AllWaypoints_Ignored");
    NSAssert(Group_LiveImport != nil, @"Group_LiveImport");
    NSAssert(Group_LastImport != nil, @"Group_LastImport");
    NSAssert(Group_LastImportAdded != nil, @"Group_LastImportAdded");
    NSAssert(Group_ManualWaypoints != nil, @"Group_ManualWaypoints");

    [Containers enumerateObjectsUsingBlock:^(dbContainer *c, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([c.size isEqualToString:@"Unknown"] == YES) {
            Container_Unknown = c;
            *stop = YES;
        }
    }];
    // You cannot do this until the configuration files are loaded.
    // NSAssert(Container_Unknown != nil, @"Container_Unknown");

    [Types enumerateObjectsUsingBlock:^(dbType *ct, NSUInteger idx, BOOL *stop) {
        if ([ct.type_major isEqualToString:@"*"] == YES) {
            Type_Unknown = ct;
            *stop = YES;
        }
    }];
    if ([Types count] != 0)
        NSAssert(Type_Unknown != nil, @"Type_Unknown");

    [Pins enumerateObjectsUsingBlock:^(dbPin *pt, NSUInteger idx, BOOL *stop) {
        if ([pt.description isEqualToString:@"*"] == YES) {
            Pin_Unknown = pt;
            *stop = YES;
        }
    }];
    if ([Pins count] != 0)
        NSAssert(Pin_Unknown != nil, @"Pin_Unknown");

    [Symbols enumerateObjectsUsingBlock:^(dbSymbol *s, NSUInteger idx, BOOL *stop) {
        if ([s.symbol isEqualToString:@"*"] == YES) {
            Symbol_Unknown = s;
            *stop = YES;
        }
    }];
    if ([Symbols count] != 0)
        NSAssert(Symbol_Unknown != nil, @"Symbol_Unknown");

    [Attributes enumerateObjectsUsingBlock:^(dbAttribute *a, NSUInteger idx, BOOL *stop) {
        if ([a.label isEqualToString:@"Unknown"] == YES) {
            Attribute_Unknown = a;
            *stop = YES;
        }
    }];
    if ([Attributes count] != 0)
        NSAssert(Attribute_Unknown != nil, @"Attribute_Unknown");

    Names = [NSMutableDictionary dictionaryWithCapacity:200];
    [[dbName dbAll] enumerateObjectsUsingBlock:^(dbName *name, NSUInteger idx, BOOL * _Nonnull stop) {
        [Names setObject:name forKey:[NSNumber numberWithLongLong:name._id]];
    }];
}

- (dbType *)Type_get_byname:(NSString *)major minor:(NSString *)minor
{
    __block dbType *_ct = nil;
    [Types enumerateObjectsUsingBlock:^(dbType *ct, NSUInteger idx, BOOL *stop) {
        if ([ct.type_major isEqualToString:major] == YES &&
            [ct.type_minor isEqualToString:minor] == YES) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return Type_Unknown;
    return _ct;
}

- (dbType *)Type_get_byminor:(NSString *)minor
{
    __block dbType *_ct = nil;
    [Types enumerateObjectsUsingBlock:^(dbType *ct, NSUInteger idx, BOOL *stop) {
        if ([ct.type_minor isEqualToString:minor] == YES) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return Type_Unknown;
    return _ct;
}

- (dbType *)Type_get:(NSId)_id
{
    __block dbType *_ct = nil;
    [Types enumerateObjectsUsingBlock:^(dbType *ct, NSUInteger idx, BOOL *stop) {
        if (ct._id == _id) {
            _ct = ct;
            *stop = YES;
        }
    }];
    if (_ct == nil)
        return Type_Unknown;
    return _ct;
}

- (void)Type_add:(dbType *)type
{
    NSMutableArray *as = [NSMutableArray arrayWithArray:Types];
    [as addObject:type];
    Types = as;
}

- (dbPin *)Pin_get:(NSId)_id
{
    __block dbPin *_pt = nil;
    [Pins enumerateObjectsUsingBlock:^(dbPin *pt, NSUInteger idx, BOOL *stop) {
        if (pt._id == _id) {
            _pt = pt;
            *stop = YES;
        }
    }];
    if (_pt == nil)
        return Pin_Unknown;
    return _pt;
}

- (void)Pin_add:(dbPin *)pin
{
    NSMutableArray *as = [NSMutableArray arrayWithArray:Pins];
    [as addObject:pin];
    Pins = as;
}

- (dbSymbol *)Symbol_get_bysymbol:(NSString *)symbol
{
    __block dbSymbol *_lt = nil;
    [Symbols enumerateObjectsUsingBlock:^(dbSymbol *lt, NSUInteger idx, BOOL *stop) {
        if ([lt.symbol isEqualToString:symbol] == YES) {
            _lt = lt;
            *stop = YES;
        }
    }];
    if (_lt == nil)
        return Symbol_Unknown;
    return _lt;
}

- (dbSymbol *)Symbol_get:(NSId)_id
{
    __block dbSymbol *_lt = nil;
    [Symbols enumerateObjectsUsingBlock:^(dbSymbol *lt, NSUInteger idx, BOOL *stop) {
        if (lt._id == _id) {
            _lt = lt;
            *stop = YES;
        }
    }];
    if (_lt == nil)
        return Symbol_Unknown;
    return _lt;
}

- (void)Symbols_add:(NSId)_id symbol:(NSString *)symbol
{
    dbSymbol *cs = [[dbSymbol alloc] init:_id symbol:symbol];
    [Symbols addObject:cs];
}

- (dbLogString *)LogString_get_bytype:(dbAccount *)account logtype:(NSInteger)logtype type:(NSString *)type
{
    __block dbLogString *_ls = nil;
    [LogStrings enumerateObjectsUsingBlock:^(dbLogString *ls, NSUInteger idx, BOOL *stop) {
        if (ls.account == account &&
            ls.logtype == logtype &&
            [ls.text compare:type options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _ls = ls;
            *stop = YES;
        }
    }];
    return _ls;
}

- (dbLogString *)LogString_get:(NSId)_id
{
    __block dbLogString *_ls = nil;
    [LogStrings enumerateObjectsUsingBlock:^(dbLogString *ls, NSUInteger idx, BOOL *stop) {
        if (ls._id == _id) {
            _ls = ls;
            *stop = YES;
        }
    }];
    return _ls;
}

- (void)LogString_add:(dbLogString *)logstring
{
    NSMutableArray *as = [NSMutableArray arrayWithArray:LogStrings];
    [as addObject:logstring];
    LogStrings = as;
}

- (dbGroup *)Group_get:(NSId)_id
{
    __block dbGroup *_g = nil;
    [Groups enumerateObjectsUsingBlock:^(dbGroup *g, NSUInteger idx, BOOL *stop) {
        if (g._id == _id) {
            _g = g;
            *stop = YES;
        }
    }];
    return _g;
}

- (void)Group_add:(dbGroup *)group
{
    [Groups addObject:group];
}

- (void)Group_delete:(dbGroup *)group
{
    [Groups removeObject:group];
}

- (dbContainer *)Container_get:(NSId)_id
{
    __block dbContainer *_c = nil;
    [Containers enumerateObjectsUsingBlock:^(dbContainer *c, NSUInteger idx, BOOL *stop) {
        if (c._id == _id) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbContainer *)Container_get_bysize:(NSString *)size
{
    __block dbContainer *_c = nil;
    [Containers enumerateObjectsUsingBlock:^(dbContainer *c, NSUInteger idx, BOOL *stop) {
        if ([c.size isEqualToString:size] == YES) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbAttribute *)Attribute_get:(NSId)_id
{
    __block dbAttribute *_a = nil;
    [Attributes enumerateObjectsUsingBlock:^(dbAttribute *a, NSUInteger idx, BOOL *stop) {
        if (a._id == _id) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (dbAttribute *)Attribute_get_bygcid:(NSId)gcid
{
    __block dbAttribute *_a = nil;
    [Attributes enumerateObjectsUsingBlock:^(dbAttribute *a, NSUInteger idx, BOOL *stop) {
        if (a.gc_id == gcid) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (void)Attribute_add:(dbAttribute *)attr
{
    NSMutableArray *as = [NSMutableArray arrayWithArray:Attributes];
    [as addObject:attr];
    Attributes = as;
}

- (dbCountry *)Country_get_byNameCode:(NSString *)name
{
    __block dbCountry *_c = nil;
    [Countries enumerateObjectsUsingBlock:^(dbCountry *c, NSUInteger idx, BOOL *stop) {
        if ([c.name isEqualToString:name] == YES || [c.code isEqualToString:name] == YES) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (dbCountry *)Country_get:(NSId)_id
{
    __block dbCountry *_c = nil;
    [Countries enumerateObjectsUsingBlock:^(dbCountry *c, NSUInteger idx, BOOL *stop) {
        if (c._id == _id) {
            _c = c;
            *stop = YES;
        }
    }];
    return _c;
}

- (void)Country_add:(dbCountry *)country
{
    [Countries addObject:country];
}

- (dbState *)State_get_byNameCode:(NSString *)name
{
    __block dbState *_s = nil;
    [States enumerateObjectsUsingBlock:^(dbState *s, NSUInteger idx, BOOL *stop) {
        if ([s.name isEqualToString:name] == YES || [s.code isEqualToString:name] == YES) {
            _s = s;
            *stop = YES;
        }
    }];
    return _s;
}

- (dbState *)State_get:(NSId)_id
{
    __block dbState *_s = nil;
    [States enumerateObjectsUsingBlock:^(dbState *s, NSUInteger idx, BOOL *stop) {
        if (s._id == _id) {
            _s = s;
            *stop = YES;
        }
    }];
    return _s;
}

- (void)State_add:(dbState *)state
{
    [States addObject:state];
}

- (dbLocale *)Locale_get_byName:(NSString *)name
{
    __block dbLocale *_l = nil;
    [Locales enumerateObjectsUsingBlock:^(dbLocale *l, NSUInteger idx, BOOL *stop) {
        if ([l.name isEqualToString:name] == YES) {
            _l = l;
            *stop = YES;
        }
    }];
    return _l;
}

- (dbLocale *)Locale_get:(NSId)_id
{
    __block dbLocale *_l = nil;
    [Locales enumerateObjectsUsingBlock:^(dbLocale *l, NSUInteger idx, BOOL *stop) {
        if (l._id == _id) {
            _l = l;
            *stop = YES;
        }
    }];
    return _l;
}

- (void)Locale_add:(dbLocale *)l
{
    [Locales addObject:l];
}

- (void)AccountsReload
{
    NSMutableArray *newAccounts = [NSMutableArray arrayWithArray:[dbAccount dbAll]];

    [newAccounts enumerateObjectsUsingBlock:^(dbAccount *newAccount, NSUInteger idx, BOOL *stop) {
        __block BOOL found = NO;
        [Accounts enumerateObjectsUsingBlock:^(dbAccount *oldAccount, NSUInteger idx, BOOL *stop) {
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
            [Accounts addObject:newAccount];
    }];
}

- (dbAccount *)Account_get:(NSId)_id
{
    __block dbAccount *_a;
    [Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        if (a._id == _id) {
            _a = a;
            *stop = YES;
        }
    }];
    return _a;
}

- (dbName *)Name_get:(NSId)_id
{
    NSNumber *n = [NSNumber numberWithLongLong:_id];
    dbName *name = [Names objectForKey:n];
    return name;
}

- (void)Name_add:(dbName *)name
{
    NSNumber *n = [NSNumber numberWithLongLong:name._id];
    [Names setObject:name forKey:n];
}

@end
