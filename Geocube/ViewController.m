//
//  ViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "ViewController.h"
#import "Import_GPX.h"
#import "My Tools.h"

@implementation ViewController

- (void)pushed:(UIButton *)aButton
{
    NSLog(@"Pressed");

    NSString *fname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], @"GC - 15670269_ACT-1.zip"];
    Import_GPX *i = [[Import_GPX alloc] init:fname group:@"Last Import"];
    [i parse];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(30, 30, 100, 100)];
    [button setTitle:@"Foo" forState:UIControlStateNormal];
    [button setTitle:@"Bar" forState:UIControlStateHighlighted];
    button.showsTouchWhenHighlighted = YES;
    
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button addTarget:self action:@selector(pushed:) forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
