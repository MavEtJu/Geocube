//
//  Import_GPX.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Geocube.h"
#import "Import_GPX.h"
#import "SSZipArchive.h"
#import "My Tools.h"

@implementation Import_GPX

- (id)init:(NSString *)filename group:(NSString *)_groupname
{
    groupname = _groupname;
    group = [db WaypointGroups_get_byName:groupname];

    NSMutableArray *_files = [[NSMutableArray alloc] initWithCapacity:20];

    NSLog(@"Import_GPX: Importing %@", filename);
    
    if ([[filename pathExtension] compare:@"zip"] == NSOrderedSame) {
        NSString *destdir = [[NSString alloc] initWithFormat:@"%@/Import_GPX", [MyTools DocumentRoot]];
        NSString *destfile = [[NSString alloc] initWithFormat:@"%@/%@", destdir, @"temp.data"];

        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:destdir error:nil];

        BOOL isdir = false;
        if ([fm fileExistsAtPath:destdir isDirectory:&isdir] == NO)
            [fm createDirectoryAtPath:destdir withIntermediateDirectories:YES attributes:nil error:nil];
        
        [SSZipArchive unzipFileAtPath:filename toDestination:destfile];
        NSLog(@"Unzipping to %@", destfile);
        
        NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:destdir];
        NSString *file;
        while ((file = [dirEnum nextObject]) != nil) {
            if ([[file pathExtension] isEqualToString: @"gpx"]) {
                NSLog(@"found file : %@/%@", destdir, file);
                [_files addObject:[NSString stringWithFormat:@"%@/%@", destdir, file]];
            }
        }
        
        //[fm removeItemAtPath:destdir error:nil];
    } else {
        [_files addObject:filename];
    }
    
    files = _files;
    NSLog(@"Found %ld files", [_files count]);
    return self;
}

- (void)parse
{
    NSEnumerator *eFile = [files objectEnumerator];
    NSString *filename;
    while ((filename = [eFile nextObject]) != nil) {
        NSLog(@"Parsing %@", filename);
        [self parseOne:filename];
    }
    
}

- (void)parseOne:(NSString *)filename
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
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
    NSString * errorString = [NSString stringWithFormat:@"Import_GPX error (Error code %ld)", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
    currentText = nil;
    index++;
    
    if ([currentElement compare:@"wpt"] == NSOrderedSame) {
        currentWP = [[dbObjectWaypoint alloc] init];
        [currentWP setLat:[attributeDict objectForKey:@"lat"]];
        [currentWP setLon:[attributeDict objectForKey:@"lon"]];
        
        //[items addObject:currentItem];
        inItem = TRUE;
    }
    
    return;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    index--;
    
    [currentText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [currentText length])];
    
    if (index == 1 && [elementName compare:@"wpt"] == NSOrderedSame) {
        [currentWP setLat_float:[currentWP.lat doubleValue]];
        [currentWP setLon_float:[currentWP.lon doubleValue]];
        [currentWP setLat_int:currentWP.lat_float * 1000000];
        [currentWP setLon_int:currentWP.lon_float * 1000000];
        
        [currentWP setWp_group:group];
        [currentWP setWp_group_int:group._id];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:[currentWP.date_placed substringWithRange:NSMakeRange(0, 19)]];
        [currentWP setDate_placed_epoch:[date timeIntervalSince1970]];
        goto bye;
    }
    if (inItem) {
        if (index == 2 && currentText != nil) {
            if ([elementName compare:@"time"] == NSOrderedSame) {
                [currentWP setDate_placed:currentText];
                goto bye;
            }
            if ([elementName compare:@"name"] == NSOrderedSame) {
                [currentWP setName:currentText];
                goto bye;
            }
            if ([elementName compare:@"desc"] == NSOrderedSame) {
                [currentWP setDescription:currentText];
                goto bye;
            }
            if ([elementName compare:@"url"] == NSOrderedSame) {
                [currentWP setUrl:currentText];
                goto bye;
            }
            if ([elementName compare:@"type"] == NSOrderedSame) {
                [currentWP setWp_type:nil];
                goto bye;
            }
        }
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
    return;
}

@end
