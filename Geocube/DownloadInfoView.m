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

- (DownloadInfoDownload *)addDownload:(NSString *)description
{
    DownloadInfoDownload *did = [self addDownload];
    [did setDescription:description];
    return did;
}

- (DownloadInfoDownload *)addDownload
{
    __block NSInteger max = 0;
    DownloadInfoDownload *did = [[DownloadInfoDownload alloc] init];

    header = [[GCLabel alloc] initWithFrame:CGRectZero];
    header.text = @"Downloads";
    header.backgroundColor = [UIColor lightGrayColor];

    did.view = [[GCView alloc] initWithFrame:(CGRectZero)];
    did.view.backgroundColor = [UIColor lightGrayColor];

    did.labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    did.labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

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

    return did;
}

- (void)removeDownload:(DownloadInfoDownload *)did
{
    [did.view removeFromSuperview];

    @synchronized (downloads) {
        [downloads removeObject:did];
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

    header.frame = CGRectMake(5, height, width - 5, header.font.lineHeight);
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
    self.backgroundColor = [UIColor lightGrayColor];
}

@end
