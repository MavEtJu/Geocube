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

@interface ImportGeocube ()

@end

@implementation ImportGeocube

+ (BOOL)parse:(NSData *)data
{
    ImportGeocube *ig = [[ImportGeocube alloc] init];
    [ig parse:data];

    return YES;
}

- (BOOL)parse:(NSData *)XMLdata
{
    NSError *error;
    NSDictionary *d;
    BOOL okay = YES;

    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:XMLdata error:&error];
    if (xmlDictionary == nil)
        return NO;

    if ((d = [xmlDictionary objectForKey:@"notices"]) != nil)
        okay |= [self parseNotices:d];

    if ((d = [xmlDictionary objectForKey:@"config"]) != nil)
        xmlDictionary = d;
    if ((d = [xmlDictionary objectForKey:@"sites"]) != nil)
        okay |= [self parseSites:d];
    if ((d = [xmlDictionary objectForKey:@"keys"]) != nil)
        okay |= [self parseKeys:d];
    if ((d = [xmlDictionary objectForKey:@"externalmaps"]) != nil)
        okay |= [self parseExternalMaps:d];
    if ((d = [xmlDictionary objectForKey:@"attributes"]) != nil)
        okay |= [self parseAttributes:d];
    if ((d = [xmlDictionary objectForKey:@"countries"]) != nil)
        okay |= [self parseCountries:d];
    if ((d = [xmlDictionary objectForKey:@"states"]) != nil)
        okay |= [self parseStates:d];

    return okay;
}

- (BOOL)parseNotices:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_NOTICES];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_NOTICES;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *notices = [dict objectForKey:@"notice"];
    [notices enumerateObjectsUsingBlock:^(NSDictionary *notice, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *geocube_id = [notice objectForKey:@"id"];

#define KEY(__dict__, __var__, __key__) \
    NSString *__var__ = [[__dict__ objectForKey:__key__] objectForKey:@"text"]; \
    __var__ = [__var__ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        KEY(notice, note, @"note");
        KEY(notice, sender, @"sender");
        KEY(notice, date, @"date");

        dbNotice *n = [dbNotice dbGetByGCId:[geocube_id integerValue]];
        if (n == nil) {
            n = [[dbNotice alloc] init];
            n.geocube_id = [geocube_id integerValue];;
            n.seen = NO;
            n.sender = sender;
            n.date = date;
            n.note = note;
            [n dbCreate];
        } else {
            n.sender = sender;
            n.date = date;
            n.note = note;
            [n dbUpdate];
        }
    }];

    return YES;
}

- (BOOL)parseSites:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_SITES];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_SITES;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *sites = [dict objectForKey:@"site"];
    if ([sites isKindOfClass:[NSDictionary class]] == YES)
        sites = @[sites];
    [sites enumerateObjectsUsingBlock:^(NSDictionary *site, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *_id = [site objectForKey:@"id"];
        NSString *revision = [site objectForKey:@"revision"];
        NSString *_site = [site objectForKey:@"site"];
        NSString *enabled = [site objectForKey:@"enabled"];

        KEY(site, gca_authenticate_url, @"gca_authenticate_url");
        KEY(site, gca_callback_url, @"gca_callback_url");
        KEY(site, gca_cookie, @"gca_cookie");

        KEY(site, oauth_key_private, @"oauth_key_private");
        KEY(site, oauth_key_public, @"oauth_key_public");
        KEY(site, oauth_url_access, @"oauth_url_access");
        KEY(site, oauth_url_authorize, @"oauth_url_authorize");
        KEY(site, oauth_url_request, @"oauth_url_request");

        KEY(site, protocol, @"protocol");
        KEY(site, url_queries, @"queries");
        KEY(site, url_website, @"website");

        NSInteger protocol_id = ProtocolNone;
        if ([protocol isEqualToString:@"OKAPI"] == YES)
            protocol_id = ProtocolOKAPI;
        if ([protocol isEqualToString:@"GCA"] == YES)
            protocol_id = ProtocolGCA;
        if ([protocol isEqualToString:@"LiveAPI"] == YES)
            protocol_id = ProtocolLiveAPI;

        BOOL enabledBool = NO;
        if ([enabled isEqualToString:@"YES"] == YES)
            enabledBool = YES;

        dbAccount *a = [dbAccount dbGetBySite:_site];
        if (a == nil) {
            a = [[dbAccount alloc] init];
            a.site = _site;
            a.enabled = enabledBool;
            a.url_site = url_website;
            a.url_queries = url_queries;
            a.protocol = protocol_id;
            a.oauth_consumer_public = oauth_key_public;
            a.oauth_consumer_private = oauth_key_private;
            a.oauth_request_url = oauth_url_request;
            a.oauth_authorize_url = oauth_url_authorize;
            a.oauth_access_url = oauth_url_access;
            a.gca_cookie_name = gca_cookie;
            a.gca_authenticate_url = gca_authenticate_url;
            a.gca_callback_url = gca_callback_url;
            a.geocube_id = [_id integerValue];
            a.revision = [revision integerValue];
            [a dbCreate];
        } else {
            a.enabled = enabledBool;
            a.url_site = url_website;
            a.url_queries = url_queries;
            a.protocol = protocol_id;
            a.oauth_consumer_public = oauth_key_public;
            a.oauth_consumer_private = oauth_key_private;
            a.oauth_request_url = oauth_url_request;
            a.oauth_authorize_url = oauth_url_authorize;
            a.oauth_access_url = oauth_url_access;
            a.gca_cookie_name = gca_cookie;
            a.gca_authenticate_url = gca_authenticate_url;
            a.gca_callback_url = gca_callback_url;
            a.geocube_id = [_id integerValue];
            a.revision = [revision integerValue];
            [a dbUpdate];
        }
    }];

    return YES;
}

