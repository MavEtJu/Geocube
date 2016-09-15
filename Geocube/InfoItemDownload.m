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

@interface InfoItemDowload ()
{
    NSInteger chunksTotal, chunksCount;
}

@end

@implementation InfoItemDowload

@synthesize labelChunks;

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

- (void)resetBytesChunks
{
    [self setChunksTotal:0];
    [self setChunksCount:-1];
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)setChunks
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (chunksCount < 0)
            labelChunks.text = @"Chunks: -";
        else if (chunksTotal == 0)
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld", (long)chunksCount];
        else
            labelChunks.text = [NSString stringWithFormat:@"Chunks: %ld of %ld", (long)chunksCount, (long)chunksTotal];
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

@end
