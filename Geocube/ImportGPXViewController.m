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

@implementation ImportGPXViewController

- (instancetype)init:(NSString *)_filename group:(dbGroup *)_group account:(dbAccount *)_account
{
    self = [super init];

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

    group = _group;
    account = _account;

    menuItems = nil;
    hasCloseButton = YES;

    return self;
}

- (void)zipArchiveDidUnzipFileAtIndex:(NSInteger)fileIndex totalFiles:(NSInteger)totalFiles archivePath:(NSString *)archivePath unzippedFilePath:(NSString *)unzippedFilePath
{
    [filenames addObject:[unzippedFilePath lastPathComponent]];
    [filenamesToBeRemoved addObject:[unzippedFilePath lastPathComponent]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    [self addOrResizeFields];

    imp = [[ImportGPX alloc] init:group account:account];

    [self performSelectorInBackground:@selector(run) withObject:nil];
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
        if (filenameString == nil)
            [filenameLabel setText:@"Import of ?"];
        else
            [filenameLabel setText:[NSString stringWithFormat:@"Import of %@", filenameString]];
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

        // Total images counter
        l = [[GCLabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
        l.text = @"Total images read:";
        l.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:l];

        totalImagesLabel = [[GCLabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
        totalImagesLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:totalImagesLabel];
        y += height;

        [self updateData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    imp.delegate = self;
    imagesDownloadManager.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    imp.delegate = nil;
    imagesDownloadManager.delegate = nil;
}

- (void)run
{
    [imp parseBefore];
    @autoreleasepool {
        [filenames enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                filenameString = filename;
                [filenameLabel setText:[NSString stringWithFormat:@"Import of %@", filename]];
            }];
            [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename]];
            progressValue = 100;
            [self updateData];
            [waypointManager needsRefresh];
        }];
    }
    [imp parseAfter];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)updateData:(NSInteger)percentageRead newWaypointsCount:(NSInteger)newWaypointsCount totalWaypointsCount:(NSInteger)totalWaypointsCount newLogsCount:(NSInteger)newLogsCount totalLogsCount:(NSInteger)totalLogsCount newTrackablesCount:(NSInteger)newTrackablesCount totalTrackablesCount:(NSInteger)totalTrackablesCount newImagesCount:(NSInteger)newImagesCount
{
    @synchronized(self) {
        progressValue = percentageRead;
        newWaypointsValue = newWaypointsCount;
        totalWaypointsValue = totalWaypointsCount;
        newLogsValue = newLogsCount;
        totalLogsValue = totalLogsCount;
        newTrackablesValue = newTrackablesCount;
        totalTrackablesValue = totalTrackablesCount;
        totalImagesValue = newImagesCount;
        [self updateData];
    }
}

- (void)updateData:(NSInteger)queuedImages
{
    @synchronized(self) {
        queuedImagesValue = queuedImages;
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
    }];
}

@end
