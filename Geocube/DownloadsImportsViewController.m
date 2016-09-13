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

#define MAXHISTORY  10

@interface DownloadsImportsViewController ()
{
    UIScrollView *contentView;

    GCLabel *labelDownloading;
    GCLabel *labelDownloadingDescription;
    GCLabel *labelDownloadingURL;
    GCLabel *labelDownloadingNumbers;
    GCLabel *labelDownloadingChunks;

    GCLabel *labelBGDownloading;
    GCLabel *labelBGDownloadingDescription;
    GCLabel *labelBGDownloadingURL;
    GCLabel *labelBGDownloadingNumbers;

    GCLabel *labelImageDownloading;
    GCLabel *labelImageDownloadingQueued;
    GCLabel *labelImageDownloadingDownloaded;

    GCLabel *labelImport;
    GCLabel *labelImportDescription;
    GCLabel *labelImportAccount;
    GCLabel *labelImportProgress;
    GCLabel *labelImportWaypoints;
    GCLabel *labelImportLogs;
    GCLabel *labelImportTrackables;

    NSInteger valueImportTrackablesNew;
    NSInteger valueImportTrackablesTotal;
    NSInteger valueImportLogsNew;
    NSInteger valueImportLogsTotal;
    NSInteger valueImportWaypointsNew;
    NSInteger valueImportWaypointsTotal;

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
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [_AppDelegate switchController:RC_DOWNLOADS];
//        [downloadTabController setSelectedIndex:VC_DOWNLOADS_DOWNLOADS animated:YES];
//    }];
}

- (void)showImportManager
{
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [_AppDelegate switchController:RC_DOWNLOADS];
//        [downloadTabController setSelectedIndex:VC_DOWNLOADS_DOWNLOADS animated:YES];
//    }];
}

- (void)viewDidLoad
{
    lmi = nil;

    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    labelDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloading];
    labelDownloadingDescription = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingDescription];
    labelImportAccount = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportAccount];
    labelDownloadingURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingURL];
    labelDownloadingChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingChunks];
    labelDownloadingNumbers = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelDownloadingNumbers];

    labelBGDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloading];
    labelBGDownloadingDescription = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingDescription];
    labelBGDownloadingURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingURL];
    labelBGDownloadingNumbers = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelBGDownloadingNumbers];

    labelImageDownloading = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImageDownloading];
    labelImageDownloadingQueued = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImageDownloadingQueued];
    labelImageDownloadingDownloaded = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImageDownloadingDownloaded];

    labelImport = [[GCLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImport];
    labelImportDescription = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportDescription];
    labelImportProgress = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportProgress];
    labelImportWaypoints = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportWaypoints];
    labelImportLogs = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportLogs];
    labelImportTrackables = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:labelImportTrackables];

    [self resetForegroundDownload];
    [self resetBackgroundDownload];
    [self resetImports];
    [self resetImagesDownloads];

    [self calculateRects];
}

- (void)calculateRects
{
#define MARGIN  5
#define INDENT  10
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger y = MARGIN;
    NSInteger lh = labelDownloading.font.lineHeight;

#define LABEL_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;
#define INDENT_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;

    LABEL_RESIZE(labelDownloading);
    INDENT_RESIZE(labelDownloadingDescription);
    INDENT_RESIZE(labelDownloadingURL);
    INDENT_RESIZE(labelDownloadingChunks);
    INDENT_RESIZE(labelDownloadingNumbers);
    y += lh / 2;

    LABEL_RESIZE(labelBGDownloading);
    INDENT_RESIZE(labelBGDownloadingDescription);
    INDENT_RESIZE(labelBGDownloadingURL);
    INDENT_RESIZE(labelBGDownloadingNumbers);
    y += lh / 2;

    LABEL_RESIZE(labelImageDownloading);
    INDENT_RESIZE(labelImageDownloadingQueued);
    INDENT_RESIZE(labelImageDownloadingDownloaded);
    y += lh / 2;

    LABEL_RESIZE(labelImport);
    INDENT_RESIZE(labelImportDescription);
    INDENT_RESIZE(labelImportAccount);
    INDENT_RESIZE(labelImportProgress);
    INDENT_RESIZE(labelImportWaypoints);
    INDENT_RESIZE(labelImportLogs);
    INDENT_RESIZE(labelImportTrackables);

    contentView.contentSize = CGSizeMake(width, y);
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

- (void)ImportManager_setWaypoints
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportWaypoints.text = [NSString stringWithFormat:@"Total waypoints: %ld (new: %ld)", (long)valueImportWaypointsTotal, (long)valueImportWaypointsNew];
    }];
}
- (void)ImportManager_setTotalWaypoints:(NSInteger)v
{
    valueImportWaypointsTotal = v;
    [self ImportManager_setWaypoints];
}
- (void)ImportManager_setNewWaypoints:(NSInteger)v
{
    valueImportWaypointsNew = v;
    [self ImportManager_setWaypoints];
}

