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

#define MAXHISTORY  10

@interface ImportViewController ()
{
    NSMutableArray *filenames;
    NSMutableArray *filenamesToBeRemoved;
    dbGroup *group;
    dbAccount *account;

    GCLabel *filenameLabel;
    GCLabel *newWaypointsLabel;
    GCLabel *totalWaypointsLabel;
    GCLabel *newLogsLabel;
    GCLabel *totalLogsLabel;
    GCLabel *newTrackablesLabel;
    GCLabel *totalTrackablesLabel;
    GCLabel *progressLabel;
    GCLabel *totalImagesLabel;
    GCLabel *downloadedImagesLabel;
    GCLabel *queuedImagesLabel;

    GCLabel *prevtotalWaypointsLabel;
    GCLabel *prevtotalLogsLabel;
    GCLabel *prevtotalTrackablesLabel;
    GCLabel *prevtotalImagesLabel;
    GCLabel *prevdownloadedImagesLabel;

    NSString *filenameString;
    NSInteger newWaypointsValue;
    NSInteger totalWaypointsValue;
    NSInteger newLogsValue;
    NSInteger totalLogsValue;
    NSInteger newTrackablesValue;
    NSInteger totalTrackablesValue;
    NSInteger progressValue;
    NSInteger totalImagesValue;
    NSInteger downloadedImagesValue;
    NSInteger queuedImagesValue;

    time_t prevpolls[MAXHISTORY], prevpoll;
    NSInteger prevtotalWaypointsValue[MAXHISTORY];
    NSInteger prevtotalLogsValue[MAXHISTORY];
    NSInteger prevtotalTrackablesValue[MAXHISTORY];
    NSInteger prevtotalImagesValue[MAXHISTORY];
    NSInteger prevdownloadedImagesValue[MAXHISTORY];

    Importer *imp;
}

@end

@implementation ImportViewController

- (instancetype)init
{
    self = [super init];

    group = nil;
    account = nil;

    prevpoll = time(NULL);
    for (NSInteger i = 0; i < MAXHISTORY; i++) {
        prevpolls[i] = prevpoll;
        prevdownloadedImagesValue[i] = 0;
        prevtotalImagesValue[i] = 0;
        prevtotalLogsValue[i] = 0;
        prevtotalTrackablesValue[i] = 0;
        prevtotalWaypointsValue[i] = 0;
    }

    return self;
}

- (void)setGroupAccount:(dbGroup *)_group account:(dbAccount *)_account
{
    group = _group;
    account = _account;
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [filenames addObject:[unzippedFilePath lastPathComponent]];
    [filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)viewDidLoad
{
    lmi = nil;
    hasCloseButton = YES;

    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    [self prepareCloseButton:contentView];

    [self addOrResizeFields];
}

- (void)run:(NSObject *)data;
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

    [self performSelectorInBackground:@selector(runImporter:) withObject:data];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self addOrResizeFields];
                                 }
     ];
}

