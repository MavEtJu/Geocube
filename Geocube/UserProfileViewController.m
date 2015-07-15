//
//  UserProfileViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 2/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

- (id)init
{
    self = [super init];

    menuItems = [NSArray arrayWithObjects:@"XNothing", nil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 100, 40)];
    [label setText:@"Label created in ScrollerController.loadView"];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
