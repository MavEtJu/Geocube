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

@interface DownloadsImportsViewController ()
{
    GCLabel *labelDownloading;
    GCLabel *labelDownloadingDescription;
    GCLabel *labelDownloadingURL;
    GCLabel *labelDownloadingNumber;

    GCLabel *labelBGDownloading;
    GCLabel *labelBGDownloadingDescription;
    GCLabel *labelBGDownloadingURL;
    GCLabel *labelBGDownloadingNumber;
    GCLabel *labelBGPending;
    GCLabel *labelBGPendingQueued;

    GCLabel *labelImport;
    GCLabel *labelImportFilename;
    GCLabel *labelImportNewWaypoints;
    GCLabel *labelImportTotalWaypoints;
    GCLabel *labelImportNewLogs;
    GCLabel *labelImportTotalLogs;
    GCLabel *labelImportNewTrackables;
    GCLabel *labelImportTotalTrackables;
    GCLabel *labelImportTotalImages;
    GCLabel *labelImportQueuedImages;

    NSInteger valueDownloadingNumberDownloaded;
    NSInteger valueDownloadingNumberTotal;

    time_t prevpolls[MAXHISTORY], prevpoll;
    NSInteger prevtotalWaypointsValue[MAXHISTORY];
    NSInteger prevtotalLogsValue[MAXHISTORY];
    NSInteger prevtotalTrackablesValue[MAXHISTORY];
    NSInteger prevtotalImagesValue[MAXHISTORY];
    NSInteger prevdownloadedImagesValue[MAXHISTORY];
}

@end

@implementation DownloadsImportsViewController

- (instancetype)init
{
    self = [super init];

    prevpoll = time(NULL);
    for (NSInteger i = 0; i < MAXHISTORY; i++) {
        prevpolls[i] = prevpoll;
        prevdownloadedImagesValue[i] = 0;
        prevtotalImagesValue[i] = 0;
        prevtotalLogsValue[i] = 0;
        prevtotalTrackablesValue[i] = 0;
        prevtotalWaypointsValue[i] = 0;
    }

    valueDownloadingNumberDownloaded = 0;
    valueDownloadingNumberTotal = 0;

    return self;
}

- (void)showDownloadManager
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_AppDelegate switchController:RC_DOWNLOADS];
        [downloadTabController setSelectedIndex:VC_DOWNLOADS_DOWNLOADS animated:YES];
    }];
}

- (void)viewDidLoad
{
    lmi = nil;

    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    labelDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDownloading.text = @"Downloading";
    [self.view addSubview:labelDownloading];
    labelDownloadingDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDownloadingDescription.text = @"(downloadingDescription)";
    [self.view addSubview:labelDownloadingDescription];
    labelDownloadingURL = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDownloadingURL.text = @"(downloadingURL)";
    [self.view addSubview:labelDownloadingURL];
    labelDownloadingNumber = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelDownloadingNumber.text = @"(downloadingNumber)";
    [self.view addSubview:labelDownloadingNumber];

    labelBGDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGDownloading.text = @"Background downloading";
    [self.view addSubview:labelBGDownloading];
    labelBGDownloadingDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGDownloadingDescription.text = @"(bgdownloadingDescription)";
    [self.view addSubview:labelBGDownloadingDescription];
    labelBGDownloadingURL = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGDownloadingURL.text = @"(bgdownloadingURL)";
    [self.view addSubview:labelBGDownloadingURL];
    labelBGDownloadingNumber = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGDownloadingNumber.text = @"(bgdownloadingNumber)";
    [self.view addSubview:labelBGDownloadingNumber];
    labelBGPending = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGPending.text = @"Pending";
    [self.view addSubview:labelBGPending];
    labelBGPendingQueued = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGPendingQueued.text = @"(bgpendingQueued)";
    [self.view addSubview:labelBGPendingQueued];

    labelImport = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImport.text = @"Importing";
    [self.view addSubview:labelImport];
    labelImportFilename = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportFilename.text = @"(importFilename)";
    [self.view addSubview:labelImportFilename];
    labelImportNewWaypoints = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportNewWaypoints.text = @"(importNewWaypoints)";
    [self.view addSubview:labelImportNewWaypoints];
    labelImportTotalWaypoints = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportTotalWaypoints.text = @"(importTotalWaypoints)";
    [self.view addSubview:labelImportTotalWaypoints];
    labelImportNewLogs = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportNewLogs.text = @"(labelImportNewLogs)";
    [self.view addSubview:labelImportNewLogs];
    labelImportTotalLogs = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportTotalLogs.text = @"(importTotalLogs)";
    [self.view addSubview:labelImportTotalLogs];
    labelImportNewTrackables = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportNewTrackables.text = @"(importNewTrackables)";
    [self.view addSubview:labelImportNewTrackables];
    labelImportTotalTrackables = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportTotalTrackables.text = @"(importTotalTrackables)";
    [self.view addSubview:labelImportTotalTrackables];
    labelImportTotalImages = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportTotalImages.text = @"(importTotalImages)";
    [self.view addSubview:labelImportTotalImages];
    labelImportQueuedImages = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImportQueuedImages.text = @"(importQueuedImages)";
    [self.view addSubview:labelImportQueuedImages];

    [self calculateRects];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self calculateRects];
                                 }
     ];
}

