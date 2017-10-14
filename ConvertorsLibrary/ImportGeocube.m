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

@interface ImportGeocube ()

@end

@implementation ImportGeocube

/***************************************************
 * Do not use the database-cache inside this class *
 ***************************************************/

typedef NS_ENUM(NSInteger, Type) {
    TYPE_UNKNOWN = 0,
    TYPE_LOGTEMPLATESANDMACROS,
};

+ (BOOL)parse:(NSData *)data
{
    return [self parse:data infoViewer:nil iiImport:0];
}

+ (BOOL)parse:(NSData *)data infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    NSString *d = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 1)] encoding:NSASCIIStringEncoding];

    if ([d isEqualToString:@"<"] == YES) {
        // Assume XML
        ImportGeocube *ig = [[ImportGeocube alloc] init];
        return [ig parse:data infoViewer:iv iiImport:iii];
    }

    return [self parseFlatFile:data infoViewer:iv iiImport:iii];
}

+ (BOOL)parseFlatFile:(NSData *)data infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    NSString *d = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray<NSString *> *lines = [d componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    __block BOOL inBlock = NO;
    __block NSMutableString *block = nil;

    __block Type filetype = TYPE_UNKNOWN;

    __block dbLogTemplate *lt = nil;
    __block dbLogMacro *lm = nil;

    NSMutableArray<dbLogTemplate *> *lts = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray<dbLogMacro *> *lms = [NSMutableArray arrayWithCapacity:10];

    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([line length] > 0 && [[line substringToIndex:1] isEqualToString:@";"] == YES)
            return;

        NSArray<NSString *> *words = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([words count] == 1 && [[words objectAtIndex:0] isEqualToString:[self blockSeparator]] == YES) {
            if (inBlock == NO) {
                inBlock = YES;
                block = [NSMutableString stringWithString:@""];
                return;
            }

            if (filetype == TYPE_LOGTEMPLATESANDMACROS) {
                if (lm != nil) {
                    lm.text = block;
                    [lm finish];
                    [lms addObject:lm];
                    lm = nil;
                }
                if (lt != nil) {
                    lt.text = block;
                    [lt finish];
                    [lts addObject:lt];
                    lt = nil;
                }
            }

            inBlock = NO;
            block = nil;
            return;
        }

        if (inBlock == YES) {
            [block appendString:line];
            [block appendString:@"\n"];
            return;
        }

        if ([words count] == 0)
            return;

        NSString *key = [words objectAtIndex:0];
        if ([key isEqualToString:@"Version:"] == YES) {
            // All is fine for now.
            return;
        }

        if ([key isEqualToString:@"Type:"] == YES) {
            NSString *type = [words objectAtIndex:1];
            if ([type isEqualToString:@"LogTemplatesAndMacros"] == YES) {
                filetype = TYPE_LOGTEMPLATESANDMACROS;
                return;
            }

            // Happily ignore the rest
            filetype = TYPE_UNKNOWN;
            return;
        }

        if (filetype == TYPE_LOGTEMPLATESANDMACROS) {
            if ([key isEqualToString:@"Template"] == YES) {
                NSString *title = [[words subarrayWithRange:NSMakeRange(1, [words count] - 1)] componentsJoinedByString:@" "];
                words = [title componentsSeparatedByString:@"'"];
                if ([words count] >= 1)
                    title = [words objectAtIndex:1];
                lt = [[dbLogTemplate alloc] init];
                lt.name = title;
                return;
            }

            if ([key isEqualToString:@"Macro"] == YES) {
                NSString *title = [[words subarrayWithRange:NSMakeRange(1, [words count] - 1)] componentsJoinedByString:@" "];
                words = [title componentsSeparatedByString:@"'"];
                if ([words count] >= 1)
                    title = [words objectAtIndex:1];
                lm = [[dbLogMacro alloc] init];
                lm.name = title;
                return;
            }
        }
    }];

    if (filetype == TYPE_LOGTEMPLATESANDMACROS) {
        if ([lts count] != 0) {
            [dbLogTemplate dbDeleteAll];
            [lts enumerateObjectsUsingBlock:^(dbLogTemplate * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
                [lt dbCreate];
            }];
        }
        if ([lms count] != 0) {
            [dbLogMacro dbDeleteAll];
            [lms enumerateObjectsUsingBlock:^(dbLogMacro * _Nonnull lm, NSUInteger idx, BOOL * _Nonnull stop) {
                [lm dbCreate];
            }];
        }
    }

    return TRUE;
}

