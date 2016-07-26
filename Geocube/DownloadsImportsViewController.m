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
    GCLabel *labelDownloadingNumbers;
    GCLabel *labelDownloadingChunks;

    GCLabel *labelBGDownloading;
    GCLabel *labelBGDownloadingDescription;
    GCLabel *labelBGDownloadingURL;
    GCLabel *labelBGDownloadingNumbers;
    GCLabel *labelBGPending;
    GCLabel *labelBGPendingQueued;

    GCLabel *labelImport;
    GCLabel *labelImportDescription;
    GCLabel *labelImportAccount;
    GCLabel *labelImportProgress;
    GCLabel *labelImportNewWaypoints;
    GCLabel *labelImportTotalWaypoints;
    GCLabel *labelImportNewLogs;
    GCLabel *labelImportTotalLogs;
    GCLabel *labelImportNewTrackables;
    GCLabel *labelImportTotalTrackables;
    GCLabel *labelImportTotalImages;
    GCLabel *labelImportQueuedImages;

    NSInteger valueDownloadingNumbersDownloaded;
    NSInteger valueDownloadingNumbersTotal;
    NSInteger valueDownloadingChunksDownloaded;
    NSInteger valueDownloadingChunksTotal;

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

    valueDownloadingNumbersDownloaded = 0;
    valueDownloadingNumbersTotal = 0;
    valueDownloadingChunksDownloaded = 0;
    valueDownloadingChunksTotal = 0;

    return self;
}

- (void)showDownloadManager
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_AppDelegate switchController:RC_DOWNLOADS];
        [downloadTabController setSelectedIndex:VC_DOWNLOADS_DOWNLOADS animated:YES];
    }];
}

- (void)showImportManager
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
    [self.view addSubview:labelDownloadingDescription];
    labelImportAccount = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportAccount];
    labelDownloadingURL = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingURL];
    labelDownloadingNumbers = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingNumbers];
    labelDownloadingChunks = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingChunks];

    labelBGDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelBGDownloading.text = @"Background downloading";
    [self.view addSubview:labelBGDownloading];
    labelBGDownloadingDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingDescription];
    labelBGDownloadingURL = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingURL];
    labelBGDownloadingNumbers = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingNumbers];
    labelBGPending = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGPending];
    labelBGPendingQueued = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGPendingQueued];

    labelImport = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelImport.text = @"Importing";
    [self.view addSubview:labelImport];
    labelImportDescription = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportDescription];
    labelImportProgress = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportProgress];
    labelImportNewWaypoints = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportNewWaypoints];
    labelImportTotalWaypoints = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportTotalWaypoints];
    labelImportNewLogs = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportNewLogs];
    labelImportTotalLogs = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportTotalLogs];
    labelImportNewTrackables = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportNewTrackables];
    labelImportTotalTrackables = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportTotalTrackables];
    labelImportQueuedImages = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportQueuedImages];
    labelImportTotalImages = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportTotalImages];

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

#define LABEL_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, lh); \
    y += lh;
#define INDENT_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, lh); \
    y += lh;

    LABEL_RESIZE(labelDownloading);
    INDENT_RESIZE(labelDownloadingDescription);
    INDENT_RESIZE(labelDownloadingURL);
    INDENT_RESIZE(labelDownloadingNumbers);
    INDENT_RESIZE(labelDownloadingChunks);
    y += lh / 2;

    LABEL_RESIZE(labelBGDownloading);
    INDENT_RESIZE(labelBGDownloadingDescription);
    INDENT_RESIZE(labelBGDownloadingURL);
    INDENT_RESIZE(labelBGDownloadingNumbers);
    LABEL_RESIZE(labelBGPending);
    INDENT_RESIZE(labelBGPendingQueued);
    y += lh / 2;

    LABEL_RESIZE(labelImport);
    INDENT_RESIZE(labelImportDescription);
    INDENT_RESIZE(labelImportAccount);
    INDENT_RESIZE(labelImportProgress);
    INDENT_RESIZE(labelImportNewWaypoints);
    INDENT_RESIZE(labelImportTotalWaypoints);
    INDENT_RESIZE(labelImportNewLogs);
    INDENT_RESIZE(labelImportTotalLogs);
    INDENT_RESIZE(labelImportNewTrackables);
    INDENT_RESIZE(labelImportTotalTrackables);
    INDENT_RESIZE(labelImportTotalImages);
    INDENT_RESIZE(labelImportQueuedImages);
}

- (void)importerDelegateUpdate
{
}

- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages
{
}

//////////////////////////////////////////////////////////////////////////

- (void)importManager_setDescription:(NSString *)description
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportDescription.text = description;
    }];
}

- (void)importManager_setAccount:(dbAccount *)account
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportAccount.text = account.site;
    }];
}

- (void)ImportManager_setNewWaypoints:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportNewWaypoints.text = [NSString stringWithFormat:@"New waypoints: %ld", (long)v];
    }];
}

- (void)ImportManager_setTotalWaypoints:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTotalWaypoints.text = [NSString stringWithFormat:@"Total waypoints: %ld", (long)v];
    }];
}

- (void)ImportManager_setNewLogs:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportNewLogs.text = [NSString stringWithFormat:@"New logs: %ld", (long)v];
    }];
}

