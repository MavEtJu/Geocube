/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface InfoItem ()
{
    NSInteger bytesTotal, bytesCount;
    BOOL isLines;
    BOOL isExpanded;
    InfoItemType type;

    NSInteger viewHeight;

    NSInteger objectCount, objectTotal;
    NSInteger lineObjectCount, lineObjectTotal;
    NSInteger chunksTotal, chunksCount;
    NSInteger logsNew, logsTotal;
    NSInteger waypointsNew, waypointsTotal;
    NSInteger trackablesNew, trackablesTotal;

    GCSmallLabel *labelDesc;
    GCSmallLabel *labelURL;
    GCSmallLabel *labelChunks;
    GCSmallLabel *labelBytes;
    GCSmallLabel *labelLinesObjects;
    GCSmallLabel *labelQueue;
    GCSmallLabel *labelTrackables;
    GCSmallLabel *labelLogs;
    GCSmallLabel *labelWaypoints;

    BOOL showLogs, showWaypoints, showTrackables;
}

@end

@implementation InfoItem

- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)_type
{
    return [self initWithInfoViewer:parent type:_type expanded:YES];
}

- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)_type expanded:(BOOL)expanded
{
    self = [super init];
    self.infoViewer = parent;
    isExpanded = expanded;
    type = _type;

    switch (type) {
        case INFOITEM_DOWNLOAD: {
            NSLog(@"rectFromBottom: %@", [MyTools niceCGRect:[parent rectFromBottom]]);
            self.view = [[GCView alloc] initWithFrame:[parent rectFromBottom]];
            self.view.backgroundColor = [UIColor lightGrayColor];

            labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.view addSubview:labelDesc];
                [self.view addSubview:labelURL];
                [self.view addSubview:labelChunks];
                [self.view addSubview:labelBytes];
                [self calculateRects];
            }];

            break;
        }

        case INFOITEM_IMPORT: {
            NSLog(@"rectFromBottom: %@", [MyTools niceCGRect:[parent rectFromBottom]]);
            self.view = [[GCView alloc] initWithFrame:[parent rectFromBottom]];
            self.view.backgroundColor = [UIColor lightGrayColor];

            labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelLinesObjects = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelTrackables = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelLogs = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelWaypoints = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

            showLogs = YES;
            showWaypoints = YES;
            showTrackables = YES;

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.view addSubview:labelDesc];
                [self.view addSubview:labelLinesObjects];
                [self.view addSubview:labelWaypoints];
                [self.view addSubview:labelLogs];
                [self.view addSubview:labelTrackables];
                [self calculateRects];
            }];
        }

        case INFOITEM_IMAGE:
            break;
    }

    return self;
}

- (void)calculateRects
{
#define MARGIN  5
#define INDENT  10
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger y = MARGIN;

#define LABEL_RESIZE(__s__) \
    if (__s__ != nil) { \
        __s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, __s__.font.lineHeight); \
        y += __s__.font.lineHeight; \
    }
#define INDENT_RESIZE(__s__) \
    if (__s__ != nil) { \
        __s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, __s__.font.lineHeight); \
        y += __s__.font.lineHeight; \
    }

    INDENT_RESIZE(labelDesc);
    INDENT_RESIZE(labelURL);
    INDENT_RESIZE(labelChunks);
    INDENT_RESIZE(labelBytes);
    INDENT_RESIZE(labelLinesObjects);
    INDENT_RESIZE(labelLogs);
    INDENT_RESIZE(labelTrackables);
    INDENT_RESIZE(labelWaypoints);
    INDENT_RESIZE(labelBytes);
    INDENT_RESIZE(labelChunks);
    INDENT_RESIZE(labelQueue);

    y += MARGIN;
    self.view.frame = CGRectMake(0, 0, width, y);
    self.height = y;
}

- (void)expand:(BOOL)yesno
{
    isExpanded = yesno;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.infoViewer viewWillTransitionToSize];
    }];
}

- (BOOL)isExpanded
{
    return isExpanded;
}

- (void)setDescription:(NSString *)newDesc
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDesc.text = newDesc;
    }];
}

- (void)setURL:(NSString *)newURL
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelURL.text = newURL;
    }];
}

- (void)setQueueSize:(NSInteger)queueSize
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelQueue.text = [NSString stringWithFormat:@"Queue depth: %ld", (long)queueSize];
    }];
}