+ (NSString *)blockSeparator
{
    return @"-------------";
}

+ (NSString *)type_LogTemplatesAndMacros
{
    return @"LogTemplatesAndMacros";
}

- (BOOL)parse:(NSData *)XMLdata infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    NSError *error;
    NSDictionary *d;
    BOOL okay = YES;

    infoViewer = iv;
    iiImport = iii;

    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:XMLdata error:&error];
    if (xmlDictionary == nil)
        return NO;

    if ((d = [xmlDictionary objectForKey:@"notices"]) != nil)
        okay &= [self parseNotices:d];

    if ((d = [xmlDictionary objectForKey:@"config"]) != nil)
        xmlDictionary = d;
    if ((d = [xmlDictionary objectForKey:@"sites"]) != nil)
        okay &= [self parseSites:d];
    if ((d = [xmlDictionary objectForKey:@"externalmaps"]) != nil)
        okay &= [self parseExternalMaps:d];
    if ((d = [xmlDictionary objectForKey:@"attributes"]) != nil)
        okay &= [self parseAttributes:d];
    if ((d = [xmlDictionary objectForKey:@"countries"]) != nil)
        okay &= [self parseCountries:d];
    if ((d = [xmlDictionary objectForKey:@"states"]) != nil)
        okay &= [self parseStates:d];
    if ((d = [xmlDictionary objectForKey:@"types"]) != nil)
        okay &= [self parseTypes:d];
    if ((d = [xmlDictionary objectForKey:@"pins"]) != nil)
        okay &= [self parsePins:d];
    if ((d = [xmlDictionary objectForKey:@"bookmarks"]) != nil)
        okay &= [self parseBookmarks:d];
    if ((d = [xmlDictionary objectForKey:@"containers"]) != nil)
        okay &= [self parseContainers:d];
    if ((d = [xmlDictionary objectForKey:@"logstrings"]) != nil)
        okay &= [self parseLogStrings:d];
    if ((d = [xmlDictionary objectForKey:@"sqls"]) != nil)
        okay &= [self parseSQL:d];

    return okay;
}

- (BOOL)checkVersion:(NSDictionary *)dict version:(NSInteger)knownVersion revisionKey:(NSString *)revkey
{
    NSNumber *version = [dict objectForKey:@"version"];
    NSString *revision = [dict objectForKey:@"revision"];

    if ([version integerValue] != knownVersion) {
        NSLog(@"For %@: version retrieved was %@, while known version is %ld", revkey, version, (long)knownVersion);
        return NO;
    }

    dbConfig *currevision = [dbConfig dbGetByKey:revkey];
    if (currevision == nil) {
        currevision = [[dbConfig alloc] init];
        currevision.key = revkey;
        currevision.value = @"0";
        [currevision dbCreate];
    }
    if ([revision integerValue] != 0 &&
        [currevision.value isEqualToString:revision] == NO) {
        currevision.value = revision;
        [currevision dbUpdate];
    }

    return YES;
}

- (BOOL)parseNotices:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_NOTICES revisionKey:KEY_REVISION_NOTICES] == NO)
        return NO;

    NSArray<NSDictionary *> *notices = [dict objectForKey:@"notice"];
    [infoViewer setLineObjectTotal:iiImport total:[notices count] isLines:NO];

    if ([notices isKindOfClass:[NSDictionary class]] == YES)
        notices = @[notices];

    [notices enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull notice, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *geocube_id = [notice objectForKey:@"id"];
        [infoViewer setLineObjectCount:iiImport count:idx + 1];

#define KEY(__dict__, __var__, __key__) \
    NSString *__var__ = [[__dict__ objectForKey:__key__] objectForKey:@"text"]; \
    __var__ = [__var__ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#define KEYATTR(__dict__, __var__, __key__, __attr__) \
    NSString *__var__ = [[__dict__ objectForKey:__key__] objectForKey:__attr__]; \
    __var__ = [__var__ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        KEY(notice, note, @"note");
        KEY(notice, sender, @"sender");
        KEY(notice, date, @"date");
        KEY(notice, url, @"url");

        dbNotice *n = [dbNotice dbGetByGCId:[geocube_id integerValue]];
        if (n == nil) {
            n = [[dbNotice alloc] init];
            n.geocube_id = [geocube_id integerValue];
            n.seen = NO;
            n.sender = sender;
            n.date = date;
            n.note = note;
            n.url = url;
            [n dbCreate];
        } else {
            n.sender = sender;
            n.date = date;
            n.note = note;
            n.url = url;
            [n dbUpdate];
        }
    }];

    return YES;
}

