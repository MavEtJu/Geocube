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

@interface ImagesDownloadManager ()

@property (nonatomic        ) NSInteger downloaded;

@property (nonatomic, retain) dbImage *imgToDownload;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSURLConnection *conn;

@property (nonatomic        ) NSInteger running;

@property (nonatomic, retain) NSMutableArray<dbImage *> *todo;

- (void)start;

@end

@implementation ImagesDownloadManager

- (instancetype)init
{
    self = [super init];

    NSString *imagesDir = [MyTools ImagesDir];

    if ([fileManager fileExistsAtPath:imagesDir] == NO)
        [fileManager createDirectoryAtPath:imagesDir withIntermediateDirectories:NO attributes:nil error:nil];

    for (char c1 = 'a'; c1 <= 'f'; c1++) {
        for (char c2 = 'a'; c2 <= 'f'; c2++) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%c/%c", imagesDir, c1, c2] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        for (char c2 = '0'; c2 <= '9'; c2++) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%c/%c", imagesDir, c1, c2] withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }

    for (char c1 = '0'; c1 <= '9'; c1++) {
        for (char c2 = 'a'; c2 <= 'f'; c2++) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%c/%c", imagesDir, c1, c2] withIntermediateDirectories:YES attributes:nil error:nil];
        }
        for (char c2 = '0'; c2 <= '9'; c2++) {
            [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%c/%c", imagesDir, c1, c2] withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }

    // Should be done only once
    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:imagesDir error:nil];
    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        // Check if it isn't a directory
        NSString *oldName = [NSString stringWithFormat:@"%@/%@", imagesDir, file];
        BOOL isDirectory;
        [fileManager fileExistsAtPath:oldName isDirectory:&isDirectory];
        if (isDirectory == YES)
            return;
        [fileManager moveItemAtPath:oldName toPath:[MyTools ImageFile:file] error:nil];
    }];

    // Queued files to download

    self.todo = [NSMutableArray<dbImage *> arrayWithCapacity:20];

    self.running = 0;
    self.downloaded = 0;

    return self;
}

- (void)start
{
    if (self.running == 0) {
        NSLog(@"%@/starting", [self class]);
        self.running = 10;
        BACKGROUND(run, nil);
    }
    self.running = 10;
}

- (void)run
{
    while (TRUE) {
        self.imgToDownload = nil;

        NSLog(@"%@/run: Queue is %ld deep", [self class], (unsigned long)[self.todo count]);
        @synchronized(imagesDownloadManager) {
            if ([self.todo count] != 0)
                self.imgToDownload = [self.todo objectAtIndex:0];
        }
        // After 10 attempts stop, enough for now
        if (--self.running == 0) {
            NSLog(@"%@/stopping", [self class]);
            return;
        }

        // Nothing to download, wait one second and try again.
        if (self.imgToDownload == nil) {
            [NSThread sleepForTimeInterval:1.0];
            continue;
        }

        // Make sure we don't accidently fall asleep
        self.running = 10;

        // It could be that multiple entries for the same URL is here.
        // If so, only download the first one.
        if ([self.imgToDownload imageHasBeenDowloaded] == YES) {
            NSLog(@"%@/run: Already found %@", [self class], self.imgToDownload.datafile);
            @synchronized(imagesDownloadManager) {
                [self.todo removeObjectAtIndex:0];
            }
            continue;
        }

        NSLog(@"%@/run: Downloading %@", [self class], self.imgToDownload.url);

        // Send a synchronous request
        GCURLRequest *urlRequest = [GCURLRequest requestWithURL:[NSURL URLWithString:self.imgToDownload.url]];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [downloadManager downloadImage:urlRequest returningResponse:&response error:&error];

        if (error == nil) {
            NSLog(@"%@/run: Downloaded %@ (%ld bytes)", [self class], self.imgToDownload.url, (unsigned long)[data length]);
            [data writeToFile:[MyTools ImageFile:self.imgToDownload.datafile] atomically:NO];
        } else {
            NSLog(@"Failed! %@", error);
        }

        @synchronized(imagesDownloadManager) {
            [self.todo removeObjectAtIndex:0];
        }
        self.downloaded++;
    }
}

+ (NSInteger)findImagesInDescription:(dbWaypoint *)wp text:(NSString *)desc type:(NSInteger)type
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

        if ([imgtag length] < 5) {
            NSLog(@"%@/parse: Not long enough %@", [self class], quote);
            continue;
        }

        if ([[imgtag substringToIndex:5] isEqualToString:@"file:"] == YES) {
            NSLog(@"%@/parse: file:// URL", [self class]);
            continue;
        }

        if ([[imgtag substringToIndex:5] isEqualToString:@"data:"] == YES) {
            if ([self downloadImage:wp url:imgtag name:[dbImage filename:imgtag] type:type] == YES)
                found++;
            NSLog(@"%@/parse: Found image: data:-URL", [self class]);
            continue;
        }

        if ([self downloadImage:wp url:imgtag name:[dbImage filename:imgtag] type:type] == YES)
            found++;
        NSLog(@"%@/parse: Found image: %@", [self class], imgtag);

    } while (next != nil);

    return found;
}

+ (BOOL)downloadImage:(dbWaypoint *)wp url:(NSString *)url name:(NSString *)name type:(NSInteger)type
{
    NSString *datafile = [dbImage createDataFilename:url];
    dbImage *img = [dbImage dbGetByURL:url];
    if (img == nil) {
        img = [[dbImage alloc] init];
        img.url = url;
        img.name = name;
        img.datafile = datafile;
        [img dbCreate];
    }

    if ([img dbLinkedtoWaypoint:wp] == NO)
        [img dbLinkToWaypoint:wp type:type];

    if ([img imageHasBeenDowloaded] == NO) {
        // Do nothing for images outside the waypoint data itself if they shouldn't be downloaded.
        if (type != IMAGECATEGORY_CACHE && configManager.downloadImagesLogs == NO)
            return NO;

        [ImagesDownloadManager addToQueueImmediately:img];
    }

    return YES;
}

+ (void)addToQueue:(dbImage *)img imageType:(ImageCategory)imageType
{
    // Do not download images if disabled.
    if (configManager.downloadImagesWaypoints == NO)
        return;

    // Do not download anything unless Wifi is required and available.
    if (configManager.downloadImagesMobile == NO && [MyTools hasWifiNetwork] == NO)
        return;

    // Check if the image type is a log and if it needs to be downloaded
    if (configManager.downloadImagesLogs == NO && imageType == IMAGECATEGORY_LOG)
        return;

    // Check if the image type is a waypoint image and if it needs to be downloaded
    if (configManager.downloadImagesWaypoints == NO && imageType == IMAGECATEGORY_CACHE)
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
