/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface ImportGPXGarmin ()
{
    NSArray *files;

    NSMutableDictionary *logIdGCId;
    NSMutableArray *attributesYES, *attributesNO;
    NSMutableArray *logs;
    NSMutableArray *trackables;
    NSMutableArray *imagesLog, *imagesCache;
    NSInteger index;
    NSInteger inItem, inLog, inTrackable, inGroundspeak, inImageLog, inImageCache;
    NSMutableString *currentText;
    NSString *currentElement;
    NSString *gsOwnerNameId, *logFinderNameId;
    dbWaypoint *currentWP;
    dbLog *currentLog;
    dbTrackable *currentTB;
    dbImage *currentImage;

    BOOL runOption_LogsOnly;
    NSInteger numberOfLines;
}

@end

@implementation ImportGPXGarmin

- (void)parseFile:(NSString *)filename infoViewer:(InfoViewer *)iv ivi:(InfoItemID)iii
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain

    NSLog(@"%@: Parsing %@", [self class], filename);

    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
    [self parseData:data infoViewer:iv ivi:iii];
}

- (void)parseString:(NSString *)string infoViewer:(InfoViewer *)iv ivi:(InfoItemID)iii
{
    [self parseData:[string dataUsingEncoding:NSUTF8StringEncoding] infoViewer:iv ivi:iii];
}

