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

@interface GCTableViewController ()

@property (nonatomic, retain) GCCloseButton *closeButton;
@property (nonatomic        ) NSInteger verticalContentOffset;

@end

@implementation GCTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    self.lmi = nil;
    self.numberOfItemsInRow = 3;

    self.closeButton = nil;
    self.hasCloseButton = NO;

    return self;
}

- (void)changeTheme
{
    self.tableView.backgroundColor = currentStyleTheme.viewControllerBackgroundColor;

    [themeManager changeThemeStyleArray:[self.tableView visibleCells]];
    for (UIView *v in [self.tableView subviews]) {
        if ([v isKindOfClass:[UITableViewHeaderFooterView class]] == YES) {
            UITableViewHeaderFooterView *tvhfv = (UITableViewHeaderFooterView *)v;
            tvhfv.textLabel.backgroundColor = currentStyleTheme.labelTextColor;
            tvhfv.textLabel.textColor = currentStyleTheme.viewControllerBackgroundColor;
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
    self.infoView = [[InfoViewer alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.infoView];
}

- (void)hideInfoView
{
    NSAssert1(self.infoView != nil, @"makeInfoView2 not called for %@", [self class]);
    [self.infoView hide];
}

- (void)showInfoView
{
    NSAssert1(self.infoView != nil, @"makeInfoView not called for %@", [self class]);
    [self.infoView show];
}

- (void)buttonMenuLocal:(id)sender
{
    [menuGlobal.menuLocal show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.hasCloseButton == YES)
        [self.view bringSubviewToFront:self.closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@/viewWillAppear: %0.0f px", [self class], self.view.frame.size.height);

    [super viewWillAppear:animated];

    [menuGlobal defineLocalMenu:self.lmi forVC:self];

    // Add a close button to the view
    if (self.hasCloseButton == YES && self.closeButton == nil) {
        GCCloseButton *b = [GCCloseButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        [b addTarget:self action:@selector(closePage:) forControlEvents:UIControlEventTouchDown];
        self.closeButton = b;
    }
    [self.infoView show];
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
//    [self.infoView2 viewWillTransitionToSize];
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
    MAINQUEUE(
        [self.tableView reloadData];
    )
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(20, 0, 320, 20);
    myLabel.font = [UIFont boldSystemFontOfSize:configManager.fontNormalTextSize];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    [myLabel sizeToFit];

    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    headerView.backgroundColor = currentStyleTheme.tableHeaderBackground;
    [headerView sizeToFit];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *s = [self tableView:tableView titleForHeaderInSection:section];
    if (IS_EMPTY(s) == YES)
        return 0;
    return configManager.fontNormalTextSize - currentStyleTheme.GCLabelNormalSizeFont.descender;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.verticalContentOffset = scrollView.contentOffset.y;

    if (self.closeButton != nil) {
        CGRect frame = self.closeButton.frame;
        frame.origin.y = scrollView.contentOffset.y;
        self.closeButton.frame = frame;

        [self.view bringSubviewToFront:self.closeButton];
    }

    [self.infoView adjustScroll:self.verticalContentOffset];
}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    header.contentView.backgroundColor = currentTheme.tableHeaderBackground;
//    header.textLabel.textColor = currentTheme.tableHeaderTextColor;
//    header.textLabel.backgroundColor = currentTheme.tableHeaderBackground;
//}

#pragma -- Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Not localized as it will only happen in development conditions
    [MyTools messageBox:self header:@"You selected..." text:[NSString stringWithFormat:@"number %@", @(index + 1)]];
}

@end