- (BOOL)parseSites:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_SITES revisionKey:KEY_REVISION_SITES] == NO)
        return NO;

    NSArray<NSDictionary *> *sites = [dict objectForKey:@"site"];
    if ([sites isKindOfClass:[NSDictionary class]] == YES)
        sites = @[sites];
    [infoViewer setLineObjectTotal:iiImport total:[sites count] isLines:NO];
    [sites enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull site, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *_id = [site objectForKey:@"id"];
        NSString *revision = [site objectForKey:@"revision"];
        NSString *_site = [site objectForKey:@"site"];
        NSString *enabled = [site objectForKey:@"enabled"];
        NSString *hidden = [site objectForKey:@"hidden"];
        BOOL enabledBool = NO;
        if ([enabled isEqualToString:@"YES"] == YES)
            enabledBool = YES;

        KEY(site, gca_authenticate_url, @"gca_authenticate_url");
        KEY(site, gca_callback_url, @"gca_callback_url");
        KEY(site, gca_cookie, @"gca_cookie");

        KEY(site, oauth_key_private, @"oauth_key_private");
        KEYATTR(site, oauth_key_private_ss, @"oauth_key_private", @"sharedsecret");
        KEY(site, oauth_key_public, @"oauth_key_public");
        KEYATTR(site, oauth_key_public_ss, @"oauth_key_public", @"sharedsecret");
        KEY(site, oauth_url_access, @"oauth_url_access");
        KEY(site, oauth_url_authorize, @"oauth_url_authorize");
        KEY(site, oauth_url_request, @"oauth_url_request");

        if (oauth_key_private_ss != nil) {
            oauth_key_private = [keyManager decrypt:oauth_key_private_ss data:oauth_key_private];
            if (oauth_key_private == nil) {
                NSLog(@"Couldn't find oauth private key for %@. This means that EncryptionKeys.plist is missing data", oauth_key_private_ss);
                // To keep the program from crashing, disable this account.
                enabledBool = NO;
            }
        }
        if (oauth_key_public_ss != nil) {
            oauth_key_public = [keyManager decrypt:oauth_key_public_ss data:oauth_key_public];
            if (oauth_key_public == nil) {
                NSLog(@"Couldn't find oauth public key for %@. This means that EncryptionKeys.plist is missing data", oauth_key_public_ss);
                // To keep the program from crashing, disable this account.
                enabledBool = NO;
            }
        }

        KEY(site, protocol_string, @"protocol");
        KEY(site, url_queries, @"queries");
        KEY(site, url_website, @"website");
        KEY(site, distance, @"minimum_distance");

        dbProtocol *protocol = [dbProtocol dbGetByName:protocol_string];

        dbAccount *a = [dbAccount dbGetByGeocubeID:[_id integerValue]];
        if (a == nil) {
            a = [[dbAccount alloc] init];
            a.site = _site;
            a.enabled = enabledBool;
            a.url_site = url_website;
            a.url_queries = url_queries;
            a.protocol = protocol;
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
            a.distance_minimum = [distance integerValue];
            a.hidden = [hidden boolValue];
            [a finish];
            [a dbCreate];
        } else {
            a.enabled = enabledBool;
            a.site = _site;
            a.url_site = url_website;
            a.url_queries = url_queries;
            a.protocol = protocol;
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
            a.distance_minimum = [distance integerValue];
            a.hidden = [hidden boolValue];
            [a finish];
            [a dbUpdate];
        }
    }];

    return YES;
}

- (BOOL)parseExternalMaps:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_EXTERNALMAPS revisionKey:KEY_REVISION_EXTERNALMAPS] == NO)
        return NO;

    NSArray<NSDictionary *> *keys = [dict objectForKey:@"externalmap"];
    [infoViewer setLineObjectTotal:iiImport total:[keys count] isLines:NO];
    [keys enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [dbExternalMapURL dbDeleteByExternalMap:em];

        NSArray<NSDictionary *> *urls = [key objectForKey:@"url"];
        [urls enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *model = [dict objectForKey:@"model"];
            NSInteger type = [[dict objectForKey:@"type"] integerValue];
            NSString *url = [dict objectForKey:@"text"];
            url = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            dbExternalMapURL *emu = [[dbExternalMapURL alloc] init];
            emu.model = model;
            emu.externalMap = em;
            emu.url = url;
            emu.type = type;
            [emu dbCreate];
        }];

    }];

    return YES;
}

