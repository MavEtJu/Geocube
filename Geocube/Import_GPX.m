//
//  Import_GPX.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

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
    inItem = NO;
    inLog = NO;
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
        currentWP = [[dbWaypoint alloc] init];
        [currentWP setLat:[attributeDict objectForKey:@"lat"]];
        [currentWP setLon:[attributeDict objectForKey:@"lon"]];
        
        logs = [NSMutableArray arrayWithCapacity:20];
        
        inItem = YES;
        return;
    }
    
    if ([currentElement compare:@"groundspeak:long_description"] == NSOrderedSame) {
        [currentWP setGc_long_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
        return;
    }
    
    if ([currentElement compare:@"groundspeak:short_description"] == NSOrderedSame) {
        [currentWP setGc_short_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
        return;
    }
    
    if ([currentElement compare:@"groundspeak:log"] == NSOrderedSame) {
        currentLog = [[dbLog alloc] init];
        [currentLog setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
        inLog = YES;
        return;
    }

    return;
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    index--;
    
    [currentText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [currentText length])];
    
    if (index == 1 && [elementName compare:@"wpt"] == NSOrderedSame) {
        [currentWP finish];
        
        NSInteger cwp_id = [db Waypoint_get_byname:currentWP.name];
        if (cwp_id == 0) {
            cwp_id = [db Waypoint_add:currentWP];
            
            [db WaypointGroups_add_waypoint:dbc.WaypointGroup_LastImportAdded._id waypoint_id:cwp_id];
            [db WaypointGroups_add_waypoint:dbc.WaypointGroup_AllWaypoints._id waypoint_id:cwp_id];
            [db WaypointGroups_add_waypoint:group._id waypoint_id:cwp_id];
        } else {
            currentWP._id = cwp_id;
            [db Waypoint_update:currentWP];
            if ([db WaypointGroups_contains_waypoint:group._id waypoint_id:cwp_id] == NO)
                [db WaypointGroups_add_waypoint:group._id waypoint_id:cwp_id];
        }
        [db WaypointGroups_add_waypoint:dbc.WaypointGroup_LastImport._id waypoint_id:cwp_id];
        
        // Link logs to waypoint
        NSEnumerator *e = [logs objectEnumerator];
        dbLog *l;
        while ((l = [e nextObject]) != nil) {
            [db Logs_update_waypoint_id:l waypoint_id:cwp_id];
        }

        inItem = NO;
        goto bye;
    }
    
    if (index == 4 && [elementName compare:@"groundspeak:log"] == NSOrderedSame) {
        [currentLog finish];
        
        NSInteger log_id = [db Log_by_gcid:currentLog.gc_id];
        if (log_id == 0) {
            currentLog._id = [db Logs_add:currentLog];
        } else {
            currentLog._id = log_id;
            [db Logs_update:log_id log:currentLog];
        }
        [logs addObject:currentLog];
        
        inLog = NO;
        goto bye;
    }
    
    if (inItem == YES && inLog == NO) {
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
                [currentWP setWp_type:[dbc WaypointType_get_byname:currentText]];
                [currentWP setWp_type_int:currentWP.wp_type._id];
                goto bye;
            }
            goto bye;
        }
        if (index == 3 && currentText != nil) {
            if ([elementName compare:@"groundspeak:difficulty"] == NSOrderedSame) {
                [currentWP setGc_rating_difficulty:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:terrain"] == NSOrderedSame) {
                [currentWP setGc_rating_terrain:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:country"] == NSOrderedSame) {
                [currentWP setGc_country:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:state"] == NSOrderedSame) {
                [currentWP setGc_state:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:container"] == NSOrderedSame) {
                [currentWP setGc_containerSize_str:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:short_description"] == NSOrderedSame) {
                [currentWP setGc_short_desc:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:long_description"] == NSOrderedSame) {
                [currentWP setGc_long_desc:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:encoded_hints"] == NSOrderedSame) {
                [currentWP setGc_hint:currentText];
                goto bye;
            }
            goto bye;
        }
        goto bye;
    }
    
    if (inLog == YES) {
        if (index == 5) {
            if ([elementName compare:@"groundspeak:date"] == NSOrderedSame) {
                [currentLog setDatetime:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:type"] == NSOrderedSame) {
                [currentLog setLogtype_string:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:finder"] == NSOrderedSame) {
                [currentLog setLogger:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:text"] == NSOrderedSame) {
                [currentLog setLog:currentText];
                goto bye;
            }
            goto bye;
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
    return;
}

@end
