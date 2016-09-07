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

@interface FilesViewController ()
{
    NSMutableArray *filesNames;
    NSMutableArray *filesSizes;
    NSMutableArray *filesDates;
    NSInteger filesCount;
    NSArray *fileImports;
}

@end

#define THISCELL @"FilesViewControllerCell"

@implementation FilesViewController

enum {
    menuICloud,
    menuRefresh,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];
    [self refreshFileData];

    // Make sure we get told when a new file is here
    IOSFTM.delegate = self;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuICloud label:@"iCloud"];
    [lmi addItem:menuRefresh label:@"Refresh"];
}

- (void)refreshFileData
{
    // Count files in FilesDir

    NSArray *files = [fm contentsOfDirectoryAtPath:[MyTools FilesDir] error:nil];
    filesNames = [NSMutableArray arrayWithCapacity:20];
    filesDates = [NSMutableArray arrayWithCapacity:20];
    filesSizes = [NSMutableArray arrayWithCapacity:20];

    [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
        NSDictionary *a = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file] error:nil];
        if ([[a objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            return;
        [filesNames addObject:file];
        NSNumber *s = [a objectForKey:NSFileSize];
        [filesSizes addObject:s];
        NSDate *d = [a objectForKey:NSFileModificationDate];
        [filesDates addObject:d];
    }];

    fileImports = [dbFileImport dbAll];
    filesCount = [filesNames count];

    [self refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)refreshFilelist
{
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
        NSString *fn = [filesNames objectAtIndex:indexPath.row];
        [self fileDelete:fn];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fn = [filesNames objectAtIndex:indexPath.row];

    UIAlertController *view= [UIAlertController
                              alertControllerWithTitle:fn
                              message:@"Choose you action"
                              preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [self fileDelete:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *import = nil;
    if ([[fn pathExtension] isEqualToString:@"gpx"] == YES ||
        [[fn pathExtension] isEqualToString:@"zip"] == YES ||
        [[fn pathExtension] isEqualToString:@"geocube"] == YES) {
        import = [UIAlertAction
                  actionWithTitle:@"Import"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action) {
                      [self fileImport:indexPath.row view:[aTableView cellForRowAtIndexPath:indexPath]];
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }
    UIAlertAction *restore = nil;
    if ([[fn pathExtension] isEqualToString:@"sqlite"] == YES) {
        restore = [UIAlertAction
                   actionWithTitle:@"Restore"
                   style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {
                       [self fileRestore:indexPath.row view:[aTableView cellForRowAtIndexPath:indexPath]];
                       [view dismissViewControllerAnimated:YES completion:nil];
                   }];
    }
    UIAlertAction *unzip = nil;
    if ([[fn pathExtension] isEqualToString:@"zip"] == YES) {
        unzip = [UIAlertAction
                 actionWithTitle:@"Unzip"
                 style:UIAlertActionStyleDefault
                 handler:^(UIAlertAction * action) {
                     [self fileUnzip:fn];
                     [view dismissViewControllerAnimated:YES completion:nil];
                 }];
    }
    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:@"Rename"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [self fileRename:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *uploadAirdrop = [UIAlertAction
                                    actionWithTitle:@"Upload with Airdrop"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self uploadAirdrop:fn];
                                        [view dismissViewControllerAnimated:YES completion:nil];
                                    }];
    UIAlertAction *uploadICloud = [UIAlertAction
                                   actionWithTitle:@"Upload to iCloud"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self uploadICloud:fn];
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
    if (restore != nil)
        [view addAction:restore];
    if (import != nil)
        [view addAction:import];
    if (unzip != nil)
        [view addAction:unzip];
    [view addAction:rename];
    [view addAction:uploadAirdrop];
    [view addAction:uploadICloud];
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)uploadAirdrop:(NSString *)filename
{
    [IOSFTM uploadAirdrop:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] vc:self];
}

- (void)uploadICloud:(NSString *)filename
{
    [IOSFTM uploadICloud:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] vc:self];
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

- (void)fileRestore:(NSInteger)row view:(UITableViewCell *)tablecell
{
    // If the suffix is .sqlite, restore it as the database
    NSString *fn = [filesNames objectAtIndex:row];
    if ([[fn pathExtension] isEqualToString:@"sqlite"] == YES) {
        if ([db restoreFromCopy:fn] == NO)
            [MyTools messageBox:self header:@"Restore failed" text:@"Unable to restore to the database."];
        else
            [MyTools messageBox:self header:@"Restore successful" text:@"Please quit Geocube and restart it."];
        return;
    }
}

- (void)fileImport:(NSInteger)row view:(UITableViewCell *)tablecell
{
    // If the suffix is .geocube, import it as a Geocube datafile
    NSString *fn = [filesNames objectAtIndex:row];
    if ([[fn pathExtension] isEqualToString:@"geocube"] == YES) {
        NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], fn]];
        if ([ImportGeocube parse:data] == NO) {
            [MyTools messageBox:self header:@"Import failed" text:[NSString stringWithFormat:@"There was a problem importing the file %@.", fn]];
        } else {
            [MyTools messageBox:self header:@"Import successful" text:@"The import was successful."];
        };
        return;
    }

    // Pre-requisites
    __block BOOL groupsOkay = NO;
    __block BOOL accountsOkay = NO;

    [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == 0)
            return;
        groupsOkay = YES;
        *stop = YES;
    }];
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.accountname == nil)
            return;
        accountsOkay = YES;
        *stop = YES;
    }];

    if (groupsOkay == NO) {
        [MyTools messageBox:self header:@"Prerequisite failed" text:@"Make sure there are user groups defined. Go to Groups -> User Groups and add a group."];
        return;
    }
    if (accountsOkay == NO) {
        [MyTools messageBox:self header:@"Prerequisite failed" text:@"Make sure that you have at least have defined one user account. Go to Settings -> Accounts and define an username."];
        return;
    }

    // Show all user groups.
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
        initialSelection:myConfig.lastImportGroup
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
        if (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES)
            return;
        [accountNames addObject:a.site];
        [accounts addObject:a];
    }];

    [ActionSheetStringPicker
        showPickerWithTitle:@"Select the source"
        rows:accountNames
        initialSelection:myConfig.lastImportSource
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [myConfig lastImportSourceUpdate:selectedIndex];
            __block NSString *filename = [filesNames objectAtIndex:row];
            __block NSNumber *filesize = [filesSizes objectAtIndex:row];
            GCStringFilename *sfn = [[GCStringFilename alloc] initWithString:filename];

            [downloadsImportsViewController showImportManager];
            [downloadsImportsViewController resetImports];

            [importManager addToQueue:sfn group:group account:[accounts objectAtIndex:selectedIndex] options:RUN_OPTION_NONE];

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

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuICloud:
            [IOSFTM downloadICloud:self];
            return;
        case menuRefresh:
            [self refreshFileData];
            [self.tableView reloadData];
            return;
    }
    [super performLocalMenuAction:index];
}

@end