- (BOOL)parseAttributes:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_ATTRIBUTES revisionKey:KEY_REVISION_ATTRIBUTES] == NO)
        return NO;

    NSArray<NSDictionary *> *attrs = [dict objectForKey:@"attribute"];
    [infoViewer setLineObjectTotal:iiImport total:[attrs count] isLines:NO];
    [attrs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSInteger gc_id = [[attr objectForKey:@"gc_id"] integerValue];
        NSInteger icon = [[attr objectForKey:@"icon"] integerValue];
        NSString *label = [attr objectForKey:@"label"];

        dbAttribute *a = [dbAttribute dbGetByGCId:gc_id];
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
            [dbc attributeAdd:a];
        }
    }];

    return YES;
}

- (BOOL)parseStates:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_STATES revisionKey:KEY_REVISION_STATES] == NO)
        return NO;

    NSArray<NSDictionary *> *states = [dict objectForKey:@"state"];
    [infoViewer setLineObjectTotal:iiImport total:[states count] isLines:NO];
    [states enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull state, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *abbr = [state objectForKey:@"abbr"];
        NSString *name = [state objectForKey:@"name"];

        dbState *s = [dbState dbGetByNameCode:name];
        if (s != nil) {
            s.code = abbr;
            s.name = name;
            [s dbUpdate];
        } else {
            dbState *s = [[dbState alloc] init];
            s.name = name;
            s.code = abbr;
            [s dbCreate];
            [dbc stateAdd:s];
        }
    }];

    return YES;
}

- (BOOL)parseCountries:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_COUNTRIES revisionKey:KEY_REVISION_COUNTRIES] == NO)
        return NO;

    NSArray<NSDictionary *> *countries = [dict objectForKey:@"country"];
    [infoViewer setLineObjectTotal:iiImport total:[countries count] isLines:NO];
    [countries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull country, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *abbr = [country objectForKey:@"abbr"];
        NSString *name = [country objectForKey:@"name"];

        dbCountry *c = [dbCountry dbGetByCountry:name];
        if (c != nil) {
            c.code = abbr;
            c.name = name;
            [c dbUpdate];
        } else {
            c = [[dbCountry alloc] init];
            c.name = name;
            c.code = abbr;
            [c dbCreate];
            [dbc countryAdd:c];
        }
    }];

    return YES;
}

- (BOOL)parseTypes:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_TYPES revisionKey:KEY_REVISION_TYPES] == NO)
        return NO;

    NSArray<NSDictionary *> *types = [dict objectForKey:@"type"];
    [infoViewer setLineObjectTotal:iiImport total:[types count] isLines:NO];
    [types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *major = [type objectForKey:@"major"];
        NSString *minor = [type objectForKey:@"minor"];
        NSInteger icon = [[type objectForKey:@"icon"] integerValue];
        NSInteger pin = [[type objectForKey:@"pin"] integerValue];
        NSString *b = [type objectForKey:@"hasBoundary"];
        BOOL hasBoundary = NO;
        if (b != nil)
            hasBoundary = [b boolValue];

        dbType *t = [dbType dbGetByMajor:major minor:minor];
        if (t != nil) {
            t.type_major = major;
            t.type_minor = minor;
            t.icon = icon;
            t.pin = [dbPin dbGet:pin];
            t.hasBoundary = hasBoundary;
            [t finish];
            [t dbUpdate];
        } else {
            t = [[dbType alloc] init];
            t.type_major = major;
            t.type_minor = minor;
            t.icon = icon;
            t.pin = [dbPin dbGet:pin];
            t.hasBoundary = hasBoundary;
            [t finish];
            [t dbCreate];
            [dbc typeAdd:t];
        }
    }];

    return YES;
}

