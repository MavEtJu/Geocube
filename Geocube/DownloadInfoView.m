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

    self.backgroundColor = [UIColor redColor];

    return self;
}

- (BOOL)hasDownloads
{
    return ([downloads count] != 0);
}

- (NSInteger)addDownload:(NSString *)desc url:(NSString *)url
{
    __block NSInteger max = 0;
    DownloadInfoDownload *did = [[DownloadInfoDownload alloc] init];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    did.desc = desc;
    did.url = url;
    did.view = [[GCView alloc] initWithFrame:(CGRectZero)];
    did.view.backgroundColor = [UIColor lightGrayColor];

    did.labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelDesc.text = did.desc;
    did.labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelURL.text = did.url;
    did.labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelChunks.text = @"Chunks:";
    did.labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelBytes.text = @"Downloaded:";

    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoDownload *d, NSUInteger idx, BOOL *stop) {
            max = MAX(max, d._id);
        }];
        did._id = max + 1;
        [downloads addObject:did];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addSubview:header];

        [did.view addSubview:did.labelDesc];
        [did.view addSubview:did.labelURL];
        [did.view addSubview:did.labelChunks];
        [did.view addSubview:did.labelBytes];
        [did calculateRects];

        [self addSubview:did.view];
        [self calculateRects];
    }];

    return did._id;
}

- (void)removeDownload:(NSInteger)__id
{
    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoDownload *d, NSUInteger idx, BOOL *stop) {
            if (d._id == __id) {
                [d.view removeFromSuperview];
                [downloads removeObject:d];
                *stop = YES;
            }
        }];
    }

    [self calculateRects];
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

    header.frame = CGRectMake(0, height, width, header.font.lineHeight);
    height += header.font.lineHeight;
    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoDownload *d, NSUInteger idx, BOOL *stop) {
            d.view.frame = CGRectMake(0, height, width, d.view.frame.size.height);
            height += d.view.frame.size.height;
        }];
    }
    self.frame = CGRectMake(0, self.superview.frame.size.height - height, width, height);
}

- (void)viewWillTransitionToSize
{
    @synchronized (downloads) {
        [downloads enumerateObjectsUsingBlock:^(DownloadInfoDownload *d, NSUInteger idx, BOOL *stop) {
            [d calculateRects];
        }];
    }
}

- (void)changeTheme
{
    [super changeTheme];
}

@end
