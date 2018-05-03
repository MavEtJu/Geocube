/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface ImportGPX ()

@property (nonatomic, retain) NSArray<NSString *> *files;

@property (nonatomic, retain) NSMutableDictionary *logIdGCId;
@property (nonatomic, retain) NSMutableArray<dbAttribute *> *attributesYES, *attributesNO;
@property (nonatomic, retain) NSMutableArray<dbLog *> *logs;
@property (nonatomic, retain) NSMutableArray<dbTrackable *> *trackables;
@property (nonatomic, retain) NSMutableArray<dbImage *> *imagesLog, *imagesCache;
@property (nonatomic        ) NSInteger index;
@property (nonatomic        ) NSInteger inItem, inLog, inTrackable, inGroundspeak, inImageLog, inImageCache;
@property (nonatomic, retain) NSMutableString *currentText;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSString *gsOwnerNameId, *logFinderNameId;
@property (nonatomic, retain) dbWaypoint *currentWP;
@property (nonatomic, retain) dbLog *currentLog;
@property (nonatomic, retain) dbTrackable *currentTB;
@property (nonatomic, retain) dbImage *currentImage;

@property (nonatomic        ) BOOL runOption_LogsOnly;
@property (nonatomic        ) NSInteger numberOfLines;

@end

@implementation ImportGPX

- (void)parseFile:(NSString *)filename infoItem:(InfoItem *)iii
{
    // here, for some reason you have to use NSClassFromString when trying to alloc NSXMLParser, otherwise you will get an object not found error
    // this may be necessary only for the toolchain

    NSLog(@"%@: Parsing %@", [self class], filename);

    NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
    [self parseData:data infoItem:iii];
}

- (void)parseString:(NSString *)string infoItem:(InfoItem *)iii
{
    [self parseData:[string dataUsingEncoding:NSUTF8StringEncoding] infoItem:iii];
}

