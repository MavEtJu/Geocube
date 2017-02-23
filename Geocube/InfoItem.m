/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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
    BOOL isLines;
    BOOL isExpanded;
    InfoItemType type;

    NSInteger viewHeight;

    NSInteger nextLineObjectCount, nextLineObjectTotal;
    NSInteger nextChunksCount, nextChunksTotal;
    NSInteger nextBytesCount, nextBytesTotal;

    NSInteger nextLogsNew, nextLogsTotal;
    NSInteger nextWaypointsNew, nextWaypointsTotal;
    NSInteger nextTrackablesNew, nextTrackablesTotal;

    NSString *nextBytes, *nextObjects, *nextChunks;
    NSString *nextDesc, *nextURL, *nextWaypoints;
    NSString *nextQueue, *nextLinesObjects, *nextLogs, *nextTrackables;

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

@property (nonatomic) BOOL needsRefresh;
@property (nonatomic) BOOL needsRecalculate;

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

            break;
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

    if (isExpanded == YES) {
        INDENT_RESIZE(labelDesc);
        INDENT_RESIZE(labelURL);
        INDENT_RESIZE(labelChunks);
        INDENT_RESIZE(labelBytes);
        INDENT_RESIZE(labelLinesObjects);
        INDENT_RESIZE(labelLogs);
        INDENT_RESIZE(labelTrackables);
        INDENT_RESIZE(labelWaypoints);
        INDENT_RESIZE(labelQueue);
    }

    y += MARGIN;
    self.view.frame = CGRectMake(0, 0, width, y);
    self.height = y;
}

- (void)expand:(BOOL)yesno
{
    isExpanded = yesno;
    self.needsRecalculate = YES;
}

- (BOOL)isExpanded
{
    return isExpanded;
}

- (void)recalculate
{
    if (self.needsRecalculate == NO)
        return;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self calculateRects];
    }];
    self.needsRecalculate = NO;
}

- (void)refresh
{
    if (self.needsRefresh == NO)
        return;

#define UPDATE(__label__, __var__) \
    if (__var__ != nil) { \
        __label__.text = __var__; \
        __var__ = nil; \
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UPDATE(labelDesc, nextDesc);
        UPDATE(labelURL, nextURL);
        UPDATE(labelChunks, nextChunks);
        UPDATE(labelBytes, nextBytes);
        UPDATE(labelLinesObjects, nextLinesObjects);
        UPDATE(labelLogs, nextLogs);
        UPDATE(labelTrackables, nextTrackables);
        UPDATE(labelWaypoints, nextWaypoints);
        UPDATE(labelQueue, nextQueue);
    }];

    self.needsRefresh = NO;
}

- (void)setDescription:(NSString *)newDesc
{
    nextDesc = newDesc;
    self.needsRefresh = YES;
}

- (void)setURL:(NSString *)newURL
{
    nextURL = newURL;
    self.needsRefresh = YES;
}

- (void)setQueueSize:(NSInteger)queueSize
{
    nextQueue = [NSString stringWithFormat:@"Queue depth: %ld", (long)queueSize];
    self.needsRefresh = YES;
}

- (void)showLinesObjects
{
    NSInteger lot = nextLineObjectTotal;
    NSInteger loc = nextLineObjectCount;
    if (lot <= 0)
        nextLinesObjects = [NSString stringWithFormat:@"%@: %ld", isLines ? @"Lines" : @"Objects", (long)loc];
    else
        nextLinesObjects = [NSString stringWithFormat:@"%@: %ld of %ld (%ld%%)", isLines ? @"Lines" : @"Objects", (long)loc, (long)lot, (long)(100 * loc / lot)];
    self.needsRefresh = YES;
}
- (void)setLineObjectCount:(NSInteger)count
{
    nextLineObjectCount = count;
    [self showLinesObjects];
}
- (void)setLineObjectTotal:(NSInteger)total isLines:(BOOL)_isLines
{
    nextLineObjectTotal = total;
    isLines = _isLines;
    [self showLinesObjects];
}

