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

#define XIB_INFOITEMVIEW2 @"InfoItem2"

@interface InfoItem2 : GCView

@property (nonatomic, weak) InfoViewer2 *infoViewer;
@property (nonatomic      ) BOOL needsRefresh;

- (void)changeExpanded:(BOOL)isExpanded;
- (BOOL)isExpanded;
- (void)removeFromInfoViewer;

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
