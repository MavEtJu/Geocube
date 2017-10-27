//
//  InfoItem2.m
//  Geocube
//
//  Created by Edwin Groothuis on 27/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@interface InfoItem2 ()

@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelDescription;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelURL;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelQueueSize;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelBytes;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelChunks;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelLineObject;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelWaypoints;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelLogs;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackables;

@property (nonatomic, retain) NSString *changedURL;
@property (nonatomic, retain) NSString *changedDescription;

@property (nonatomic        ) NSInteger changedQueueSize;
@property (nonatomic        ) NSInteger changedBytesTotal;
@property (nonatomic        ) NSInteger changedBytesCount;
@property (nonatomic        ) NSInteger changedChunksTotal;
@property (nonatomic        ) NSInteger changedChunksCount;
@property (nonatomic        ) NSInteger changedLineObjectCount;
@property (nonatomic        ) NSInteger changedLineObjectTotal;
@property (nonatomic        ) NSInteger changedWaypointsTotal;
@property (nonatomic        ) NSInteger changedWaypointsNew;
@property (nonatomic        ) NSInteger changedLogsTotal;
@property (nonatomic        ) NSInteger changedLogsNew;
@property (nonatomic        ) NSInteger changedTrackablesNew;
@property (nonatomic        ) NSInteger changedTrackablesTotal;

@property (nonatomic        ) NSInteger currentQueueSize;
@property (nonatomic        ) NSInteger currentBytesTotal;
@property (nonatomic        ) NSInteger currentBytesCount;
@property (nonatomic        ) NSInteger currentChunksTotal;
@property (nonatomic        ) NSInteger currentChunksCount;
@property (nonatomic        ) NSInteger currentLineObjectCount;
@property (nonatomic        ) NSInteger currentLineObjectTotal;
@property (nonatomic        ) NSInteger currentWaypointsTotal;
@property (nonatomic        ) NSInteger currentWaypointsNew;
@property (nonatomic        ) NSInteger currentLogsTotal;
@property (nonatomic        ) NSInteger currentLogsNew;
@property (nonatomic        ) NSInteger currentTrackablesNew;
@property (nonatomic        ) NSInteger currentTrackablesTotal;

@property (nonatomic        ) NSInteger height;
@property (nonatomic        ) BOOL expanded;
@property (nonatomic        ) BOOL isLines;

@end

@implementation InfoItem2

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.labelDescription.text = @"";
    self.labelURL.text = @"";
    self.labelQueueSize.text = @"";
    self.labelBytes.text = @"";
    self.labelChunks.text = @"";
    self.labelLineObject.text = @"";
    self.labelWaypoints.text = @"";
    self.labelLogs.text = @"";
    self.labelTrackables.text = @"";

    self.labelDescription.backgroundColor = [UIColor yellowColor];
    self.labelURL.backgroundColor = [UIColor yellowColor];

    self.height = self.labelURL.font.lineHeight + 1;
    self.expanded = YES;

    self.changedQueueSize = -1;
    self.changedBytesTotal = -1;
    self.changedBytesCount = -1;
    self.changedChunksTotal = -1;
    self.changedChunksCount = -1;
    self.changedLineObjectCount = -1;
    self.changedLineObjectTotal = -1;
    self.changedWaypointsTotal = -1;
    self.changedWaypointsNew = -1;
    self.self.changedLogsTotal = -1;
    self.changedLogsNew = -1;
    self.changedTrackablesNew = -1;
    self.changedTrackablesTotal = -1;

    self.backgroundColor = [UIColor clearColor];

    [self changeTheme];
}

- (void)changeExpanded:(BOOL)isExpanded
{
    self.expanded = isExpanded;
    self.needsRefresh = YES;
}
- (BOOL)isExpanded
{
    return self.expanded;
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelDescription changeTheme];
    [self.labelURL changeTheme];
}

- (void)changeURL:(NSString *)url
{
    self.changedURL = url;
    self.needsRefresh = YES;
}

- (void)changeDescription:(NSString *)desc
{
    self.changedDescription = desc;
    self.needsRefresh = YES;
}

