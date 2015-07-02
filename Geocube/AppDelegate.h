//
//  AppDelegate.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASidePanelController;

@interface AppDelegate : UIResponder <UITabBarControllerDelegate> {
    NSMutableArray *tabBars;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JASidePanelController *viewController;
@property (nonatomic, retain) NSMutableArray *tabBars;

- (void)switchController:(NSInteger)idx;


@end

