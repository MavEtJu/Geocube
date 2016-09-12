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

@interface DownloadInfoView ()
{
    NSMutableArray *downloads;
    GCLabel *header;
}

@end

@implementation DownloadInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    downloads = [NSMutableArray arrayWithCapacity:5];

    [self calculateRects];
    [self changeTheme];

    return self;
}

- (BOOL)hasDownloads
{
    return ([downloads count] != 0);
}

- (DownloadInfoItem *)addDownload:(NSString *)description
{
    DownloadInfoItem *dii = [self addDownload];
    [dii setDescription:description];
    return dii;
}

- (DownloadInfoItem *)addDownload
{
    __block NSInteger max = 0;
    DownloadInfoItem *dii = [[DownloadInfoItem alloc] init];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    dii.view = [[GCView alloc] initWithFrame:(CGRectZero)];
    dii.view.backgroundColor = [UIColor lightGrayColor];

    dii.labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    dii.labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    dii.labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    dii.labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoItem *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        dii._id = max + 1;
        [downloads addObject:dii];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];

        [dii.view addSubview:dii.labelDesc];
        [dii.view addSubview:dii.labelURL];
        [dii.view addSubview:dii.labelChunks];
        [dii.view addSubview:dii.labelBytes];
        [dii calculateRects];

        [self addSubview:dii.view];
        [self calculateRects];
    }];

    return dii;
}

- (void)removeDownload:(DownloadInfoItem *)dii
{
    [dii.view removeFromSuperview];

    @synchronized (downloads) {
        [downloads removeObject:dii];
    }

    [self calculateRects];
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

    if ([downloads count] == 0) {
        self.frame = CGRectZero;
        return;
    }

    header.frame = CGRectMake(5, height, width - 5, header.font.lineHeight);
    height += header.font.lineHeight;
    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoItem *d, NSUInteger idx, BOOL *stop) {
            d.view.frame = CGRectMake(0, height, width, d.view.frame.size.height);
            height += d.view.frame.size.height;
        }];
    }
    self.frame = CGRectMake(0, self.superview.frame.size.height - height, width, height);
}

- (void)viewWillTransitionToSize
{
    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoItem *d, NSUInteger idx, BOOL *stop) {
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
