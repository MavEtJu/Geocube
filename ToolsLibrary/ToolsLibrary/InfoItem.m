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

#import "InfoItem.h"

#import "Geocube-defines.h"

#import "BaseObjectsLibrary/GCSmallLabel.h"
#import "BaseObjectsLibrary/GCView.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "ToolsLibrary/MyTools.h"

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
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

            MAINQUEUE(
                [self.view addSubview:labelDesc];
                [self.view addSubview:labelURL];
                [self.view addSubview:labelChunks];
                [self.view addSubview:labelBytes];
                [self calculateRects];
            )

            break;
        }

        case INFOITEM_IMPORT: {
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelLinesObjects = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelTrackables = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelLogs = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelWaypoints = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

            showLogs = YES;
            showWaypoints = YES;
            showTrackables = YES;

            MAINQUEUE(
                [self.view addSubview:labelDesc];
                [self.view addSubview:labelLinesObjects];
                [self.view addSubview:labelWaypoints];
                [self.view addSubview:labelLogs];
                [self.view addSubview:labelTrackables];
                [self calculateRects];
            )

            break;
        }

        case INFOITEM_IMAGE:
            self.view = [[GCView alloc] initWithFrame:CGRectZero];
            self.view.backgroundColor = [UIColor lightGrayColor];

            labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
            labelQueue = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

            MAINQUEUE(
                [self.view addSubview:labelDesc];
                [self.view addSubview:labelQueue];
                [self.view addSubview:labelURL];
                [self.view addSubview:labelBytes];
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

    if (isExpanded == YES) {
        INDENT_RESIZE(labelDesc);
        INDENT_RESIZE(labelURL);
        INDENT_RESIZE(labelQueue);
        INDENT_RESIZE(labelChunks);
        INDENT_RESIZE(labelBytes);
        INDENT_RESIZE(labelLinesObjects);
        INDENT_RESIZE(labelLogs);
        INDENT_RESIZE(labelTrackables);
        INDENT_RESIZE(labelWaypoints);
    } else {
        INDENT_RESIZE(labelDesc);
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
        UPDATE(labelDesc, nextDesc);
        UPDATE(labelURL, nextURL);
        UPDATE(labelChunks, nextChunks);
        UPDATE(labelBytes, nextBytes);
        UPDATE(labelLinesObjects, nextLinesObjects);
        UPDATE(labelLogs, nextLogs);
        UPDATE(labelTrackables, nextTrackables);
        UPDATE(labelWaypoints, nextWaypoints);
        UPDATE(labelQueue, nextQueue);
    )

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
    nextQueue = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Queue depth"), (long)queueSize];
    self.needsRefresh = YES;
}

- (void)showLinesObjects
{
    NSInteger lot = nextLineObjectTotal;
    NSInteger loc = nextLineObjectCount;
    if (lot <= 0)
        nextLinesObjects = [NSString stringWithFormat:@"%@: %ld", isLines ? _(@"infoitem-Lines") : _(@"infoitem-Objects"), (long)loc];
    else
        nextLinesObjects = [NSString stringWithFormat:@"%@: %ld %@ %ld (%ld%%)", isLines ? _(@"infoitem-Lines") : _(@"infoitem-Objects"), (long)loc, _(@"of"), (long)lot, (long)(100 * loc / lot)];
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
        nextBytes = [NSString stringWithFormat:@"%@: -", _(@"infoitem-Bytes")];
    else if (bt <= 0)
        nextBytes = [NSString stringWithFormat:@"%@: %@", _(@"infoitem-Bytes"), [MyTools niceFileSize:bc]];
    else
        nextBytes = [NSString stringWithFormat:@"%@: %@ %@ %@ (%ld %%)", _(@"infoitem-Bytes"), [MyTools niceFileSize:bc], _(@"of"), [MyTools niceFileSize:bt], (long)((bc * 100) / bt)];
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
        nextChunks = [NSString stringWithFormat:@"%@: -", _(@"infoitem-Chunks")];
    else if (nextChunksTotal == 0)
        nextChunks = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Chunks"), (long)nextChunksCount];
    else
        nextChunks = [NSString stringWithFormat:@"%@: %ld %@ %ld", _(@"infoitem-Chunks"), (long)nextChunksCount, _(@"of"), (long)nextChunksTotal];
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
        nextWaypoints = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Waypoints"), (long)nextWaypointsTotal];
    else
        nextWaypoints = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Waypoints"), (long)nextWaypointsTotal, (long)nextWaypointsNew, _(@"new")];
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
        s = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Logs"), (long)nextLogsTotal];
    else
        s = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Logs"), (long)nextLogsTotal, (long)nextLogsNew, _(@"new")];
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
        s = [NSString stringWithFormat:@"%@: %ld", _(@"infoitem-Trackables"), (long)nextTrackablesTotal];
    else
        s = [NSString stringWithFormat:@"%@: %ld (%ld %@)", _(@"infoitem-Trackables"), (long)nextTrackablesTotal, (long)nextTrackablesNew, _(@"new")];
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
