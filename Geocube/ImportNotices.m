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

@implementation ImportNotices

- (instancetype)init
{
    self = [super init];

    note = nil;
    sender = nil;
    date = nil;
    geocube_id = 0;

    return self;
}

+ (void)parse:(NSData *)data
{
    ImportNotices *in = [[ImportNotices alloc] init];
    [in parse:data];
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
    if ([elementName isEqualToString:@"notices"] == YES) {
        version = [attributeDict objectForKey:@"version"];
        revision = [attributeDict objectForKey:@"revision"];

        dbConfig *currevision = [dbConfig dbGetByKey:@"notices_revision"];
        if (currevision == nil) {
            currevision = [[dbConfig alloc] init];
            currevision.key = @"notices_revision";
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

    if ([elementName isEqualToString:@"notice"] == YES) {
        NSString *geocube_idStr = [attributeDict objectForKey:@"id"];
        note = nil;
        sender = nil;
        date = nil;
        geocube_id = [geocube_idStr integerValue];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"note"] == YES) {
        note = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }
    if ([elementName isEqualToString:@"sender"] == YES) {
        sender = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }

    if ([elementName isEqualToString:@"date"] == YES) {
        date = [currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        goto bye;
    }

    if ([elementName isEqualToString:@"notice"] == YES) {
        dbNotice *n = [dbNotice dbGetByGCId:geocube_id];
        if (n == nil) {
            n = [[dbNotice alloc] init];
            n.geocube_id = geocube_id;
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
