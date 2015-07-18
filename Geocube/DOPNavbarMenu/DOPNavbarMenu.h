//
//  DOPNavbarMenu.h
//  DOPNavbarMenu
//
//  Created by weizhou on 5/14/15.
//  Copyright (c) 2015 weizhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIView+DOPExtension.h"

@interface UITouchGestureRecognizer : UIGestureRecognizer
@end

@interface DOPNavbarMenuItem : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) BOOL enabled;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon enabled:(BOOL)enabled;
+ (DOPNavbarMenuItem *)ItemWithTitle:(NSString *)title icon:(UIImage *)icon enabled:(BOOL)enabled;

@end

@class DOPNavbarMenu;
@protocol DOPNavbarMenuDelegate <NSObject>

- (void)didShowMenu:(DOPNavbarMenu *)menu;
- (void)didDismissMenu:(DOPNavbarMenu *)menu;
- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index;

@end

//iOS7+
@interface DOPNavbarMenu : UIView

@property (copy, nonatomic, readonly) NSArray *items;
@property (assign, nonatomic, readonly) NSInteger maximumNumberInRow;
@property (assign, nonatomic, getter=isOpen) BOOL open;
@property (weak, nonatomic) id <DOPNavbarMenuDelegate> delegate;
@property (copy, nonatomic) NSString *menuName;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *separatarColor;

- (instancetype)initWithItems:(NSArray *)items
                        width:(CGFloat)width
           maximumNumberInRow:(NSInteger)max;

- (void)showInNavigationController:(UINavigationController *)nvc;
- (void)dismissWithAnimation:(BOOL)animation;

@end
