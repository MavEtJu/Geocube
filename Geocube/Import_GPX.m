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

    NSLog(@"Import_GPX: Importing %@", filename);
    
    files = @[filename];
    NSLog(@"Found %ld files", [files count]);
    return self;
}

- (void)parse
{
    [db WaypointGroups_empty:dbc.WaypointGroup_LastImport._id ];
    [db WaypointGroups_empty:dbc.WaypointGroup_LastImportAdded._id ];

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
        
        NSInteger cwp_id = [db Waypoint_get_byname:currentWP.name];
        if (cwp_id == 0) {
            cwp_id = [db Waypoint_add:currentWP];
            [db WaypointGroups_add_waypoint:dbc.WaypointGroup_LastImportAdded._id waypoint_id:cwp_id];
            [db WaypointGroups_add_waypoint:dbc.WaypointGroup_AllWaypoints._id waypoint_id:cwp_id];
            [db WaypointGroups_add_waypoint:group._id waypoint_id:cwp_id];
        } else {
            [db Waypoint_update:currentWP];
            if ([db WaypointGroups_contains_waypoint:group._id waypoint_id:cwp_id] == NO)
                [db WaypointGroups_add_waypoint:group._id waypoint_id:cwp_id];
        }
        [db WaypointGroups_add_waypoint:dbc.WaypointGroup_LastImport._id waypoint_id:cwp_id];

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
                [currentWP setWp_type:[dbc waypointType_get_byname:currentText]];
                [currentWP setWp_type_int:currentWP.wp_type._id];
                goto bye;
            }
            goto bye;
        }
        if (index == 3 && currentText != nil) {
            if ([elementName compare:@"groundspeak:difficulty"] == NSOrderedSame) {
                [currentWP setRating_difficulty:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:terrain"] == NSOrderedSame) {
                [currentWP setRating_terrain:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:country"] == NSOrderedSame) {
                [currentWP setCountry:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:state"] == NSOrderedSame) {
                [currentWP setState:currentText];
                goto bye;
            }
            goto bye;
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
