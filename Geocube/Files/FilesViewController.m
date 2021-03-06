/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSMutableArray<NSDictionary *> *fileData;

@end

@implementation FilesViewController

enum {
    menuICloud,
    menuRefresh,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILESTABLEVIEWCELL];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.fileData = [NSMutableArray arrayWithCapacity:20];
    [self refreshFileData];

    // Make sure we get told when a new file is here
    IOSFTM.delegate = self;

    [self makeInfoView];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuICloud label:_(@"filesviewcontroller-iCloud")];
    [self.lmi addItem:menuRefresh label:_(@"filesviewcontroller-Refresh")];
}

- (void)refreshFileData
{
    // Count files in FilesDir

    [self.fileData removeAllObjects];

    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:[MyTools FilesDir] error:nil];

    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *filedata = [NSMutableDictionary dictionaryWithCapacity:5];
        NSDictionary *a = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file] error:nil];
        if ([[a objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            return;
        [filedata setObject:file forKey:@"name"];
        NSNumber *s = [a objectForKey:NSFileSize];
        [filedata setObject:s forKey:@"size"];
        NSDate *d = [a objectForKey:NSFileModificationDate];
        [filedata setObject:d forKey:@"date"];
        dbFileImport *fi = [dbFileImport dbGetByFilename:file];
        [filedata setObject:(fi != nil ? fi : [NSNull null]) forKey:@"import"];

        [self.fileData addObject:filedata];
    }];

    [self.fileData sortUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *o1 = [obj1 objectForKey:@"name"];
        NSString *o2 = [obj2 objectForKey:@"name"];
        return (NSComparisonResult)[o1 compare:o2 options:NSCaseInsensitiveSearch];
    }];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)viewWillTransitionToSize
{
    [super viewWillTransitionToSize];
    [self.tableView reloadData];
}

// Part of IOSFileTransfersDelegate
- (void)IOSFileTransferRefreshFilelist
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
    return [self.fileData count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_FILESTABLEVIEWCELL forIndexPath:indexPath];

    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    NSDictionary *dict = [self.fileData objectAtIndex:indexPath.row];
    NSString *fn = [dict objectForKey:@"name"];
    NSNumber *fs = [dict objectForKey:@"size"];
    NSDate *date = [dict objectForKey:@"date"];
    dbFileImport *fi = [dict objectForKey:@"import"];

    NSString *imported = @"";
    if ([fi isKindOfClass:[NSNull class]] == NO)
        imported = [NSString stringWithFormat:_(@"filesviewcontroller-Last imported: %@"), [MyTools niceTimeDifference:fi.lastimport]];

    cell.labelFilename.text = fn;
    cell.labelSize.text = [NSString stringWithFormat:_(@"filesviewcontroller-File size: %@"), [MyTools niceFileSize:[fs integerValue]]];
    cell.labelDateTime.text = [NSString stringWithFormat:_(@"filesviewcontroller-File age: %@"), [MyTools niceTimeDifference:[date timeIntervalSince1970]]];
    cell.labelLastImport.text = imported;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self fileDelete:indexPath.row forceReload:NO];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.fileData objectAtIndex:indexPath.row];
    NSString *fn = [dict objectForKey:@"name"];

    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:fn
                               message:_(@"filesviewcontroller-Choose your action")
                               preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:_(@"filesviewcontroller-Delete")
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 [self fileDelete:indexPath.row forceReload:YES];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *kmlmove = nil;
    if ([[fn pathExtension] isEqualToString:@"kml"] == YES) {
        kmlmove = [UIAlertAction
                   actionWithTitle:_(@"filesviewcontroller-Move to KML folder")
                   style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {
                       [self fileKML:fn];
                       [view dismissViewControllerAnimated:YES completion:nil];
                   }];
    }

    UIAlertAction *import = nil;
    if ([[fn pathExtension] isEqualToString:@"gpx"] == YES ||
        [[fn pathExtension] isEqualToString:@"zip"] == YES ||
        [[fn pathExtension] isEqualToString:@"geocube"] == YES) {
        import = [UIAlertAction
                  actionWithTitle:_(@"filesviewcontroller-Import")
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action) {
                      [self fileImport:indexPath.row view:[aTableView cellForRowAtIndexPath:indexPath]];
                      [view dismissViewControllerAnimated:YES completion:nil];
                  }];
    }

    UIAlertAction *restore = nil;
    if ([[fn pathExtension] isEqualToString:@"sqlite"] == YES) {
        restore = [UIAlertAction
                   actionWithTitle:_(@"filesviewcontroller-Restore")
                   style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {
                       [self fileRestore:indexPath.row view:[aTableView cellForRowAtIndexPath:indexPath]];
                       [view dismissViewControllerAnimated:YES completion:nil];
                   }];
    }

    UIAlertAction *unzip = nil;
    if ([[fn pathExtension] isEqualToString:@"zip"] == YES) {
        unzip = [UIAlertAction
                 actionWithTitle:_(@"filesviewcontroller-Unzip")
                 style:UIAlertActionStyleDefault
                 handler:^(UIAlertAction * action) {
                     [self fileUnzip:fn];
                     [view dismissViewControllerAnimated:YES completion:nil];
                 }];
    }

    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:_(@"filesviewcontroller-Rename")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [self fileRename:fn];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *uploadAirdrop = [UIAlertAction
                                    actionWithTitle:_(@"filesviewcontroller-Upload with Airdrop")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self uploadAirdrop:fn];
                                        [view dismissViewControllerAnimated:YES completion:nil];
                                    }];

    UIAlertAction *uploadICloud = [UIAlertAction
                                   actionWithTitle:_(@"filesviewcontroller-Upload to iCloud")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self uploadICloud:fn];
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                   }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
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
    if (kmlmove != nil)
        [view addAction:kmlmove];
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