- (void)parseData:(NSData *)data infoViewer:(InfoViewer *)iv ivi:(InfoItemID)iii
{
    runOption_LogsOnly = (self.run_options & RUN_OPTION_LOGSONLY) != 0;
    NSLog(@"%@: Parsing data", [self class]);

    infoViewer = iv;
    ivi = iii;

    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];

    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    numberOfLines = [MyTools numberOfLines:s];

    NSLog(@"run_options: %ld", (long)self.run_options);

    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];

    index = 0;
    inItem = NO;
    inLog = NO;
    inTrackable = NO;
    inImageLog = NO;
    inImageCache = NO;
    logIdGCId = [dbLog dbAllIdGCId];

    [infoViewer setLineObjectTotal:ivi total:numberOfLines isLines:YES];
    @autoreleasepool {
        [rssParser parse];
    }
    [infoViewer setLineObjectCount:ivi count:numberOfLines];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    @autoreleasepool {
        currentElement = elementName;
        currentText = nil;
        index++;

        if ([currentElement isEqualToString:@"wpt"] == YES) {
            currentWP = [[dbWaypoint alloc] init];
            [currentWP setWpt_lat:[attributeDict objectForKey:@"lat"]];
            [currentWP setWpt_lon:[attributeDict objectForKey:@"lon"]];

            currentWP.account = account;
            currentWP.account_id = account._id;

            logs = [NSMutableArray arrayWithCapacity:20];
            attributesYES = [NSMutableArray arrayWithCapacity:20];
            attributesNO = [NSMutableArray arrayWithCapacity:20];
            trackables = [NSMutableArray arrayWithCapacity:20];
            imagesLog = [NSMutableArray arrayWithCapacity:20];
            imagesCache = [NSMutableArray arrayWithCapacity:20];

            inItem = YES;
            return;
        }

        if ([currentElement isEqualToString:@"cache"] == YES) {
            [currentWP setGs_archived:[[attributeDict objectForKey:@"archived"] boolValue]];
            [currentWP setGs_available:[[attributeDict objectForKey:@"available"] boolValue]];

            inGroundspeak = YES;
            return;
        }

        if ([currentElement isEqualToString:@"long_description"] == YES) {
            [currentWP setGs_long_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([currentElement isEqualToString:@"short_description"] == YES) {
            [currentWP setGs_short_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([currentElement isEqualToString:@"log"] == YES) {
            currentLog = [[dbLog alloc] init];
            [currentLog setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];

            inLog = YES;
            return;
        }

        if ([currentElement isEqualToString:@"finder"] == YES) {
            logFinderNameId = [attributeDict objectForKey:@"id"];
            [currentLog setLogger_gsid:logFinderNameId];
            return;
        }
        if ([currentElement isEqualToString:@"owner"] == YES) {
            gsOwnerNameId = [attributeDict objectForKey:@"id"];
            [currentWP setGs_owner_gsid:gsOwnerNameId];
            return;
        }

        if ([currentElement isEqualToString:@"travelbug"] == YES) {
            currentTB = [[dbTrackable alloc] init];
            [currentTB setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
            [currentTB setRef:[attributeDict objectForKey:@"ref"]];
            [currentTB setWaypoint_name:currentWP.wpt_name];

            inTrackable = YES;
            return;
        }

        if ([currentElement isEqualToString:@"attribute"] == YES) {
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
    if (parser.lineNumber % 25 == 0)
        [infoViewer setLineObjectCount:ivi count:parser.lineNumber];

    @autoreleasepool {
        index--;

        NSMutableString *cleanText = nil;
        if (currentText != nil) {
            cleanText = [NSMutableString stringWithString:currentText];
            [cleanText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [currentText length])];
        }

        // Deal with the completion of the cache
        if (index == 1 && [elementName isEqualToString:@"wpt"] == YES) {
            [currentWP finish];
            currentWP.date_lastimport_epoch = time(NULL);

            // Determine if it is a new waypoint or an existing one
            currentWP._id = [dbWaypoint dbGetByName:currentWP.wpt_name];
            totalWaypointsCount++;
            [infoViewer setWaypointsTotal:ivi total:totalWaypointsCount];
            if (runOption_LogsOnly == NO) {
                if (currentWP._id == 0) {
                    [dbWaypoint dbCreate:currentWP];
                    newWaypointsCount++;
                    [infoViewer setWaypointsNew:ivi new:newWaypointsCount];

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
                    newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentWP.gs_long_desc type:IMAGECATEGORY_CACHE];
                if (currentWP.gs_short_desc != nil)
                    newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:currentWP.gs_short_desc type:IMAGECATEGORY_CACHE];
            }

            // Link images to cache
            [imagesCache enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL * _Nonnull stop) {
                newImagesCount += [ImagesDownloadManager downloadImage:currentWP._id url:img.url name:img.name type:IMAGECATEGORY_CACHE];
            }];

            [imagesLog enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL * _Nonnull stop) {
                newImagesCount += [ImagesDownloadManager downloadImage:currentWP._id url:img.url name:img.name type:IMAGECATEGORY_LOG];
            }];

            // Link logs to cache
            [logs enumerateObjectsUsingBlock:^(dbLog *l, NSUInteger idx, BOOL *stop) {
                newImagesCount += [ImagesDownloadManager findImagesInDescription:currentWP._id text:l.log type:IMAGECATEGORY_LOG];
                l.waypoint_id = currentWP._id;
                [l finish];

                __block NSId _id = 0;
                dbLog *_l = [logIdGCId objectForKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                if (_l != nil)
                    _id = _l._id;

                if (_id == 0) {
                    newLogsCount++;
                    [infoViewer setLogsNew:ivi new:newLogsCount];
                    [l finish];
                    [l dbCreate];
                    [logIdGCId setObject:l forKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                } else {
                    l._id = _id;
                    [l dbUpdateNote];
                }
                totalLogsCount++;
                [infoViewer setLogsTotal:ivi total:totalLogsCount];
            }];

            if (runOption_LogsOnly == NO) {
                // Link attributes to cache
                [dbAttribute dbUnlinkAllFromWaypoint:currentWP._id];
                [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesNO YesNo:NO];
                [dbAttribute dbAllLinkToWaypoint:currentWP._id attributes:attributesYES YesNo:YES];

                // Link trackables to cache
                [dbTrackable dbUnlinkAllFromWaypoint:currentWP._id];
                [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL *stop) {
                    NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
                    [tb finish:account];
                    if (_id == 0) {
                        newTrackablesCount++;
                        [infoViewer setTrackablesNew:ivi new:newTrackablesCount];
                        [tb dbCreate];
                    } else {
                        tb._id = _id;
                        [tb dbUpdate];
                    }
                    [tb dbLinkToWaypoint:currentWP._id];
                    totalTrackablesCount++;
                    [infoViewer setTrackablesTotal:ivi total:totalTrackablesCount];
                }];
            }

            inItem = NO;
            goto bye;
        }

        if (index == 2 && [currentElement isEqualToString:@"cache"] == YES) {
            inGroundspeak = NO;
            goto bye;
        }

        // Deal with the completion of the travelbug
        if (index == 4 && inTrackable == YES && [elementName isEqualToString:@"travelbug"] == YES) {
            [trackables addObject:currentTB];

            inTrackable = NO;
            goto bye;
        }

        // Deal with the completion of the log
        if (index == 4 && inLog == YES && [elementName isEqualToString:@"log"] == YES) {
            [logs addObject:currentLog];

            inLog = NO;
            goto bye;
        }

        // Deal with the data of the travelbug
        if (inTrackable == YES) {
            if (index == 5) {
                if ([elementName isEqualToString:@"name"] == YES) {
                    [currentTB setName:cleanText];
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the log
        if (inLog == YES) {
            if (index == 5) {
                if ([elementName isEqualToString:@"date"] == YES) {
                    [currentLog setDatetime:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"type"] == YES) {
                    currentLog.logstring_string = cleanText;
                    goto bye;
                }
                if ([elementName isEqualToString:@"finder"] == YES) {
                    [dbName makeNameExist:cleanText code:logFinderNameId account:account];
                    [currentLog setLogger_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"text"] == YES) {
                    [currentLog setLog:currentText]; // Can contain newlines
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the cache. Always the last one!
        if (inItem == YES) {
            if (index == 2 && cleanText != nil) {
                if ([elementName isEqualToString:@"time"] == YES) {
                    [currentWP setWpt_date_placed:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"name"] == YES) {
                    [currentWP setWpt_name:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"desc"] == YES) {
                    [currentWP setWpt_description:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"url"] == YES) {
                    [currentWP setWpt_url:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"urlname"] == YES) {
                    [currentWP setWpt_urlname:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"sym"] == YES) {
                    if ([dbc Symbol_get_bysymbol:cleanText] == nil) {
                        NSLog(@"Adding symbol '%@'", cleanText);
                        NSId _id = [dbSymbol dbCreate:cleanText];
                        [dbc Symbols_add:_id symbol:cleanText];
                    }
                    [currentWP setWpt_symbol_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"type"] == YES) {
                    NSArray *as = [cleanText componentsSeparatedByString:@"|"];
                    if ([as count] == 1)
                        [currentWP setWpt_type:[dbc Type_get_byminor:[as objectAtIndex:0]]];
                    else
                        [currentWP setWpt_type:[dbc Type_get_byname:[as objectAtIndex:0] minor:[as objectAtIndex:1]]];
                    [currentWP setWpt_type_id:currentWP.wpt_type._id];
                    goto bye;
                }
                goto bye;
            }
            if (index == 3 && cleanText != nil) {
                if ([elementName isEqualToString:@"difficulty"] == YES) {
                    [currentWP setGs_rating_difficulty:[cleanText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"terrain"] == YES) {
                    [currentWP setGs_rating_terrain:[cleanText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"country"] == YES) {
                    [dbCountry makeNameExist:cleanText];
                    [currentWP setGs_country_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"state"] == YES) {
                    [dbState makeNameExist:cleanText];
                    [currentWP setGs_state_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"container"] == YES) {
                    [currentWP setGs_container_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"short_description"] == YES) {
                    [currentWP setGs_short_desc:[MyTools HTMLUnescape:currentText]]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"long_description"] == YES) {
                    [currentWP setGs_long_desc:[MyTools HTMLUnescape:currentText]]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"encoded_hints"] == YES) {
                    [currentWP setGs_hint:[MyTools HTMLUnescape:currentText]]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"owner"] == YES) {
                    [dbName makeNameExist:cleanText code:gsOwnerNameId account:account];
                    [currentWP setGs_owner_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"placed_by"] == YES) {
                    [currentWP setGs_placed_by:cleanText];
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

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    @autoreleasepool {
        if (string == nil)
            return;
        if (currentText == nil)
            currentText = [[NSMutableString alloc] initWithString:string];
        else
            [currentText appendString:string];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)error
{
    NSLog(@"[%@] validationErrorOccurred: %@", [self class], error);
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSString *errorString = [NSString stringWithFormat:@"%@ error (Error code %ld)", [self class], (long)[parseError code]];
    NSLog(@"Error parsing XML: %@ (%@)", errorString, parseError);
}

@end
