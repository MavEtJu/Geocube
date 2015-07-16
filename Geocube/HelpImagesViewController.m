//
//  HelpImagesViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 16/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL @"HelpImagesCells"

@implementation HelpImagesViewController

- (id)init
{
    self = [super init];
    menuItems = nil;
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshImages];
    [self.tableView reloadData];
}

- (void)refreshImages
{
    imgs = [[NSMutableArray alloc] initWithCapacity:20];
    names = [[NSMutableArray alloc] initWithCapacity:20];
    numbers = [[NSMutableArray alloc] initWithCapacity:20];
    UIImage *img;
    NSString *name;

    for (NSInteger i = 0; i < ImageLibraryImagesMax ;i++) {
        if ((img = [imageLibrary get:i]) == nil)
            continue;
        [numbers addObject:[NSNumber numberWithInteger:i]];
        [imgs addObject:img];
        if ((name = [imageLibrary getName:i]) == nil)
            continue;
        [names addObject:name];
    }
    imgCount = [imgs count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 11;
    if (section == 1)
        return imgCount;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"getRating:";
    if (section == 1)
        return @"get:";
    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    if (indexPath.section == 0) {
        cell.imageView.image = [imageLibrary getRating:indexPath.row / 2.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld (%0.1f)", indexPath.row, indexPath.row / 2.0];
        cell.detailTextLabel.text = nil;

        return cell;
    }

    if (indexPath.section == 1) {
        cell.imageView.image = [imgs objectAtIndex:indexPath.row];
        cell.textLabel.text = [names objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[numbers objectAtIndex:indexPath.row] stringValue];
    
        return cell;
    }
    return nil;
}

@end
