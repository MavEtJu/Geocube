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

typedef NSInteger InfoItemID;

@interface InfoItem : NSObject

- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)type;
- (instancetype)initWithInfoViewer:(InfoViewer *)parent type:(InfoItemType)type expanded:(BOOL)expanded;

@property (nonatomic) InfoItemID _id;
@property (nonatomic, retain) GCView *view;
@property (nonatomic, retain) InfoViewer *infoViewer;
@property (nonatomic) NSInteger height;
@property (nonatomic, readonly) BOOL needsRefresh;
@property (nonatomic, readonly) BOOL needsRecalculate;

- (void)calculateRects;

- (void)expand:(BOOL)yesno;
- (BOOL)isExpanded;
- (void)refresh;
- (void)recalculate;

- (void)setDescription:(NSString *)newDesc;
- (void)setURL:(NSString *)newURL;
- (void)setQueueSize:(NSInteger)queueSize;

- (void)resetBytes;
- (void)resetBytesChunks;

- (void)setBytesTotal:(NSInteger)newTotal;
- (void)setBytesCount:(NSInteger)newCount;
- (void)setChunksTotal:(NSInteger)newTotal;
- (void)setChunksCount:(NSInteger)newCount;
- (void)setLineObjectCount:(NSInteger)count;
- (void)setLineObjectTotal:(NSInteger)total isLines:(BOOL)isLines;

- (void)setWaypointsTotal:(NSInteger)i;
- (void)setWaypointsNew:(NSInteger)i;
- (void)setLogsTotal:(NSInteger)i;
- (void)setLogsNew:(NSInteger)i;
- (void)setTrackablesNew:(NSInteger)i;
- (void)setTrackablesTotal:(NSInteger)i;

- (void)showWaypoints:(BOOL)yesno;
- (void)showLogs:(BOOL)yesno;
- (void)showTrackables:(BOOL)yesno;

@end