- (BOOL)parsePins:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_PINS revisionKey:KEY_REVISION_PINS] == NO)
        return NO;

    NSArray<NSDictionary *> *pins = [dict objectForKey:@"pin"];
    [infoViewer setLineObjectTotal:iiImport total:[pins count] isLines:NO];
    [pins enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull pin, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *description = [pin objectForKey:@"description"];
        NSString *rgb = [pin objectForKey:@"rgb"];
        NSInteger _id = [[pin objectForKey:@"id"] integerValue];

        dbPin *p = [dbPin dbGet:_id];
        if (p != nil) {
            p.desc = description;
            p._id = _id;
            p.rgb_default = rgb;
            [p finish];
            [p dbUpdate];
        } else {
            p = [[dbPin alloc] init];
            p.desc = description;
            p._id = _id;
            p.rgb_default = rgb;
            p.rgb = @"";
            [p finish];
            [p dbCreate];
            [dbc pinAdd:p];
        }
    }];

    return YES;
}

- (BOOL)parseBookmarks:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_BOOKMARKS revisionKey:KEY_REVISION_BOOKMARKS] == NO)
        return NO;

    NSArray<NSDictionary *> *bookmarks = [dict objectForKey:@"bookmark"];
    [infoViewer setLineObjectTotal:iiImport total:[bookmarks count] isLines:NO];
    [bookmarks enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull bookmark, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *description = [bookmark objectForKey:@"description"];
        NSString *url = [bookmark objectForKey:@"url"];
        NSInteger import_id = [[bookmark objectForKey:@"id"] integerValue];

        dbBookmark *bm = [dbBookmark dbGetByImport:import_id];
        if (bm != nil) {
            bm.name = description;
            bm.url = url;
            bm.import = [dbFileImport dbGet:import_id];
            [bm finish];
            [bm dbUpdate];
        } else {
            bm = [[dbBookmark alloc] init];
            bm.name = description;
            bm.url = url;
            bm.import = [dbFileImport dbGet:import_id];
            [bm dbCreate];
        }
    }];

    return YES;
}

- (BOOL)parseContainers:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_CONTAINERS revisionKey:KEY_REVISION_CONTAINERS] == NO)
        return NO;

    NSArray<NSDictionary *> *containers = [dict objectForKey:@"container"];
    [infoViewer setLineObjectTotal:iiImport total:[containers count] isLines:NO];
    [containers enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull container, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *label = [container objectForKey:@"label"];
        NSInteger gc_id = [[container objectForKey:@"gc_id"] integerValue];
        NSInteger icon = [[container objectForKey:@"icon"] integerValue];

        dbContainer *c = [dbContainer dbGetByGCID:gc_id];
        if (c != nil) {
            c.size = label;
            c.gc_id = gc_id;
            c.icon = icon;
            [c finish];
            [c dbUpdate];
        } else {
            c = [[dbContainer alloc] init];
            c.size = label;
            c.gc_id = gc_id;
            c.icon = icon;
            [c dbCreate];
        }
    }];

    return YES;
}

