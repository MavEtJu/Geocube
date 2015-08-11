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

@implementation ImagesDownloadManager

@synthesize todo, activeDownload, imageConnection;

- (id)init
{
    self = [super init];

    if ([fm fileExistsAtPath:[MyTools ImagesDir]] == NO)
        [fm createDirectoryAtPath:[MyTools ImagesDir] withIntermediateDirectories:NO attributes:nil error:nil];
    todo = [NSMutableArray arrayWithCapacity:20];

    running = 0;

    return self;
}

- (void)start
{
    if (running == 0) {
        running = 10;
        [self performSelectorInBackground:@selector(run) withObject:nil];
    }
    running = 10;
}

- (void)run
{
    while (TRUE) {
        imgToDownload = nil;

        NSLog(@"%@/run: Queue is %ld deep", [self class], [todo count]);
        @synchronized (imagesDownloadManager) {
            if ([todo count] != 0)
                imgToDownload = [todo objectAtIndex:0];
        }
        // After 10 attempts stop, enough for now
        if (--running == 0)
            return;

        // Nothing to download, wait one second and try again.
        if (imgToDownload == nil) {
            [NSThread sleepForTimeInterval:1.0];
            continue;
        }

        // Make sure we don't accidently fall asleep
        running = 10;

        // It could be that multiple entries for the same URL is here.
        // If so, only download the first one.
        if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], imgToDownload.datafile ]] == YES) {
            NSLog(@"%@/run: Already found %@", [self class], imgToDownload.datafile);
            @synchronized (imagesDownloadManager) {
                [todo removeObjectAtIndex:0];
            }
            continue;
        }
        NSLog(@"%@/run: Downloading %@", [self class], imgToDownload.url);

        // Send a synchronous request
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imgToDownload.url]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

        if (error == nil) {
            NSLog(@"%@/run: Downloaded %@ (%ld bytes)", [self class], imgToDownload.url, [data length]);
            [data writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], imgToDownload.datafile] atomically:NO];
        } else {
            NSLog(@"Failed! %@", error);
        }

        @synchronized (imagesDownloadManager) {
            [todo removeObjectAtIndex:0];
        }
    }
}

+ (NSInteger)findImagesInDescription:(NSInteger)wp_id text:(NSString *)desc type:(NSInteger)type
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

        while ([[imgtag substringToIndex:1] compare:@" "] == NSOrderedSame) {
            imgtag = [imgtag substringFromIndex:1];
        }
        if ([[imgtag substringToIndex:1] compare:@"="] != NSOrderedSame) {
            NSLog(@"No =");
            continue;
        }
        imgtag = [imgtag substringFromIndex:1];
        while ([[imgtag substringToIndex:1] compare:@" "] == NSOrderedSame) {
            imgtag = [imgtag substringFromIndex:1];
        }
        //NSLog(@"%@", imgtag);

        // Search for the " or '
        NSString *quote = [imgtag substringToIndex:1];
        if ([quote compare:@"'"] != NSOrderedSame && [quote compare:@"\""] != NSOrderedSame)
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

        if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], img.datafile]] == NO) {
            @synchronized(imagesDownloadManager) {
                NSLog(@"%@/parse: Queue for downloading", [self class]);
                [imagesDownloadManager.todo addObject:img];
                [imagesDownloadManager start];
            }
        }

        found++;
    } while (next != nil);

    return found;
}

@end
