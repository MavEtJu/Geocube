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

@interface GCViewController ()

@property (nonatomic, retain) GCCloseButton *closeButton;

@end

@implementation GCViewController

- (instancetype)init
{
    self = [super init];

    self.lmi = nil;
    self.numberOfItemsInRow = 3;

    self.hasCloseButton = NO;
    self.closeButton = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeTheme];
}

- (void)makeInfoView
{
    self.infoView = [[InfoViewer alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.infoView];
}

- (void)hideInfoView
{
    [self.infoView hide];
}

- (void)showInfoView
{
    NSAssert1(self.infoView != nil, @"makeInfoView not called for %@", [self class]);
    if (self.infoView.superview == nil)
        [self.view addSubview:self.infoView];
    [self.infoView show:0];
}

- (void)prepareCloseButton:(UIView *)view
{
    if (self.hasCloseButton == YES) {
        UISwipeGestureRecognizer *swipeToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closePage:)];
        swipeToRight.direction = UISwipeGestureRecognizerDirectionRight;
        [view addGestureRecognizer:swipeToRight];
    }
}

- (void)changeTheme
{
    self.view.backgroundColor = currentTheme.viewControllerBackgroundColor;

    for (UIView *v in self.view.subviews) {
        if ([v respondsToSelector:@selector(changeTheme)] == YES)
            [v performSelector:@selector(changeTheme)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showCloseButton];
}

- (void)showCloseButton
{
    if (self.hasCloseButton == YES)
        [self.view bringSubviewToFront:self.closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@/viewWillAppear: %0.0f px", [self class], self.view.frame.size.height);

    [menuGlobal defineLocalMenu:self.lmi forVC:self];

    // Add a close button to the view
    if (self.hasCloseButton == YES && self.closeButton == nil) {
        GCCloseButton *b = [GCCloseButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        [b addTarget:self action:@selector(closePage:) forControlEvents:UIControlEventTouchDown];
        self.closeButton = b;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                                [self calculateRects];
                                                [self viewWilltransitionToSize];
                                            }
                                 completion:nil
     ];
}

- (void)calculateRects
{
    if (self.infoView != nil)
        [self.infoView calculateRects];
    // Dummy for this class
}

- (void)viewWilltransitionToSize
{
    if (self.infoView != nil)
        [self.infoView viewWillTransitionToSize];
    // Dummy for this class
}

- (void)willClosePage
{
    // Nothing for now
}

- (void)closePage:(UIButton *)b
{
    [self willClosePage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.closeButton == nil)
        return;

    CGRect frame = self.closeButton.frame;
    frame.origin.x = scrollView.contentOffset.x;
    frame.origin.y = scrollView.contentOffset.y;
    self.closeButton.frame = frame;

    [self.view bringSubviewToFront:self.closeButton];
}

#pragma -- Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Not localized as it will only happen in development conditions
    [MyTools messageBox:self header:@"You selected..." text:[NSString stringWithFormat:@"number %@", @(index + 1)]];
}

@end
