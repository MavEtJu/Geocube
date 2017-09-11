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

@interface InfoViewer ()
{
    NSMutableArray<InfoItem *> *imageItems;
    NSMutableArray<InfoItem *> *downloadItems;
    NSMutableArray<InfoItem *> *importItems;
    GCLabel *imageHeader;
    GCLabel *downloadHeader;
    GCLabel *importHeader;
    InfoItemID maxid;
    BOOL stopUpdating;
    NSInteger contentOffset;
}

@end

@implementation InfoViewer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    imageHeader = [[GCLabel alloc] initWithFrame:CGRectZero];
    imageHeader.text = _(@"infoviewer-Images");
    imageHeader.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:imageHeader];

    downloadHeader = [[GCLabel alloc] initWithFrame:CGRectZero];
    downloadHeader.text = _(@"infoviewer-Downloads");
    downloadHeader.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:downloadHeader];

    importHeader = [[GCLabel alloc] initWithFrame:CGRectZero];
    importHeader.text = _(@"infoviewer-Imports");
    importHeader.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:importHeader];

    importItems = [NSMutableArray arrayWithCapacity:5];
    downloadItems = [NSMutableArray arrayWithCapacity:5];
    imageItems = [NSMutableArray arrayWithCapacity:5];
    maxid = 1;

    [self calculateRects];
    [self changeTheme];

    stopUpdating = YES;

    return self;
}

- (void)show:(NSInteger)_contentOffset
{
    stopUpdating = NO;
    contentOffset = _contentOffset;
    BACKGROUND(refreshItems, nil);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
        CGRect frame = self.frame;
        CGRect bounds = self.superview.frame;

        frame.origin.y = contentOffset + bounds.size.height - frame.size.height;
        self.frame = frame;

        self.hidden = NO;
        [self.superview bringSubviewToFront:self];
    }];
}

- (void)hide
{
    stopUpdating = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
        self.hidden = YES;
    }];
}

- (void)refreshItems
{
    while (1) {
        [NSThread sleepForTimeInterval:0.1];

        [self refreshItems:imageItems];
        [self refreshItems:downloadItems];
        [self refreshItems:importItems];

        if (stopUpdating == YES)
            break;
    }
}

- (void)refreshItems:(NSArray<InfoItem *> *)items
{
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem * _Nonnull ii, NSUInteger idx, BOOL * _Nonnull stop) {
            if (ii.needsRefresh == YES) {
                NSLog(@".");
                [ii refresh];
            }
            if (ii.needsRecalculate == YES) {
                NSLog(@"!");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [ii recalculate];
                    [self calculateRects];
                }];
            }
        }];
    }
}

- (BOOL)hasItems
{
    return ([imageItems count] + [downloadItems count] + [importItems count] != 0);
}

- (NSInteger)addImage
{
    return [self addImage:YES];
}

- (NSInteger)addImage:(BOOL)expanded
{
    InfoItem *iii = [[InfoItem alloc] initWithInfoViewer:self type:INFOITEM_IMAGE expanded:expanded];

    @synchronized (imageItems) {
        iii._id = maxid++;
        [imageItems addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:iii.view];
        [self calculateRects];
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

    @synchronized (importItems) {
        iii._id = maxid++;
        [importItems addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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

    @synchronized (downloadItems) {
        iid._id = maxid++;
        [downloadItems addObject:iid];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:iid.view];
        [self calculateRects];
    }];

    return iid._id;
}

- (void)removeItem:(InfoItemID)_id
{
    [self removeItem:_id from:imageItems];
    [self removeItem:_id from:downloadItems];
    [self removeItem:_id from:importItems];
}

- (void)removeItem:(InfoItemID)_id from:(NSMutableArray<InfoItem *> *)items
{
    __block InfoItem *ii = nil;
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem * _Nonnull _ii, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_ii._id == _id) {
                [items removeObjectAtIndex:idx];
                ii = _ii;
                *stop = YES;
            }
        }];
    }

    if (ii != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [ii.view removeFromSuperview];
            [self calculateRects];
        }];
    }
}

- (void)setImageHeaderSuffix:(NSString *)suffix
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        imageHeader.text = [NSString stringWithFormat:@"%@ (%@)", _(@"infoviewer-Images"), suffix];
    }];
}

- (void)setDownloadHeaderSuffix:(NSString *)suffix
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        downloadHeader.text = [NSString stringWithFormat:@"%@ (%@)", _(@"infoviewer-Downloads"), suffix];
    }];
}

- (void)setImportHeaderSuffix:(NSString *)suffix
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        importHeader.text = [NSString stringWithFormat:@"%@ (%@)", _(@"infoviewer-Imports"), suffix];
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

    if ([self hasItems] == NO) {
        self.frame = [self rectFromBottom];
        return;
    }

    height += [self calculateRects:imageItems header:imageHeader height:height];
    height += [self calculateRects:downloadItems header:downloadHeader height:height];
    height += [self calculateRects:importItems header:importHeader height:height];

    self.frame = CGRectMake(0, contentOffset + self.superview.frame.size.height - height, width, height);
}

- (NSInteger)calculateRects:(NSArray<InfoItem *> *)items header:(GCLabel *)header height:(NSInteger)heightOffset
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    __block NSInteger height = heightOffset;

    // Header
    header.frame = CGRectMake(5, height, width - 5, header.font.lineHeight);
    height += header.font.lineHeight;

    // Items
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem * _Nonnull ii, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([ii isExpanded] == NO)
                ii.view.frame = CGRectMake(0, height, width, header.font.lineHeight);
            else
                ii.view.frame = CGRectMake(0, height, width, ii.height);
            height += ii.view.frame.size.height;
        }];
    }

    return height - heightOffset;
}

- (void)viewWillTransitionToSize
{
    [self viewWillTransitionToSize:imageItems];
    [self viewWillTransitionToSize:downloadItems];
    [self viewWillTransitionToSize:importItems];
    [self calculateRects];
}

- (void)viewWillTransitionToSize:(NSArray<InfoItem *> *)items
{
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
            [d calculateRects];
        }];
    }
}

- (void)changeTheme
{
    [super changeTheme];
    self.backgroundColor = [UIColor lightGrayColor];
}

// -----------------------------------------------------

- (InfoItem *)findInfoItem:(InfoItemID)_id
{
    InfoItem *ii = nil;

    ii = [self findInfoItem:imageItems infoItem:_id];
    if (ii != nil)
        return ii;
    ii = [self findInfoItem:downloadItems infoItem:_id];
    if (ii != nil)
        return ii;
    ii = [self findInfoItem:importItems infoItem:_id];
    return ii;
}

- (InfoItem *)findInfoItem:(NSArray<InfoItem *> *)items infoItem:(InfoItemID)_id
{
    __block InfoItem *ii = nil;

    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem * _Nonnull _ii, NSUInteger idx, BOOL * _Nonnull stop) {
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
