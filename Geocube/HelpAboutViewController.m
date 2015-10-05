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

@implementation HelpAboutViewController

- (instancetype)init
{
    self = [super init];

    menuItems = nil;

    return self;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self reloadTexts];
                                 }
     ];
}

- (NSInteger)addText:(NSInteger)y text:(NSString *)t
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    width = bounds.size.width;
    GCTextblock *l;

    CGRect rect = CGRectMake(10, y, width - 20, 0);
    l = [[GCTextblock alloc] initWithFrame:rect];
    l.text = t;
    [l sizeToFit];
    [self.view addSubview:l];

    return l.frame.size.height + 10;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadTexts];
}

- (void)reloadTexts
{
    NSInteger y = 10;

    // CLean up and write again.
    for (GCView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[GCCloseButton class]] == YES)
            continue;
        [subview removeFromSuperview];
    }

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    GCScrollView *contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    self.view = contentView;

    y += [self addText:y text:
          @"This software uses the following 3rd party modules:"
          ];

    y += [self addText:y text:
          @"ActionSheetPicker: Copyright (c) 2011, Tim Cinel (https://github.com/skywinder/ActionSheetPicker-3.0)"
          ];
    y += [self addText:y text:
          @"BHTabBar: Copyright (c) 2011 Fictorial LLC. (https://github.com/fictorial/BHTabBar)."
          ];
    y += [self addText:y text:
          @"CMRangeSlider: Copyright (c) 2010 Charlie Mezak <charliemezak@gmail.com>  (https://github.com/cmezak/CMRangeSlider)."
          ];
    y += [self addText:y text:
          @"DejalActivityView: Includes 'DejalActivtyView' code from Dejal (http://www.dejal.com/developer/)."
          ];
    y += [self addText:y text:
          @"DOPNavbarMenu: Copyright (c) 2015 Weizhou (https://github.com/dopcn/DOPNavbarMenu)"
          ];
    y += [self addText:y text:
          @"NKOColorPickerView: Copyright (C) 2014 Carlos Vidal (https://github.com/nakiostudio/NKO-Color-Picker-View-iOS)"
          ];
    y += [self addText:y text:
          @"YIPopupTextView: Copyright (c) 2012 Yasuhiro Inami. All rights reserved. (https://github.com/inamiy/YIPopupTextView)"
          ];
    y += [self addText:y text:
          @"SSZipArchive: Copyright (c) 2010-2015, Sam Soffes, http://soff.es (https://github.com/iosphere/ssziparchive)"
          ];
    y += [self addText:y text:
          @"'Import Complete' sound: Copyright (c) 2011, Brandon Morris CC-BY 3.0 (http://opengameart.org/content/completion-sound)"
          ];

    y += [self addText:y text:
          @"My sincere thanks to all of the above for their generousity."
          ];

    contentView.contentSize = CGSizeMake(width, y);
}

@end
