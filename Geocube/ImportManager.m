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

@interface ImportManager ()
{
    ImportTemplate *imp;
    NSMutableArray *filenames;
    NSMutableArray *filenamesToBeRemoved;

    NSMutableArray *queue;
}

@end

@implementation ImportManager

@synthesize downloadsImportsDelegate;

- (instancetype)init
{
    self = [super init];

    queue = [NSMutableArray arrayWithCapacity:10];

    return self;
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [filenames addObject:[unzippedFilePath lastPathComponent]];
    [filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)addToQueue:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions
{
    NSAssert(group != nil, @"group should be initialized");
    NSAssert(account != nil, @"account should be initialized");

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    [d setObject:data forKey:@"data"];
    [d setObject:group forKey:@"group"];
    [d setObject:account forKey:@"account"];
    [d setObject:[NSNumber numberWithInteger:runoptions] forKey:@"runoptions"];

    @synchronized (queue) {
        [queue addObject:d];
        if ([queue count] == 1) {
            NSLog(@"%@/starting", [self class]);
            [self performSelectorInBackground:@selector(runQueue) withObject:nil];
        }
        [downloadsImportsDelegate ImportManager_setQueueSize:[queue count]];
    }

}

- (void)runQueue
{
    NSDictionary *d;
    while (TRUE) {
        // If there is nothing left, leave.
        @synchronized (queue) {
            [downloadsImportsDelegate ImportManager_setQueueSize:[queue count]];
            if ([queue count] == 0)
                return;
            d = [queue objectAtIndex:0];
        }

        dbAccount *account = [d objectForKey:@"account"];
        dbGroup *group = [d objectForKey:@"group"];
        NSNumber *runoptions = [d objectForKey:@"runoptions"];
        NSObject *data = [d objectForKey:@"data"];

        [downloadsImportsDelegate importManager_setAccount:account];

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

        if ([data isKindOfClass:[GCStringFilename class]] == YES ||
            [data isKindOfClass:[GCStringGPX class]] == YES) {
            imp = [[ImportGPX alloc] init:group account:account];
        } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
            imp = [[ImportGCAJSON alloc] init:group account:account];
        } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
            imp = [[ImportLiveAPIJSON alloc] init:group account:account];
        } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
            imp = [[ImportOKAPIJSON alloc] init:group account:account];
        } else {
            NSAssert1(NO, @"Unknown data class: %@", [data class]);
        }
        imp.delegate = self;

        [self runImporter:data run_options:[runoptions integerValue]];

        // Remove the one just done.
        @synchronized (queue) {
            [queue removeObjectAtIndex:0];
        }
    }
}

- (void)runImporter:(NSObject *)data run_options:(NSInteger)run_options
{
    [imp parseBefore];

    imp.run_options = run_options;

    @synchronized (self) {
        @autoreleasepool {
            if ([data isKindOfClass:[GCStringFilename class]] == YES) {
                [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
                    [downloadsImportsDelegate importManager_setDescription:filename];
                    [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename]];
                    [waypointManager needsRefreshAll];
                }];
            } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
                [downloadsImportsDelegate importManager_setDescription:@"GPX data"];
                [imp parseString:(NSString *)data];
            } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
                [downloadsImportsDelegate importManager_setDescription:@"LiveAPI data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
                [downloadsImportsDelegate importManager_setDescription:@"Geocaching Australia data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
                [downloadsImportsDelegate importManager_setDescription:@"OKAPI data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else {
                NSAssert1(NO, @"Unknown data object type: %@", [data class]);
            }
        }
    }

    [imp parseAfter];
    [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)resetImports
{
    [downloadsImportsViewController resetImports];
}

/////////////////////////////////////////////////////////

- (void)Import_setNewWaypoints:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setNewWaypoints:v];
}

- (void)Import_setNewLogs:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setNewLogs:v];
}

- (void)Import_setNewTrackables:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setNewTrackables:v];
}

- (void)Import_setTotalWaypoints:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setTotalWaypoints:v];
}

- (void)Import_setTotalLogs:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setTotalLogs:v];
}

- (void)Import_setTotalTrackables:(NSInteger)v
{
    [downloadsImportsDelegate ImportManager_setTotalTrackables:v];
}

- (void)Import_setProgress:(NSInteger)v total:(NSInteger)t
{
    [downloadsImportsDelegate ImportManager_setProgress:v total:t];
}

@end
