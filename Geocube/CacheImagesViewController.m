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

@implementation CacheImagesViewController

@synthesize overlayView;

#define THISCELL @"CacheImagesViewController"

- (id)init:(dbWaypoint *)wp
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"Import photo"]];
    hasCloseButton = YES;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];

    waypoint = wp;
    userImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_USER];
    cacheImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_CACHE];
    logImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_LOG];

    currentIndexPath = [[NSIndexPath alloc] init];

    return self;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [userImages count];
        case 1: return [cacheImages count];
        case 2: return [logImages count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"User Images";
        case 1: return @"Waypoint Images";
        case 2: return @"Log Images";
    }
    return @"Images???";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == 0)
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section != 0)
            return;
        dbImage *img = [userImages objectAtIndex:indexPath.row];

        [img dbUnlinkFromWaypoint:waypoint._id];

        userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGETYPE_USER];
        [self.tableView reloadData];
    }
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbImage *img;
    switch (indexPath.section) {
        case 0: img = [userImages objectAtIndex:indexPath.row]; break;
        case 1: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case 2: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return nil;

    cell.textLabel.text = img.name;
    cell.userInteractionEnabled = YES;
    cell.imageView.image = [img imageGet];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbImage *img = nil;

    currentIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
    switch (indexPath.section) {
        case 0: img = [userImages objectAtIndex:indexPath.row]; break;
        case 1: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case 2: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return;

    CacheImageViewController *newController = [[CacheImageViewController alloc] init:img];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    newController.delegate = self;
    return;
}

- (dbImage *)swipeToRight
{
    NSLog(@"SwipeToRight");
    if (currentIndexPath.row != 0) {
        dbImage *img = nil;
        currentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.row - 1 inSection:currentIndexPath.section];
        switch (currentIndexPath.section) {
            case 0: img = [userImages objectAtIndex:currentIndexPath.row]; break;
            case 1: img = [cacheImages objectAtIndex:currentIndexPath.row]; break;
            case 2: img = [logImages objectAtIndex:currentIndexPath.row]; break;
        }
        return img;
    }
    return nil;
}

- (dbImage *)swipeToLeft
{
    NSLog(@"SwipeToLeft");
    NSInteger max = 0;
    switch (currentIndexPath.section) {
        case 0: max = [userImages count]; break;
        case 1: max = [cacheImages count]; break;
        case 2: max = [logImages count]; break;
    }

    if (currentIndexPath.row != max - 1) {
        dbImage *img = nil;
        currentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.row + 1 inSection:currentIndexPath.section];
        switch (currentIndexPath.section) {
            case 0: img = [userImages objectAtIndex:currentIndexPath.row]; break;
            case 1: img = [cacheImages objectAtIndex:currentIndexPath.row]; break;
            case 2: img = [logImages objectAtIndex:currentIndexPath.row]; break;
        }
        return img;
    }
    return nil;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Import a photo
    if (index == 0) {
        [self importPhoto];
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)importPhoto
{
 //   UIImagePickerController *imgpicker = [UIImagePickerController pic];
}

#pragma mark - Camera import related functions


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    /*
    if (self.imageView.isAnimating)
    {
        [self.imageView stopAnimating];
    }

    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
     */

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;

    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSURL *imgURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *imgtag = imgURL.absoluteString;

    dbImage *img = [dbImage dbGetByURL:imgtag];
    NSString *datafile = [dbImage createDataFilename:imgtag];
    if (img == nil) {
        img = [[dbImage alloc] init:imgtag name:[dbImage filename:imgtag] datafile:datafile];
        [dbImage dbCreate:img];
    } else {
        //NSLog(@"%@/parse: Image already seen", [self class]);
    }

    if ([img dbLinkedtoWaypoint:waypoint._id] == NO)
        [img dbLinkToWaypoint:waypoint._id type:IMAGETYPE_USER];

    [UIImageJPEGRepresentation(image, 1.0) writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], datafile] atomically:NO];

    userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGETYPE_USER];
    [self.tableView reloadData];

    [self finishAndUpdate];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
