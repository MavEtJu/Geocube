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

@implementation Import_GPX

- (id)init:(NSString *)filename group:(dbCacheGroup *)_group newCachesCount:(NSInteger *)nCC totalCachesCount:(NSInteger *)tCC newLogsCount:(NSInteger *)nLC totalLogsCount:(NSInteger *)tLC percentageRead:(NSUInteger *)pR newTravelbugsCount:(NSInteger *)nTC totalTravelbugsCount:(NSInteger *)tTC
{
    newCachesCount = nCC;
    totalCachesCount = tCC;
    newLogsCount = nLC;
    totalLogsCount = tLC;
    percentageRead = pR;
    newTravelbugsCount = nTC;
    totalTravelbugsCount = tTC;

    group = _group;

    NSLog(@"Import_GPX: Importing %@ into %@", filename, group.name);

    files = @[filename];
    NSLog(@"Found %ld files", [files count]);
    return self;
}

- (void)parse
{
    [dbc.CacheGroup_LastImport dbEmpty];
    [dbc.CacheGroup_LastImportAdded dbEmpty];

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
        currentC = [[dbCache alloc] init];
        [currentC setLat:[attributeDict objectForKey:@"lat"]];
        [currentC setLon:[attributeDict objectForKey:@"lon"]];

        logs = [NSMutableArray arrayWithCapacity:20];
        attributes = [NSMutableArray arrayWithCapacity:20];
        travelbugs = [NSMutableArray arrayWithCapacity:20];

        inItem = YES;
        return;
    }

    if ([currentElement compare:@"groundspeak:cache"] == NSOrderedSame) {
        [currentC setGc_archived:[[attributeDict objectForKey:@"archived"] boolValue]];
        [currentC setGc_available:[[attributeDict objectForKey:@"available"] boolValue]];
        return;
    }

    if ([currentElement compare:@"groundspeak:long_description"] == NSOrderedSame) {
        [currentC setGc_long_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
        return;
    }

    if ([currentElement compare:@"groundspeak:short_description"] == NSOrderedSame) {
        [currentC setGc_short_desc_html:[[attributeDict objectForKey:@"html"] boolValue]];
        return;
    }

    if ([currentElement compare:@"groundspeak:log"] == NSOrderedSame) {
        currentLog = [[dbLog alloc] init];
        [currentLog setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
        inLog = YES;
        return;
    }

    if ([currentElement compare:@"groundspeak:travelbug"] == NSOrderedSame) {
        currentTB = [[dbTravelbug alloc] init];
        [currentTB setGc_id:[[attributeDict objectForKey:@"id"] integerValue]];
        [currentTB setRef:[attributeDict objectForKey:@"ref"]];
        inTravelbug = YES;
        return;
    }

    if ([currentElement compare:@"groundspeak:attribute"] == NSOrderedSame) {
        NSInteger _id = [[attributeDict objectForKey:@"id"] integerValue];
        BOOL YesNo = [[attributeDict objectForKey:@"inc"] boolValue];
        dbAttribute *a = [dbc Attribute_get_bygcid:_id];
        a._YesNo = YesNo;
        [attributes addObject:[dbc Attribute_get_bygcid:_id]];
        return;
    }

    return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    index--;

    [currentText replaceOccurrencesOfString:@"\\s+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [currentText length])];

    // Deal with the completion of the cache
    if (index == 1 && [elementName compare:@"wpt"] == NSOrderedSame) {
        [currentC finish];

        NSInteger cwp_id = [dbCache dbGetByName:currentC.name];
        (*totalCachesCount)++;
        if (cwp_id == 0) {
            cwp_id = [dbCache dbCreate:currentC];
            (*newCachesCount)++;

            [dbc.CacheGroup_LastImportAdded dbAddCache:cwp_id];
            [dbc.CacheGroup_AllCaches dbAddCache:cwp_id];
            [group dbAddCache:cwp_id];
        } else {
            currentC._id = cwp_id;
            [currentC dbUpdate];
            if ([group dbContainsCache:cwp_id] == NO)
                [group dbAddCache:cwp_id];
        }
        [dbc.CacheGroup_LastImport dbAddCache:cwp_id];

        // Link logs to cache
        NSEnumerator *e = [logs objectEnumerator];
        dbLog *l;
        while ((l = [e nextObject]) != nil) {
            [l dbUpdateCache:cwp_id];
        }

        // Link attributes to cache
        [dbAttribute dbUnlinkAllFromCache:cwp_id];
        e = [attributes objectEnumerator];
        dbAttribute *a;
        while ((a = [e nextObject]) != nil) {
            [a dbLinkToCache:cwp_id YesNo:a._YesNo];
        }

        // Link travelbugs to cache
        [dbTravelbug dbUnlinkAllFromCache:cwp_id];
        e = [travelbugs objectEnumerator];
        dbTravelbug *tb;
        while ((tb = [e nextObject]) != nil) {
            [tb dbLinkToCache:cwp_id];
        }

        inItem = NO;
        goto bye;
    }

    // Deal with the completion of the travelbug
    if (index == 4 && inTravelbug == YES && [elementName compare:@"groundspeak:travelbug"] == NSOrderedSame) {
        [currentTB finish];

        NSInteger tb_id = [dbTravelbug dbGetIdByGC:currentTB.gc_id];
        (*totalTravelbugsCount)++;
        if (tb_id == 0) {
            (*newTravelbugsCount)++;
            currentTB._id = [dbTravelbug dbCreate:currentTB];
        } else {
            currentTB._id = tb_id;
            [currentTB dbUpdate];
        }
        [travelbugs addObject:currentTB];

        inTravelbug = NO;
        goto bye;
    }

    // Deal with the completion of the log
    if (index == 4 && inLog == YES && [elementName compare:@"groundspeak:log"] == NSOrderedSame) {
        [currentLog finish];

        NSInteger log_id = [dbLog dbGetIdByGC:currentLog.gc_id];
        (*totalLogsCount)++;
        if (log_id == 0) {
            (*newLogsCount)++;
            currentLog._id = [dbLog dbCreate:currentLog];
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
            if ([elementName compare:@"groundspeak:name"] == NSOrderedSame) {
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

    // Deal with the data of the cache. Always the last one!
    if (inItem == YES) {
        if (index == 2 && currentText != nil) {
            if ([elementName compare:@"time"] == NSOrderedSame) {
                [currentC setDate_placed:currentText];
                goto bye;
            }
            if ([elementName compare:@"name"] == NSOrderedSame) {
                [currentC setName:currentText];
                goto bye;
            }
            if ([elementName compare:@"desc"] == NSOrderedSame) {
                [currentC setDescription:currentText];
                goto bye;
            }
            if ([elementName compare:@"url"] == NSOrderedSame) {
                [currentC setUrl:currentText];
                goto bye;
            }
            if ([elementName compare:@"sym"] == NSOrderedSame) {
                if ([dbc CacheSymbol_get_bysymbol:currentText] == nil) {
                    NSLog(@"Adding symbol '%@'", currentText);
                    NSInteger _id = [dbCacheSymbol dbCreate:currentText];
                    [dbc CacheSymbols_add:_id symbol:currentText];
                }
                [currentC setCache_symbol_str:currentText];
                goto bye;
            }
            if ([elementName compare:@"type"] == NSOrderedSame) {
                [currentC setCache_type:[dbc CacheType_get_byname:currentText]];
                [currentC setCache_type_int:currentC.cache_type._id];
                goto bye;
            }
            goto bye;
        }
        if (index == 3 && currentText != nil) {
            if ([elementName compare:@"groundspeak:difficulty"] == NSOrderedSame) {
                [currentC setGc_rating_difficulty:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:terrain"] == NSOrderedSame) {
                [currentC setGc_rating_terrain:[currentText floatValue]];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:country"] == NSOrderedSame) {
                [currentC setGc_country:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:state"] == NSOrderedSame) {
                [currentC setGc_state:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:container"] == NSOrderedSame) {
                [currentC setGc_containerSize_str:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:short_description"] == NSOrderedSame) {
                [currentC setGc_short_desc:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:long_description"] == NSOrderedSame) {
                [currentC setGc_long_desc:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:encoded_hints"] == NSOrderedSame) {
                [currentC setGc_hint:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:owner"] == NSOrderedSame) {
                [currentC setGc_owner:currentText];
                goto bye;
            }
            if ([elementName compare:@"groundspeak:placed_by"] == NSOrderedSame) {
                [currentC setGc_placed_by:currentText];
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
    *percentageRead = 100 * parser.lineNumber / totalLines;
    if (string == nil)
        return;
    if (currentText == nil)
        currentText = [[NSMutableString alloc] initWithString:string];
    else
        [currentText appendString:string];
    return;
}

@end
