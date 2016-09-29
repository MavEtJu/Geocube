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

@end

@implementation InfoItemDowload

- (instancetype)initWithInfoViewer:(InfoViewer *)parent
{
    self = [super init];

    NSLog(@"rectFromBottom: %@", [MyTools niceCGRect:[parent rectFromBottom]]);
    view = [[GCView alloc] initWithFrame:[parent rectFromBottom]];
    view.backgroundColor = [UIColor lightGrayColor];

    labelDesc = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelURL = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelChunks = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
    labelBytes = [[GCSmallLabel alloc] initWithFrame:CGRectZero];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [view addSubview:labelDesc];
        [view addSubview:labelURL];
        [view addSubview:labelChunks];
        [view addSubview:labelBytes];
        [self calculateRects];
    }];

    return self;
}

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

@end
