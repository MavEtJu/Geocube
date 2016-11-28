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

@interface InfoViewer ()
{
    NSMutableArray *items;
    GCLabel *header;
    InfoItemID maxid;
}

@end

@implementation InfoViewer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    header = [[GCLabel alloc] initWithFrame:[self rectFromBottom]];
    header.text = @"?";
    header.backgroundColor = [UIColor lightGrayColor];

    items = [NSMutableArray arrayWithCapacity:5];
    maxid = 1;

    [self calculateRects];
    [self changeTheme];

    return self;
}

- (BOOL)hasItems
{
    return ([items count] != 0);
}

- (NSInteger)addImage
{
    return [self addImage:YES];
}

- (NSInteger)addImage:(BOOL)expanded
{
    InfoItem *iii = [[InfoItem alloc] initWithInfoViewer:self type:INFOITEM_IMAGE expanded:expanded];

    @synchronized (items) {
        iii._id = maxid++;
        [items addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        header.text = @"Images";
        [self addSubview:header];
        [self addSubview:iii.view];
    }];

    return iii._id;
}

- (NSInteger)addImport
{
    return [self addImport:YES];
}

- (NSInteger)addImport:(BOOL)expanded
{
    InfoItem *iii = [[InfoItem alloc] initWithInfoViewer:self type:INFOITEM_IMPORT expanded:expanded];

    @synchronized (items) {
        iii._id = maxid++;
        [items addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        header.text = @"Imports";
        [self addSubview:header];
        [self addSubview:iii.view];
        [self calculateRects];
    }];

    return iii._id;
}

- (NSInteger)addDownload
{
    return [self addDownload:YES];
}

- (NSInteger)addDownload:(BOOL)expanded
{
    InfoItem *iid = [[InfoItem alloc] initWithInfoViewer:self type:INFOITEM_DOWNLOAD expanded:expanded];

    @synchronized (items) {
        iid._id = maxid++;
        [items addObject:iid];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        header.text = @"Downloads";
        [self addSubview:header];
        [self addSubview:iid.view];
        [self calculateRects];
    }];

    return iid._id;
}

- (void)removeItem:(InfoItemID)_id
{
    __block InfoItem *ii;
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *_ii, NSUInteger idx, BOOL *stop) {
            if (_ii._id == _id) {
                [items removeObjectAtIndex:idx];
                ii = _ii;
                *stop = YES;
            }
        }];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        ii.view.hidden = YES;
        [self calculateRects];
        [ii.view removeFromSuperview];
    }];
}

- (void)setHeaderSuffix:(NSString *)suffix
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        header.text = [NSString stringWithFormat:@"Downloads (%@)", suffix];
    }];
}

- (CGRect)rectFromBottom
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.origin.y = bounds.size.height;
    bounds.size.height = 0;

    return bounds;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    __block NSInteger height = 0;

    if ([items count] == 0) {
        self.frame = [self rectFromBottom];
        return;
    }

    // Header
    header.frame = CGRectMake(5, height, width - 5, header.font.lineHeight);
    height += header.font.lineHeight;

    // Items
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *ii, NSUInteger idx, BOOL *stop) {
            if ([ii isExpanded] == NO)
                ii.view.frame = CGRectMake(0, height, width, header.font.lineHeight);
            else
                ii.view.frame = CGRectMake(0, height, width, ii.height);
            height += ii.view.frame.size.height;
        }];
    }
    self.frame = CGRectMake(0, self.superview.frame.size.height - height, width, height);
}

- (void)viewWillTransitionToSize
{
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *d, NSUInteger idx, BOOL *stop) {
            [d calculateRects];
        }];
    }
    [self calculateRects];
}

- (void)changeTheme
{
    [super changeTheme];
    self.backgroundColor = [UIColor lightGrayColor];
}

// -----------------------------------------------------

- (InfoItem *)findInfoItem:(InfoItemID)_id
{
    __block InfoItem *ii = nil;
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *_ii, NSUInteger idx, BOOL *stop) {
            if (_ii._id == _id) {
                ii = _ii;
                *stop = YES;
            }
        }];
    }
    return ii;
}

- (void)calculateRects:(InfoItemID)_id
{
    [[self findInfoItem:_id] calculateRects];
}

- (void)expand:(InfoItemID)_id yesno:(BOOL)yesno
{
    [[self findInfoItem:_id] expand:yesno];
}
- (BOOL)isExpanded:(InfoItemID)_id
{
    return [[self findInfoItem:_id] isExpanded];
}

- (void)setDescription:(InfoItemID)_id description:(NSString *)newDesc
{
    [[self findInfoItem:_id] setDescription:newDesc];
}

- (void)setURL:(InfoItemID)_id url:(NSString *)newURL
{
    [[self findInfoItem:_id] setURL:newURL];
}

- (void)setQueueSize:(InfoItemID)_id queueSize:(NSInteger)queueSize
{
    [[self findInfoItem:_id] setQueueSize:queueSize];
}

- (void)resetBytes:(InfoItemID)_id
{
    [[self findInfoItem:_id] resetBytes];
}

- (void)resetBytesChunks:(InfoItemID)_id
{
    [[self findInfoItem:_id] resetBytesChunks];
}

- (void)setBytesTotal:(InfoItemID)_id total:(NSInteger)newTotal
{
    [[self findInfoItem:_id] setBytesTotal:newTotal];
}

- (void)setBytesCount:(InfoItemID)_id count:(NSInteger)newCount
{
    [[self findInfoItem:_id] setBytesCount:newCount];
}

- (void)setChunksTotal:(InfoItemID)_id total:(NSInteger)newTotal
{
    [[self findInfoItem:_id] setChunksTotal:newTotal];
}

- (void)setChunksCount:(InfoItemID)_id count:(NSInteger)newCount
{
    [[self findInfoItem:_id] setChunksCount:newCount];
}

- (void)setLineObjectCount:(InfoItemID)_id count:(NSInteger)count
{
    [[self findInfoItem:_id] setLineObjectCount:count];
}

- (void)setLineObjectTotal:(InfoItemID)_id total:(NSInteger)total isLines:(BOOL)isLines
{
    [[self findInfoItem:_id] setLineObjectTotal:total isLines:isLines];
}

- (void)setWaypointsTotal:(InfoItemID)_id total:(NSInteger)i
{
    [[self findInfoItem:_id] setWaypointsTotal:i];
}

- (void)setWaypointsNew:(InfoItemID)_id new:(NSInteger)i
{
    [[self findInfoItem:_id] setWaypointsNew:i];
}

- (void)setLogsTotal:(InfoItemID)_id total:(NSInteger)i
{
    [[self findInfoItem:_id] setLogsTotal:i];
}

- (void)setLogsNew:(InfoItemID)_id new:(NSInteger)i
{
    [[self findInfoItem:_id] setLogsNew:i];
}

- (void)setTrackablesNew:(InfoItemID)_id new:(NSInteger)i
{
    [[self findInfoItem:_id] setTrackablesNew:i];
}

- (void)setTrackablesTotal:(InfoItemID)_id total:(NSInteger)i
{
    [[self findInfoItem:_id] setTrackablesTotal:i];
}

- (void)showWaypoints:(InfoItemID)_id yesno:(BOOL)yesno
{
    [[self findInfoItem:_id] showWaypoints:yesno];
}

- (void)showLogs:(InfoItemID)_id yesno:(BOOL)yesno
{
    [[self findInfoItem:_id] showLogs:yesno];
}

- (void)showTrackables:(InfoItemID)_id yesno:(BOOL)yesno
{
    [[self findInfoItem:_id] showTrackables:yesno];
}

@end
