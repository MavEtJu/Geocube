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
    KxIntroViewPage *page0 = [KxIntroViewPage introViewPageWithTitle: @"Hello from SampleApp"
                                                          withDetail: @"Look at this example of using the intro screen! Gradient background, full screen support and more."
                                                           withImage: [UIImage imageNamed:@"sun"]];

    KxIntroViewPage *page1 = [KxIntroViewPage introViewPageWithTitle: @"What's new"
                                                          withDetail: @"List of new features\n\n- feature #1\n- feature #2\n- feature #3\n- feature #4\n- feature #5"
                                                           withImage: [UIImage imageNamed:@"tor"]];

    KxIntroViewPage *page2 = [KxIntroViewPage introViewPageWithTitle: @"Lorem Ipsum passage"
                                                          withDetail: @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!"
                                                           withImage: nil];

    page1.detailLabel.textAlignment = NSTextAlignmentLeft;

    KxIntroViewController *vc = [[KxIntroViewController alloc ] initWithPages:@[ page0, page1, page2 ]];

    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = YES;

    //[vc presentInView:self.window.rootViewController.view];
    [vc presentInViewController:appDelegate.window.rootViewController fullScreenLayout:YES];
}

@end