- (void)showLinesObjects
{
    NSInteger lot = lineObjectTotal;
    NSInteger loc = lineObjectCount;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (lot <= 0)
            labelLinesObjects.text = [NSString stringWithFormat:@"%@: %ld", isLines ? @"Lines" : @"Objects", (long)loc];
        else
            labelLinesObjects.text = [NSString stringWithFormat:@"%@: %ld of %ld (%ld%%)", isLines ? @"Lines" : @"Objects", (long)loc, (long)lot, (long)(100 * loc / lot)];
    }];
}
- (void)setLineObjectCount:(NSInteger)count
{
    lineObjectCount = count;
    [self showLinesObjects];
}
- (void)setLineObjectTotal:(NSInteger)total isLines:(BOOL)_isLines
{
    isLines = _isLines;
    lineObjectTotal = total;
    [self showLinesObjects];
}

- (void)resetBytes
{
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)showBytes
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSInteger bt = bytesTotal;
        NSInteger bc = bytesCount;
        if (bc < 0)
            labelBytes.text = @"Bytes: -";
        else if (bt <= 0)
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@", [MyTools niceFileSize:bc]];
        else
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@ of %@ (%ld %%)", [MyTools niceFileSize:bc], [MyTools niceFileSize:bt], (long)((bc * 100) / bt)];
    }];
}
- (void)setBytesTotal:(NSInteger)newTotal
{
    bytesTotal = newTotal;
    [self showBytes];
}
- (void)setBytesCount:(NSInteger)newCount
{
    bytesCount = newCount;
    [self showBytes];
}


- (void)resetBytesChunks
{
    [self setChunksTotal:0];
    [self setChunksCount:-1];
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)setChunks
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (chunksCount < 0)
            labelChunks.text = @"Chunks: -";
        else if (chunksTotal == 0)
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld", (long)chunksCount];
        else
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld of %ld", (long)chunksCount, (long)chunksTotal];
    }];
}
- (void)setChunksTotal:(NSInteger)newTotal
{
    chunksTotal = newTotal;
    [self setChunks];
}
- (void)setChunksCount:(NSInteger)newCount
{
    chunksCount = newCount;
    [self setChunks];
}

- (void)showWaypoints:(BOOL)yesno
{
    showWaypoints = yesno;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self calculateRects];
    }];
}

- (void)showLogs:(BOOL)yesno
{
    showLogs = yesno;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self calculateRects];
    }];
}

- (void)showTrackables:(BOOL)yesno
{
    showTrackables = yesno;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self calculateRects];
    }];
}
- (void)setWaypoints
{
    NSString *s;
    if (waypointsNew == 0)
        s = [NSString stringWithFormat:@"Waypoints: %ld", (long)waypointsTotal];
    else
        s = [NSString stringWithFormat:@"Waypoints: %ld (%ld new)", (long)waypointsTotal, (long)waypointsNew];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelWaypoints.text = s;
    }];
}
- (void)setWaypointsNew:(NSInteger)i
{
    waypointsNew = i;
    [self setWaypoints];
}
- (void)setWaypointsTotal:(NSInteger)i
{
    waypointsTotal = i;
    [self setWaypoints];
}

- (void)setLogs
{
    NSString *s;
    if (logsNew == 0)
        s = [NSString stringWithFormat:@"Logs: %ld", (long)logsTotal];
    else
        s = [NSString stringWithFormat:@"Logs: %ld (%ld new)", (long)logsTotal, (long)logsNew];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelLogs.text = s;
    }];
}
- (void)setLogsNew:(NSInteger)i
{
    logsNew = i;
    [self setLogs];
}
- (void)setLogsTotal:(NSInteger)i
{
    logsTotal = i;
    [self setLogs];
}

- (void)setTrackables
{
    NSString *s;
    if (trackablesNew == 0)
        s = [NSString stringWithFormat:@"Trackables: %ld", (long)trackablesTotal];
    else
        s = [NSString stringWithFormat:@"Trackables: %ld (%ld new)", (long)trackablesTotal, (long)trackablesNew];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelTrackables.text = s;
    }];
}
- (void)setTrackablesNew:(NSInteger)i
{
    trackablesNew = i;
    [self setTrackables];
}
- (void)setTrackablesTotal:(NSInteger)i
{
    trackablesTotal = i;
    [self setTrackables];
}

@end