- (BOOL)parseKeys:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_KEYS];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_KEYS;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *keys = [dict objectForKey:@"key"];
    [keys enumerateObjectsUsingBlock:^(NSDictionary *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *site = [key objectForKey:@"site"];
        NSString *text = [key objectForKey:@"text"];
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([site isEqualToString:@"googlemaps"] == YES) {
            [myConfig keyGMSUpdate:text];
        }
        if ([site isEqualToString:@"mapbox"] == YES) {
            [myConfig keyMapboxUpdate:text];
        }
    }];

    return YES;
}

- (BOOL)parseExternalMaps:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_EXTERNALMAPS];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_EXTERNALMAPS;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *keys = [dict objectForKey:@"externalmap"];
    [keys enumerateObjectsUsingBlock:^(NSDictionary *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger gc_id = [[key objectForKey:@"id"] integerValue];
        NSString *enabled = [key objectForKey:@"enabled"];
        KEY(key, name, @"name");

        BOOL enabled_bool = NO;
        if ([enabled isEqualToString:@"YES"] == YES)
            enabled_bool = YES;

        dbExternalMap *em = [dbExternalMap dbGetByGeocubeID:gc_id];
        if (em == nil) {
            em = [[dbExternalMap alloc] init];
            em.name = name;
            em.geocube_id = gc_id;
            em.enabled = enabled_bool;
            em._id = [em dbCreate];
        } else {
            em.name = name;
            em.enabled = enabled_bool;
            [em dbUpdate];
        }
        [dbExternalMapURL dbDeleteByExternalMap:em._id];

        NSArray *urls = [key objectForKey:@"url"];
        [urls enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *model = [dict objectForKey:@"model"];
            NSInteger type = [[dict objectForKey:@"type"] integerValue];
            NSString *url = [dict objectForKey:@"text"];
            url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            dbExternalMapURL *emu = [[dbExternalMapURL alloc] init];
            emu.model = model;
            emu.externalMap_id = em._id;
            emu.url = url;
            emu.type = type;
            [emu dbCreate];
        }];

    }];

    return YES;
}

- (BOOL)parseAttributes:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_ATTRIBUTES];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_ATTRIBUTES;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *attrs = [dict objectForKey:@"attribute"];
    [attrs enumerateObjectsUsingBlock:^(NSDictionary *attr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger gc_id = [[attr objectForKey:@"gc_id"] integerValue];
        NSInteger icon = [[attr objectForKey:@"icon"] integerValue];
        NSString *label = [attr objectForKey:@"label"];

        dbAttribute *a = [dbc Attribute_get_bygcid:gc_id];
        if (a != nil) {
            a.label = label;
            a.icon = icon;
            [a dbUpdate];
        } else {
            a = [[dbAttribute alloc] init];
            a.gc_id = gc_id;
            a.label = label;
            a.icon = icon;
            [a dbCreate];
            [dbc Attribute_add:a];
        }
    }];

    return YES;
}

- (BOOL)parseStates:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_STATES];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_STATES;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *states = [dict objectForKey:@"state"];
    [states enumerateObjectsUsingBlock:^(NSDictionary *state, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *abbr = [state objectForKey:@"abbr"];
        NSString *name = [state objectForKey:@"name"];

        dbState *s = [dbc State_get_byName:name];
        if (s != nil) {
            s.code = abbr;
            s.name = name;
            [s dbUpdate];
        } else {
            s = [[dbState alloc] init];
            s.code = abbr;
            s.name = name;
            [s dbCreate];
            [dbc State_add:s];
        }
    }];

    return YES;
}

- (BOOL)parseCountries:(NSDictionary *)dict
{
    //NSNumber *version = [dict objectForKey:@"version"];   // Ignored for now
    NSString *revision = [dict objectForKey:@"revision"];

    dbConfig *currevision = [dbConfig dbGetByKey:KEY_REVISION_COUNTRIES];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = KEY_REVISION_COUNTRIES;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    NSArray *countries = [dict objectForKey:@"country"];
    [countries enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *abbr = [country objectForKey:@"abbr"];
        NSString *name = [country objectForKey:@"name"];

        dbCountry *c = [dbc Country_get_byName:name];
        if (c != nil) {
            c.code = abbr;
            c.name = name;
            [c dbUpdate];
        } else {
            c = [[dbCountry alloc] init];
            c.code = abbr;
            c.name = name;
            [c dbCreate];
            [dbc Country_add:c];
        }
    }];

    return YES;
}


@end