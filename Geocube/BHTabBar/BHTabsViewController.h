#import <UIKit/UIKit.h>
#import "BHTabView.h"

@class BHTabsViewController;
@class BHTabsFooterView;
@class BHTabStyle;
@class BHTabsView;

@protocol BHTabsViewControllerDelegate <NSObject>
@optional

- (BOOL)shouldMakeTabCurrentAtIndex:(NSUInteger)index
                         controller:(UIViewController *)viewController
                   tabBarController:(BHTabsViewController *)tabBarController;

- (void)didMakeTabCurrentAtIndex:(NSUInteger)index
                      controller:(UIViewController *)viewController
                tabBarController:(BHTabsViewController *)tabBarController;

@end

@interface BHTabsViewController : UIViewController <BHTabViewDelegate> {
  NSArray *viewControllers;
  UIView *contentView;
  BHTabsView *tabsContainerView;
  BHTabsFooterView *footerView;
  BHTabStyle *tabStyle;
  NSUInteger currentTabIndex;
  id <BHTabsViewControllerDelegate> delegate;
}

@property (nonatomic) id <BHTabsViewControllerDelegate> delegate;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, retain) BHTabStyle *style;
@property (nonatomic, retain) NSArray *viewControllers;

- (id)initWithViewControllers:(NSInteger)tabNr
              viewControllers:(NSArray *)viewControllers
                        style:(BHTabStyle *)style;
- (void)makeTabViewCurrent:(NSInteger)idx;

@end
