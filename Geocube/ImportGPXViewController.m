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

- (id)init:(NSString *)_filename group:(dbGroup *)_group account:(dbAccount *)_account
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

    NSInteger width = applicationFrame.size.width;
    NSInteger margin = 10;
    NSInteger labelOffset = margin;
    NSInteger labelSize = 3 * width / 4 - 2 * margin;
    NSInteger valueOffset = 3 * width / 4 + margin;
    NSInteger valueSize = width / 4 - 2 * margin;
    NSInteger height = 30;
    NSInteger y = 0;
    UILabel *l;

    filenameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, width - 2 * margin, height)];
    [filenameLabel setText:@"Import of ?"];
    filenameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:filenameLabel];
    y += height;

    // Progress label
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"Done:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:progressLabel];
    y += height;

    // New waypoint counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"New waypoints imported:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    newWaypointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:newWaypointsLabel];
    y += height;

    // Total waypoint counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"Total waypoints read:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    totalWaypointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:totalWaypointsLabel];
    y += height;

    // New travelbugs counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"New travelbugs imported:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    newTravelbugsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:newTravelbugsLabel];
    y += height;

    // Total travelbugs counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"Total travelbugs read:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    totalTravelbugsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:totalTravelbugsLabel];
    y += height;

    // New logs counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"New logs imported:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    newLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:newLogsLabel];
    y += height;

    // Total logs counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"Total logs read:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    totalLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:totalLogsLabel];
    y += height;

    // Queued images counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"New images queued:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    queuedImagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:queuedImagesLabel];
    y += height;

    // Total images counter
    l = [[UILabel alloc] initWithFrame:CGRectMake(labelOffset, y, labelSize, height)];
    l.text = @"Total images read:";
    l.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:l];

    totalImagesLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueOffset, y, valueSize, height)];
    [self.view addSubview:totalImagesLabel];
    y += height;

    imp = [[ImportGPX alloc] init:group account:account];

    [self performSelectorInBackground:@selector(run) withObject:nil];
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
                [filenameLabel setText:[NSString stringWithFormat:@"Import of %@", filename]];
            }];
            [imp parseFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename]];
            progressLabel.text = @"100%";
            [waypointManager needsRefresh];
        }];
    }
    [imp parseAfter];

    [filenamesToBeRemoved enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] error:nil];
    }];
}

- (void)updateData:(NSInteger)percentageRead newWaypointsCount:(NSInteger)newWaypointsCount totalWaypointsCount:(NSInteger)totalWaypointsCount newLogsCount:(NSInteger)newLogsCount totalLogsCount:(NSInteger)totalLogsCount newTravelbugsCount:(NSInteger)newTravelbugsCount totalTravelbugsCount:(NSInteger)totalTravelbugsCount newImagesCount:(NSInteger)newImagesCount
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        progressLabel.text = [NSString stringWithFormat:@"%@%%", [MyTools niceNumber:percentageRead]];
        newWaypointsLabel.text = [MyTools niceNumber:newWaypointsCount];
        totalWaypointsLabel.text = [MyTools niceNumber:totalWaypointsCount];
        newLogsLabel.text = [MyTools niceNumber:newLogsCount];
        totalLogsLabel.text = [MyTools niceNumber:totalLogsCount];
        newTravelbugsLabel.text = [MyTools niceNumber:newTravelbugsCount];
        totalTravelbugsLabel.text = [MyTools niceNumber:totalTravelbugsCount];
        totalImagesLabel.text = [MyTools niceNumber:newImagesCount];
    }];
}

- (void)updateData:(NSInteger)queuedImages
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        queuedImagesLabel.text = [MyTools niceNumber:queuedImages];
    }];
}

@end