- (void)parseData:(NSData *)data infoItem:(InfoItem *)iii
{
    self.runOption_LogsOnly = (self.run_options & IMPORTOPTION_LOGSONLY) != 0;
    NSLog(@"%@: Parsing data", [self class]);

    self.iiImport = iii;

    NSXMLParser *rssParser = [[NSXMLParser alloc] initWithData:data];

    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    self.numberOfLines = [MyTools numberOfLines:s];

    NSLog(@"run_options: %ld", (long)self.run_options);

    [rssParser setDelegate:self];
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];

    self.index = 0;
    self.inItem = NO;
    self.inLog = NO;
    self.inTrackable = NO;
    self.inImageLog = NO;
    self.inImageCache = NO;
    self.logIdGCId = [dbLog dbAllIdGCId];

    [self.iiImport changeLineObjectTotal:self.numberOfLines isLines:YES];
    @autoreleasepool {
        [rssParser parse];
    }
    [self.iiImport changeLineObjectCount:self.numberOfLines];
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    @autoreleasepool {
        self.currentElement = elementName;
        self.currentText = nil;
        self.index++;

        if ([self.currentElement isEqualToString:@"wpt"] == YES) {
            self.currentWP = [[dbWaypoint alloc] init];
            [self.currentWP set_wpt_lat_str:[attributeDict objectForKey:@"lat"]];
            [self.currentWP set_wpt_lon_str:[attributeDict objectForKey:@"lon"]];

            self.currentWP.account = self.account;

            self.logs = [NSMutableArray arrayWithCapacity:20];
            self.attributesYES = [NSMutableArray arrayWithCapacity:20];
            self.attributesNO = [NSMutableArray arrayWithCapacity:20];
            self.trackables = [NSMutableArray arrayWithCapacity:20];
            self.imagesLog = [NSMutableArray arrayWithCapacity:20];
            self.imagesCache = [NSMutableArray arrayWithCapacity:20];

            self.inItem = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            [self.currentWP setGs_archived:[[attributeDict objectForKey:@"archived"] boolValue]];
            [self.currentWP setGs_available:[[attributeDict objectForKey:@"available"] boolValue]];

            self.inGroundspeak = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:long_description"] == YES) {
            [self.currentWP setGs_long_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:short_description"] == YES) {
            [self.currentWP setGs_short_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:log"] == YES) {
            self.currentLog = [[dbLog alloc] init];
            [self.currentLog setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];

            self.inLog = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:log_wpt"] == YES) {
            self.currentLog.latitude = [[attributeDict objectForKey:@"lat"] floatValue];
            self.currentLog.longitude = [[attributeDict objectForKey:@"lon"] floatValue];

            self.inLog = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:finder"] == YES) {
            self.logFinderNameId = [attributeDict objectForKey:@"id"];
            [self.currentLog setLogger_gsid:self.logFinderNameId];
            return;
        }
        if ([self.currentElement isEqualToString:@"groundspeak:owner"] == YES) {
            self.gsOwnerNameId = [attributeDict objectForKey:@"id"];
            [self.currentWP setGs_owner_gsid:self.gsOwnerNameId];
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:travelbug"] == YES) {
            self.currentTB = [[dbTrackable alloc] init];
            self.currentTB.gc_id = [[attributeDict objectForKey:@"id"] integerValue];
            self.currentTB.tbcode = [attributeDict objectForKey:@"ref"];
            self.currentTB.waypoint_name = self.currentWP.wpt_name;

            self.inTrackable = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"groundspeak:attribute"] == YES) {
            NSId _id = [[attributeDict objectForKey:@"id"] integerValue];
            BOOL YesNo = [[attributeDict objectForKey:@"inc"] boolValue];
            dbAttribute *a = [dbc attributeGetByGCId:_id];
            a._YesNo = YesNo;
            if (YesNo == YES)
                [self.attributesYES addObject:[dbc attributeGetByGCId:_id]];
            else
                [self.attributesNO addObject:[dbc attributeGetByGCId:_id]];
            return;
        }

        if ([self.currentElement isEqualToString:@"gsak:CacheImage"] == YES) {
            self.currentImage = [[dbImage alloc] init];
            self.currentImage.url = [attributeDict objectForKey:@"iimage"];
            self.currentImage.name = [attributeDict objectForKey:@"iname"];
            self.inImageCache = YES;
            return;
        }

        if ([self.currentElement isEqualToString:@"gsak:LogImage"] == YES) {
            self.currentImage = [[dbImage alloc] init];
            self.currentImage.url = [attributeDict objectForKey:@"iimage"];
            self.currentImage.name = [attributeDict objectForKey:@"iname"];
            self.inImageLog = YES;
            return;
        }

        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (parser.lineNumber % 25 == 0)
        [self.iiImport changeLineObjectCount:parser.lineNumber];

    @autoreleasepool {
        self.index--;

        NSMutableString *cleanText = nil;
        if (self.currentText != nil) {
            cleanText = [NSMutableString stringWithString:self.currentText];
            [cleanText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [self.currentText length])];
        }

        // Deal with the completion of the cache
        if (self.index == 1 && [elementName isEqualToString:@"wpt"] == YES) {
            [self.currentWP finish];
            self.currentWP.date_lastimport_epoch = time(NULL);
            self.currentWP.dirty_logs = YES;

            // Geosphere GPX files can be without an owner.
            if (self.currentWP.gs_owner == nil) {
                [dbName makeNameExist:NAME_NONAMESUPPLIED code:0 account:self.currentWP.account];
                self.currentWP.gs_owner = [dbName dbGetByName:NAME_NONAMESUPPLIED account:self.currentWP.account];
            }

            // Determine if it is a new waypoint or an existing one
            self.currentWP._id = [dbWaypoint dbGetByName:self.currentWP.wpt_name]._id;
            self.totalWaypointsCount++;
            [self.iiImport changeWaypointsTotal:self.totalWaypointsCount];
            if (self.runOption_LogsOnly == NO) {
                if (self.currentWP._id == 0) {
                    [self.currentWP dbCreate];
                    self.newWaypointsCount++;
                    [self.iiImport changeWaypointsNew:self.newWaypointsCount];

                    // Update the group
                    [dbc.groupLastImportAdded addWaypointToGroup:self.currentWP];
                    [dbc.groupAllWaypoints addWaypointToGroup:self.currentWP];
                    [self.group addWaypointToGroup:self.currentWP];
                } else {
                    [self.currentWP dbUpdate];

                    // Update the group
                    if ([self.group containsWaypoint:self.currentWP] == NO)
                        [self.group addWaypointToGroup:self.currentWP];
                }
                [self.delegate Import_WaypointProcessed:self.currentWP];

                [opencageManager addForProcessing:self.currentWP];

                [dbc.groupLastImport addWaypointToGroup:self.currentWP];
                if (self.currentWP.gs_long_desc != nil)
                    self.newImagesCount += [imagesDownloadManager findImagesInDescription:self.currentWP text:self.currentWP.gs_long_desc type:IMAGECATEGORY_CACHE];
                if (self.currentWP.gs_short_desc != nil)
                    self.newImagesCount += [imagesDownloadManager findImagesInDescription:self.currentWP text:self.currentWP.gs_short_desc type:IMAGECATEGORY_CACHE];
            }

            // Link images to cache
            [self.imagesCache enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
                self.newImagesCount += [imagesDownloadManager downloadImage:self.currentWP url:img.url name:img.name type:IMAGECATEGORY_CACHE];
            }];

            [self.imagesLog enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
                self.newImagesCount += [imagesDownloadManager downloadImage:self.currentWP url:img.url name:img.name type:IMAGECATEGORY_LOG];
            }];

            // Link logs to cache
            [self.logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull l, NSUInteger idx, BOOL * _Nonnull stop) {
                self.newImagesCount += [imagesDownloadManager findImagesInDescription:self.currentWP text:l.log type:IMAGECATEGORY_LOG];
                l.waypoint = self.currentWP;
                [l finish];

                __block NSId _id = 0;
                dbLog *_l = [self.logIdGCId objectForKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                if (_l != nil)
                    _id = _l._id;

                if (_id == 0) {
                    self.newLogsCount++;
                    [self.iiImport changeLogsNew:self.newLogsCount];
                    [l finish];
                    [l dbCreate];
                    [self.logIdGCId setObject:l forKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
                } else {
                    l._id = _id;
                    [l dbUpdateNote];
                }
                self.totalLogsCount++;
                [self.iiImport changeLogsTotal:self.totalLogsCount];
            }];

            if (self.runOption_LogsOnly == NO) {
                // Link attributes to cache
                [dbAttribute dbUnlinkAllFromWaypoint:self.currentWP];
                [dbAttribute dbAllLinkToWaypoint:self.currentWP attributes:self.attributesNO YesNo:NO];
                [dbAttribute dbAllLinkToWaypoint:self.currentWP attributes:self.attributesYES YesNo:YES];

                // Link trackables to cache
                [dbTrackable dbUnlinkAllFromWaypoint:self.currentWP];
                [self.trackables enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSId _id = [dbTrackable dbGetIdByGC:tb.gc_id];
                    if (tb.owner == nil)
                        tb.owner = [dbc nameGetNoName:self.account];
                    [tb finish];
                    if (_id == 0) {
                        self.newTrackablesCount++;
                        [self.iiImport changeTrackablesNew:self.newTrackablesCount];
                        [tb dbCreate];
                    } else {
                        tb._id = _id;
                        [tb dbUpdate];
                    }
                    [tb dbLinkToWaypoint:self.currentWP];
                    self.totalTrackablesCount++;
                    [self.iiImport changeTrackablesTotal:self.totalTrackablesCount];
                }];
            }

            self.inItem = NO;
            goto bye;
        }

        if (self.index == 2 && [self.currentElement isEqualToString:@"groundspeak:cache"] == YES) {
            self.inGroundspeak = NO;
            goto bye;
        }

        // Deal with the completion of the travelbug
        if (self.index == 4 && self.inTrackable == YES && [elementName isEqualToString:@"groundspeak:travelbug"] == YES) {
            [self.trackables addObject:self.currentTB];

            self.inTrackable = NO;
            goto bye;
        }

        // Deal with the completion of the log
        if (self.index == 4 && self.inLog == YES && [elementName isEqualToString:@"groundspeak:log"] == YES) {
            [self.logs addObject:self.currentLog];

            self.inLog = NO;
            goto bye;
        }

        // Deal with the completion of the image
        if (self.index == 4 && self.inImageCache  == YES && [elementName isEqualToString:@"gsak:CacheImage"] == YES) {
            [self.imagesCache addObject:self.currentImage];

            self.inImageCache = NO;
            goto bye;
        }

        if (self.index == 4 && self.inImageLog == YES && [elementName isEqualToString:@"gsak:LogImage"] == YES) {
            [self.imagesLog addObject:self.currentImage];

            self.inImageLog = NO;
            goto bye;
        }

        // Deal with the data of the travelbug
        if (self.inTrackable == YES) {
            if (self.index == 5) {
                if ([elementName isEqualToString:@"groundspeak:name"] == YES) {
                    [self.currentTB setName:cleanText];
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the log
        if (self.inLog == YES) {
            if (self.index == 5) {
                if ([elementName isEqualToString:@"groundspeak:date"] == YES) {
                    self.currentLog.datetime_epoch = [MyTools secondsSinceEpochFromISO8601:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:type"] == YES) {
                    LogStringWPType wptype = [dbLogString wptTypeToWPType:self.currentWP.wpt_type.type_full];
                    NSAssert(wptype != 0, @"wptype != 0");
                    // In case there is no text provided, make it a note.
                    if (IS_EMPTY(cleanText) == YES)
                        cleanText = [NSMutableString stringWithString:@"Write Note"];
                    self.currentLog.logstring = [dbc logStringGetByDisplayString:self.account displayString:cleanText];
                    NSAssert(self.currentLog.logstring != nil, @"currentLog.logstring != nil");
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:finder"] == YES) {
                    if (cleanText == nil)
                        cleanText = [NSMutableString stringWithString:NAME_NONAMESUPPLIED];
                    [dbName makeNameExist:cleanText code:self.logFinderNameId account:self.account];
                    self.currentLog.logger = [dbName dbGetByName:cleanText account:self.account];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:text"] == YES) {
                    [self.currentLog setLog:self.currentText]; // Can contain newlines
                    goto bye;
                }
                goto bye;
            }
            goto bye;
        }

        // Deal with the data of the GSAK image
        // Sometimes it's here, sometimes it's in its own XML:
        //    <gsak:CacheImage iname="3 guys" idescription="3 guys" iimage="http://img.geocaching.com/xxx"/>
        if (self.inImageLog == YES || self.inImageCache == YES) {
            if (self.index == 5 && cleanText != nil) {
                if ([elementName isEqualToString:@"gsak:iimage"] == YES) {
                    [self.currentImage setUrl:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"gsak:iname"] == YES) {
                    [self.currentImage setName:cleanText];
                    goto bye;
                }
                goto bye;
            }
        }

        // Deal with the data of the cache. Always the last one!
        if (self.inItem == YES) {
            if (self.index == 2 && cleanText != nil) {
                if ([elementName isEqualToString:@"time"] == YES) {
                    [self.currentWP set_wpt_date_placed:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"name"] == YES) {
                    [self.currentWP setWpt_name:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"desc"] == YES) {
                    [self.currentWP setWpt_description:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"url"] == YES) {
                    [self.currentWP setWpt_url:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"urlname"] == YES) {
                    [self.currentWP setWpt_urlname:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"sym"] == YES) {
                    if ([dbc symbolGetBySymbol:cleanText] == nil) {
                        NSLog(@"Adding symbol '%@'", cleanText);
                        dbSymbol *s = [[dbSymbol alloc] init];
                        s.symbol = cleanText;
                        [s dbCreate];
                        [dbc symbolsAdd:s];
                    }
                    [self.currentWP set_wpt_symbol_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"type"] == YES) {
                    [self.currentWP set_wpt_type_str:cleanText];
                    goto bye;
                }
                goto bye;
            }
            if (self.index == 3 && cleanText != nil) {
                if ([elementName isEqualToString:@"groundspeak:difficulty"] == YES) {
                    [self.currentWP setGs_rating_difficulty:[cleanText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:terrain"] == YES) {
                    [self.currentWP setGs_rating_terrain:[cleanText floatValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:country"] == YES) {
                    [dbCountry makeNameExist:cleanText];
                    [self.currentWP set_gs_country_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:state"] == YES) {
                    [dbState makeNameExist:cleanText];
                    [self.currentWP set_gs_state_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:container"] == YES) {
                    [self.currentWP set_gs_container_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:short_description"] == YES) {
                    [self.currentWP setGs_short_desc:self.currentText]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:long_description"] == YES) {
                    [self.currentWP setGs_long_desc:self.currentText]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:encoded_hints"] == YES) {
                    [self.currentWP setGs_hint:self.currentText]; // Can contain newlines
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:owner"] == YES) {
                    if (IS_EMPTY(cleanText) == YES)
                        cleanText = [NSMutableString stringWithString:_(@"importgpx-(No name specified)")];
                    [dbName makeNameExist:cleanText code:self.gsOwnerNameId account:self.account];
                    [self.currentWP set_gs_owner_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"groundspeak:placed_by"] == YES) {
                    if (IS_EMPTY(cleanText) == YES)
                        cleanText = [NSMutableString stringWithString:_(@"importgpx-(No name specified)")];
                    [self.currentWP setGs_placed_by:cleanText];
                    goto bye;
                }

                if ([elementName isEqualToString:@"gsak:County"] == YES) {
                    [self.currentWP set_gca_locality_str:cleanText];
                    goto bye;
                }
                if ([elementName isEqualToString:@"gsak:FavPoints"] == YES) {
                    [self.currentWP setGs_favourites:[cleanText integerValue]];
                    goto bye;
                }
                if ([elementName isEqualToString:@"gsak:GcNote"] == YES) {
                    NSString *personal_note = self.currentText;  // Can contain newlines
                    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:self.currentWP.wpt_name];
                    if (pn != nil) {
                        if (IS_EMPTY(personal_note) == YES) {
                            [pn dbDelete];
                            pn = nil;
                        } else {
                            pn.note = personal_note;
                            [pn dbUpdate];
                        }
                    } else {
                        if (IS_EMPTY(personal_note) == NO) {
                            pn = [[dbPersonalNote alloc] init];
                            pn.wp_name = self.currentWP.wpt_name;
                            pn.note = personal_note;
                            [pn dbCreate];
                        }
                    }

                    goto bye;
                }

                goto bye;
            }
            goto bye;
        }
    }

bye:
    self.currentText = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    @autoreleasepool {
        if (string == nil)
            return;
        if (self.currentText == nil)
            self.currentText = [[NSMutableString alloc] initWithString:string];
        else
            [self.currentText appendString:string];
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
    [MyTools messageBox:[MyTools topMostController] header:_(@"importgpx-Error parsing XML code") text:_(@"importgpx-An error occured while importing the GPX file.") error:[parseError.userInfo description]];
}

@end