- (void)changeLineObjectTotal:(NSInteger)total isLines:(BOOL)isLines;
{
    self.changedLineObjectTotal = total;
    self.isLines = isLines;
    self.needsRefresh = YES;
}

#define CHANGE(__field__) \
    - (void)change ## __field__:(NSInteger)i \
    { \
        self.changed ## __field__ = i; \
        self.needsRefresh = YES; \
    }

CHANGE(QueueSize)
CHANGE(ChunksTotal)
CHANGE(ChunksCount)
CHANGE(BytesTotal)
CHANGE(BytesCount)
CHANGE(LineObjectCount)
CHANGE(WaypointsTotal)
CHANGE(WaypointsNew)
CHANGE(LogsTotal)
CHANGE(LogsNew)
CHANGE(TrackablesTotal)
CHANGE(TrackablesNew)

- (void)resetBytes
{
    self.changedBytesCount = 0;
    self.changedBytesTotal = 0;
    self.needsRefresh = YES;
}
- (void)resetBytesChunks
{
    self.changedBytesCount = 0;
    self.changedBytesTotal = 0;
    self.changedChunksCount = 0;
    self.changedChunksTotal = 0;
    self.needsRefresh = YES;
}

- (void)sizeToFit
{
    if (self.needsRefresh == YES) {
        self.needsRefresh = NO;

        if (self.changedDescription != nil) {
            self.labelDescription.text = self.changedDescription;
            [self.labelDescription sizeToFit];
            self.changedDescription = nil;
        }
        if (self.changedURL != nil) {
            self.labelURL.text = [NSString stringWithFormat:_(@"URL: %@"), self.changedURL];
            [self.labelURL sizeToFit];
            self.changedURL = nil;
        }
        if (self.changedQueueSize >= 0) {
            self.currentQueueSize = self.currentQueueSize;
            self.labelQueueSize.text = [NSString stringWithFormat:_(@"Queue: %ld"), (long)self.currentQueueSize];
            [self.labelQueueSize sizeToFit];
            self.changedQueueSize = -1;
        }
        if (self.changedChunksCount != -1 || self.changedChunksTotal != -1) {
            if (self.changedChunksTotal >= 0)
                self.currentChunksTotal = 0;
            if (self.changedChunksCount >= 0)
                self.currentChunksCount = 0;

            if (self.currentChunksTotal == 0)
                self.labelChunks.text = [NSString stringWithFormat:_(@"Chunks: %ld"), (long)self.currentChunksCount];
            else
                self.labelChunks.text = [NSString stringWithFormat:_(@"Chunks: %ld of %ld (%@%%)"),
                                        (long)self.currentChunksCount,
                                        (long)self.currentChunksTotal,
                                        [MyTools nicePercentage:self.currentChunksCount total:self.currentChunksTotal]
                                       ];
            [self.labelChunks sizeToFit];
            self.changedChunksTotal = -1;
            self.changedChunksCount = -1;
        }
        if (self.changedBytesCount != -1 || self.changedBytesTotal != -1) {
            if (self.changedBytesTotal >= 0)
                self.currentBytesTotal = 0;
            if (self.changedBytesCount >= 0)
                self.currentBytesCount = 0;

            if (self.currentBytesTotal == 0)
                self.labelBytes.text = [NSString stringWithFormat:_(@"Bytes: %@"), [MyTools niceFileSize:self.currentBytesCount]];
            else
                self.labelBytes.text = [NSString stringWithFormat:_(@"Bytes: %@ of %@ (%@%%)"),
                                        [MyTools niceFileSize:self.currentBytesCount],
                                        [MyTools niceFileSize:self.currentBytesTotal],
                                        [MyTools nicePercentage:self.currentBytesCount total:self.currentBytesTotal]
                                        ];
            [self.labelBytes sizeToFit];
            self.changedBytesTotal = -1;
            self.changedBytesCount = -1;
        }
        if (self.changedLineObjectCount >= 0 || self.changedLineObjectTotal >= 0) {
            if (self.changedLineObjectCount >= 0)
                self.changedLineObjectCount = 0;
            if (self.changedLineObjectTotal >= 0)
                self.changedLineObjectTotal = 0;

            NSString *prefix;
            if (self.isLines == YES)
                prefix = @"Lines";
            else
                prefix = @"Objects";

            if (self.currentLineObjectTotal == 0)
                self.labelLineObject.text = [NSString stringWithFormat:_(@"%@: %ld"), prefix, (long)self.currentLineObjectTotal];
            else
                self.labelLineObject.text = [NSString stringWithFormat:_(@"%@: %ld of %ld %@%%)"), prefix,
                                             (long)self.currentLineObjectCount,
                                             (long)self.currentLineObjectTotal,
                                             [MyTools nicePercentage:self.currentLineObjectCount total:self.currentLineObjectTotal]
                                             ];
            [self.labelLineObject sizeToFit];
            self.changedLineObjectCount = -1;
            self.changedLineObjectTotal = -1;
        }
        if (self.changedWaypointsNew >= 0 || self.changedWaypointsTotal >= 0) {
            if (self.changedWaypointsNew >= 0)
                self.changedWaypointsNew = 0;
            if (self.changedWaypointsTotal >= 0)
                self.changedWaypointsTotal = 0;

            if (self.currentWaypointsNew == 0)
                self.labelWaypoints.text = [NSString stringWithFormat:_(@"Waypoints: %ld"), (long)self.currentWaypointsTotal];
            else
                self.labelWaypoints.text = [NSString stringWithFormat:_(@"Waypoints: %ld (%ld new)"),
                                            (long)self.currentWaypointsTotal,
                                            (long)self.currentWaypointsNew
                                            ];
            [self.labelWaypoints sizeToFit];
            self.changedWaypointsNew = -1;
            self.changedWaypointsTotal = -1;
        }
        if (self.changedLogsNew >= 0 || self.changedLogsTotal >= 0) {
            if (self.changedLogsNew >= 0)
                self.changedLogsNew = 0;
            if (self.changedLogsTotal >= 0)
                self.changedLogsTotal = 0;

            if (self.currentLogsNew == 0)
                self.labelLogs.text = [NSString stringWithFormat:_(@"Logs: %ld"), (long)self.currentLogsTotal];
            else
                self.labelLogs.text = [NSString stringWithFormat:_(@"Logs: %ld (%ld new)"),
                                            (long)self.currentLogsTotal,
                                            (long)self.currentLogsNew
                                            ];
            [self.labelLogs sizeToFit];
            self.changedLogsNew = -1;
            self.changedLogsTotal = -1;
        }
        if (self.changedTrackablesNew >= 0 || self.changedTrackablesTotal >= 0) {
            if (self.changedTrackablesNew >= 0)
                self.changedTrackablesNew = 0;
            if (self.changedTrackablesTotal >= 0)
                self.changedTrackablesTotal = 0;

            if (self.currentTrackablesNew == 0)
                self.labelTrackables.text = [NSString stringWithFormat:_(@"Trackables: %ld"), (long)self.currentTrackablesTotal];
            else
                self.labelTrackables.text = [NSString stringWithFormat:_(@"Trackables: %ld (%ld new)"),
                                             (long)self.currentTrackablesTotal,
                                             (long)self.currentTrackablesNew
                                            ];
            [self.labelTrackables sizeToFit];
            self.changedTrackablesNew = -1;
            self.changedTrackablesTotal = -1;
        }
    }

    CGRect frame = [[UIScreen mainScreen] bounds];
    NSInteger width = frame.size.width;

#define ADD(__field__) \
    if (IS_EMPTY(self.label ## __field__.text) == NO) { \
        self.label ## __field__ .frame = CGRectMake(4, y, width, self.height); \
        y += self.height; \
    } else \
        self.label ## __field__.frame = CGRectZero;

    NSInteger y = 4;
    ADD(Description)

    if (self.expanded == YES) {
        ADD(URL)
        ADD(QueueSize)
        ADD(Bytes)
        ADD(Chunks)
        ADD(LineObject)
        ADD(Waypoints)
        ADD(Logs)
        ADD(Trackables)
    } else {
        self.labelURL.frame = CGRectZero;
    }

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, y);
}

@end