- (void)ImportManager_setTotalLogs:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTotalLogs.text = [NSString stringWithFormat:@"Total logs: %ld", (long)v];
    }];
}

- (void)ImportManager_setNewTrackables:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportNewTrackables.text = [NSString stringWithFormat:@"New trackables: %ld", (long)v];
    }];
}

- (void)ImportManager_setTotalTrackables:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTotalTrackables.text = [NSString stringWithFormat:@"Total trackables: %ld", (long)v];
    }];
}

- (void)ImportManager_setTotalImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTotalImages.text = [NSString stringWithFormat:@"Total images: %ld", (long)v];
    }];
}

- (void)ImportManager_setQueuedImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportQueuedImages.text = [NSString stringWithFormat:@"Queued images: %ld", (long)v];
    }];
}

- (void)ImportManager_setProgress:(NSInteger)v total:(NSInteger)t
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportProgress.text = [NSString stringWithFormat:@"Progress: %@", [MyTools nicePercentage:v total:t]];
    }];
}

//////////////////////////////////////////////////////////////////////////

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

- (void)downloadManager_setNumberOfChunks
{
    NSString *output = nil;
    if (valueDownloadingChunksDownloaded == 0)
        output = @"Chunks: n/a";
    else if (valueDownloadingChunksTotal == 0)
        output = [NSString stringWithFormat:@"Chunks: %ld", valueDownloadingChunksDownloaded];
    else
        output = [NSString stringWithFormat:@"Chunks: %ld of %ld", valueDownloadingChunksDownloaded, valueDownloadingChunksTotal];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingChunks.text = output;
    }];
}

- (void)downloadManager_setNumberOfChunksTotal:(NSInteger)chunks
{
    valueDownloadingChunksTotal = chunks;
    [self downloadManager_setNumberOfChunks];
}

- (void)downloadManager_setNumberOfChunksDownload:(NSInteger)chunks
{
    valueDownloadingChunksDownloaded = chunks;
    [self downloadManager_setNumberOfChunks];
}

- (void)downloadManager_setNumberBytes
{
    NSString *output = nil;
    if (valueDownloadingNumbersTotal == 0)
        output = [NSString stringWithFormat:@"Downloaded: %@",
                  [MyTools niceFileSize:valueDownloadingNumbersDownloaded]];
    else
        output = [NSString stringWithFormat:@"Downloaded: %@ (%@ of %@)",
                  [MyTools nicePercentage:valueDownloadingNumbersDownloaded total:valueDownloadingNumbersTotal],
                  [MyTools niceFileSize:valueDownloadingNumbersDownloaded],
                  [MyTools niceFileSize:valueDownloadingNumbersTotal]];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingNumbers.text = output;
    }];
}

- (void)downloadManager_setNumberBytesTotal:(NSInteger)bytes
{
    valueDownloadingNumbersTotal = bytes;
    [self downloadManager_setNumberBytes];
}

- (void)downloadManager_setNumberBytesDownload:(NSInteger)bytes
{
    valueDownloadingNumbersDownloaded = bytes;
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

- (void)downloadManager_setQueueSize:(NSInteger)size
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelBGPendingQueued.text = [[NSNumber numberWithInteger:size] stringValue];
    }];
}

//////////////////////////////////////////////////////////////////////////

- (void)imagesDownloadManager_setDownloadedImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTotalImages.text = [NSString stringWithFormat:@"Images downloaded: %ld", v];
    }];
}

- (void)imagesDownloadManager_setQueuedImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportQueuedImages.text = [NSString stringWithFormat:@"Images queued: %ld", v];
    }];
}

//////////////////////////////////////////////////////////////////////////

- (void)resetForegroundDownload
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloadingDescription.text = @"(no description yet)";
        labelDownloadingURL.text = @"(no URL yet)";
        labelDownloadingNumbers.text = @"(no download yet)";
        labelDownloadingChunks.text = @"(no data yet)";
        valueDownloadingNumbersDownloaded = 0;
        valueDownloadingNumbersTotal = 0;
        valueDownloadingChunksDownloaded = 0;
        valueDownloadingChunksTotal = 0;
    }];
}

- (void)resetBackgroundDownload
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelBGDownloadingDescription.text = @"(no description yet)";
        labelBGDownloadingURL.text = @"(no URL yet)";
        labelBGDownloadingNumbers.text = @"(no download yet)";
        labelBGPendingQueued.text = @"(no data yet)";
    }];
}

- (void)resetImports
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportDescription.text = @"(no description yet)";
        labelImportAccount.text = @"(no description yet)";
        labelImportProgress.text = @"Progress: 0%";
        labelImportTotalWaypoints.text = @"Total waypoints: 0";
        labelImportNewWaypoints.text = @"New waypoints: 0";
        labelImportNewLogs.text = @"New logs: 0";
        labelImportTotalLogs.text = @"Total logs: 0";
        labelImportNewTrackables.text = @"New trackables: 0";
        labelImportTotalTrackables.text = @"Total trackables: 0";
        labelImportQueuedImages.text = @"Queued images: 0";
        labelImportTotalImages.text = @"Total images: 0";
    }];
}

@end
