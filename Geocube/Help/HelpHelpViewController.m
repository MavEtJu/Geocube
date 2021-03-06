/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface HelpHelpViewController ()

@property (nonatomic, retain) GCScrollView *contentView;

@end

@implementation HelpHelpViewController

enum {
    menuIntroduction,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuIntroduction label:_(@"helphelpviewcontroller-Show introduction")];

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = NO;
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    self.contentView.delegate = self;
    self.view = self.contentView;

    [self changeThemeStyle];

    NSInteger y = 10;
    NSInteger width = applicationFrame.size.width;

    GCLabel *t = [[GCLabel alloc] initWithFrame:(CGRectMake(10, y, width - 20, 0))];
    t.numberOfLines = 0;
    t.lineBreakMode = NSLineBreakByWordWrapping;
    t.text = [NSString stringWithFormat:@"%@:\n\n%@\n\n%@\n\n%@\n\n%@\n",
              _(@"helphelpviewcontroller-For further help"),
              _(@"helphelpviewcontroller-The website https://geocube.mavetju.org/ has a lot of documentation on the workings of Geocube."),
              _(@"helphelpviewcontroller-Follow the project on Twitter as @GeocubeCaching for announcements."),
              _(@"helphelpviewcontroller-Checkout on the Facebook page as Geocube Geocaching for announcements."),
              _(@"helphelpviewcontroller-Email me geocube@mavetju.org if you have any questions, comments or feedback.")
              ];

    [t sizeToFit];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    y += t.frame.size.height;

    [self.contentView addSubview:t];
    self.contentView.contentSize = CGSizeMake(200, y);
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuIntroduction:
            [HelpIntroduction showIntro:_AppDelegate];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
