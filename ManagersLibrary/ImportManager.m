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

@interface ImportManager ()

@property (nonatomic, retain) NSMutableArray<NSString *> *filenames;
@property (nonatomic, retain) NSMutableArray<NSString *> *filenamesToBeRemoved;
@property (nonatomic, retain) NSMutableArray<NSString *> *processedWaypoints;

@end

@implementation ImportManager

- (instancetype)init
{
    self = [super init];

    self.processedWaypoints = [NSMutableArray arrayWithCapacity:100];

    return self;
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [self.filenames addObject:[unzippedFilePath lastPathComponent]];
    [self.filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)addToQueue:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions
{
    NSAssert(NO, @"addToQueue called");
}

- (NSArray<NSString *> *)process:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(ImportOptions)runoptions infoItem:(InfoItem *)iii
{
    if ([data isKindOfClass:[GCStringFilename class]] == YES) {
        NSString *_filename = [data description];
        self.filenamesToBeRemoved = [NSMutableArray arrayWithCapacity:1];
        self.filenames = [NSMutableArray arrayWithCapacity:1];
        if ([[_filename pathExtension] isEqualToString:@"gpx"] == YES) {
            [self.filenames addObject:_filename];
        }
        if ([[_filename pathExtension] isEqualToString:@"zip"] == YES) {
            NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], _filename];
            NSLog(@"Decompressing file '%@' to '%@'", fullname, [MyTools FilesDir]);
            [SSZipArchive unzipFileAtPath:fullname toDestination:[MyTools FilesDir] delegate:self];
        }
    }

    if ([data isKindOfClass:[GCArray class]] == YES) {
        GCArray *as = (GCArray *)data;
        [as enumerateObjectsUsingBlock:^(NSObject * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
            [self process:a group:group account:account options:runoptions infoItem:iii];
        }];
        return self.processedWaypoints;
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

    @synchronized(self) {
        [iii changeExpanded:YES];
        NSLog(@"%@ - My turn to import %@", [self class], [data class]);
        [self runImporter:imp data:(NSObject *)data run_options:runoptions infoItem:iii];
    }

    return self.processedWaypoints;
}

- (void)runImporter:(ImportTemplate *)imp data:(NSObject *)data run_options:(ImportOptions)run_options infoItem:(InfoItem *)iii
{
    imp.run_options = run_options;

    if ((run_options & IMPORTOPTION_NOPRE) == 0)
        [imp parseBefore];

    if (iii != nil) {
        [iii changeLineObjectTotal:0 isLines:NO];
        [iii changeWaypointsTotal:0];
        [iii changeLogsTotal:0];
        [iii changeTrackablesTotal:0];
    }

    if ((run_options & IMPORTOPTION_NOPARSE) == 0) {
        @autoreleasepool {
            if ([data isKindOfClass:[GCStringFilename class]] == YES) {
                [self.filenames enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
                    [iii changeDescription:filename];
                    [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] infoItem:iii];
                    [waypointManager needsRefreshAll];
                }];
            } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
                [iii changeDescription:_(@"importmanager-GPX data")];
                [imp parseString:(NSString *)data infoItem:iii];
            } else if ([data isKindOfClass:[GCStringGPXGarmin class]] == YES) {
                [iii changeDescription:_(@"importmanager-GPX Garmin data")];
                [imp parseString:(NSString *)data infoItem:iii];
            } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
                [iii changeDescription:_(@"importmanager-LiveAPI data")];
                [imp parseDictionary:(GCDictionaryLiveAPI *)data infoItem:iii];
            } else if ([data isKindOfClass:[GCDictionaryGCA2 class]] == YES) {
                [iii changeDescription:_(@"importmanager-Geocaching Australia API data")];
                [imp parseDictionary:(GCDictionaryGCA2 *)data infoItem:iii];
            } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
                [iii changeDescription:_(@"importmanager-OKAPI data")];
                [imp parseDictionary:(GCDictionaryOKAPI *)data infoItem:iii];
            } else if ([data isKindOfClass:[GCDictionaryGGCW class]] == YES) {
                [iii changeDescription:_(@"importmanager-Geocaching.com data")];
                [imp parseDictionary:(GCDictionaryGGCW *)data infoItem:iii];
            } else {
                NSAssert1(NO, @"Unknown data object type: %@", [data class]);
            }
        }
    }

    if ((run_options & IMPORTOPTION_NOPOST) == 0)
        [imp parseAfter];

    [self.filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString * _Nonnull filename, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)resetImports
{
//    [downloadsImportsViewController resetImports];
}

- (void)Import_WaypointProcessed:(dbWaypoint *)wp
{
    [self.processedWaypoints addObject:wp.wpt_name];
}

@end
