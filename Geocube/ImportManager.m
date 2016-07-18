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

@interface ImportManager ()
{
    Importer *imp;
    NSMutableArray *filenames;
    NSMutableArray *filenamesToBeRemoved;
}

@end

@implementation ImportManager

@synthesize delegate;

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [filenames addObject:[unzippedFilePath lastPathComponent]];
    [filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)run:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions
{
    NSAssert(group != nil, @"group should be initialized");
    NSAssert(account != nil, @"account should be initialized");

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

    [self performSelectorInBackground:@selector(runImporter:) withObject:[NSArray arrayWithObjects:data, [NSNumber numberWithInteger:runoptions], nil]];
}

- (void)runImporter:(NSArray *)datas
{
    NSObject *data = [datas objectAtIndex:0];
    NSNumber *run_options = [datas objectAtIndex:1];

    [imp parseBefore];

    imp.run_options = [run_options integerValue];

    @synchronized (self) {
        @autoreleasepool {
            if ([data isKindOfClass:[GCStringFilename class]] == YES) {
                [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
                    [delegate importManager_setDescription:filename];
                    [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename]];
                    [waypointManager needsRefresh];
                }];
            } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
                [delegate importManager_setDescription:@"GPX data"];
                [imp parseString:(NSString *)data];
            } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
                [delegate importManager_setDescription:@"LiveAPI data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
                [delegate importManager_setDescription:@"Geocaching Australia data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
                [delegate importManager_setDescription:@"OKAPI data"];
                [imp parseDictionary:(NSDictionary *)data];
            } else {
                NSAssert1(NO, @"Unknown data object type: %@", [data class]);
            }
        }
    }

    [imp parseAfter];
    [MyTools playSound:playSoundImportComplete];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)resetImports
{
    [downloadsImportsViewController resetImports];
}

@end
