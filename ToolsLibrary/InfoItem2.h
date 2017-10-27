//
//  InfoItem2.h
//  Geocube
//
//  Created by Edwin Groothuis on 27/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#define XIB_INFOITEMVIEW2 @"InfoItem2"

@interface InfoItem2 : GCView

@property (nonatomic, weak) InfoViewer2 *parent;
@property (nonatomic      ) BOOL needsRefresh;

- (void)changeExpanded:(BOOL)isExpanded;
- (BOOL)isExpanded;

- (void)changeDescription:(NSString *)desc;
- (void)changeURL:(NSString *)url;
- (void)changeQueueSize:(NSInteger)queueSize;

- (void)changeBytesTotal:(NSInteger)newTotal;
- (void)changeBytesCount:(NSInteger)newCount;
- (void)changeChunksTotal:(NSInteger)newTotal;
- (void)changeChunksCount:(NSInteger)newCount;
- (void)changeLineObjectCount:(NSInteger)count;
- (void)changeLineObjectTotal:(NSInteger)total isLines:(BOOL)isLines;

- (void)changeWaypointsTotal:(NSInteger)i;
- (void)changeWaypointsNew:(NSInteger)i;
- (void)changeLogsTotal:(NSInteger)i;
- (void)changeLogsNew:(NSInteger)i;
- (void)changeTrackablesNew:(NSInteger)i;
- (void)changeTrackablesTotal:(NSInteger)i;

- (void)resetBytes;
- (void)resetBytesChunks;

@end