- (void)addOrResizeFields
{
    @synchronized(self) {
        for (GCView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[GCCloseButton class]] == YES)
                continue;
            [subview removeFromSuperview];
        }

        NSInteger margin = 10;
        NSInteger labelOffset;
        NSInteger labelSize;
        NSInteger valueOffset;
        NSInteger valueSize;
        NSInteger height = myConfig.GCLabelFont.lineHeight;

        CGRect bounds = [[UIScreen mainScreen] bounds];
        NSInteger width = bounds.size.width;

        if (bounds.size.height > bounds.size.width) {
            labelOffset = margin;
            labelSize = 3 * width / 4 - 2 * margin;
            valueOffset = 3 * width / 4 + margin - myConfig.GCLabelFont.pointSize;
            valueSize = width / 4 - 2 * margin;
        } else {
            labelOffset = margin;
            labelSize = 2 * width / 4 - 2 * margin;
            valueOffset = 2 * width / 4 + margin - myConfig.GCLabelFont.pointSize;
            valueSize = width / 4 - 2 * margin;
        }

        NSInteger y = 0;
        GCLabel *l;

        filenameLabel = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, width - 2 * margin, height)];
        [filenameLabel setText:@"Import of ..."];
        filenameLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:filenameLabel];
        y += 1.5 * height;

        // Progress label
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Done:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        progressLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize + myConfig.GCLabelFont.pointSize, height)];
        progressLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:progressLabel];
        y += height;

        // New waypoint counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"New waypoints imported:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        newWaypointsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        newWaypointsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:newWaypointsLabel];
        y += height;

        // Total waypoint counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total waypoints read:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        totalWaypointsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        totalWaypointsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:totalWaypointsLabel];
        y += height;

        // New trackables counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"New trackables imported:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        newTrackablesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        newTrackablesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:newTrackablesLabel];
        y += height;

        // Total trackables counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total trackables read:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        totalTrackablesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        totalTrackablesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:totalTrackablesLabel];
        y += height;

        // New logs counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"New logs imported:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        newLogsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        newLogsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:newLogsLabel];
        y += height;

        // Total logs counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total logs read:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        totalLogsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        totalLogsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:totalLogsLabel];
        y += height;

        // Queued images counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"New images queued:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        queuedImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        queuedImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:queuedImagesLabel];
        y += height;

        // Downloaded images counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total images imported:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        downloadedImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        downloadedImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:downloadedImagesLabel];
        y += height;

        // Total images counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total images read:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        totalImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        totalImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:totalImagesLabel];
        y += height;

        y += height;

        // Waypoints per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Waypoints/s:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        prevtotalWaypointsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        prevtotalWaypointsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:prevtotalWaypointsLabel];
        y += height;

        // Logs per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Logs/s:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        prevtotalLogsLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        prevtotalLogsLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:prevtotalLogsLabel];
        y += height;

        // Trackables per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Trackables/s:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        prevtotalTrackablesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        prevtotalTrackablesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:prevtotalTrackablesLabel];
        y += height;

        // Images per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Images/s:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        prevtotalImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        prevtotalImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:prevtotalImagesLabel];
        y += height;

        // Downloaded images per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Images downloaded/s:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        prevdownloadedImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        prevdownloadedImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:prevdownloadedImagesLabel];
        y += height;

        // Downloaded images per second
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"(10 second average)";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        [self updateData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    imp.delegate = self;
    [imagesDownloadManager addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    imp.delegate = nil;
    [imagesDownloadManager removeDelegate:self];
}

- (void)runImporter:(NSObject *)data
{
    [imp parseBefore];

    imp.run_options = self.run_options;

    @autoreleasepool {
        if ([data isKindOfClass:[GCStringFilename class]] == YES) {
            [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    filenameString = [NSString stringWithFormat:@"Import of %@", filename];
                    [filenameLabel setText:filenameString];
                }];
                [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename]];
                progressValue = 100;
                [self updateData];
                [waypointManager needsRefresh];
            }];
        } else if ([data isKindOfClass:[GCStringGPX class]] == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                filenameString = [NSString stringWithFormat:@"Import of GPX string"];
                [filenameLabel setText:filenameString];
            }];
            [imp parseString:(NSString *)data];
            progressValue = 100;
            [self updateData];
        } else if ([data isKindOfClass:[GCDictionaryLiveAPI class]] == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                filenameString = [NSString stringWithFormat:@"Import of LiveAPI data"];
                [filenameLabel setText:filenameString];
            }];
            [imp parseDictionary:(NSDictionary *)data];
            progressValue = 100;
            [self updateData];
        } else if ([data isKindOfClass:[GCDictionaryGCA class]] == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                filenameString = [NSString stringWithFormat:@"Import of Geocaching Australia data"];
                [filenameLabel setText:filenameString];
            }];
            [imp parseDictionary:(NSDictionary *)data];
            progressValue = 100;
        } else if ([data isKindOfClass:[GCDictionaryOKAPI class]] == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                filenameString = [NSString stringWithFormat:@"Import of OKAPI data"];
                [filenameLabel setText:filenameString];
            }];
            [imp parseDictionary:(NSDictionary *)data];
            progressValue = 100;
        } else {
            NSAssert1(NO, @"Unknown data object type: %@", [data class]);
        }
    }

    [imp parseAfter];
    [MyTools playSound:playSoundImportComplete];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)importerDelegateUpdate
{
    @synchronized(self) {
        progressValue = imp.percentageRead;
        newWaypointsValue = imp.newWaypointsCount;
        totalWaypointsValue = imp.totalWaypointsCount;
        newLogsValue = imp.newLogsCount;
        totalLogsValue = imp.totalLogsCount;
        newTrackablesValue = imp.newTrackablesCount;
        totalTrackablesValue = imp.totalTrackablesCount;
        totalImagesValue = imp.newImagesCount;
        [self updateData];
    }
}



- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages
{
    @synchronized(self) {
        queuedImagesValue = queuedImages;
        downloadedImagesValue = downloadedImages;
        [self updateData];
    }
}

- (void)updateData
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        progressLabel.text = [NSString stringWithFormat:@"%@%%", [MyTools niceNumber:progressValue]];
        newWaypointsLabel.text = [MyTools niceNumber:newWaypointsValue];
        totalWaypointsLabel.text = [MyTools niceNumber:totalWaypointsValue];
        newLogsLabel.text = [MyTools niceNumber:newLogsValue];
        totalLogsLabel.text = [MyTools niceNumber:totalLogsValue];
        newTrackablesLabel.text = [MyTools niceNumber:newTrackablesValue];
        totalTrackablesLabel.text = [MyTools niceNumber:totalTrackablesValue];
        totalImagesLabel.text = [MyTools niceNumber:totalImagesValue];
        queuedImagesLabel.text = [MyTools niceNumber:queuedImagesValue];
        downloadedImagesLabel.text = [MyTools niceNumber:downloadedImagesValue];

        if (time(NULL) - prevpoll > 0) {
            for (NSInteger i = 0; i < MAXHISTORY - 1; i++) {
                prevdownloadedImagesValue[i] = prevdownloadedImagesValue[i + 1];
                prevtotalImagesValue[i] = prevtotalImagesValue[i + 1];
                prevtotalLogsValue[i] = prevtotalLogsValue[i + 1];
                prevtotalTrackablesValue[i] = prevtotalTrackablesValue[i + 1];
                prevtotalWaypointsValue[i] = prevtotalWaypointsValue[i + 1];

                prevpolls[i] = prevpolls[i + 1];
            }
            prevdownloadedImagesValue[MAXHISTORY - 1] = downloadedImagesValue;
            prevtotalImagesValue[MAXHISTORY - 1] = totalImagesValue;
            prevtotalLogsValue[MAXHISTORY - 1] = totalLogsValue;
            prevtotalTrackablesValue[MAXHISTORY - 1] = totalTrackablesValue;
            prevtotalWaypointsValue[MAXHISTORY - 1] = totalWaypointsValue;

            prevpoll = time(NULL);
            prevpolls[MAXHISTORY - 1] = prevpoll;

            double deltaT = prevpolls[MAXHISTORY - 1] - prevpolls[0];
#define DISPLAY(__a__, __b__) \
            __a__.text = [NSString stringWithFormat:@"%0.2f", (__b__[MAXHISTORY - 1] - __b__[0]) / deltaT]

            DISPLAY(prevdownloadedImagesLabel, prevdownloadedImagesValue);
            DISPLAY(prevtotalImagesLabel, prevtotalImagesValue);
            DISPLAY(prevtotalLogsLabel, prevtotalLogsValue);
            DISPLAY(prevtotalTrackablesLabel, prevtotalTrackablesValue);
            DISPLAY(prevtotalWaypointsLabel, prevtotalWaypointsValue);
        }
    }];
}

@end
