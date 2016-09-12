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

@interface DownloadInfoDownload ()
{
    NSInteger chunksTotal, chunksCount;
    NSInteger bytesTotal, bytesCount;

    NSString *description;
    NSString *url;
}

@end

@implementation DownloadInfoDownload

@synthesize view;
@synthesize labelDesc, labelURL, labelBytes, labelChunks;

- (void)calculateRects
{
#define MARGIN  5
#define INDENT  10
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger y = MARGIN;

#define LABEL_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;
#define INDENT_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;

    INDENT_RESIZE(labelDesc);
    INDENT_RESIZE(labelURL);
    INDENT_RESIZE(labelChunks);
    INDENT_RESIZE(labelBytes);

    y += MARGIN;
    view.frame = CGRectMake(0, 0, width, y);
}

- (void)setDescription:(NSString *)newDesc
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        description = newDesc;
        labelDesc.text = newDesc;
    }];
}

- (void)setURL:(NSString *)newURL
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        url = newURL;
        labelURL.text = newURL;
    }];
}

- (void)setChunks
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (chunksTotal == 0)
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld", chunksCount];
        else
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld of %ld", chunksCount, chunksTotal];
    }];
}
- (void)setChunksTotal:(NSInteger)newTotal
{
    chunksTotal = newTotal;
    [self setChunks];
}
- (void)setChunksCount:(NSInteger)newCount
{
    chunksCount = newCount;
    [self setChunks];
}

- (void)setBytes
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (bytesTotal == 0)
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %ld", bytesCount];
        else
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@ of %@ (%ld %%)", [MyTools niceFileSize:bytesCount], [MyTools niceFileSize:bytesTotal], (bytesCount * 100) / bytesTotal];
    }];
}
- (void)setBytesTotal:(NSInteger)newTotal
{
    bytesTotal = newTotal;
    [self setBytes];
}
- (void)setBytesCount:(NSInteger)newCount
{
    bytesCount = newCount;
    [self setBytes];
}

@end