- (void)ImportManager_setLogs
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportLogs.text = [NSString stringWithFormat:@"Total logs: %ld (new: %ld)", (long)valueImportLogsTotal, (long)valueImportLogsNew];
    }];
}
- (void)ImportManager_setNewLogs:(NSInteger)v
{
    valueImportLogsNew = v;
    [self ImportManager_setLogs];
}
- (void)ImportManager_setTotalLogs:(NSInteger)v
{
    valueImportLogsTotal = v;
    [self ImportManager_setLogs];
}

- (void)ImportManager_setTrackables
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportTrackables.text = [NSString stringWithFormat:@"Total trackables: %ld (new: %ld)", (long)valueImportTrackablesTotal, (long)valueImportTrackablesNew];
    }];
}
- (void)ImportManager_setNewTrackables:(NSInteger)v
{
    valueImportTrackablesNew = v;
    [self ImportManager_setTrackables];
}
- (void)ImportManager_setTotalTrackables:(NSInteger)v
{
    valueImportTrackablesTotal = v;
    [self ImportManager_setTrackables];
}

- (void)ImportManager_setQueueSize:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImport.text = [NSString stringWithFormat:@"Importing (%ld pending)", (long)v];
    }];
}

- (void)ImportManager_setProgress:(NSInteger)v total:(NSInteger)t
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImportProgress.text = [NSString stringWithFormat:@"Progress: %@", [MyTools nicePercentage:v total:t]];
    }];
}

//////////////////////////////////////////////////////////////////////////

- (void)imagesDownloadManager_setDownloadedImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImageDownloadingDownloaded.text = [NSString stringWithFormat:@"Total images downloaded: %ld", (long)v];
    }];
}

- (void)imagesDownloadManager_setQueuedImages:(NSInteger)v
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImageDownloadingQueued.text = [NSString stringWithFormat:@"Images queued for downloading: %ld", (long)v];
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
        output = [NSString stringWithFormat:@"Chunks: %ld", (long)valueDownloadingChunksDownloaded];
    else
        output = [NSString stringWithFormat:@"Chunks: %ld of %ld", (long)valueDownloadingChunksDownloaded, (long)valueDownloadingChunksTotal];
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
    else if (valueDownloadingNumbersDownloaded == valueDownloadingNumbersTotal)
        output = [NSString stringWithFormat:@"Downloaded: 100%% (%@)",
                  [MyTools niceFileSize:valueDownloadingNumbersTotal]];
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

//////////////////////////////////////////////////////////////////////////

- (void)resetForegroundDownload
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDownloading.text = @"Download";
        labelDownloadingDescription.text = @"(description)";
        labelDownloadingURL.text = @"(URL)";
        labelDownloadingNumbers.text = @"Dowloaded:";
        labelDownloadingChunks.text = @"Chunks:";
        valueDownloadingNumbersDownloaded = 0;
        valueDownloadingNumbersTotal = 0;
        valueDownloadingChunksDownloaded = 0;
        valueDownloadingChunksTotal = 0;
    }];
}

- (void)resetBackgroundDownload
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelBGDownloading.text = @"Background download (0 pending)";
        labelBGDownloadingDescription.text = @"(description)";
        labelBGDownloadingURL.text = @"(URL)";
        labelBGDownloadingNumbers.text = @"Downloaded:";
    }];
}

- (void)resetImports
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImport.text = @"Importing (0 pending)";
        labelImportDescription.text = @"(description)";
        labelImportAccount.text = @"(account)";
        labelImportProgress.text = @"Progress: 0%";
        labelImportWaypoints.text = @"Total waypoints: 0 (new: 0)";
        labelImportLogs.text = @"Total logs: 0 (new: 0)";
        labelImportTrackables.text = @"Total trackables: 0 (new: 0)";
    }];
}

- (void)resetImagesDownloads
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelImageDownloading.text = @"Images Download";
        labelImageDownloadingQueued.text = @"Images queued for downloading: 0";
        labelImageDownloadingDownloaded.text = @"Total images downloaded: 0";
    }];
}

@end
