//
//  FilesViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "FilesViewController.h"
#import "My Tools.h"
#import "SSZipArchive.h"

@implementation FilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    fm = [[NSFileManager alloc] init];
    [self refreshFileData];
    
    menuItems = [NSArray arrayWithObjects:@"XNothing", nil];
}

- (void)refreshFileData
{
    // Count files in FilesDir
    files = [fm contentsOfDirectoryAtPath:[MyTools FilesDir] error:nil];
    filesCount = [files count];
    [self refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return filesCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    NSString *fn = [files objectAtIndex:indexPath.row];
    cell.textLabel.text = fn;
    cell.detailTextLabel.text = @"Detail Label";
    
    return cell;
}

// On selection, update the title and enable find/deselect
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fn = [files objectAtIndex:indexPath.row];
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:fn
                                 message:@"Select you Choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self fileDelete:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction* import = [UIAlertAction
                             actionWithTitle:@"XImport"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction *unzip = nil;
    if ([[fn pathExtension] compare:@"zip"] == NSOrderedSame) {
        unzip = [UIAlertAction
                 actionWithTitle:@"Unzip"
                 style:UIAlertActionStyleDefault
                 handler:^(UIAlertAction * action)
                 {
                     //Do some thing here
                     [self fileUnzip:fn];
                     [view dismissViewControllerAnimated:YES completion:nil];
                 }];
    }
    UIAlertAction* rename = [UIAlertAction
                             actionWithTitle:@"XRename"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self fileRename:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:delete];
    [view addAction:import];
    if (unzip != nil)
        [view addAction:unzip];
    [view addAction:rename];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (void)fileDelete:(NSString *)filename
{
    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    NSLog(@"Removing file '%@'", fullname);
    [fm removeItemAtPath:fullname error:nil];
 
    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)fileUnzip:(NSString *)filename
{
    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    NSLog(@"Decompressing file '%@' to '%@'", fullname, [MyTools FilesDir]);
    [SSZipArchive unzipFileAtPath:fullname toDestination:[MyTools FilesDir]];

    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)fileRename:(NSString *)filename
{
    
}


@end
