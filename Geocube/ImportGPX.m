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

@interface ImportGPX ()
{
    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;
    NSInteger newLogsCount;
    NSInteger totalLogsCount;
    NSInteger newTrackablesCount;
    NSInteger totalTrackablesCount;
    NSUInteger percentageRead;
    NSUInteger totalLines;
    NSInteger newImagesCount;

    NSArray *files;
    dbGroup *group;
    dbAccount *account;

    NSMutableDictionary *logIdGCId;
    NSMutableArray *attributesYES, *attributesNO;
    NSMutableArray *logs;
    NSMutableArray *trackables;
    NSInteger index;
    NSInteger inItem, inLog, inTrackable, inGroundspeak;
    NSMutableString *currentText;
    NSString *currentElement;
    NSString *gsOwnerNameId, *logFinderNameId;
    dbWaypoint *currentWP;
    dbLog *currentLog;
    dbTrackable *currentTB;

    id delegate;
}

@end

@implementation ImportGPX

@synthesize delegate;

- (instancetype)init:(dbGroup *)_group account:(dbAccount *)_account;
{
    self = [super init];
    delegate = nil;

    newWaypointsCount = 0;
    totalWaypointsCount = 0;
    newLogsCount = 0;
    totalLogsCount = 0;
    percentageRead = 0;
    newTrackablesCount = 0;
    totalTrackablesCount = 0;
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

- (void)parseFile:(NSString *)filename
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain

    NSLog(@"%@: Parsing %@", [self class], filename);

    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
    [self parseData:data];
}