- (void)fileDelete:(NSInteger)index forceReload:(BOOL)forceReload
{
    NSDictionary *dict = [self.fileData objectAtIndex:index];
    NSString *fn = [dict objectForKey:@"name"];
    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], fn];
    NSLog(@"Removing file '%@'", fullname);
    [fileManager removeItemAtPath:fullname error:nil];

    [self.fileData removeObjectAtIndex:index];
    if (forceReload == YES)
        [self.tableView reloadData];
}

- (void)fileKML:(NSString *)filename
{
    NSString *from = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    NSString *to = [NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], filename];
    [fileManager moveItemAtPath:from toPath:to error:nil];

    dbKMLFile *f = [dbKMLFile dbGetByFilename:filename];
    if (f == nil) {
        f = [[dbKMLFile alloc] init];
        f.filename = filename;
        f.enabled = NO;
        [f dbCreate];
    }

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
    NSDictionary *dict = [self.fileData objectAtIndex:row];
    NSString *fn = [dict objectForKey:@"name"];
    if ([[fn pathExtension] isEqualToString:@"sqlite"] == YES) {
        if ([db restoreFromCopy:fn] == NO)
            [MyTools messageBox:self header:@"Restore failed" text:@"Unable to restore to the database."];
        else
            [MyTools messageBox:self header:@"Restore successful" text:@"Please quit Geocube and restart it."];
        return;
    }
}

- (void)fileImportGeocube:(NSString *)fn
{
    [self showInfoView];
    InfoItem *iii = [self.infoView addImport];
    [iii changeDescription:[NSString stringWithFormat:_(@"filesviewcontroller-Geocube import of %@"), fn]];

    NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], fn]];

    BOOL success = NO;
    BOOL done = NO;
    if (done == NO && [fn isEqualToString:@"mapbox.geocube"] == YES) {
        done = YES;
        success = [ImportGeocube parse:data infoItem:iii filetype:GEOCUBEFILETYPE_MAPBOXKEY];
    }
    if (done == NO && [fn isEqualToString:@"opencage.geocube"] == YES) {
        done = YES;
        success = [ImportGeocube parse:data infoItem:iii filetype:GEOCUBEFILETYPE_OPENCAGEKEY];
    }
    if (done == NO && [fn isEqualToString:@"thunderforest.geocube"] == YES) {
        done = YES;
        success = [ImportGeocube parse:data infoItem:iii filetype:GEOCUBEFILETYPE_THUNDERFORESTKEY];
    }
    if (done == NO && [fn isEqualToString:@"Log Templates and Macros.geocube"] == YES) {
        done = YES;
        success = [ImportGeocube parse:data infoItem:iii filetype:GEOCUBEFILETYPE_LOGMACROS];
    }
    if (done == NO) {
        done = YES;
        success = [ImportGeocube parse:data infoItem:iii];
    }

    if (success == NO) {
        [MyTools messageBox:self header:_(@"filesviewcontroller-Import failed") text:[NSString stringWithFormat:_(@"filesviewcontroller-There was a problem importing the file %@."), fn]];
    } else {
        [MyTools messageBox:self header:_(@"filesviewcontroller-Import successful") text:_(@"filesviewcontroller-The import was successful.")];
    };

    [iii removeFromInfoViewer];
    [self hideInfoView];
}