- (void)resetBytes
{
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)showBytes
{
    NSInteger bt = nextBytesTotal;
    NSInteger bc = nextBytesCount;
    if (bc < 0)
        nextBytes = @"Bytes: -";
    else if (bt <= 0)
        nextBytes = [NSString stringWithFormat:@"Bytes: %@", [MyTools niceFileSize:bc]];
    else
        nextBytes = [NSString stringWithFormat:@"Bytes: %@ of %@ (%ld %%)", [MyTools niceFileSize:bc], [MyTools niceFileSize:bt], (long)((bc * 100) / bt)];
    self.needsRefresh = YES;
}
- (void)setBytesTotal:(NSInteger)newTotal
{
    nextBytesTotal = newTotal;
    [self showBytes];
}
- (void)setBytesCount:(NSInteger)newCount
{
    nextBytesCount = newCount;
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
    if (nextChunksCount < 0)
        nextChunks = @"Chunks: -";
    else if (nextChunksTotal == 0)
        nextChunks = [NSString stringWithFormat:@"Chunks: %ld", (long)nextChunksCount];
    else
        nextChunks = [NSString stringWithFormat:@"Chunks: %ld of %ld", (long)nextChunksCount, (long)nextChunksTotal];
    self.needsRefresh = YES;
}
- (void)setChunksTotal:(NSInteger)newTotal
{
    nextChunksTotal = newTotal;
    [self setChunks];
}
- (void)setChunksCount:(NSInteger)newCount
{
    nextChunksCount = newCount;
    [self setChunks];
}

- (void)showWaypoints:(BOOL)yesno
{
    showWaypoints = yesno;
    self.needsRecalculate = YES;
}

- (void)showLogs:(BOOL)yesno
{
    showLogs = yesno;
    self.needsRecalculate = YES;
}

- (void)showTrackables:(BOOL)yesno
{
    showTrackables = yesno;
    self.needsRecalculate = YES;
}
- (void)setWaypoints
{
    if (nextWaypointsNew == 0)
        nextWaypoints = [NSString stringWithFormat:@"Waypoints: %ld", (long)nextWaypointsTotal];
    else
        nextWaypoints = [NSString stringWithFormat:@"Waypoints: %ld (%ld new)", (long)nextWaypointsTotal, (long)nextWaypointsNew];
    self.needsRefresh = YES;
}
- (void)setWaypointsNew:(NSInteger)i
{
    nextWaypointsNew = i;
    [self setWaypoints];
}
- (void)setWaypointsTotal:(NSInteger)i
{
    nextWaypointsTotal = i;
    [self setWaypoints];
}

- (void)setLogs
{
    NSString *s;
    if (nextLogsNew == 0)
        s = [NSString stringWithFormat:@"Logs: %ld", (long)nextLogsTotal];
    else
        s = [NSString stringWithFormat:@"Logs: %ld (%ld new)", (long)nextLogsTotal, (long)nextLogsNew];
    nextLogs = s;
    [self needsRefresh];
}
- (void)setLogsNew:(NSInteger)i
{
    nextLogsNew = i;
    [self setLogs];
}
- (void)setLogsTotal:(NSInteger)i
{
    nextLogsTotal = i;
    [self setLogs];
}

- (void)setTrackables
{
    NSString *s;
    if (nextTrackablesNew == 0)
        s = [NSString stringWithFormat:@"Trackables: %ld", (long)nextTrackablesTotal];
    else
        s = [NSString stringWithFormat:@"Trackables: %ld (%ld new)", (long)nextTrackablesTotal, (long)nextTrackablesNew];
    nextTrackables = s;
    self.needsRefresh = YES;
}
- (void)setTrackablesNew:(NSInteger)i
{
    nextTrackablesNew = i;
    [self setTrackables];
}
- (void)setTrackablesTotal:(NSInteger)i
{
    nextTrackablesTotal = i;
    [self setTrackables];
}

@end