- (void)parseString:(NSString *)string
{
    [self parseData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)parseData:(NSData *)data
{
    NSLog(@"%@: Parsing data", [self class]);

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
    inTrackable = NO;
    logIdGCId = [dbLog dbAllIdGCId];

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
    [[dbc Group_AllWaypoints_Ignored] dbEmpty];
    [[dbc Group_AllWaypoints_Ignored] dbAddWaypoints:[dbWaypoint dbAllIgnored]];
    [dbc loadWaypointData];
    [dbWaypoint dbUpdateLogStatus];

    /* Crappy way to do sound but will work for now */
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"Import Complete"
                                                withExtension: @"wav"];
    CFURLRef        soundFileURLRef;
    SystemSoundID   soundFileObject;

    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) tapSound;

    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID ( soundFileURLRef, &soundFileObject );
    AudioServicesPlaySystemSound (soundFileObject);
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
            trackables = [NSMutableArray arrayWithCapacity:20];

            inItem = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            [currentWP setGs_archived:[[attributeDict objectForKey:@"archived"] boolValue]];
            [currentWP setGs_available:[[attributeDict objectForKey:@"available"] boolValue]];

            inGroundspeak = YES;
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:long_description"] == YES) {
            [currentWP setGs_long_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:short_description"] == YES) {
            [currentWP setGs_short_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
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
            [currentWP setGs_owner_gsid:gsOwnerNameId];
            return;
        }

        if ([currentElement isEqualToString:@"groundspeak:travelbug"] == YES) {
            currentTB = [[dbTrackable alloc] init];
            [currentTB setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
            [currentTB setRef:[attributeDict objectForKey:@"ref"]];

            inTrackable = YES;
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

            // Determine if it is a new waypoint or an existing one
            currentWP._id = [dbWaypoint dbGetByName:currentWP.name];
            totalWaypointsCount++;
            if (currentWP._id == 0) {
                [dbWaypoint dbCreate:currentWP];
                newWaypointsCount++;

                // Update the group
                [dbc.Group_LastImportAdded dbAddWaypoint:currentWP._id];
                [dbc.Group_AllWaypoints dbAddWaypoint:currentWP._id];
                [group dbAddWaypoint:currentWP._id];
            } else {
                [currentWP dbUpdate];

                // Update the group
                if ([group dbContainsWaypoint:currentWP._id] == NO)
                    [group dbAddWaypoint:currentWP._id];
            }
            [dbc.Group_LastImport dbAddWaypoint:currentWP._id];

            if (currentWP.gs_long_desc != nil)
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentWP.gs_long_desc type:IMAGETYPE_CACHE];
            if (currentWP.gs_short_desc != nil)
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentWP.gs_short_desc type:IMAGETYPE_CACHE];

            // Link logs to cache
            [logs enumerateObjectsUsingBlock:^(dbLog *l, NSUInteger idx, BOOL *stop) {
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:l.log type:IMAGETYPE_LOG];
                l.waypoint_id = currentWP._id;

                __block NSId _id = 0;
                dbLog *_l = [logIdGCId objectForKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                if (_l != nil)
                    _id = _l._id;

                if (_id == 0) {
                    newLogsCount++;
                    [l finish];
                    [l dbCreate];
                    [logIdGCId setObject:l forKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                } else {
                    l._id = _id;
                    [l dbUpdateNote];
                }
                totalLogsCount++;
            }];

            // Link attributes to cache
            [dbAttribute dbUnlinkAllFromWaypoint:currentWP._id];
            [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesNO YesNo:NO];
            [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesYES YesNo:YES];

            // Link trackables to cache
            [dbTrackable dbUnlinkAllFromWaypoint:currentWP._id];
            [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL *stop) {
                NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
                [tb finish];
                if (_id == 0) {
                    newTrackablesCount++;
                    [tb dbCreate];
                } else {
                    tb._id = _id;
                    [tb dbUpdate];
                }
                [tb dbLinkToWaypoint:currentWP._id];
                totalTrackablesCount++;
            }];

            inItem = NO;
            if (delegate != nil)
                [delegate updateGPXImportData:percentageRead newWaypointsCount:newWaypointsCount totalWaypointsCount:totalWaypointsCount newLogsCount:newLogsCount totalLogsCount:totalLogsCount newTrackablesCount:newTrackablesCount totalTrackablesCount:totalTrackablesCount newImagesCount:newImagesCount];

            goto bye;
        }

        if (index == 2 && [currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            inGroundspeak = NO;
            goto bye;
        }

        // Deal with the completion of the travelbug
        if (index == 4 && inTrackable == YES && [elementName isEqualToString:@"groundspeak:travelbug"] == YES) {
            [trackables addObject:currentTB];

            inTrackable = NO;
            goto bye;
        }

        // Deal with the completion of the log
        if (index == 4 && inLog == YES && [elementName isEqualToString:@"groundspeak:log"] == YES) {
            [logs addObject:currentLog];

            inLog = NO;
            goto bye;
        }

        // Deal with the data of the travelbug
        if (inTrackable == YES) {
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
                    [dbName makeNameExist:currentText code:logFinderNameId account:account];
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
                    NSArray *as = [currentText componentsSeparatedByString:@"|"];
                    [currentWP setType:[dbc Type_get_byname:[as objectAtIndex:0] minor:[as objectAtIndex:1]]];
                    [currentWP setType_id:currentWP.type._id];
                    goto bye;
                }
                goto bye;
            }
            if (index == 3 && currentText != nil) {
                if ([elementName isEqualToString:@"groundspeak:difficulty"] == YES) {
                    [currentWP setGs_rating_difficulty:[currentText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:terrain"] == YES) {
                    [currentWP setGs_rating_terrain:[currentText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:country"] == YES) {
                    [dbCountry makeNameExist:currentText];
                    [currentWP setGs_country_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:state"] == YES) {
                    [dbState makeNameExist:currentText];
                    [currentWP setGs_state_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:container"] == YES) {
                    [currentWP setGs_container_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:short_description"] == YES) {
                    [currentWP setGs_short_desc:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:long_description"] == YES) {
                    [currentWP setGs_long_desc:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:encoded_hints"] == YES) {
                    [currentWP setGs_hint:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:owner"] == YES) {
                    [dbName makeNameExist:currentText code:gsOwnerNameId account:account];
                    [currentWP setGs_owner_str:currentText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:placed_by"] == YES) {
                    [currentWP setGs_placed_by:currentText];
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
