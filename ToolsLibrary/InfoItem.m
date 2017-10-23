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

@property (nonatomic        ) BOOL isLines;
@property (nonatomic        ) BOOL hasBeenExpanded;
@property (nonatomic        ) InfoItemType type;

@property (nonatomic        ) NSInteger viewHeight;

@property (nonatomic        ) NSInteger nextLineObjectCount, nextLineObjectTotal;
@property (nonatomic        ) NSInteger nextChunksCount, nextChunksTotal;
@property (nonatomic        ) NSInteger nextBytesCount, nextBytesTotal;

@property (nonatomic        ) NSInteger nextLogsNew, nextLogsTotal;
@property (nonatomic        ) NSInteger nextWaypointsNew, nextWaypointsTotal;
@property (nonatomic        ) NSInteger nextTrackablesNew, nextTrackablesTotal;

@property (nonatomic, retain) NSString *nextBytes, *nextObjects, *nextChunks;
@property (nonatomic, retain) NSString *nextDesc, *nextURL, *nextWaypoints;
@property (nonatomic, retain) NSString *nextQueue, *nextLinesObjects, *nextLogs, *nextTrackables;

@property (nonatomic, retain) GCLabelSmallText *labelDesc;
@property (nonatomic, retain) GCLabelSmallText *labelURL;
@property (nonatomic, retain) GCLabelSmallText *labelChunks;
@property (nonatomic, retain) GCLabelSmallText *labelBytes;
@property (nonatomic, retain) GCLabelSmallText *labelLinesObjects;
@property (nonatomic, retain) GCLabelSmallText *labelQueue;
@property (nonatomic, retain) GCLabelSmallText *labelTrackables;
@property (nonatomic, retain) GCLabelSmallText *labelLogs;
@property (nonatomic, retain) GCLabelSmallText *labelWaypoints;

@property (nonatomic        ) BOOL showLogs, showWaypoints, showTrackables;

@property (nonatomic        ) BOOL needsRefresh;
@property (nonatomic        ) BOOL needsRecalculate;

@end

@implementation InfoItem

- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)type
{
    return [self initWithInfoViewer:parent type:type expanded:YES];
}

- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)type expanded:(BOOL)expanded
{
    self = [super init];
    self.infoViewer = parent;
    self.hasBeenExpanded = expanded;
    self.type = type;

    switch (self.type) {
        case INFOITEM_DOWNLOAD: {
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            self.labelDesc = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelURL = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelChunks = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelBytes = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];

            MAINQUEUE(
                [self.view addSubview:self.labelDesc];
                [self.view addSubview:self.labelURL];
                [self.view addSubview:self.labelChunks];
                [self.view addSubview:self.labelBytes];
                [self calculateRects];
            )

            break;
        }

        case INFOITEM_IMPORT: {
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            self.labelDesc = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelLinesObjects = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelTrackables = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelLogs = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelWaypoints = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];

            self.showLogs = YES;
            self.showWaypoints = YES;
            self.showTrackables = YES;

            MAINQUEUE(
                [self.view addSubview:self.labelDesc];
                [self.view addSubview:self.labelLinesObjects];
                [self.view addSubview:self.labelWaypoints];
                [self.view addSubview:self.labelLogs];
                [self.view addSubview:self.labelTrackables];
                [self calculateRects];
            )

            break;
        }

        case INFOITEM_IMAGE:
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            self.labelDesc = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelURL = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelBytes = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];
            self.labelQueue = [[GCLabelSmallText alloc] initWithFrame:CGRectZero];

            MAINQUEUE(
                [self.view addSubview:self.labelDesc];
                [self.view addSubview:self.labelQueue];
                [self.view addSubview:self.labelURL];
                [self.view addSubview:self.labelBytes];
                [self calculateRects];
            )
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

    if (self.hasBeenExpanded == YES) {
        INDENT_RESIZE(self.labelDesc);
        INDENT_RESIZE(self.labelURL);
        INDENT_RESIZE(self.labelQueue);
        INDENT_RESIZE(self.labelChunks);
        INDENT_RESIZE(self.labelBytes);
        INDENT_RESIZE(self.labelLinesObjects);
        INDENT_RESIZE(self.labelLogs);
        INDENT_RESIZE(self.labelTrackables);
        INDENT_RESIZE(self.labelWaypoints);
    } else {
        INDENT_RESIZE(self.labelDesc);
    }

    y += MARGIN;
    self.view.frame = CGRectMake(0, 0, width, y);
    self.height = y;
}

- (void)expand:(BOOL)yesno
{
    self.hasBeenExpanded = yesno;
    self.needsRecalculate = YES;
}

- (BOOL)isExpanded
{
    return self.hasBeenExpanded;
}

- (void)recalculate
{
    if (self.needsRecalculate == NO)
        return;

    // This doesn't need to go on the main thread as this is done by the calling function.
    [self calculateRects];
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

    MAINQUEUE(
        UPDATE(self.labelDesc, self.nextDesc);
        UPDATE(self.labelURL, self.nextURL);
        UPDATE(self.labelChunks, self.nextChunks);
        UPDATE(self.labelBytes, self.nextBytes);
        UPDATE(self.labelLinesObjects, self.nextLinesObjects);
        UPDATE(self.labelLogs, self.nextLogs);
        UPDATE(self.labelTrackables, self.nextTrackables);
        UPDATE(self.labelWaypoints, self.nextWaypoints);
        UPDATE(self.labelQueue, self.nextQueue);
    )

    self.needsRefresh = NO;
}

