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

@interface InfoItemImport ()
{
    GCSmallLabel *labelTrackables;
    GCSmallLabel *labelLogs;
    GCSmallLabel *labelWaypoints;

    NSInteger logsNew, logsTotal;
    NSInteger waypointsNew, waypointsTotal;
    NSInteger trackablesNew, trackablesTotal;

    BOOL showLogs, showWaypoints, showTrackables;
}

@end

@implementation InfoItemImport

@synthesize height;

- (instancetype)initWithInfoViewer:(InfoViewer *)parent expanded:(BOOL)expanded
{
    self = [super initWithInfoViewer:parent expanded:expanded];

    NSLog(@"rectFromBottom: %@", [MyTools niceCGRect:[parent rectFromBottom]]);
    view = [[GCView alloc] initWithFrame:[parent rectFromBottom]];
    view.backgroundColor = [UIColor lightGrayColor];

    labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelLinesObjects = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelTrackables = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelLogs = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelWaypoints = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

    showLogs = YES;
    showWaypoints = YES;
    showTrackables = YES;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [view addSubview:labelDesc];
        [view addSubview:labelLinesObjects];
        [view addSubview:labelWaypoints];
        [view addSubview:labelLogs];
        [view addSubview:labelTrackables];
        [self calculateRects];
    }];

    return self;
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

- (void)calculateRects
{
#define MARGIN  5
#define INDENT  10
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger y = MARGIN;

#define LABEL_RESIZE(__s__) \
__s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, __s__.font.lineHeight); \
y += __s__.font.lineHeight;
#define INDENT_RESIZE(__s__) \
__s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, __s__.font.lineHeight); \
y += __s__.font.lineHeight;

    INDENT_RESIZE(labelDesc);
    INDENT_RESIZE(labelLinesObjects);
    if (showWaypoints == YES) {
        INDENT_RESIZE(labelWaypoints)
    } else
        labelWaypoints.frame = CGRectZero;

    if (showLogs == YES) {
        INDENT_RESIZE(labelLogs);
    } else
        labelLogs.frame = CGRectZero;
    if (showTrackables == YES) {
        INDENT_RESIZE(labelTrackables);
    } else
        labelTrackables.frame = CGRectZero;

    y += MARGIN;
    view.frame = CGRectMake(0, 0, width, y);
    height = y;
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
