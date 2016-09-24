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

- (InfoItemImage *)addImage
{
    __block NSInteger max = 0;
    InfoItemImage *iii = [[InfoItemImage alloc] initWithInfoViewer:self];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Images";
    header.backgroundColor = [UIColor lightGrayColor];

    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        iii._id = max + 1;
        [items addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];
        [self addSubview:iii.view];
        [self calculateRects];
    }];

    return iii;
}

- (InfoItemImport *)addImport
{
    __block NSInteger max = 0;
    InfoItemImport *iii = [[InfoItemImport alloc] initWithInfoViewer:self];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Imports";
    header.backgroundColor = [UIColor lightGrayColor];

    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        iii._id = max + 1;
        [items addObject:iii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];
        [self addSubview:iii.view];
        [self calculateRects];
    }];

    return iii;
}

- (InfoItemDowload *)addDownload
{
    InfoItemDowload *iid = [[InfoItemDowload alloc] initWithInfoViewer:self];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    __block NSInteger max = 0;
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        iid._id = max + 1;
        [items addObject:iid];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];
        [self addSubview:iid.view];
        [self calculateRects];
    }];

    return iid;
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
        [items enumerateObjectsUsingBlock:^(InfoItemDowload *d, NSUInteger idx, BOOL *stop) {
            d.view.frame = CGRectMake(0, height, width, d.view.frame.size.height);
            height += d.view.frame.size.height;
        }];
    }
    self.frame = CGRectMake(0, self.superview.frame.size.height - height, width, height);
}

- (void)viewWillTransitionToSize
{
    @synchronized (items) {
        [items enumerateObjectsUsingBlock:^(InfoItemDowload *d, NSUInteger idx, BOOL *stop) {
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