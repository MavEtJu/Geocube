//
//  DeveloperInfoViewViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 26/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@interface DeveloperInfoViewViewController ()

@property (nonatomic, retain) InfoItem2 *ii1;
@property (nonatomic, retain) InfoItem2 *ii2;
@property (nonatomic, retain) InfoItem2 *ii3;

@end

@implementation DeveloperInfoViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeInfoView2];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self showInfoView2];

    self.ii1 = [self.infoView2 addDownload];
    self.ii2 = [self.infoView2 addDownload];
    self.ii3 = [self.infoView2 addImport];
    [self.infoView2 show];

    BACKGROUND(animate, nil);
}

- (void)animate
{
    NSInteger i = 0;
    while (1) {
        i++;
        if (i % 10 == 0) {
            self.ii1 = [self.infoView2 addDownload];
        } else if (i % 10 == 5) {
            [self.infoView2 removeDownload:self.ii1];
            self.ii1 = nil;
        }

        if (i % 3 == 0)
            [self.ii1 changeExpanded:![self.ii1 isExpanded]];

        [self.ii1 changeURL:[NSString stringWithFormat:@"1 gg jURL foo: %@", [NSNumber numberWithInteger:rand()]]];
        [self.ii1 changeDescription:[NSString stringWithFormat:@"1 gg jDescription foo: %@", [NSNumber numberWithInteger:rand()]]];

        [self.ii2 changeURL:[NSString stringWithFormat:@"2 gg jURL foo: %@", [NSNumber numberWithInteger:rand()]]];

        [self.ii3 changeDescription:[NSString stringWithFormat:@"3 gg jDescription foo: %@", [NSNumber numberWithInteger:rand()]]];

        [self.infoView2 show];
        [NSThread sleepForTimeInterval:1];
    }
}

@end
