//
//  Import_GPX.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Import_GPX.h"

@implementation Import_GPX

- (void) parse:(NSData *)data
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];
    
    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
    
    index = 0;
    inItem = 0;
    [rssParser parse];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString * errorString = [NSString stringWithFormat:@"Planet FreeBSD Parser error (Error code %i)", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
    currentText = nil;
    index++;
    
    if ([currentElement compare:@"entry"] == NSOrderedSame) {
        currentItem = [[PFBObject alloc] init];
        [items addObject:currentItem];
        inItem = TRUE;
    }
    if (index == 3 && [elementName compare:@"link"] == NSOrderedSame) {
        NSString *rel = [attributeDict objectForKey:@"rel"];
        if ([rel compare:@"alternate"] == NSOrderedSame) {
            [currentItem setLink:[attributeDict objectForKey:@"href"]];
            return;
        }
    }
    
    return;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    index--;
    
    [currentText replaceOccurrencesOfRegex:@"\\s+" withString:@" "];
    
    if (inItem) {
        if (index == 2 && [elementName compare:@"title"] == NSOrderedSame && currentText != nil) {
            [currentItem setTitle:currentText];
            return;
        }
        if (index == 3 && [elementName compare:@"name"] == NSOrderedSame && currentText != nil) {
            [currentItem setName:currentText];
            return;
        }
        if (index == 2 && [elementName compare:@"summary"] == NSOrderedSame && currentText != nil) {
            [currentItem setDescription:currentText];
            return;
        }
        if (index == 2 && [elementName compare:@"published"] == NSOrderedSame && currentText != nil) {
            [currentItem setPubdate:currentText];
            return;
        }
        
        if ([elementName compare:@"entry"] == NSOrderedSame) {
            inItem = FALSE;
            [currentItem fillup];
            return;
        }
        
    }
    
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
    return;
}

@end
