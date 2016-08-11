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

    GCLabel *t = [[GCLabel alloc] initWithFrame:(CGRectMake(10, y, width - 20, 0))];
    t.numberOfLines = 0;
    t.lineBreakMode = NSLineBreakByWordWrapping;
    t.text = @"For further help:\n\n"
              "The website https://geocube.mavetju.org/ has a lot of documentation on the workings of Geocube.\n\n"
              "Follow me on Twitter @GeocubeCaching for announcements.\n\n"
              "Checkout on Facebook: Geocube Geocaching for announcements.\n\n"
              "Email: geocube@mavetju.org if you have any questions, comments or feedback.\n";

    [t sizeToFit];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:t];
}

@end
