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
#import "database.h"
#import "Geocube.h"
#import "Import_GPX.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"GroupsViewController:viewWillAppear");
    [super viewWillAppear:animated];
    [self refreshFileData];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewController related functions

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

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fn = [files objectAtIndex:indexPath.row];
    
    UIAlertController *view=   [UIAlertController
                                 alertControllerWithTitle:fn
                                 message:@"Select you choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self fileDelete:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *import = nil;
    if ([[fn pathExtension] compare:@"gpx"] == NSOrderedSame) {
        import = [UIAlertAction
                  actionWithTitle:@"Import"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      //Do some thing here
                      [self fileImport:fn];
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }
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
    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:@"Rename"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self fileRename:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    [view addAction:delete];
    if (import != nil)
        [view addAction:import];
    if (unzip != nil)
        [view addAction:unzip];
    [view addAction:rename];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)fileImport:(NSString *)filename
{
    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    Import_GPX *i = [[Import_GPX alloc] init:fullname group:@"Testje"];
    [i parse];
    [db loadWaypointData];
}

- (void)fileRename:(NSString *)filename
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Rename file"
                               message:[NSString stringWithFormat:@"Rename %@ to", filename]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             NSString *fromfullfile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *tofullfile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], tf.text];
                             
                             NSLog(@"Renaming file '%@' to '%@'", fromfullfile, tofullfile);
                             [fm moveItemAtPath:fromfullfile toPath:tofullfile error:nil];
                             [self refreshFileData];
                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = filename;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

@end
