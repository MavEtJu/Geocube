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

@implementation ImportGPX

@synthesize delegate;

- (id)init:(dbGroup *)_group account:(dbAccount *)_account;
{
    self = [super init];
    delegate = nil;

    newWaypointsCount = 0;
    totalWaypointsCount = 0;
    newLogsCount = 0;
    totalLogsCount = 0;
    percentageRead = 0;
    newTravelbugsCount = 0;
    totalTravelbugsCount = 0;
    newImagesCount = 0;

    group = _group;
    account = _account;

    NSLog(@"%@: Importing info %@", [self class], group.name);

    return self;
}

- (void)parseBefore
{
    NSLog(@"%@: Parsing initializing", [self class]);
    [dbc.Group_LastImport dbEmpty];
    [dbc.Group_LastImportAdded dbEmpty];
}

- (void)parse:(NSString *)filename
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain

    NSLog(@"%@: Parsing %@", [self class], filename);

    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];

    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    totalLines = [MyTools numberOfLines:s];

    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];

    index = 0;
    inItem = NO;
    inLog = NO;
    inTravelbug = NO;
    logIdGCId = [NSMutableArray arrayWithArray:[dbLog dbAllIdGCId]];

    @autoreleasepool {
        [rssParser parse];
    }
}

- (void)parseAfter
{
    NSLog(@"%@: Parsing done", [self class]);
    [[dbc Group_AllWaypoints_Found] dbEmpty];
    [[dbc Group_AllWaypoints_Found] dbAddWaypoints:[dbWaypoint dbAllFound]];
    [[dbc Group_AllWaypoints_Attended] dbEmpty];
    [[dbc Group_AllWaypoints_Attended] dbAddWaypoints:[dbWaypoint dbAllAttended]];
    [[dbc Group_AllWaypoints_NotFound] dbEmpty];
    [[dbc Group_AllWaypoints_NotFound] dbAddWaypoints:[dbWaypoint dbAllNotFound]];
    [dbc loadWaypointData];
    [dbWaypoint dbUpdateLogStatus];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString * errorString = [NSString stringWithFormat:@"%@ error (Error code %ld)", [self class], (long)[parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    @autoreleasepool {
        currentElement = elementName;
        currentText = nil;
        index++;

        if ([currentElement isEqualToString:@"wpt"] == YES) {
            currentWP = [[dbWaypoint alloc] init];
            [currentWP setLat:[attributeDict objectForKey:@"lat"]];
            [currentWP setLon:[attributeDict objectForKey:@"lon"]];

            currentWP.account = account;
            currentWP.account_id = account._id;

            logs = [NSMutableArray arrayWithCapacity:20];
            attributesYES = [NSMutableArray arrayWithCapacity:20];
            attributesNO = [NSMutableArray arrayWithCapacity:20];
            travelbugs = [NSMutableArray arrayWithCapacity:20];
            currentGS = nil;

            inItem = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            currentGS = [[dbGroundspeak alloc] init];
            [currentGS setArchived:[[attributeDict objectForKey:@"archived"] boolValue]];
            [currentGS setAvailable:[[attributeDict objectForKey:@"available"] boolValue]];

            inGroundspeak = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:long_description"] == YES) {
            [currentGS setLong_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:short_description"] == YES) {
            [currentGS setShort_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:log"] == YES) {
            currentLog = [[dbLog alloc] init];
            [currentLog setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];

            inLog = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:finder"] == YES) {
            logFinderNameId = [attributeDict objectForKey:@"id"];
            [currentLog setLogger_gsid:logFinderNameId];
            return;
        }
        if ([currentElement isEqualToString:@"groundspeak:owner"] == YES) {
            gsOwnerNameId = [attributeDict objectForKey:@"id"];
            [currentGS setOwner_gsid:gsOwnerNameId];
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:travelbug"] == YES) {
            currentTB = [[dbTravelbug alloc] init];
            [currentTB setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
            [currentTB setRef:[attributeDict objectForKey:@"ref"]];

            inTravelbug = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:attribute"] == YES) {
            NSId _id = [[attributeDict objectForKey:@"id"] integerValue];
            BOOL YesNo = [[attributeDict objectForKey:@"inc"] boolValue];
            dbAttribute *a = [dbc Attribute_get_bygcid:_id];
            a._YesNo = YesNo;
            if (YesNo == YES)
                [attributesYES addObject:[dbc Attribute_get_bygcid:_id]];
            else
                [attributesNO addObject:[dbc Attribute_get_bygcid:_id]];
            return;
        }
        
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    @autoreleasepool {
        index--;

        [currentText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [currentText length])];

        // Deal with the completion of the cache
        if (index == 1 && [elementName isEqualToString:@"wpt"] == YES) {
            [currentWP finish];
            [currentGS finish];

            // Determine if it is a new waypoint or an existing one
            currentWP._id = [dbWaypoint dbGetByName:currentWP.name];
            totalWaypointsCount++;
            if (currentWP._id == 0) {
                [dbWaypoint dbCreate:currentWP];
                newWaypointsCount++;

                // Save the groundspeak related data
                if (currentGS != nil) {
                    [currentGS setWaypoint_id:currentWP._id];
                    [dbGroundspeak dbCreate:currentGS];
                    currentWP.groundspeak_id = currentGS._id;
                    [currentWP dbUpdateGroundspeak];
                }

                // Update the group
                [dbc.Group_LastImportAdded dbAddWaypoint:currentWP._id];
                [dbc.Group_AllWaypoints dbAddWaypoint:currentWP._id];
                [group dbAddWaypoint:currentWP._id];
            } else {
                dbWaypoint *oldWP = [dbWaypoint dbGet:currentWP._id];
                currentWP.groundspeak_id = oldWP.groundspeak_id;
                [currentWP dbUpdate];

                // Save the groundspeak data
                currentGS.waypoint_id = currentWP._id;
                currentGS._id = currentWP.groundspeak_id;
                [currentGS dbUpdate];

                // Update the group
                if ([group dbContainsWaypoint:currentWP._id] == NO)
                    [group dbAddWaypoint:currentWP._id];
            }
            [dbc.Group_LastImport dbAddWaypoint:currentWP._id];

            if (currentGS != nil) {
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentGS.long_desc type:IMAGETYPE_CACHE];
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentGS.short_desc type:IMAGETYPE_CACHE];
            }

            // Link logs to cache
            [logs enumerateObjectsUsingBlock:^(dbLog *l, NSUInteger idx, BOOL *stop) {
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:l.log type:IMAGETYPE_LOG];
                [l dbUpdateCache:currentWP._id];
            }];

            // Link attributes to cache
            [dbAttribute dbUnlinkAllFromWaypoint:currentWP._id];
            [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesNO YesNo:NO];
            [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesYES YesNo:YES];

            // Link travelbugs to cache
            [dbTravelbug dbUnlinkAllFromWaypoint:currentWP._id];
            [travelbugs enumerateObjectsUsingBlock:^(dbTravelbug *tb, NSUInteger idx, BOOL *stop) {
                [tb dbLinkToWaypoint:currentWP._id];
            }];

            inItem = NO;
            if (delegate != nil)
                [delegate updateData:percentageRead newWaypointsCount:newWaypointsCount totalWaypointsCount:totalWaypointsCount newLogsCount:newLogsCount totalLogsCount:totalLogsCount newTravelbugsCount:newTravelbugsCount totalTravelbugsCount:totalTravelbugsCount newImagesCount:newImagesCount];

            goto bye;
        }

        if (index == 2 && [currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            [currentGS finish];
            // The saving of the data gets done when the waypoint is finished.

            inGroundspeak = NO;
            goto bye;
        }

        // Deal with the completion of the travelbug
        if (index == 4 && inTravelbug == YES && [elementName isEqualToString:@"groundspeak:travelbug"] == YES) {
            [currentTB finish];

            NSId tb_id = [dbTravelbug dbGetIdByGC:currentTB.gc_id];
            totalTravelbugsCount++;
            if (tb_id == 0) {
                newTravelbugsCount++;
                [dbTravelbug dbCreate:currentTB];
            } else {
                currentTB._id = tb_id;
                [currentTB dbUpdate];
            }
            [travelbugs addObject:currentTB];

            inTravelbug = NO;
            goto bye;
        }

        // Deal with the completion of the log
        if (index == 4 && inLog == YES && [elementName isEqualToString:@"groundspeak:log"] == YES) {
            [currentLog finish];

            __block NSId log_id = 0;
            [logIdGCId enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL *stop) {
                if (log.gc_id == currentLog.gc_id) {
                    log_id = log._id;
                    *stop = YES;
                }
            }];

            totalLogsCount++;
            if (log_id == 0) {
                newLogsCount++;
                [dbLog dbCreate:currentLog];
                [logIdGCId addObject:currentLog];   // Extend array just in case
            } else {
                currentLog._id = log_id;
                [currentLog dbUpdate];
            }
            [logs addObject:currentLog];

            inLog = NO;
            goto bye;
        }

        // Deal with the data of the travelbug
        if (inTravelbug == YES) {
            if (index == 5) {
                if ([elementName isEqualToString:@"groundspeak:name"] == YES) {
                    [currentTB setName:currentText];
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the log
        if (inLog == YES) {
            if (index == 5) {
                if ([elementName isEqualToString:@"groundspeak:date"] == YES) {
                    [currentLog setDatetime:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:type"] == YES) {
                    [currentLog setLogtype_string:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:finder"] == YES) {
                    [dbName makeNameExist:currentText code:logFinderNameId];
                    [currentLog setLogger_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:text"] == YES) {
                    [currentLog setLog:currentText];
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the cache. Always the last one!
        if (inItem == YES) {
            if (index == 2 && currentText != nil) {
                if ([elementName isEqualToString:@"time"] == YES) {
                    [currentWP setDate_placed:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"name"] == YES) {
                    [currentWP setName:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"desc"] == YES) {
                    [currentWP setDescription:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"url"] == YES) {
                    [currentWP setUrl:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"urlname"] == YES) {
                    [currentWP setUrlname:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"sym"] == YES) {
                    if ([dbc Symbol_get_bysymbol:currentText] == nil) {
                        NSLog(@"Adding symbol '%@'", currentText);
                        NSId _id = [dbSymbol dbCreate:currentText];
                        [dbc Symbols_add:_id symbol:currentText];
                    }
                    [currentWP setSymbol_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"type"] == YES) {
                    [currentWP setType:[dbc Type_get_byname:currentText]];
                    [currentWP setType_id:currentWP.type._id];
                    goto bye;
                }
                goto bye;
            }
            if (index == 3 && currentText != nil) {
                if ([elementName isEqualToString:@"groundspeak:difficulty"] == YES) {
                    [currentGS setRating_difficulty:[currentText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:terrain"] == YES) {
                    [currentGS setRating_terrain:[currentText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:country"] == YES) {
                    [dbCountry makeNameExist:currentText];
                    [currentGS setCountry_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:state"] == YES) {
                    [dbState makeNameExist:currentText];
                    [currentGS setState_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:container"] == YES) {
                    [currentGS setContainer_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:short_description"] == YES) {
                    [currentGS setShort_desc:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:long_description"] == YES) {
                    [currentGS setLong_desc:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:encoded_hints"] == YES) {
                    [currentGS setHint:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:owner"] == YES) {
                    [dbName makeNameExist:currentText code:gsOwnerNameId];
                    [currentGS setOwner_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:placed_by"] == YES) {
                    [currentGS setPlaced_by:currentText];
                    goto bye;
                }
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
    @autoreleasepool {
        percentageRead = 100 * parser.lineNumber / totalLines;
        if (string == nil)
            return;
        if (currentText == nil)
            currentText = [[NSMutableString alloc] initWithString:string];
        else
            [currentText appendString:string];
        return;
    }
}

@end