- (void)setDescription:(NSString *)newDesc
{
    self.nextDesc = newDesc;
    self.needsRefresh = YES;
}

- (void)setURL:(NSString *)newURL
{
    self.nextURL = newURL;
    self.needsRefresh = YES;
}

- (void)setQueueSize:(NSInteger)queueSize
{
    self.nextQueue = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Queue depth"), (long)queueSize];
    self.needsRefresh = YES;
}

- (void)showLinesObjects
{
    NSInteger lot = self.nextLineObjectTotal;
    NSInteger loc = self.nextLineObjectCount;
    if (lot <= 0)
        self.nextLinesObjects = [NSString stringWithFormat:@"%@: %ld", self.isLines ? _(@"infoitem-Lines") : _(@"infoitem-Objects"), (long)loc];
    else
        self.nextLinesObjects = [NSString stringWithFormat:@"%@: %ld %@ %ld (%ld%%)", self.isLines ? _(@"infoitem-Lines") : _(@"infoitem-Objects"), (long)loc, _(@"of"), (long)lot, (long)(100 * loc / lot)];
    self.needsRefresh = YES;
}
- (void)setLineObjectCount:(NSInteger)count
{
    self.nextLineObjectCount = count;
    [self showLinesObjects];
}
- (void)setLineObjectTotal:(NSInteger)total isLines:(BOOL)isLines
{
    self.nextLineObjectTotal = total;
    self.isLines = isLines;
    [self showLinesObjects];
}

- (void)resetBytes
{
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)showBytes
{
    NSInteger bt = self.nextBytesTotal;
    NSInteger bc = self.nextBytesCount;
    if (bc < 0)
        self.nextBytes = [NSString stringWithFormat:@"%@: -", _(@"infoitem-Bytes")];
    else if (bt <= 0)
        self.nextBytes = [NSString stringWithFormat:@"%@: %@", _(@"infoitem-Bytes"), [MyTools niceFileSize:bc]];
    else
        self.nextBytes = [NSString stringWithFormat:@"%@: %@ %@ %@ (%ld %%)", _(@"infoitem-Bytes"), [MyTools niceFileSize:bc], _(@"of"), [MyTools niceFileSize:bt], (long)((bc * 100) / bt)];
    self.needsRefresh = YES;
}
- (void)setBytesTotal:(NSInteger)newTotal
{
    self.nextBytesTotal = newTotal;
    [self showBytes];
}
- (void)setBytesCount:(NSInteger)newCount
{
    self.nextBytesCount = newCount;
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
    if (self.nextChunksCount < 0)
        self.nextChunks = [NSString stringWithFormat:@"%@: -", _(@"infoitem-Chunks")];
    else if (self.nextChunksTotal == 0)
        self.nextChunks = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Chunks"), (long)self.nextChunksCount];
    else
        self.nextChunks = [NSString stringWithFormat:@"%@: %ld %@ %ld", _(@"infoitem-Chunks"), (long)self.nextChunksCount, _(@"of"), (long)self.nextChunksTotal];
    self.needsRefresh = YES;
}
- (void)setChunksTotal:(NSInteger)newTotal
{
    self.nextChunksTotal = newTotal;
    [self setChunks];
}
- (void)setChunksCount:(NSInteger)newCount
{
    self.nextChunksCount = newCount;
    [self setChunks];
}

- (void)showWaypoints:(BOOL)yesno
{
    self.showWaypoints = yesno;
    self.needsRecalculate = YES;
}

- (void)showLogs:(BOOL)yesno
{
    self.showLogs = yesno;
    self.needsRecalculate = YES;
}

- (void)showTrackables:(BOOL)yesno
{
    self.showTrackables = yesno;
    self.needsRecalculate = YES;
}
- (void)setWaypoints
{
    if (self.nextWaypointsNew == 0)
        self.nextWaypoints = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Waypoints"), (long)self.nextWaypointsTotal];
    else
        self.nextWaypoints = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Waypoints"), (long)self.nextWaypointsTotal, (long)self.nextWaypointsNew, _(@"new")];
    self.needsRefresh = YES;
}
- (void)setWaypointsNew:(NSInteger)i
{
    self.nextWaypointsNew = i;
    [self setWaypoints];
}
- (void)setWaypointsTotal:(NSInteger)i
{
    self.nextWaypointsTotal = i;
    [self setWaypoints];
}

- (void)setLogs
{
    NSString *s;
    if (self.nextLogsNew == 0)
        s = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Logs"), (long)self.nextLogsTotal];
    else
        s = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Logs"), (long)self.nextLogsTotal, (long)self.nextLogsNew, _(@"new")];
    self.nextLogs = s;
    [self needsRefresh];
}
- (void)setLogsNew:(NSInteger)i
{
    self.nextLogsNew = i;
    [self setLogs];
}
- (void)setLogsTotal:(NSInteger)i
{
    self.nextLogsTotal = i;
    [self setLogs];
}

- (void)setTrackables
{
    NSString *s;
    if (self.nextTrackablesNew == 0)
        s = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Trackables"), (long)self.nextTrackablesTotal];
    else
        s = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Trackables"), (long)self.nextTrackablesTotal, (long)self.nextTrackablesNew, _(@"new")];
    self.nextTrackables = s;
    self.needsRefresh = YES;
}
- (void)setTrackablesNew:(NSInteger)i
{
    self.nextTrackablesNew = i;
    [self setTrackables];
}
- (void)setTrackablesTotal:(NSInteger)i
{
    self.nextTrackablesTotal = i;
    [self setTrackables];
}

@end
