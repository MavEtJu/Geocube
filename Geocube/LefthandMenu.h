//
//  LefthandMenu.h
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LefthandMenu : UIViewController <UITabBarControllerDelegate>

@property (nonatomic, weak, readonly) UILabel *label;
@property (nonatomic, weak, readonly) UIButton *hide;
@property (nonatomic, weak, readonly) UIButton *show;
@property (nonatomic, weak, readonly) UIButton *removeRightPanel;
@property (nonatomic, weak, readonly) UIButton *addRightPanel;
@property (nonatomic, weak, readonly) UIButton *changeCenterPanel;

@end

