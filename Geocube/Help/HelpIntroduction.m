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
    page = [KxIntroViewPage introViewPageWithTitle:NSLocalizedString(@"helpintroduction-title1", nil)
                                        withDetail:NSLocalizedString(@"helpintroduction-text1", nil)
                                         withImage:[UIImage imageNamed:@"GC - logo - 512x512"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle:NSLocalizedString(@"helpintroduction-title2", nil)
                                        withDetail:NSLocalizedString(@"helpintroduction-text2", nil)
                                         withImage:[UIImage imageNamed:@"Menu - 640x623"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle:NSLocalizedString(@"helpintroduction-title3", nil)
                                        withDetail:NSLocalizedString(@"helpintroduction-text3", nil)
                                         withImage:[UIImage imageNamed:@"Close Window - 640x430"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle:NSLocalizedString(@"helpintroduction-title4", nil)
                                        withDetail:NSLocalizedString(@"helpintroduction-text4", nil)
                                         withImage:[UIImage imageNamed:@"Map icons - 362x86"]];
    [pages addObject:page];

    page = [KxIntroViewPage introViewPageWithTitle:NSLocalizedString(@"helpintroduction-title5", nil)
                                        withDetail:NSLocalizedString(@"helpintroduction-text5", nil)
                                         withImage:[UIImage imageNamed:@"GC - logo - 512x512"]];
    [pages addObject:page];

    KxIntroViewController *vc = [[KxIntroViewController alloc] initWithPages:pages];

    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = YES;

    [vc presentInViewController:appDelegate.window.rootViewController fullScreenLayout:YES];

    [configManager introSeenUpdate:TRUE];
}

@end