- (BOOL)parseLogStrings:(NSDictionary *)dict
{
    if ([self checkVersion:dict version:KEY_VERSION_LOGSTRINGS revisionKey:KEY_REVISION_LOGSTRINGS] == NO)
        return NO;

    NSArray<NSDictionary *> *protocols = [dict objectForKey:@"protocol"];
    [infoViewer setLineObjectTotal:iiImport total:[protocols count] isLines:NO];
    [protocols enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull protocoldict, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoViewer setLineObjectCount:iiImport count:idx + 1];
        NSString *protocol_name = [protocoldict objectForKey:@"name"];
        dbProtocol *_protocol = [dbProtocol dbGetByName:protocol_name];

//        NSString *see = [protocoldict objectForKey:@"see"];
//        if (see != nil) {
//            // Copy everything from $see to $account_name
//            dbAccount *seeAccount = [dbAccount dbGetBySite:see];
//            NSAssert1(seeAccount != nil, @"Unknown account: '%@'", see);
//
//            NSArray<dbLogString *> *as = [dbLogString dbAllByAccount:seeAccount];
//
//            [as enumerateObjectsUsingBlock:^(dbLogString * _Nonnull lsOriginal, NSUInteger idx, BOOL * _Nonnull stop) {
//                dbLogString *lsReplicate = [dbLogString dbGet_byAccountLogtypeType:_account logtype:lsOriginal.logtype type:lsOriginal.type];
//
//                lsOriginal.account = _account;
//                lsOriginal.account_id = _account._id;
//                if (lsReplicate == nil) {
//                    lsOriginal._id = 0;
//                    [lsOriginal dbCreate];
//                } else {
//                    lsOriginal._id = lsReplicate._id;
//                    [lsOriginal dbUpdate];
//                }
//
//            }];
//
//            return;
//        }

        NSArray<NSDictionary *> *logtypes = [protocoldict objectForKey:@"log"];
        if ([logtypes isKindOfClass:[NSDictionary class]] == YES)
            logtypes = @[logtypes];
        [logtypes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull logdict, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString *displaystring = [logdict objectForKey:@"displaystring"];
            NSString *logstring = [logdict objectForKey:@"logstring"];
            NSInteger icon = [[logdict objectForKey:@"icon"] integerValue];
            NSString *forlogs = [logdict objectForKey:@"forlogs"];
            NSString *dflt = [logdict objectForKey:@"default"];
            NSString *_found = [logdict objectForKey:@"found"];
            BOOL defaultNote = ([dflt isEqualToString:@"note"] == YES);
            BOOL defaultFound = ([dflt isEqualToString:@"found"] == YES);
            BOOL defaultVisit = ([dflt isEqualToString:@"visit"] == YES);
            BOOL defaultDropoff = ([dflt isEqualToString:@"dropoff"] == YES);
            BOOL defaultPickup = ([dflt isEqualToString:@"pickup"] == YES);
            BOOL defaultDiscover = ([dflt isEqualToString:@"discover"] == YES);
            BOOL defaultDNF = ([dflt isEqualToString:@"dnf"] == YES);

            LogStringFound found = LOGSTRING_FOUND_NA;
            if (_found != nil) {
                if ([_found isEqualToString:@"yes"] == YES)
                    found = LOGSTRING_FOUND_YES;
                if ([_found isEqualToString:@"no"] == YES)
                    found = LOGSTRING_FOUND_NO;
            }

            dbLogString *ls = [dbLogString dbGetByProtocolDisplayString:_protocol displayString:displaystring];
            if (ls == nil) {
                ls = [[dbLogString alloc] init];
                ls.displayString = displaystring;
                ls.logString = logstring;
                ls.protocol = _protocol;
                ls.defaultNote = defaultNote;
                ls.defaultFound = defaultFound;
                ls.defaultVisit = defaultVisit;
                ls.defaultDropoff = defaultDropoff;
                ls.defaultPickup = defaultPickup;
                ls.defaultDiscover = defaultDiscover;
                ls.defaultDNF = defaultDNF;
                ls.icon = icon;
                ls.found = found;
                [ls dbCreate];
            } else {
                ls.displayString = displaystring;
                ls.defaultNote = defaultNote;
                ls.defaultFound = defaultFound;
                ls.defaultVisit = defaultVisit;
                ls.defaultDropoff = defaultDropoff;
                ls.defaultPickup = defaultPickup;
                ls.defaultDiscover = defaultDiscover;
                ls.defaultDNF = defaultDNF;
                ls.icon = icon;
                ls.found = found;
                [ls dbUpdate];
            }

            [dbLogStringWaypoint dbDeleteAllByLogString:ls];

            [[forlogs componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull forlog, NSUInteger idx, BOOL * _Nonnull stop) {
                LogStringWPType wptype = [dbLogString stringToWPtype:forlog];
                dbLogStringWaypoint *lswp = [dbLogStringWaypoint dbGetByLogStringWPType:ls wptype:wptype];
                if (lswp == nil) {
                    lswp = [[dbLogStringWaypoint alloc] init];
                    lswp.wptype = wptype;
                    lswp.logString = ls;
                    [lswp dbCreate];
                } else {
                    lswp.wptype = wptype;
                    lswp.logString = ls;
                    [lswp dbUpdate];
                }
            }];

        }];
    }];

    return YES;
}

- (BOOL)parseSQL:(NSDictionary *)dict
{
    NSObject *sqls = [dict objectForKey:@"sql"];
    if ([sqls isKindOfClass:[NSDictionary class]] == YES) {
        NSString *sql = [[(NSDictionary *)sqls objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [db singleStatement:sql];
    }
    if ([sqls isKindOfClass:[NSArray class]] == YES) {
        [(NSArray *)sqls enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull sqldict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *sql = [[sqldict objectForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [db singleStatement:sql];
        }];
    }

    return YES;
}

@end
