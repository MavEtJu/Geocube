/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

#import "ImportManager.h"

#import "Geocube-Globals.h"

#import "ToolsLibrary/MyTools.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "Convertors/ImportGGCWJSON.h"
#import "Convertors/ImportGPX.h"
#import "Convertors/ImportGPXGarmin.h"
#import "Convertors/ImportGCA2JSON.h"
#import "Convertors/ImportOKAPIJSON.h"
#import "Convertors/ImportLiveAPIJSON.h"
#import "BaseObjectsLibrary/GCString.h"
#import "BaseObjectsLibrary/GCArray.h"
#import "BaseObjectsLibrary/GCDictionary.h"
#import "DatabaseLibrary/dbWaypoint.h"
#import "ManagersLibrary/WaypointManager.h"

#import "InfoViewer.h"
#import "InfoItem.h"

@interface ImportManager ()
{
    NSMutableArray<NSString *> *filenames;
    NSMutableArray<NSString *> *filenamesToBeRemoved;

    NSMutableArray<NSString *> *processedWaypoints;
}

@end

@implementation ImportManager

- (instancetype)init
{
    self = [super init];

    processedWaypoints = [NSMutableArray arrayWithCapacity:100];

    return self;
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [filenames addObject:[unzippedFilePath lastPathComponent]];
    [filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)addToQueue:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions
{
    NSAssert(NO, @"addToQueue called");
}

- (NSArray<NSString *> *)process:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(ImportOptions)runoptions infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    if ([data isKindOfClass:[GCStringFilename class]] == YES) {
        NSString *_filename = [data description];
        filenamesToBeRemoved = [NSMutableArray arrayWithCapacity:1];
        filenames = [NSMutableArray arrayWithCapacity:1];
        if ([[_filename pathExtension] isEqualToString:@"gpx"] == YES) {
            [filenames addObject:_filename];
        }
        if ([[_filename pathExtension] isEqualToString:@"zip"] == YES) {
            NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], _filename];
            NSLog(@"Decompressing file '%@' to '%@'", fullname, [MyTools FilesDir]);
            [SSZipArchive unzipFileAtPath:fullname toDestination:[MyTools FilesDir] delegate:self];
        }
    }

    if ([data isKindOfClass:[GCArray class]] == YES) {
        GCArray *as = (GCArray *)data;
        [as enumerateObjectsUsingBlock:^(id a, NSUInteger idx, BOOL * _Nonnull stop) {
            [self process:a group:group account:account options:runoptions infoViewer:iv iiImport:iii];
        }];
        return processedWaypoints;
    }

    ImportTemplate *imp;
    if (data == nil) {
        // This happens when the run_options are PREONLY/POSTONLY
        imp = [[ImportTemplate alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCStringFilename class]] == YES ||
        [data isKindOfClass:[GCStringGPX class]] == YES) {
        imp = [[ImportGPX alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCStringGPXGarmin class]] == YES) {
        imp = [[ImportGPXGarmin alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryGCA2 class]] == YES) {
        imp = [[ImportGCA2JSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
        imp = [[ImportLiveAPIJSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
        imp = [[ImportOKAPIJSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryGGCW class]] == YES) {
        imp = [[ImportGGCWJSON alloc] init:group account:account];
    } else {
        NSAssert1(NO, @"Unknown data class: %@", [data class]);
    }

    imp.delegate = self;

    @synchronized (self) {
        [iv expand:iii yesno:YES];
        NSLog(@"%@ - My turn to import %@", [self class], [data class]);
        [self runImporter:imp data:(NSObject *)data run_options:runoptions infoViewer:iv iiImport:iii];
    }

    return processedWaypoints;
}

- (void)runImporter:(ImportTemplate *)imp data:(NSObject *)data run_options:(ImportOptions)run_options infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii
{
    imp.run_options = run_options;

    if ((run_options & IMPORTOPTION_NOPRE) == 0)
        [imp parseBefore];

    if (iv != nil) {
        [iv setLineObjectTotal:iii total:0 isLines:NO];
        [iv setWaypointsTotal:iii total:0];
        [iv setLogsTotal:iii total:0];
        [iv setTrackablesTotal:iii total:0];
    }

    if ((run_options & IMPORTOPTION_NOPARSE) == 0) {
        @autoreleasepool {
            if ([data isKindOfClass:[GCStringFilename class]] == YES) {
                [filenames enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
                    [iv setDescription:iii description:filename];
                    [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] infoViewer:iv iiImport:iii];
                    [waypointManager needsRefreshAll];
                }];
            } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-GPX data")];
                [imp parseString:(NSString *)data infoViewer:iv iiImport:iii];
            } else if ([data isKindOfClass:[GCStringGPXGarmin class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-GPX Garmin data")];
                [imp parseString:(NSString *)data infoViewer:iv iiImport:iii];
            } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-LiveAPI data")];
                [imp parseDictionary:(GCDictionaryLiveAPI *)data infoViewer:iv iiImport:iii];
            } else if ([data isKindOfClass:[GCDictionaryGCA2 class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-Geocaching Australia API data")];
                [imp parseDictionary:(GCDictionaryGCA2 *)data infoViewer:iv iiImport:iii];
            } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-OKAPI data")];
                [imp parseDictionary:(GCDictionaryOKAPI *)data infoViewer:iv iiImport:iii];
            } else if ([data isKindOfClass:[GCDictionaryGGCW class]] == YES) {
                [iv setDescription:iii description:_(@"importmanager-Geocaching.com data")];
                [imp parseDictionary:(GCDictionaryGGCW *)data infoViewer:iv iiImport:iii];
            } else {
                NSAssert1(NO, @"Unknown data object type: %@", [data class]);
            }
        }
    }

    if ((run_options & IMPORTOPTION_NOPOST) == 0)
        [imp parseAfter];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)resetImports
{
//    [downloadsImportsViewController resetImports];
}

- (void)Import_WaypointProcessed:(dbWaypoint *)wp
{
    [processedWaypoints addObject:wp.wpt_name];
}

@end
