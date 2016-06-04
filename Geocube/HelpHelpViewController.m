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

#import "Geocube-Prefix.pch"

@interface HelpHelpViewController ()

@end

@implementation HelpHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSInteger y = 10;
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    UILabel *t = [[UILabel alloc] initWithFrame:(CGRectMake(10, y, width - 20, 0))];
    t.numberOfLines = 0;
    t.lineBreakMode = NSLineBreakByWordWrapping;
    t.font = [UIFont systemFontOfSize:myConfig.GCTextblockFont.pointSize];
    t.text = @"For further help:\n"
              "- The website https://geocube.mavetju.org/\n"
              "- Follow me on Twitter @GeocubeCaching\n"
              "- Checkout on Facebook: Geocube Geocaching\n"
              "- Email: geocube@mavetju.org\n";

    [t sizeToFit];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:t];
}

@end
