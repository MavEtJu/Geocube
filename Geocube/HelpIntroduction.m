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

@interface HelpIntroduction ()

@end

@implementation HelpIntroduction

+ (void)showIntro:(AppDelegate *)appDelegate
{
    KxIntroViewPage *page;
    NSMutableArray<KxIntroViewPage *> *pages = [NSMutableArray arrayWithCapacity:10];
    page = [KxIntroViewPage introViewPageWithTitle: @"Welcome to Geocube"
                                        withDetail: @"Please go through this quick introduction to understand the UI."
                                         withImage: [UIImage imageNamed:@"GC - logo - 512x512"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle: @"Menus and tabs"
                                        withDetail: @"The red arrow points to the global menu.\nThe brown arrow points to the local menu for this tab.\nThe green arrows point to the tabs.\nThe menu can be larger than your screen, you can scroll in it!"
                                         withImage: [UIImage imageNamed:@"Menu - 640x623"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle: @"How to close a window"
                                        withDetail: @"When you see a close button at the top left, you can either tap it or swipe left on page to close it.\n\n(Does the left swipe not work? Tap the close button!)"
                                         withImage: [UIImage imageNamed:@"Close Window - 640x430"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle: @"Map icons"
                                        withDetail: @"- Follow me with auto-zoom.\n- Follow me, do not zoom.\n- Show both me and the target.\n- Show target, do not zoom.\n- Show target and zoom in.\n\nTry them when you are at the map!"
                                         withImage: [UIImage imageNamed:@"Map icons - 362x86"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle: @"Happy geocaching!"
                                        withDetail: @"You can watch this introduction again in the Help tab of the Help menu."
                                         withImage: [UIImage imageNamed:@"GC - logo - 512x512"]];
    [pages addObject:page];

    KxIntroViewController *vc = [[KxIntroViewController alloc] initWithPages:pages];

    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = YES;

    //[vc presentInView:self.window.rootViewController.view];
    [vc presentInViewController:appDelegate.window.rootViewController fullScreenLayout:YES];

    [configManager introSeenUpdate:TRUE];
}

@end
