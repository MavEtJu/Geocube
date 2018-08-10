/*
 * Copyright (c) 2011-2012 Matthijs Hollemans
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ThemesLibrary/ThemeManager.h"
#import "ManagersLibrary/ConfigManager.h"

static const NSInteger TagOffset = 1000;

@interface MHTabBarController ()

@property (nonatomic, retain) UIView *tabButtonsContainerView;
@property (nonatomic, retain) UIView *contentContainerView;
@property (nonatomic, retain) UIImageView *indicatorImageView;

@property (nonatomic, retain) UIButton *localMenuButton;
@property (nonatomic, retain) UIButton *globalMenuButton;

@end

@implementation MHTabBarController

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	CGRect rect = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.tabBarHeight);
	self.tabButtonsContainerView = [[UIView alloc] initWithFrame:rect];
	self.tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tabButtonsContainerView.backgroundColor = currentStyleTheme.tabBarBackgroundColor;
//    tabButtonsContainerView.backgroundColor = [UIColor redColor];
	[self.view addSubview:self.tabButtonsContainerView];

	rect.origin.y = self.tabBarHeight;
	rect.size.height = self.view.bounds.size.height - self.tabBarHeight;
	self.contentContainerView = [[UIView alloc] initWithFrame:rect];
	self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentContainerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.contentContainerView];

	self.indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MHTabBarIndicator"]];
	[self.view addSubview:self.indicatorImageView];

    _buttonsEnabled = YES;
	[self reloadTabButtons];

    [self addMenus];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
    self.tabButtonsContainerView.frame = CGRectMake(self.tabButtonsContainerView.frame.origin.x, self.tabButtonsContainerView.frame.origin.y, self.tabButtonsContainerView.frame.size.width, [self tabBarHeight]);
    self.tabButtonsContainerView.frame = CGRectMake(0, 0, self.tabButtonsContainerView.frame.size.width, [self tabBarHeight]);
    self.contentContainerView.frame = CGRectMake(0, self.tabButtonsContainerView.frame.size.height, self.contentContainerView.frame.size.width, self.view.frame.size.height - self.tabButtonsContainerView.frame.size.height);

    CGSize size = self.view.frame.size;
    UIImage *imgMenu = currentStyleTheme.menuLocalIcon;
    self.localMenuButton.frame = CGRectMake(size.width - 2 - imgMenu.size.width, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);
    imgMenu = currentStyleTheme.menuGlobalIcon;
    self.globalMenuButton.frame = CGRectMake(1, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);

	[self layoutTabButtons];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];

	if ([self isViewLoaded] && self.view.window == nil)
	{
		self.view = nil;
		self.tabButtonsContainerView = nil;
		self.contentContainerView = nil;
		self.indicatorImageView = nil;
	}
}

- (void)reloadTabButtons
{
	[self removeTabButtons];
	[self addTabButtons];

	// Force redraw of the previously active tab.
	NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

- (void)addTabButtons
{
	NSUInteger index = 0;
	for (UIViewController *viewController in self.viewControllers)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = TagOffset + index;
		button.titleLabel.font = [UIFont systemFontOfSize:14];
		button.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [button setBackgroundColor:currentStyleTheme.tabBarBackgroundColor];
        [button setTitleColor:currentStyleTheme.tabBarForegroundColor forState:UIControlStateNormal];

		UIOffset offset = viewController.tabBarItem.titlePositionAdjustment;
		button.titleEdgeInsets = UIEdgeInsetsMake(offset.vertical + 20, offset.horizontal, 0.0f, 0.0f);
		button.imageEdgeInsets = viewController.tabBarItem.imageInsets;
		[button setTitle:viewController.tabBarItem.title forState:UIControlStateNormal];
		[button setImage:viewController.tabBarItem.image forState:UIControlStateNormal];

		[button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];

		[self deselectTabButton:button];
		[self.tabButtonsContainerView addSubview:button];

		++index;
	}
}

- (void)removeTabButtons
{
	while ([self.tabButtonsContainerView.subviews count] > 0)
	{
		[[self.tabButtonsContainerView.subviews lastObject] removeFromSuperview];
	}
}

- (void)enableTabButtons:(BOOL)YESNO
{
    [self.tabButtonsContainerView.subviews enumerateObjectsUsingBlock:^(UIButton *tabbutton, NSUInteger idx, BOOL * _Nonnull stop) {
        tabbutton.enabled = YESNO;
    }];
}

+ (void)enableMenus:(BOOL)YESNO controllerFrom:(UIViewController *)vc
{
    MHTabBarController *tbc = (MHTabBarController *)vc.parentViewController.parentViewController;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        tbc.buttonsEnabled = YESNO;
    }];
}

- (void)layoutTabButtons
{
	NSUInteger index = 0;
	NSUInteger count = [self.viewControllers count];
    BOOL portrait = (self.view.bounds.size.width < self.view.bounds.size.height);

    CGRect rect = CGRectMake(self.globalMenuButton.frame.size.width, 0.0f, floorf((self.view.bounds.size.width - 2 * self.globalMenuButton.frame.size.width) / count), self.tabBarHeight);
//	rect = CGRectMake(0, 0.0f, floorf((self.view.bounds.size.width) / count), self.tabBarHeight);

	self.indicatorImageView.hidden = YES;

	NSArray *buttons = [self.tabButtonsContainerView subviews];
	for (UIButton *button in buttons)
	{
		button.frame = rect;
		rect.origin.x += rect.size.width;

        if (portrait == YES)
    		button.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0.0f, 0.0f);
        else
    		button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0.0f, 0.0f);

		if (index == self.selectedIndex)
		    [self centerIndicatorOnButton:button];

		++index;
	}
}

- (void)centerIndicatorOnButton:(UIButton *)button
{
	CGRect rect = self.indicatorImageView.frame;
	rect.origin.x = button.center.x - floorf(self.indicatorImageView.frame.size.width/2.0f);
	rect.origin.y = self.tabBarHeight - self.indicatorImageView.frame.size.height;
	self.indicatorImageView.frame = rect;
	self.indicatorImageView.hidden = NO;
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
//  XXX see what this does do
//	NSAssert([newViewControllers count] >= 2, @"MHTabBarController requires at least two view controllers");

	UIViewController *oldSelectedViewController = self.selectedViewController;

	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}

	_viewControllers = [newViewControllers copy];

	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if (newIndex != NSNotFound)
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;

	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}

	if ([self isViewLoaded])
		[self reloadTabButtons];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
	[self setSelectedIndex:newSelectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated
{
	// NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");
    if (newSelectedIndex >= [self.viewControllers count])
        newSelectedIndex = 0;

    [configManager currentPageTabUpdate:newSelectedIndex];

	if ([self.delegate respondsToSelector:@selector(mh_tabBarController:shouldSelectViewController:atIndex:)])
	{
		UIViewController *toViewController = (self.viewControllers)[newSelectedIndex];
		if (![self.delegate mh_tabBarController:self shouldSelectViewController:toViewController atIndex:newSelectedIndex])
			return;
	}

	if (![self isViewLoaded])
	{
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex)
	{
		UIViewController *fromViewController;
		UIViewController *toViewController;

		if (_selectedIndex != NSNotFound)
		{
			UIButton *fromButton = (UIButton *)[self.tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
			[self deselectTabButton:fromButton];
			fromViewController = self.selectedViewController;
		}

		NSUInteger oldSelectedIndex = _selectedIndex;
		_selectedIndex = newSelectedIndex;

		UIButton *toButton;
		if (_selectedIndex != NSNotFound)
		{
			toButton = (UIButton *)[self.tabButtonsContainerView viewWithTag:TagOffset + _selectedIndex];
			[self selectTabButton:toButton];
			toViewController = self.selectedViewController;
		}

		if (toViewController == nil)  // don't animate
		{
			[fromViewController.view removeFromSuperview];
		}
		else if (fromViewController == nil)  // don't animate
		{
			toViewController.view.frame = self.contentContainerView.bounds;
			[self.contentContainerView addSubview:toViewController.view];
			[self centerIndicatorOnButton:toButton];

			if ([self.delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)])
				[self.delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
		}
		else if (animated)
		{
			CGRect rect = self.contentContainerView.bounds;
			if (oldSelectedIndex < newSelectedIndex)
				rect.origin.x = rect.size.width;
			else
				rect.origin.x = -rect.size.width;

			toViewController.view.frame = rect;
			self.tabButtonsContainerView.userInteractionEnabled = NO;

			[self transitionFromViewController:fromViewController
				toViewController:toViewController
				duration:0.3f
				options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
				animations:^
				{
					CGRect rect = fromViewController.view.frame;
					if (oldSelectedIndex < newSelectedIndex)
						rect.origin.x = -rect.size.width;
					else
						rect.origin.x = rect.size.width;

					fromViewController.view.frame = rect;
					toViewController.view.frame = self.contentContainerView.bounds;
					[self centerIndicatorOnButton:toButton];
				}
				completion:^(BOOL finished)
				{
					self.tabButtonsContainerView.userInteractionEnabled = YES;

					if ([self.delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)])
						[self.delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
				}];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];

			toViewController.view.frame = self.contentContainerView.bounds;
			[self.contentContainerView addSubview:toViewController.view];
			[self centerIndicatorOnButton:toButton];

			if ([self.delegate respondsToSelector:@selector(mh_tabBarController:didSelectViewController:atIndex:)])
				[self.delegate mh_tabBarController:self didSelectViewController:toViewController atIndex:newSelectedIndex];
		}
	}
}

- (UIViewController *)selectedViewController
{
	if (self.selectedIndex != NSNotFound)
		return (self.viewControllers)[self.selectedIndex];
	else
		return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController
{
	[self setSelectedViewController:newSelectedViewController animated:NO];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated
{
	NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
	if (index != NSNotFound)
		[self setSelectedIndex:index animated:animated];
}

- (void)tabButtonPressed:(UIButton *)sender
{
    if (_buttonsEnabled == YES)
        [self setSelectedIndex:sender.tag - TagOffset animated:YES];
}

#pragma mark - Change these methods to customize the look of the buttons

- (void)selectTabButton:(UIButton *)button
{
    //
}

- (void)deselectTabButton:(UIButton *)button
{
    //
}

- (CGFloat)tabBarHeight
{
    // landscape
    if (self.view.bounds.size.width > self.view.bounds.size.height)
        return currentStyleTheme.tabBarHeightLandscape;
    // portrait
    return currentStyleTheme.tabBarHeightPortrait;
}

// ---------------- Added ----

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    // The compass in the navigate tab might have to stay in portrait.
    if (self.selectedIndex == VC_NAVIGATE_COMPASS &&
        self == [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE] &&
        configManager.compassAlwaysInPortraitMode == YES)
        return UIInterfaceOrientationMaskPortrait;
    return configManager.orientationsAllowed;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [menuGlobal hideAll];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [_AppDelegate resizeControllers:size coordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     UIImage *imgMenu = currentStyleTheme.menuLocalIcon;
                                     self.localMenuButton.frame = CGRectMake(size.width - 2 - imgMenu.size.width, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);
                                     imgMenu = currentStyleTheme.menuGlobalIcon;
                                     self.globalMenuButton.frame = CGRectMake(1, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);
                                 }
                                 completion:nil
     ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect bounds = self.view.bounds;
    UIButton *b = self.localMenuButton;
    UIImage *imgMenu = currentStyleTheme.menuLocalIcon;
    b.frame = CGRectMake(bounds.size.width - 2 - imgMenu.size.width, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);

    // https://github.com/MavEtJu/Geocube/pull/1
    // XXX menuGlobal.menuLocalButton can get out of sync with localMenuButton.
    // XXX I'm not sure why you even have multiple local menu buttons, but
    // XXX you need to ensure that menuGlobal.menuLocalButton is set to the
    // XXX appropriate one!
    if (self.localMenuButton != menuGlobal.menuLocalButton) {
        NSLog(@"Warning! menuGlobal doesn't have the same local menu button!");
        menuGlobal.menuLocalButton = self.localMenuButton;
    }
    if (self.globalMenuButton != menuGlobal.menuGlobalButton) {
        NSLog(@"XXX menuGlobal doesn't have the same global menu button");
        menuGlobal.menuGlobalButton = self.globalMenuButton;
    }
}

- (void)resizeController:(CGSize)size coordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
}

- (void)addMenus
{
    /***** Global Menu ****/
    UIImage *imgMenu = currentStyleTheme.menuGlobalIcon;
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(2, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);
    [b setImage:imgMenu forState:UIControlStateNormal];
    [self.view addSubview:b];

    [b addTarget:menuGlobal action:@selector(buttonMenuGlobal:) forControlEvents:UIControlEventTouchDown];
    self.globalMenuButton = b;
    menuGlobal.menuGlobalButton = b;
    /***** Global Menu ****/

    /***** Local Menu ****/
    imgMenu = currentStyleTheme.menuLocalIcon;
    b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(self.view.bounds.size.width - 2 - imgMenu.size.width, self.tabBarHeight - imgMenu.size.height - 2, imgMenu.size.width, imgMenu.size.height);
    [b setImage:imgMenu forState:UIControlStateNormal];

    [self.view addSubview:b];
    [b addTarget:menuGlobal action:@selector(buttonMenuLocal:) forControlEvents:UIControlEventTouchDown];
    self.localMenuButton = b;
    menuGlobal.menuLocalButton = b;
    /***** Global Menu ****/
}

- (void)changeThemeStyle
{
	NSArray *buttons = [self.tabButtonsContainerView subviews];
    for (UIButton *button in buttons) {
        [button setBackgroundColor:currentStyleTheme.tabBarBackgroundColor];
        [button setTitleColor:currentStyleTheme.tabBarForegroundColor forState:UIControlStateNormal];
    }
    self.tabButtonsContainerView.backgroundColor = currentStyleTheme.tabBarBackgroundColor;
    self.globalMenuButton.imageView.image = currentStyleTheme.menuGlobalIcon;
    self.localMenuButton.imageView.image = currentStyleTheme.menuLocalIcon;
}

@end
