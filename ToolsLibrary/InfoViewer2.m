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

@interface InfoViewer2 ()

@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *downloads;
@property (nonatomic, retain) GCLabelNormalText *headerDownloads;
@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *imports;
@property (nonatomic, retain) GCLabelNormalText *headerImports;
@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *images;
@property (nonatomic, retain) GCLabelNormalText *headerImages;

@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *removed;
@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *added;

@property (nonatomic        ) BOOL isVisible;
@property (nonatomic        ) BOOL isRefreshing;
@property (nonatomic        ) BOOL stopUpdating;

@end

@implementation InfoViewer2

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];

    self.headerDownloads = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerDownloads.text = @"Downloads";
    [self.headerDownloads sizeToFit];
    [self addSubview:self.headerDownloads];

    self.headerImports = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerImports.text = @"Imports";
    [self.headerImports sizeToFit];
    [self addSubview:self.headerImports];

    self.headerImages = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerImages.text = @"Imports";
    [self.headerImages sizeToFit];
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

- (InfoItem2 *)addDownload
{
    InfoItem2 *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW2 owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;

    @synchronized (self.downloads) {
        [self.downloads addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (InfoItem2 *)addImport
{
    InfoItem2 *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW2 owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;

    @synchronized (self.imports) {
        [self.imports addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (InfoItem2 *)addImage
{
    InfoItem2 *ii;
    @synchronized (self) {
        ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW2 owner:self options:nil] firstObject];
    }
    ii.infoViewer = self;

    @synchronized (self.images) {
        [self.images addObject:ii];
    }
    @synchronized (self.added) {
        [self.added addObject:ii];
    }
    self.needsRefresh = YES;

    return ii;
}

- (void)removeItem:(InfoItem2 *)item
{
    if ([self removeFromItem:item elements:self.downloads] == YES) {
    } else if ([self removeFromItem:item elements:self.imports] == YES) {
    } else if ([self removeFromItem:item elements:self.images] == YES) {
        NSAssert(FALSE, @"Unknown infoItem");
    }
}

- (BOOL)removeFromItem:(InfoItem2 *)element elements:(NSMutableArray<InfoItem2 *> *)elements
{
    @synchronized (elements) {
        __block NSInteger index = -1;
        [elements enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)show
{
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

    @synchronized (self.added) {
        [self.added enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull add, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:add];
        }];
        [self.added removeAllObjects];
    }
    @synchronized (self.removed) {
        [self.removed enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull remove, NSUInteger idx, BOOL * _Nonnull stop) {
            [remove removeFromSuperview];
        }];
        [self.removed removeAllObjects];
    }

    if (self.isVisible == NO) {
        self.frame = CGRectZero;
        return;
    }

    @synchronized(self.downloads) {
        if ([self.downloads count] != 0) {
            self.headerDownloads.frame = CGRectMake(0, y, 0, 0);
            [self.headerDownloads sizeToFit];
            y += self.headerDownloads.frame.size.height;
            y += 4;

            [self.downloads enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull download, NSUInteger idx, BOOL * _Nonnull stop) {
                [download sizeToFit];
                download.backgroundColor = [UIColor redColor];
                download.frame = CGRectMake(0, y, download.frame.size.width, download.frame.size.height);
                y += download.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerDownloads.frame = CGRectMake(0, 0, 0, 0);
        }
    }

    @synchronized(self.imports) {
        if ([self.imports count] != 0) {
            self.headerImports.frame = CGRectMake(0, y, 0, 0);
            [self.headerImports sizeToFit];
            y += self.headerImports.frame.size.height;
            y += 4;

            [self.imports enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull import, NSUInteger idx, BOOL * _Nonnull stop) {
                [import sizeToFit];
                import.backgroundColor = [UIColor redColor];
                import.frame = CGRectMake(0, y, import.frame.size.width, import.frame.size.height);
                y += import.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerImports.frame = CGRectMake(0, 0, 0, 0);
        }
    }

    @synchronized(self.images) {
        if ([self.images count] != 0) {
            self.headerImages.frame = CGRectMake(0, y, 0, 0);
            [self.headerImages sizeToFit];
            y += self.headerImages.frame.size.height;
            y += 4;

            [self.images enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
                [image sizeToFit];
                image.backgroundColor = [UIColor redColor];
                image.frame = CGRectMake(0, y, image.frame.size.width, image.frame.size.height);
                y += image.frame.size.height;
                y += 4;
            }];
        } else {
            self.headerImages.frame = CGRectMake(0, 0, 0, 0);
        }
    }

    self.frame = CGRectMake(0, applicationFrame.size.height - y, width, y);
}

@end
