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

@interface GCTableViewController ()
{
    GCCloseButton *closeButton;
    NSInteger verticalContentOffset;
}

@end

@implementation GCTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    lmi = nil;
    self.numberOfItemsInRow = 3;

    closeButton = nil;
    self.hasCloseButton = NO;

    return self;
}

- (void)changeTheme
{
    self.tableView.backgroundColor = currentTheme.tableViewBackgroundColor;

    [themeManager changeThemeArray:[self.tableView visibleCells]];
    for (UIView *v in [self.tableView subviews]) {
        if ([v isKindOfClass:[UITableViewHeaderFooterView class]] == YES) {
            UITableViewHeaderFooterView *tvhfv = (UITableViewHeaderFooterView *)v;
            tvhfv.textLabel.backgroundColor = currentTheme.labelTextColor;
            tvhfv.textLabel.textColor = currentTheme.labelBackgroundColor;
        }
    }

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Make sure that the table cells size properly
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;

    [self changeTheme];
    if (self.hasCloseButton == YES) {
        UISwipeGestureRecognizer *swipeToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closePage:)];
        swipeToRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeToRight];
    }
}

- (void)makeInfoView
{
    infoView = [[InfoViewer alloc] initWithFrame:CGRectZero];
    [self.view addSubview:infoView];
}

- (void)hideInfoView
{
    [infoView hide];
}

- (void)showInfoView
{
    NSAssert1(infoView != nil, @"makeInfoView not called for %@", [self class]);
    [infoView show:verticalContentOffset];
}

- (void)buttonMenuLocal:(id)sender
{
    [menuGlobal.menuLocal show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.hasCloseButton == YES)
        [self.view bringSubviewToFront:closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@/viewWillAppear: %0.0f px", [self class], self.view.frame.size.height);

    [super viewWillAppear:animated];

    [menuGlobal defineLocalMenu:lmi forVC:self];

    // Add a close button to the view
    if (self.hasCloseButton == YES && closeButton == nil) {
        GCCloseButton *b = [GCCloseButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        [b addTarget:self action:@selector(closePage:) forControlEvents:UIControlEventTouchDown];
        closeButton = b;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                                [self.tableView reloadData];
                                                [self viewWillTransitionToSize];
                                            }
                                 completion:nil
     ];
}

- (void)viewWillTransitionToSize
{
    if (infoView != nil)
        [infoView viewWillTransitionToSize];
    // Dummy for this class
}

- (void)willClosePage
{
    // Nothing for now.
}

- (void)closePage:(UIButton *)b
{
    [self willClosePage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadDataMainQueue
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

#pragma -- UITableView related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    NSAssert(FALSE, @"This method should not have been called");
    return 0;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(FALSE, @"This method should not have been called");
    return 0;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(FALSE, @"This method should not have been called");
    return [[UITableViewCell alloc] init];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    verticalContentOffset = scrollView.contentOffset.y;

    if (closeButton != nil) {
        CGRect frame = closeButton.frame;
        frame.origin.y = scrollView.contentOffset.y;
        closeButton.frame = frame;

        [self.view bringSubviewToFront:closeButton];
    }

    if (infoView != nil) {
        CGRect frame = infoView.frame;
        CGRect bounds = self.view.superview.frame;

        frame.origin.y = scrollView.contentOffset.y + bounds.size.height - frame.size.height;
        infoView.frame = frame;

        [self.view bringSubviewToFront:infoView];
    }
}

#pragma -- Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    [MyTools messageBox:self header:@"You selected..." text:[NSString stringWithFormat:@"number %@", @(index + 1)]];
}

@end