- (void)calculateRects
{
#define MARGIN  5
#define INDENT  10
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger lh = myConfig.GCLabelFont.lineHeight;
    NSInteger y = MARGIN;

    labelDownloading.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, lh);
    y += lh;
    labelDownloadingDescription.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelDownloadingURL.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelDownloadingNumber.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;

    y += lh / 2;

    labelBGDownloading.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, lh);
    y += lh;
    labelBGDownloadingDescription.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelBGDownloadingURL.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelBGDownloadingNumber.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelBGPending.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, lh);
    y += lh;
    labelBGPendingQueued.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;

    y += lh / 2;

    labelImport.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, lh);
    y += lh;
    labelImportFilename.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportNewWaypoints.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportTotalWaypoints.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportNewLogs.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportTotalLogs.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportNewTrackables.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportTotalTrackables.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportTotalImages.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
    labelImportQueuedImages.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh);
    y += lh;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [imagesDownloadManager addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [imagesDownloadManager removeDelegate:self];
}

- (void)importerDelegateUpdate
{
}

- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages
{
}

- (void)importManager_setDescription:(NSString *)description
{
}

- (void)downloadManager_setDescription:(NSString *)description
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingDescription.text = description;
    }];
}

- (void)downloadManager_setURL:(NSString *)url
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingURL.text = url;
    }];
}

- (void)downloadManager_setNumberOfChunksTotal:(NSInteger)chunks
{
}

- (void)downloadManager_setNumberOfChunksDownload:(NSInteger)chunks
{
}

- (void)downloadManager_setNumberBytes
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingNumber .text = [NSString stringWithFormat:@"%@ of %@", [MyTools niceFileSize:valueDownloadingNumberDownloaded], [MyTools niceFileSize:valueDownloadingNumberTotal]];
    }];
}

- (void)downloadManager_setNumberBytesTotal:(NSInteger)bytes
{
    valueDownloadingNumberTotal = bytes;
    [self downloadManager_setNumberBytes];
}

- (void)downloadManager_setNumberBytesDownload:(NSInteger)bytes
{
    valueDownloadingNumberDownloaded = bytes;
    [self downloadManager_setNumberBytes];
}

- (void)downloadManager_setBGDescription:(NSString *)description
{
}
- (void)downloadManager_setBGURL:(NSString *)url
{
}
- (void)downloadManager_setBGNumberOfChunksTotal:(NSInteger)chunks
{
}
- (void)downloadManager_setBGNumberOfChunksDownload:(NSInteger)chunks
{
}
- (void)downloadManager_setBGNumberBytesTotal:(NSInteger)bytes
{
}
- (void)downloadManager_setBGNumberBytesDownload:(NSInteger)bytes
{
}

- (void)downloadManager_queueSize:(NSInteger)size
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelBGPendingQueued.text = [[NSNumber numberWithInteger:size] stringValue];
    }];
}

@end