- (void)fileImport:(NSInteger)row view:(UITableViewCell *)tablecell
{
    // If the suffix is .geocube, import it as a Geocube datafile
    NSDictionary *dict = [self.fileData objectAtIndex:row];
    NSString *fn = [dict objectForKey:@"name"];
    if ([[fn pathExtension] isEqualToString:@"geocube"] == YES) {

        BACKGROUND(fileImportGeocube:, fn);
        return;
    }

    // Pre-requisites
    __block BOOL groupsOkay = NO;
    __block BOOL accountsOkay = NO;

    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull cg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cg.usergroup == 0)
            return;
        groupsOkay = YES;
        *stop = YES;
    }];
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.accountname == nil)
            return;
        accountsOkay = YES;
        *stop = YES;
    }];

    if (groupsOkay == NO) {
        [MyTools messageBox:self header:_(@"filesviewcontroller-Prerequisite failed") text:_(@"filesviewcontroller-Make sure there are user groups defined. Go to Groups -> User Groups and add a group.")];
        return;
    }
    if (accountsOkay == NO) {
        [MyTools messageBox:self header:_(@"filesviewcontroller-Prerequisite failed") text:_(@"filesviewcontroller-Make sure that you at least have defined one user account. Go to Settings -> Accounts and define an username.")];
        return;
    }

    // Show all user groups.
    NSMutableArray<dbGroup *> *groups = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray<NSString *> *groupNames = [NSMutableArray arrayWithCapacity:10];
    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull cg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cg.usergroup == 0)
            return;
        [groupNames addObject:cg.name];
        [groups addObject:cg];
    }];

    [ActionSheetStringPicker
        showPickerWithTitle:_(@"filesviewcontroller-Select a group")
        rows:groupNames
        initialSelection:configManager.lastImportGroup
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [configManager lastImportGroupUpdate:selectedIndex];
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
    NSMutableArray<dbAccount *> *accounts = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray<NSString *> *accountNames = [NSMutableArray arrayWithCapacity:10];
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (IS_EMPTY(a.accountname.name) == YES)
            return;
        [accountNames addObject:a.site];
        [accounts addObject:a];
    }];

    NSDictionary *dict = [self.fileData objectAtIndex:row];

    [ActionSheetStringPicker
        showPickerWithTitle:_(@"filesviewcontroller-Select the source")
        rows:accountNames
        initialSelection:configManager.lastImportSource
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [configManager lastImportSourceUpdate:selectedIndex];
            NSString *filename = [dict objectForKey:@"name"];
            NSNumber *filesize = [dict objectForKey:@"size"];
            GCStringFilename *sfn = [[GCStringFilename alloc] initWithString:filename];

//            [downloadsImportsViewController showImportManager];
//            [downloadsImportsViewController resetImports];

            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
            [dict setObject:sfn forKey:@"sfn"];
            [dict setObject:filename forKey:@"filename"];
            [dict setObject:group forKey:@"group"];
            [dict setObject:[accounts objectAtIndex:selectedIndex] forKey:@"account"];
            [dict setObject:[NSNumber numberWithInt:IMPORTOPTION_NONE] forKey:@"options"];

            BACKGROUND(fileImportBG:, dict);

            dbFileImport *fi = [dict objectForKey:@"import"];
            if ([fi isKindOfClass:[NSNull class]] == YES) {
                dbFileImport *fi = [[dbFileImport alloc] init];
                fi.filename = filename;
                fi.filesize = [filesize integerValue];
                fi.lastimport = time(NULL);
                [fi dbCreate];
            } else {
                fi.lastimport = time(NULL);
                [fi dbUpdate];
            }
            [self refreshFileData];
            [self.tableView reloadData];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        }
        origin:tablecell
    ];
}

- (void)fileImportBG:(NSDictionary *)dict
{
    GCStringFilename *sfn = [dict objectForKey:@"sfn"];
    dbAccount *account = [dict objectForKey:@"account"];
    dbGroup *group = [dict objectForKey:@"group"];
    NSInteger options = [[dict objectForKey:@"options"] integerValue];
    NSString *filename = [dict objectForKey:@"filename"];

    [self showInfoView];
    InfoItem *iii = [self.infoView addImport];
    [iii changeDescription:filename];

    [importManager process:sfn group:group account:account options:options infoItem:iii];

    [iii removeFromInfoViewer];
    if ([self.infoView hasItems] == NO) {
        [self hideInfoView];
        [audioManager playSound:PLAYSOUND_IMPORTCOMPLETE];
    }
}

- (void)fileRename:(NSString *)filename
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"filesviewcontroller-Rename file")
                                message:[NSString stringWithFormat:_(@"filesviewcontroller-Rename %@ to"), filename]
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             // Rename the file
                             NSString *fromfullfile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *tofullfile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], tf.text];

                             NSLog(@"Renaming file '%@' to '%@'", fromfullfile, tofullfile);
                             [fileManager moveItemAtPath:fromfullfile toPath:tofullfile error:nil];
                             [self refreshFileData];
                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
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
