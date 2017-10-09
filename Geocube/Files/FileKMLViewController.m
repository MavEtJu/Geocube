/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

#import "FileKMLViewController.h"

#import "ManagersLibrary/LocalizationManager.h"
#import "ManagersLibrary/WaypointManager.h"

@interface FileKMLViewController ()
{
    NSMutableArray<NSString *> *filesNames;
    NSMutableArray<NSNumber *> *filesSizes;
    NSMutableArray<NSDate *> *filesDates;
}

@end

@implementation FileKMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILESTABLEVIEWCELL];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self refreshFileData];

    lmi = nil;
}

- (void)refreshFileData
{
    // Count files in KLMDir

    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:[MyTools KMLDir] error:nil];
    filesNames = [NSMutableArray arrayWithCapacity:20];
    filesDates = [NSMutableArray arrayWithCapacity:20];
    filesSizes = [NSMutableArray arrayWithCapacity:20];

    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *a = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], file] error:nil];
        if ([[a objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            return;
        [filesNames addObject:file];
        NSNumber *s = [a objectForKey:NSFileSize];
        [filesSizes addObject:s];
        NSDate *d = [a objectForKey:NSFileModificationDate];
        [filesDates addObject:d];
    }];

    [self refreshControl];
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

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [filesNames count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_FILESTABLEVIEWCELL forIndexPath:indexPath];

    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    NSString *fn = [filesNames objectAtIndex:indexPath.row];

    cell.labelFilename.text = fn;
    cell.labelSize.text = [NSString stringWithFormat:@"%@: %@", _(@"filesviewcontroller-File size"), [MyTools niceFileSize:[[filesSizes objectAtIndex:indexPath.row] integerValue]]];
    cell.labelDateTime.text = [NSString stringWithFormat:@"%@: %@.", _(@"filesviewcontroller-File age"), [MyTools niceTimeDifference:[[filesDates objectAtIndex:indexPath.row] timeIntervalSince1970]]];

    dbKMLFile *kml = [dbKMLFile dbGetByFilename:fn];
    if (kml.enabled == NO)
        cell.labelLastImport.text = _(@"filekmlviewcontroller-Not shown");
    else
        cell.labelLastImport.text = _(@"filekmlviewcontroller-Shown on map");
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
        NSString *fn = [filesNames objectAtIndex:indexPath.row];
        [self fileDelete:fn];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fn = [filesNames objectAtIndex:indexPath.row];

    dbKMLFile *kml = [dbKMLFile dbGetByFilename:fn];
    kml.enabled = !kml.enabled;
    [kml dbUpdate];
    [waypointManager refreshKMLs];

    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)fileDelete:(NSString *)filename
{
    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], filename];
    NSLog(@"Removing file '%@'", fullname);
    [fileManager removeItemAtPath:fullname error:nil];

    dbKMLFile *kml = [dbKMLFile dbGetByFilename:filename];
    [kml dbDelete];
    [waypointManager refreshKMLs];

    [self refreshFileData];
    [self.tableView reloadData];
}

@end
