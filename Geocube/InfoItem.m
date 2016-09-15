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

@interface InfoItem ()
{
    NSInteger bytesTotal, bytesCount;
}

@end

@implementation InfoItem

@synthesize view, _id;

NEEDS_OVERLOADING(calculateRects)

- (instancetype)initWithInfoViewer:(InfoViewer *)parent
{
    self = [super init];
    return self;
}

- (void)setDescription:(NSString *)newDesc
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelDesc.text = newDesc;
    }];
}

- (void)setURL:(NSString *)newURL
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelURL.text = newURL;
    }];
}

- (void)setQueueSize:(NSInteger)queueSize
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        labelQueue.text = [NSString stringWithFormat:@"Queue depth: %ld", (long)queueSize];
    }];
}

- (void)showLines
{
    NSInteger lt = lineTotal;
    NSInteger lc = lineCount;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (lt <= 0)
            labelLines.text = [NSString stringWithFormat:@"Lines: %ld", lc];
        else
            labelLines.text = [NSString stringWithFormat:@"Lines: %ld of %ld (%ld%%)", lc, lt, 100 * lc / lt];
    }];
}
- (void)setLineCount:(NSInteger)count
{
    lineCount = count;
    [self showLines];
}
- (void)setLineTotal:(NSInteger)total
{
    lineTotal = total;
    [self showLines];
}

- (void)showObjects
{
    NSInteger ot = objectTotal;
    NSInteger oc = objectCount;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (ot <= 0)
            labelObjects.text = [NSString stringWithFormat:@"Objects: %ld", oc];
        else
            labelObjects.text = [NSString stringWithFormat:@"Objects: %ld of %ld (%ld%%)", oc, ot, 100 * oc / ot];
    }];
}
- (void)setObjectCount:(NSInteger)count
{
    objectCount = count;
    [self showObjects];
}
- (void)setObjectTotal:(NSInteger)total
{
    objectTotal = total;
    [self showObjects];
}

- (void)resetBytes
{
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)showBytes
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSInteger bt = bytesTotal;
        NSInteger bc = bytesCount;
        if (bc < 0)
            labelBytes.text = @"Bytes: -";
        else if (bt <= 0)
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@", [MyTools niceFileSize:bc]];
        else
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@ of %@ (%ld %%)", [MyTools niceFileSize:bc], [MyTools niceFileSize:bt], (long)((bc * 100) / bt)];
    }];
}
- (void)setBytesTotal:(NSInteger)newTotal
{
    bytesTotal = newTotal;
    [self showBytes];
}
- (void)setBytesCount:(NSInteger)newCount
{
    bytesCount = newCount;
    [self showBytes];
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
