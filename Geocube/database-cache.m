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

@synthesize Accounts, Types, Groups, LogTypes, Containers, Attributes, Countries, States;
@synthesize Group_AllWaypoints, Group_AllWaypoints_Found, Group_AllWaypoints_Attended, Group_AllWaypoints_NotFound, Group_AllWaypoints_ManuallyAdded, Group_LastImport,Group_LastImportAdded, Type_Unknown, LogType_Unknown, Container_Unknown, Attribute_Unknown, Symbols, LogType_Found, LogType_Attended, LogType_NotFound;

- (id)init
{
    self = [super init];
    [self loadWaypointData];
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadWaypointData
{
    Accounts = [NSMutableArray arrayWithArray:[dbAccount dbAll]];
    Groups = [dbGroup dbAll];
    Types = [dbType dbAll];
    Containers = [dbContainer dbAll];
    LogTypes = [dbLogType dbAll];
    Containers = [dbContainer dbAll];
    Attributes = [dbAttribute dbAll];
    Symbols = [NSMutableArray arrayWithArray:[dbSymbol dbAll]];
    Countries = [NSMutableArray arrayWithArray:[dbCountry dbAll]];
    States = [NSMutableArray arrayWithArray:[dbState dbAll]];

    Group_AllWaypoints = nil;
    Group_AllWaypoints_Found = nil;
    Group_AllWaypoints_Attended = nil;
    Group_AllWaypoints_NotFound = nil;
    Group_AllWaypoints_ManuallyAdded = nil;
    Group_LastImport = nil;
    Group_LastImportAdded = nil;
    Type_Unknown = nil;
    Container_Unknown = nil;
    LogType_Unknown = nil;

    [Groups enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"All Waypoints"] == YES) {
            Group_AllWaypoints = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"All Waypoints - Attended"] == YES) {
            Group_AllWaypoints_Attended = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"All Waypoints - Found"] == YES) {
            Group_AllWaypoints_Found = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"All Waypoints - Not Found"] == YES) {
            Group_AllWaypoints_NotFound = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"All Waypoints - Manually entered"] == YES) {
            Group_AllWaypoints_ManuallyAdded = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"Last Import"] == YES) {
            Group_LastImport = cg;
            return;
        }
        if (cg.usergroup == 0 && [cg.name isEqualToString:@"Last Import - New"] == YES) {
            Group_LastImportAdded = cg;
            return;
        }
    }];
    NSAssert(Group_AllWaypoints != nil, @"Group_AllWaypoints");
    NSAssert(Group_AllWaypoints_Found != nil, @"Group_AllWaypoints_Found");
    NSAssert(Group_AllWaypoints_Attended != nil, @"Group_AllWaypoints_Attended");
    NSAssert(Group_AllWaypoints_NotFound != nil, @"Group_AllWaypoints_NotFound");
    NSAssert(Group_AllWaypoints_ManuallyAdded != nil, @"Group_AllWaypoints_ManuallyAdded");
    NSAssert(Group_LastImport != nil, @"Group_LastImport");
    NSAssert(Group_LastImportAdded != nil, @"Group_LastImportAdded");

    [Types enumerateObjectsUsingBlock:^(dbType *ct, NSUInteger idx, BOOL *stop) {
        if ([ct.type_major isEqualToString:@"*"] == YES) {
            Type_Unknown = ct;
            *stop = YES;
        }
    }];
    NSAssert(Type_Unknown != nil, @"Type_Unknown");

    [LogTypes enumerateObjectsUsingBlock:^(dbLogType *lt, NSUInteger idx, BOOL *stop) {
        if ([lt.logtype isEqualToString:@"Unknown"] == YES) {
            LogType_Unknown = lt;
            return;
        }
        if ([lt.logtype isEqualToString:@"Found it"] == YES) {
            LogType_Found = lt;
            return;
        }
        if ([lt.logtype isEqualToString:@"Attended"] == YES) {
            LogType_Attended = lt;
            return;
        }
        if ([lt.logtype isEqualToString:@"Didn't find it"] == YES) {
            LogType_NotFound = lt;
            return;
        }
    }];
    NSAssert(LogType_Unknown != nil, @"LogType_Unknown");
    NSAssert(LogType_Attended != nil, @"LogType_Attended");
    NSAssert(LogType_NotFound != nil, @"LogType_NotFound");
    NSAssert(LogType_Found != nil, @"LogType_Found");

    [Attributes enumerateObjectsUsingBlock:^(dbAttribute *a, NSUInteger idx, BOOL *stop) {
        if ([a.label isEqualToString:@"Unknown"] == YES) {
            Attribute_Unknown = a;
            *stop = YES;
        }
    }];
    NSAssert(Attribute_Unknown != nil, @"Attribute_Unknown");

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
    return _ct;
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
    return _lt;
}

- (void)Symbols_add:(NSId)_id symbol:(NSString *)symbol
{
    dbSymbol *cs = [[dbSymbol alloc] init:_id symbol:symbol];
    [Symbols addObject:cs];
}

- (dbLogType *)LogType_get_bytype:(NSString *)type
{
    __block dbLogType *_lt = nil;
    [LogTypes enumerateObjectsUsingBlock:^(dbLogType *lt, NSUInteger idx, BOOL *stop) {
        if ([lt.logtype isEqualToString:type] == YES) {
            _lt = lt;
            *stop = YES;
        }
    }];
    return _lt;
}

- (dbLogType *)LogType_get:(NSId)_id
{
    __block dbLogType *_lt = nil;
    [LogTypes enumerateObjectsUsingBlock:^(dbLogType *lt, NSUInteger idx, BOOL *stop) {
        if (lt._id == _id) {
            _lt = lt;
            *stop = YES;
        }
    }];
    return _lt;
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

- (dbCountry *)Country_get_byName:(NSString *)name
{
    __block dbCountry *_c = nil;
    [Countries enumerateObjectsUsingBlock:^(dbCountry *c, NSUInteger idx, BOOL *stop) {
        if ([c.name isEqualToString:name] == YES) {
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

- (dbState *)State_get_byName:(NSString *)name
{
    __block dbState *_s = nil;
    [States enumerateObjectsUsingBlock:^(dbState *s, NSUInteger idx, BOOL *stop) {
        if ([s.name isEqualToString:name] == YES) {
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

@end
