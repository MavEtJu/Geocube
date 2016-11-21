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

@interface ImportManager ()
{
    NSMutableArray *filenames;
    NSMutableArray *filenamesToBeRemoved;
}

@end

@implementation ImportManager

- (instancetype)init
{
    self = [super init];

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

- (void)process:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions infoItemImport:(InfoItemImport *)iii
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
        [as enumerateObjectsUsingBlock:^(id a, NSUInteger idx, BOOL *stop) {
            [self process:a group:group account:account options:runoptions infoItemImport:iii];
        }];
        return;
    }

    ImportTemplate *imp;
    if ([data isKindOfClass:[GCStringFilename class]] == YES ||
        [data isKindOfClass:[GCStringGPX class]] == YES) {
        imp = [[ImportGPX alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCStringGPXGarmin class]] == YES) {
        imp = [[ImportGPXGarmin alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryGCA2 class]] == YES) {
        imp = [[ImportGCA2JSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
        imp = [[ImportGCAJSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
        imp = [[ImportLiveAPIJSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
        imp = [[ImportOKAPIJSON alloc] init:group account:account];
    } else if ([data isKindOfClass:[GCDictionaryGGCW class]] == YES) {
        imp = [[ImportGGCWJSON alloc] init:group account:account];
    } else {
        NSAssert1(NO, @"Unknown data class: %@", [data class]);
    }

    @synchronized (self) {
        [iii expand:YES];
        NSLog(@"%@ - My turn to import %@", [self class], [data class]);
        [self runImporter:imp data:(NSObject *)data run_options:runoptions infoItemImport:iii];
    }
}

- (void)runImporter:(ImportTemplate *)imp data:(NSObject *)data run_options:(NSInteger)run_options infoItemImport:(InfoItemImport *)iii
{
    [imp parseBefore];

    imp.run_options = run_options;
    [iii setLineObjectTotal:0 isLines:NO];
    [iii setWaypointsTotal:0];
    [iii setLogsTotal:0];
    [iii setTrackablesTotal:0];

    @autoreleasepool {
        if ([data isKindOfClass:[GCStringFilename class]] == YES) {
            [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
                [iii setDescription:filename];
                [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] infoItemImport:iii];
                [waypointManager needsRefreshAll];
            }];
        } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
            [iii setDescription:@"GPX data"];
            [imp parseString:(NSString *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCStringGPXGarmin class]] == YES) {
            [iii setDescription:@"GPX Garmin data"];
            [imp parseString:(NSString *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
            [iii setDescription:@"LiveAPI data"];
            [imp parseDictionary:(GCDictionaryLiveAPI *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCDictionaryGCA2 class]] == YES) {
            [iii setDescription:@"Geocaching Australia API data"];
            [imp parseDictionary:(GCDictionaryGCA2 *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
            [iii setDescription:@"Geocaching Australia data"];
            [imp parseDictionary:(GCDictionaryGCA *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
            [iii setDescription:@"OKAPI data"];
            [imp parseDictionary:(GCDictionaryOKAPI *)data infoItemImport:iii];
        } else if ([data isKindOfClass:[GCDictionaryGGCW class]] == YES) {
            [iii setDescription:@"Geocaching.com data"];
            [imp parseDictionary:(GCDictionaryGGCW *)data infoItemImport:iii];
        } else {
            NSAssert1(NO, @"Unknown data object type: %@", [data class]);
        }
    }

    [imp parseAfter];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)resetImports
{
//    [downloadsImportsViewController resetImports];
}

@end
