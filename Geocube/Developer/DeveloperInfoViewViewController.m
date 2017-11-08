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

@interface DeveloperInfoViewViewController ()

@property (nonatomic, retain) InfoItem *ii1;
@property (nonatomic, retain) InfoItem *ii2;
@property (nonatomic, retain) InfoItem *ii3;

@end

@implementation DeveloperInfoViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeInfoView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self showInfoView];

    self.ii1 = [self.infoView addDownload];
    self.ii2 = [self.infoView addDownload];
    self.ii3 = [self.infoView addImport];

    [self.ii2 changeBytesTotal:100];

    [self.infoView show];

    BACKGROUND(animate, nil);
}

- (void)animate
{
    NSInteger i = 0;
    while (1) {
        i++;
        if (i % 10 == 0) {
            self.ii1 = [self.infoView addDownload];
        } else if (i % 10 == 5) {
            [self.ii1 removeFromInfoViewer];
            self.ii1 = nil;
        }

        if (i % 3 == 0)
            [self.ii1 changeExpanded:![self.ii1 isExpanded]];

        [self.ii1 changeURL:[NSString stringWithFormat:@"1 gg jURL foo: %@", [NSNumber numberWithInteger:rand()]]];
        [self.ii1 changeDescription:[NSString stringWithFormat:@"1 gg jDescription foo: %@", [NSNumber numberWithInteger:rand()]]];

        [self.ii2 changeBytesCount:rand() % 100];
        [self.ii2 changeURL:[NSString stringWithFormat:@"2 gg jURL foo: %@", [NSNumber numberWithInteger:rand()]]];

        [self.ii3 changeDescription:[NSString stringWithFormat:@"3 gg jDescription foo: %@", [NSNumber numberWithInteger:rand()]]];

        [NSThread sleepForTimeInterval:1];
    }
}

@end
