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

@synthesize view, _id, viewHeight;
@synthesize labelDesc, labelURL, labelBytes;

NEEDS_OVERLOADING(calculateRects)

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

- (void)resetBytes
{
    [self setBytesTotal:0];
    [self setBytesCount:-1];
}

- (void)setBytes
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSInteger bt = bytesTotal;
        NSInteger bc = bytesCount;
        if (bc < 0)
            labelBytes.text = @"Bytes: -";
        else if (bt <= 0)
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@", [MyTools niceFileSize:bc]];
        else
            labelBytes.text = [NSString stringWithFormat:@"Bytes: %@ of %@ (%ld %%)", [MyTools niceFileSize:bc], [MyTools niceFileSize:bt], (bc * 100) / bt];
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
