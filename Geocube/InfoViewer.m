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

@interface InfoViewer ()
{
    NSMutableArray *items;
    GCLabel *header;
}

@end

@implementation InfoViewer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    items = [NSMutableArray arrayWithCapacity:5];

    [self calculateRects];
    [self changeTheme];

    return self;
}

- (BOOL)hasItems
{
    return ([items count] != 0);
}

- (InfoImageItem *)addImage
{
    __block NSInteger max = 0;
    InfoImageItem *iii = [[InfoImageItem alloc] init];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    iii.view = [[GCView alloc] initWithFrame:(CGRectZero)];
    iii.view.backgroundColor = [UIColor lightGrayColor];

    iii.labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    iii.labelQueue = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    iii.labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    iii.labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoDownloadItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        iii._id = max + 1;
        [items addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];

        [iii.view addSubview:iii.labelDesc];
        [iii.view addSubview:iii.labelURL];
        [iii.view addSubview:iii.labelQueue];
        [iii.view addSubview:iii.labelBytes];
        [iii calculateRects];

        [self addSubview:iii.view];
        [self calculateRects];
    }];

    return iii;
}

- (InfoImportItem *)addImport
{
    return nil;
}

- (InfoDownloadItem *)addDownload
{
    __block NSInteger max = 0;
    InfoDownloadItem *idi = [[InfoDownloadItem alloc] init];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    idi.view = [[GCView alloc] initWithFrame:(CGRectZero)];
    idi.view.backgroundColor = [UIColor lightGrayColor];

    idi.labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    idi.labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    idi.labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    idi.labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoDownloadItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        idi._id = max + 1;
        [items addObject:idi];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];

        [idi.view addSubview:idi.labelDesc];
        [idi.view addSubview:idi.labelURL];
        [idi.view addSubview:idi.labelChunks];
        [idi.view addSubview:idi.labelBytes];
        [idi calculateRects];

        [self addSubview:idi.view];
        [self calculateRects];
    }];

    return idi;
}

- (void)removeItem:(InfoItem *)i
{
    [i.view removeFromSuperview];

    @synchronized (items) {
        [items removeObject:i];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self calculateRects];
    }];
}

- (void)setHeaderSuffix:(NSString *)suffix
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        header.text = [NSString stringWithFormat:@"Downloads (%@)", suffix];
    }];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    __block NSInteger height = 0;

    if ([items count] == 0) {
        self.frame = CGRectZero;
        return;
    }

    header.frame = CGRectMake(5, height, width - 5, header.font.lineHeight);
    height += header.font.lineHeight;
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoDownloadItem *d, NSUInteger idx, BOOL *stop) {
            d.view.frame = CGRectMake(0, height, width, d.view.frame.size.height);
            height += d.view.frame.size.height;
        }];
    }
    self.frame = CGRectMake(0, self.superview.frame.size.height - height, width, height);
}

- (void)viewWillTransitionToSize
{
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoDownloadItem *d, NSUInteger idx, BOOL *stop) {
            [d calculateRects];
        }];
    }
}

- (void)changeTheme
{
    [super changeTheme];
    self.backgroundColor = [UIColor lightGrayColor];
}

@end
