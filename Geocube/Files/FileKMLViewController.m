/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@interface FileKMLViewController ()

@property (nonatomic, retain) NSMutableArray<NSDictionary *> *fileData;

@end

@implementation FileKMLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILESTABLEVIEWCELL];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.fileData = [NSMutableArray arrayWithCapacity:3];
    [self refreshFileData];

    self.lmi = nil;
}

- (void)refreshFileData
{
    // Count files in KMLDir

    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:[MyTools KMLDir] error:nil];

    [self.fileData removeAllObjects];

    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *filedata = [NSMutableDictionary dictionaryWithCapacity:3];
        NSDictionary *a = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], file] error:nil];
        if ([[a objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            return;
        [filedata setObject:file forKey:@"name"];
        NSNumber *s = [a objectForKey:NSFileSize];
        [filedata setObject:s forKey:@"size"];
        NSDate *d = [a objectForKey:NSFileModificationDate];
        [filedata setObject:d forKey:@"date"];

        [self.fileData addObject:filedata];
    }];

    [self.fileData sortUsingComparator:^(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *o1 = [obj1 objectForKey:@"name"];
        NSString *o2 = [obj2 objectForKey:@"name"];
        return (NSComparisonResult)[o1 compare:o2 options:NSCaseInsensitiveSearch];
    }];
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
    return [self.fileData count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_FILESTABLEVIEWCELL forIndexPath:indexPath];

    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    NSDictionary *dict = [self.fileData objectAtIndex:indexPath.row];
    NSString *fn = [dict objectForKey:@"name"];
    NSNumber *size = [dict objectForKey:@"size"];
    NSDate *date = [dict objectForKey:@"date"];

    cell.labelFilename.text = fn;
    cell.labelSize.text = [NSString stringWithFormat:_(@"filesviewcontroller-File size: %@"), [MyTools niceFileSize:[size integerValue]]];
    cell.labelDateTime.text = [NSString stringWithFormat:_(@"filesviewcontroller-File age: %@"), [MyTools niceTimeDifference:[date timeIntervalSince1970]]];

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
        [self fileDelete:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.fileData objectAtIndex:indexPath.row];
    NSString *fn = [dict objectForKey:@"name"];

    dbKMLFile *kml = [dbKMLFile dbGetByFilename:fn];
    if (kml == nil) {
        kml = [[dbKMLFile alloc] init];
        kml.filename = fn;
        kml.enabled = NO;
        [kml dbCreate];
    }
    kml.enabled = !kml.enabled;
    [kml dbUpdate];
    [waypointManager refreshKMLs];

    [self refreshFileData];
    [self.tableView reloadData];
}

- (void)fileDelete:(NSInteger)index
{
    NSDictionary *dict = [self.fileData objectAtIndex:index];
    NSString *fn = [dict objectForKey:@"name"];

    NSString *fullname = [NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], fn];
    NSLog(@"Removing file '%@'", fullname);
    [fileManager removeItemAtPath:fullname error:nil];

    dbKMLFile *kml = [dbKMLFile dbGetByFilename:fn];
    [kml dbDelete];
    [waypointManager refreshKMLs];

    [self.fileData removeObjectAtIndex:index];
//    [self.tableView reloadData];
}

@end
