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

@interface ImagesDownloadManager ()
{
    NSMutableArray *todo;
    NSInteger downloaded;

    dbImage *imgToDownload;

    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSURLConnection *conn;

    NSInteger running;
    NSMutableArray *delegates;
}

- (void)start;

@property (nonatomic, retain) NSMutableArray *todo;

@end

@implementation ImagesDownloadManager

@synthesize todo;

- (instancetype)init
{
    self = [super init];

    if ([fm fileExistsAtPath:[MyTools ImagesDir]] == NO)
        [fm createDirectoryAtPath:[MyTools ImagesDir] withIntermediateDirectories:NO attributes:nil error:nil];
    todo = [NSMutableArray arrayWithCapacity:20];

    running = 0;
    downloaded = 0;
    delegates = [NSMutableArray arrayWithCapacity:2];

    return self;
}

- (void)addDelegate:(id)_delegate
{
    __block BOOL found = NO;
    [delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_delegate == obj) {
            *stop = YES;
            found = YES;
        }
    }];
    if (found == YES) {
        NSLog(@"%@: not adding duplicate delegate", [self class]);
        return;
    }
    [delegates addObject:_delegate];
    NSLog(@"%@: adding delegate", [self class]);
}

- (void)removeDelegate:(id)_delegate
{
    __block BOOL found = NO;
    [delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_delegate == obj) {
            *stop = YES;
            found = YES;
        }
    }];
    if (found == YES) {
        [delegates removeObject:_delegate];
        NSLog(@"%@: removed delegate", [self class]);
        return;
    }
    NSLog(@"%@: not removing unknown delegate", [self class]);
}

- (void)start
{
    if (running == 0) {
        NSLog(@"%@/starting", [self class]);
        running = 10;
        [self performSelectorInBackground:@selector(run) withObject:nil];
    }
    running = 10;
}

- (void)run
{
    while (TRUE) {
        imgToDownload = nil;

        NSLog(@"%@/run: Queue is %ld deep", [self class], (unsigned long)[todo count]);
        @synchronized (imagesDownloadManager) {
            [delegates enumerateObjectsUsingBlock:^(id  _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
                [d updateQueuedImagesData:[todo count] downloadedImages:downloaded];
            }];
            if ([todo count] != 0)
                imgToDownload = [todo objectAtIndex:0];
        }
        // After 10 attempts stop, enough for now
        if (--running == 0) {
            NSLog(@"%@/stopping", [self class]);
            return;
        }

        // Nothing to download, wait one second and try again.
        if (imgToDownload == nil) {
            [NSThread sleepForTimeInterval:1.0];
            continue;
        }

        // Make sure we don't accidently fall asleep
        running = 10;

        // It could be that multiple entries for the same URL is here.
        // If so, only download the first one.
        if ([imgToDownload imageHasBeenDowloaded] == YES) {
            NSLog(@"%@/run: Already found %@", [self class], imgToDownload.datafile);
            @synchronized (imagesDownloadManager) {
                [todo removeObjectAtIndex:0];
            }
            continue;
        }

        NSLog(@"%@/run: Downloading %@", [self class], imgToDownload.url);

        // Send a synchronous request
        GCURLRequest *urlRequest = [GCURLRequest requestWithURL:[NSURL URLWithString:imgToDownload.url]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

        if (error == nil) {
            NSLog(@"%@/run: Downloaded %@ (%ld bytes)", [self class], imgToDownload.url, (unsigned long)[data length]);
            [data writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], imgToDownload.datafile] atomically:NO];
        } else {
            NSLog(@"Failed! %@", error);
        }

        @synchronized (imagesDownloadManager) {
            [todo removeObjectAtIndex:0];
        }
        downloaded++;
    }
}

+ (NSInteger)findImagesInDescription:(NSId)wp_id text:(NSString *)desc type:(NSInteger)type
{
    NSInteger found = 0;
    NSString *next = desc;

    if (desc == nil)
        return 0;

    do {
        NSString *d = next;
        next = nil;

        // Search for '<img'
        NSRange r = [d rangeOfString:@"<img" options:NSCaseInsensitiveSearch];
        if (r.location == NSNotFound)
            continue;
        NSString *imgtag = [d substringFromIndex:r.location];
        // Search for '>'
        NSRange s = [imgtag rangeOfString:@">"];
        if (s.location == NSNotFound)
            continue;

        imgtag = [imgtag substringToIndex:s.location];
        //NSLog(@"%@", imgtag);

        // Save the string after the '>'
        next = [d substringFromIndex:s.location + r.location];

        // Search for the 'src=' or 'src = ' or 'src= ' or 'src ='
        r = [imgtag rangeOfString:@"src" options:NSCaseInsensitiveSearch];
        if (r.location == NSNotFound)
            continue;

        imgtag = [imgtag substringFromIndex:r.location + r.length];

        while ([[imgtag substringToIndex:1] isEqualToString:@" "] == YES) {
            imgtag = [imgtag substringFromIndex:1];
        }
        if ([[imgtag substringToIndex:1] isEqualToString:@"="] == NO) {
            NSLog(@"No =");
            continue;
        }
        imgtag = [imgtag substringFromIndex:1];
        while ([[imgtag substringToIndex:1] isEqualToString:@" "] == YES) {
            imgtag = [imgtag substringFromIndex:1];
        }
        //NSLog(@"%@", imgtag);

        // Search for the " or '
        NSString *quote = [imgtag substringToIndex:1];
        if ([quote isEqualToString:@"'"] == NO && [quote isEqualToString:@"\""] == NO)
            quote = @" ";
        imgtag = [imgtag substringFromIndex:1];
        r = [imgtag rangeOfString:quote];
        if (r.location == NSNotFound) {
            NSLog(@"%@/parse: No trailing %@", [self class], quote);
            continue;
        }

        imgtag = [imgtag substringToIndex:r.location];
        NSString *datafile = [dbImage createDataFilename:imgtag];
        NSLog(@"%@/parse: Found image: %@", [self class], imgtag);

        dbImage *img = [dbImage dbGetByURL:imgtag];
        if (img == nil) {
            img = [[dbImage alloc] init:imgtag name:[dbImage filename:imgtag] datafile:datafile];
            [dbImage dbCreate:img];
        } else {
            //NSLog(@"%@/parse: Image already seen", [self class]);
        }

        if ([img dbLinkedtoWaypoint:wp_id] == NO)
            [img dbLinkToWaypoint:wp_id type:type];

        if ([img imageHasBeenDowloaded] == NO) {
            // Do nothing for images outside the waypoint data itself if they shouldn't be downloaded.
            if (type != IMAGETYPE_CACHE && myConfig.downloadImagesLogs == NO)
                return 0;

            [ImagesDownloadManager addToQueueImmediately:img];
        }

        found++;
    } while (next != nil);

    return found;
}

+ (void)addToQueue:(dbImage *)img
{
    // Do not download images if disabled.
    if (myConfig.downloadImagesWaypoints == NO)
        return;

    // Do not download anything unless Wifi is required and available.
    if (myConfig.downloadImagesMobile == NO && [MyTools hasWifiNetwork] == NO)
        return;

    [self addToQueueImmediately:img];
}

+ (void)addToQueueImmediately:(dbImage *)img
{
    @synchronized(imagesDownloadManager) {
        NSLog(@"%@/parse: Queue for downloading", [self class]);
        [imagesDownloadManager.todo addObject:img];
        [imagesDownloadManager start];
    }
}

@end
