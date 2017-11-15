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

@property (nonatomic, retain) NSMutableArray<InfoItem *> *downloads;
@property (nonatomic, retain) GCLabelNormalText *headerDownloads;
@property (nonatomic, retain) NSMutableArray<InfoItem *> *imports;
@property (nonatomic, retain) GCLabelNormalText *headerImports;
@property (nonatomic, retain) NSMutableArray<InfoItem *> *images;
@property (nonatomic, retain) GCLabelNormalText *headerImages;

@property (nonatomic, retain) NSMutableArray<InfoItem *> *removed;
@property (nonatomic, retain) NSMutableArray<InfoItem *> *added;

@property (nonatomic        ) NSInteger contentOffset;
@property (nonatomic        ) BOOL isVisible;
@property (nonatomic        ) BOOL isRefreshing;
@property (nonatomic        ) BOOL stopUpdating;

@end

@implementation InfoViewer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];

    self.headerDownloads = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerDownloads.text = _(@"infoviewer-Downloads");
    [self addSubview:self.headerDownloads];

    self.headerImports = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerImports.text = _(@"infoviewer-Imports");
    [self addSubview:self.headerImports];

    self.headerImages = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerImages.text = _(@"infoviewer-Imports");
    [self addSubview:self.headerImages];

    self.isVisible = NO;
    self.needsRefresh = YES;

    self.downloads = [NSMutableArray arrayWithCapacity:5];
    self.imports = [NSMutableArray arrayWithCapacity:5];
    self.images = [NSMutableArray arrayWithCapacity:5];
    self.removed = [NSMutableArray arrayWithCapacity:5];
    self.added = [NSMutableArray arrayWithCapacity:5];

    return self;
}

- (InfoItem *)addDownload
{
    InfoItem *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;
    ii.backgroundColor = [UIColor clearColor];

    @synchronized (self.downloads) {
        [self.downloads addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (InfoItem *)addImport
{
    InfoItem *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;
    ii.backgroundColor = [UIColor clearColor];

    @synchronized (self.imports) {
        [self.imports addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (InfoItem *)addImage
{
    InfoItem *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;
    ii.backgroundColor = [UIColor clearColor];

    @synchronized (self.images) {
        [self.images addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (void)removeItem:(InfoItem *)item
{
    if ([self removeFromItem:item elements:self.downloads] == YES) {
    } else if ([self removeFromItem:item elements:self.imports] == YES) {
    } else if ([self removeFromItem:item elements:self.images] == YES) {
    } else {
        NSAssert(FALSE, @"Unknown infoItem");
    }
}

- (BOOL)removeFromItem:(InfoItem *)element elements:(NSMutableArray<InfoItem *> *)elements
{
    @synchronized (elements) {
        __block NSInteger index = -1;
        [elements enumerateObjectsUsingBlock:^(InfoItem * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
            if (e == element) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index == -1)
            return NO;
        [elements removeObjectAtIndex:index];
        element.needsRefresh = YES;
        @synchronized (self.removed) {
            [self.removed addObject:element];
        }
        self.needsRefresh = YES;
    }

    return YES;
}

- (void)adjustScroll:(NSInteger)offset
{
    NSLog(@"%ld, %@, %@", offset, [MyTools niceCGRect:self.frame], [MyTools niceCGRect:self.superview.frame]);
    if (self.contentOffset == offset)
        return;
    self.contentOffset = offset;
    NSInteger Y = self.superview.frame.size.height - self.frame.size.height + self.contentOffset;
    self.frame = CGRectMake(0, Y, self.frame.size.width, self.frame.size.height);
}

- (void)show
{
    NSLog(@"%@", [MyTools niceCGRect:self.superview.frame]);
    self.isVisible = YES;
    self.needsRefresh = YES;

    BACKGROUND(refreshItems, nil);
    MAINQUEUE(
        [self adjustRects];
    );
}

- (void)hide
{
    self.isVisible = NO;
    self.stopUpdating = YES;
    self.needsRefresh = NO;

    InfoItem *ii;
    NSEnumerator *e;
    e = [self.imports objectEnumerator];
    while ((ii = [e nextObject]) != nil) {
        [ii removeFromInfoViewer];
    }
    e = [self.downloads objectEnumerator];
    while ((ii = [e nextObject]) != nil) {
        [ii removeFromInfoViewer];
    }
    e = [self.images objectEnumerator];
    while ((ii = [e nextObject]) != nil) {
        [ii removeFromInfoViewer];
    }

    MAINQUEUE(
        [self adjustRects];
    );
}

- (BOOL)hasItems
{
    return ([self.images count] + [self.imports count] + [self.downloads count]) != 0;
}

- (void)refreshItems
{
    if (self.isRefreshing == YES)
        return;

    self.isRefreshing = YES;
    while (1) {
        [NSThread sleepForTimeInterval:0.1];

        MAINQUEUE(
            [self adjustRects];
        );
        if (self.stopUpdating == YES)
            break;
    }
    self.isRefreshing = NO;
    self.stopUpdating = NO;
}

- (void)adjustRects
{
    CGRect applicationFrame = self.superview.frame;
    NSInteger width = applicationFrame.size.width;

    __block NSInteger y = 0;

    // Deal with modifications
    @synchronized (self.added) {
        [self.added enumerateObjectsUsingBlock:^(InfoItem * _Nonnull add, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:add];
        }];
        [self.added removeAllObjects];
    }
    @synchronized (self.removed) {
        [self.removed enumerateObjectsUsingBlock:^(InfoItem * _Nonnull remove, NSUInteger idx, BOOL * _Nonnull stop) {
            [remove removeFromSuperview];
        }];
        [self.removed removeAllObjects];
    }

    @synchronized(self.downloads) {
        if ([self.downloads count] != 0) {
            self.headerDownloads.frame = CGRectMake(0, y, 0, 0);
            [self.headerDownloads sizeToFit];
            y += self.headerDownloads.frame.size.height;
            y += 4;

            [self.downloads enumerateObjectsUsingBlock:^(InfoItem * _Nonnull download, NSUInteger idx, BOOL * _Nonnull stop) {
                [download sizeToFit];
                download.frame = CGRectMake(0, y, download.frame.size.width, download.frame.size.height);
                y += download.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerDownloads.frame = CGRectZero;
        }
    }

    @synchronized(self.imports) {
        if ([self.imports count] != 0) {
            self.headerImports.frame = CGRectMake(0, y, 0, 0);
            [self.headerImports sizeToFit];
            y += self.headerImports.frame.size.height;
            y += 4;

            [self.imports enumerateObjectsUsingBlock:^(InfoItem * _Nonnull import, NSUInteger idx, BOOL * _Nonnull stop) {
                [import sizeToFit];
                import.frame = CGRectMake(0, y, import.frame.size.width, import.frame.size.height);
                y += import.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerImports.frame = CGRectZero;
        }
    }

    @synchronized(self.images) {
        if ([self.images count] != 0) {
            self.headerImages.frame = CGRectMake(0, y, 0, 0);
            [self.headerImages sizeToFit];
            y += self.headerImages.frame.size.height;
            y += 4;

            [self.images enumerateObjectsUsingBlock:^(InfoItem * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
                [image sizeToFit];
                image.frame = CGRectMake(0, y, image.frame.size.width, image.frame.size.height);
                y += image.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerImages.frame = CGRectZero;
        }
    }

    // Do not display unless....
    if (self.isVisible == NO) {
        self.frame = CGRectZero;
        return;
    }

    self.frame = CGRectMake(0, applicationFrame.size.height - y + self.contentOffset, width, y);
}

@end
