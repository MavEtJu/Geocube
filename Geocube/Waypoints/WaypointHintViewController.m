/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface WaypointHintViewController ()
{
    dbWaypoint *waypoint;
    GCScrollView *scrollview;
    GCTextblock *block;
}

@end

@implementation WaypointHintViewController

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    lmi = nil;

    return self;
}

- (void)loadView
{
    hasCloseButton = YES;
    [super loadView];
    // Do any additional setup after loading the view.

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    scrollview = [[GCScrollView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];

    block = [[GCTextblock alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    block.text = waypoint.gs_hint;
    block.numberOfLines = 0;

    [scrollview addSubview:block];
    [block sizeToFit];

    [scrollview sizeToFit];
    self.view = scrollview;

    [self prepareCloseButton:scrollview];
}

- (void)calculateRects
{
    [super calculateRects];
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    block.frame = CGRectMake(0, 0, width, 0);
    [block sizeToFit];
}

@end
