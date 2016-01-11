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

@interface ImportSites ()
{
    NSString *version;
    NSString *revision;
    NSString *site_revision;
    NSString *site_id;

    dbAccount *account;

    NSString *key;

    NSString *site;
    NSMutableString *currentText;
}

@end

@implementation ImportSites

- (instancetype)init
{
    self = [super init];

    version = nil;
    revision = nil;

    site = nil;
    account = nil;

    key = nil;

    return self;
}

+ (void)parse:(NSData *)data
{
    ImportSites *il = [[ImportSites alloc] init];
    [il parse:data];
}

- (void)parse:(NSData *)data
{
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];

    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];

    [rssParser parse];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString * errorString = [NSString stringWithFormat:@"%@ error (Error code %ld)", [self class], (long)[parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{

    if ([elementName isEqualToString:@"config"] == YES) {
        version = [attributeDict objectForKey:@"version"];
        revision = [attributeDict objectForKey:@"revision"];

        dbConfig *currevision = [dbConfig dbGetByKey:@"config_revision"];
        if (currevision == nil) {
            currevision = [[dbConfig alloc] init];
            currevision.key = @"config_revision";
            currevision.value = @"0";
            [currevision dbCreate];
        }

        // Just store it.
        if ([currevision.value isEqualToString:revision] == NO) {
            currevision.value = revision;
            [currevision dbUpdate];
        }
        return;
    }

    if ([elementName isEqualToString:@"keys"] == YES) {
        version = [attributeDict objectForKey:@"version"];
        revision = [attributeDict objectForKey:@"revision"];

        dbConfig *currevision = [dbConfig dbGetByKey:@"keys_revision"];
        if (currevision == nil) {
            currevision = [[dbConfig alloc] init];
            currevision.key = @"keys_revision";
            currevision.value = @"0";
            [currevision dbCreate];
        }

        // Just store it.
        if ([currevision.value isEqualToString:revision] == NO) {
            currevision.value = revision;
            [currevision dbUpdate];
        }
        return;
    }

    if ([elementName isEqualToString:@"sites"] == YES) {
        version = [attributeDict objectForKey:@"version"];
        revision = [attributeDict objectForKey:@"revision"];

        dbConfig *currevision = [dbConfig dbGetByKey:@"sites_revision"];
        if (currevision == nil) {
            currevision = [[dbConfig alloc] init];
            currevision.key = @"sites_revision";
            currevision.value = @"0";
            [currevision dbCreate];
        }

        // Just store it.
        if ([currevision.value isEqualToString:revision] == NO) {
            currevision.value = revision;
            [currevision dbUpdate];
        }
        return;
    }

    if ([elementName isEqualToString:@"site"] == YES) {
        site = [attributeDict objectForKey:@"site"];
        site_id = [attributeDict objectForKey:@"id"];
        site_revision = [attributeDict objectForKey:@"revision"];
        account = [dbAccount dbGetBySite:site];
        if (account == nil)
            account = [[dbAccount alloc] init];
        account.geocube_id = [site_id integerValue];
        account.revision = [site_revision integerValue];
        account.site = site;
        return;
    }

    if ([elementName isEqualToString:@"key"] == YES) {
        site = [attributeDict objectForKey:@"site"];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"website"] == YES) {
        account.url_site = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"queries"] == YES) {
        account.url_queries = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }

    if ([elementName isEqualToString:@"oauth_key_private"] == YES) {
        account.oauth_consumer_private = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"oauth_key_public"] == YES) {
        account.oauth_consumer_public = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"oauth_url_request"] == YES) {
        account.oauth_request_url = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"oauth_url_authorize"] == YES) {
        account.oauth_authorize_url = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"oauth_url_access"] == YES) {
        account.oauth_access_url = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }

    if ([elementName isEqualToString:@"gca_cookie"] == YES) {
        account.gca_cookie_name = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"gca_authenticate_url"] == YES) {
        account.gca_authenticate_url = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"gca_callback_url"] == YES) {
        account.gca_callback_url = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"protocol"] == YES) {
        NSString *protocol = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        account.protocol = ProtocolNone;
        if ([protocol isEqualToString:@"OKAPI"] == YES)
            account.protocol = ProtocolOKAPI;
        if ([protocol isEqualToString:@"GCA"] == YES)
            account.protocol = ProtocolGCA;
        if ([protocol isEqualToString:@"LiveAPI"] == YES)
            account.protocol = ProtocolLiveAPI;

        goto bye;
    }

    if ([elementName isEqualToString:@"key"] == YES) {
        NSString *k = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([site isEqualToString:@"googlemaps"] == YES) {
            [myConfig keyGMSUpdate:k];
            goto bye;
        }
        if ([site isEqualToString:@"mapbox"] == YES) {
            [myConfig keyMapboxUpdate:k];
            goto bye;
        }
        goto bye;
    }

    if ([elementName isEqualToString:@"site"] == YES) {
        if (account._id == 0)
            [account dbCreate];
        else
            [account dbUpdate];

        goto bye;
    }

bye:
    currentText = nil;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (string == nil)
        return;
    if (currentText == nil)
        currentText = [[NSMutableString alloc] initWithString:string];
    else
        [currentText appendString:string];
}

@end
