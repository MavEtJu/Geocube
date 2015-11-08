/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

#define THISCELL @"FilesViewControllerCell"

@implementation FilesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];
    [self refreshFileData];

    menuItems = [NSMutableArray arrayWithArray:@[@"iCloud", @"Airdrop"]];
}

- (void)refreshFileData
{
    // Count files in FilesDir

    NSArray *files = [fm contentsOfDirectoryAtPath:[MyTools FilesDir] error:nil];
    filesNames = [NSMutableArray arrayWithCapacity:20];
    filesDates = [NSMutableArray arrayWithCapacity:20];
    filesSizes = [NSMutableArray arrayWithCapacity:20];
    filesCount = [files count];

    [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
        NSDictionary *a = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file] error:nil];
        [filesNames addObject:file];
        NSNumber *s = [a objectForKey:NSFileSize];
        [filesSizes addObject:s];
        NSDate *d = [a objectForKey:NSFileModificationDate];
        [filesDates addObject:d];
    }];

    fileImports = [dbFileImport dbAll];

    [self refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    NSString *fn = [filesNames objectAtIndex:indexPath.row];
    NSNumber *fs = [filesSizes objectAtIndex:indexPath.row];

    __block dbFileImport *fi = nil;
    [fileImports enumerateObjectsUsingBlock:^(dbFileImport *_fi, NSUInteger idx, BOOL *stop) {
        if ([_fi.filename isEqualToString:fn] == YES &&
            _fi.filesize == [fs integerValue]) {
            fi = _fi;
            *stop = YES;
        }
    }];

    NSString *imported = @"";
    if (fi != nil)
        imported = [NSString stringWithFormat:@"(Imported %@)", [MyTools niceTimeDifference:fi.lastimport]];

    cell.textLabel.text = fn;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ %@", [MyTools niceFileSize:[[filesSizes objectAtIndex:indexPath.row] integerValue]], [MyTools niceTimeDifference:[[filesDates objectAtIndex:indexPath.row] timeIntervalSince1970]], imported];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSString *fn = [filesNames objectAtIndex:indexPath.row];
        [self fileDelete:fn];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fn = [filesNames objectAtIndex:indexPath.row];

    UIAlertController *view= [UIAlertController
                              alertControllerWithTitle:fn
                              message:@"Select you choice"
                              preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

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
    if ([[fn pathExtension] isEqualToString:@"gpx"] == YES ||
        [[fn pathExtension] isEqualToString:@"zip"] == YES) {
        import = [UIAlertAction
                  actionWithTitle:@"Import"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      //Do some thing here
                      [self fileImport:indexPath.row view:[aTableView cellForRowAtIndexPath:indexPath]];
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }
    UIAlertAction *unzip = nil;
    if ([[fn pathExtension] isEqualToString:@"zip"] == YES) {
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

    // Set close to the text beginning
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    CGRect rectToUse = cell.bounds;
    rectToUse.origin.x = rectToUse.size.width - 200;
    rectToUse.origin.x = 100;
    rectToUse.size.width -= rectToUse.origin.x;
    rectToUse.size.width = 100;

    UIPopoverPresentationController *popPresenter = [view popoverPresentationController];
    popPresenter.sourceView = [aTableView cellForRowAtIndexPath:indexPath];
    popPresenter.sourceRect = rectToUse;

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

- (void)fileImport:(NSInteger)row view:(UITableViewCell *)tablecell
{
    //    UIViewController *newController = [[ImportGPXViewController alloc] init:filename];
    //    newController.edgesForExtendedLayout = UIRectEdgeNone;
    //    newController.title = @"Import";
    //    [self.navigationController pushViewController:newController animated:YES];

    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *groupNames = [NSMutableArray arrayWithCapacity:10];
    [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == 0)
            return;
        [groupNames addObject:cg.name];
        [groups addObject:cg];
    }];

    [ActionSheetStringPicker
        showPickerWithTitle:@"Select a Group"
        rows:groupNames
        initialSelection:[myConfig lastImportGroup]
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [myConfig lastImportGroupUpdate:selectedIndex];
            [self fileImport2:row group:[groups objectAtIndex:selectedIndex] view:tablecell];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        }
        origin:tablecell
    ];
}

- (void)fileImport2:(NSInteger)row group:(dbGroup *)group view:(UITableViewCell *)tablecell
{
    NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *accountNames = [NSMutableArray arrayWithCapacity:10];
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        if (a.accountname == nil || [a.accountname isEqualToString:@""] == YES)
            return;
        [accountNames addObject:a.site];
        [accounts addObject:a];
    }];

    [ActionSheetStringPicker
        showPickerWithTitle:@"Select the source"
        rows:accountNames
        initialSelection:[myConfig lastImportSource]
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [myConfig lastImportSourceUpdate:selectedIndex];
            __block NSString *filename = [filesNames objectAtIndex:row];
            __block NSNumber *filesize = [filesSizes objectAtIndex:row];
            UIViewController *newController = [[ImportGPXViewController alloc] init:filename group:group account:[accounts objectAtIndex:selectedIndex]];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            newController.title = @"Import";
            [self.navigationController pushViewController:newController animated:YES];

            __block dbFileImport *fi = nil;
            [fileImports enumerateObjectsUsingBlock:^(dbFileImport *_fi, NSUInteger idx, BOOL *stop) {
                if ([_fi.filename isEqualToString:filename] == YES &&
                    _fi.filesize == [filesize integerValue]) {
                    fi = _fi;
                    *stop = YES;
                }
            }];
            if (fi == nil) {
                dbFileImport *fi = [[dbFileImport alloc] init];
                fi.filename = filename;
                fi.filesize = [filesize integerValue];
                fi.lastimport = time(NULL);
                [dbFileImport dbCreate:fi];
            } else {
                fi.lastimport = time(NULL);
                [fi dbUpdate];
            }
            [self.tableView reloadData];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        }
        origin:tablecell
    ];

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
                             // Rename the file
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

- (void)showICloud
{
    UIDocumentMenuViewController *importMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];

    importMenu.delegate = self;

    [self.navigationController pushViewController:importMenu animated:YES];
//    [self presentViewController:importMenu animated:YES completion:nil];
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    NSError *error = nil;
    UIAlertController *alert;
    NSURL *destinationName = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@", [MyTools FilesDir], [url lastPathComponent]]];

    /* Remove this file is it already exists. Ignore the error. */
    [fm removeItemAtURL:destinationName error:&error];
    error = nil;

    if ([fm copyItemAtURL:url toURL:destinationName error:&error] == YES) {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Download complete"
                 message:@"You can find the saved file in the Files menu."
                 preferredStyle:UIAlertControllerStyleAlert
                 ];
    } else {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Download failed"
                 message:[NSString stringWithFormat:@"Error message: %@", error]
                 preferredStyle:UIAlertControllerStyleAlert
                 ];
    }

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:nil];

    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)showAirDrop
{
    NSString *text = @"Some text I want to share";
    UIImage *image = [UIImage imageNamed:@"image.png"];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text, image] applicationActivities:nil];
    [activityViewController setCompletionWithItemsHandler:
        ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSLog(@"Foo");
        } ];
    [self.navigationController pushViewController:activityViewController animated:YES];
//    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self showICloud];
            return;
        case 1:
            [self showAirDrop];
            return;
    }
}

@end
