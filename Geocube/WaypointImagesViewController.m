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

@interface WaypointImagesViewController ()
{
    dbWaypoint *waypoint;
    NSArray *userImages;
    NSArray *logImages;
    NSArray *cacheImages;

    NSIndexPath *currentIndexPath;
    WaypointImageViewController *ivc;
    UITableView *parentTable;
}

@end

@implementation WaypointImagesViewController

@synthesize overlayView;

enum {
    SECTION_USER = 0,
    SECTION_WAYPOINT,
    SECTION_LOG,
    SECTION_MAX
};

#define THISCELL @"CacheImagesViewController"

enum {
    menuImportPhoto,
    menuMakePhoto,
    menuDownloadImages,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp table:(UITableView *)table
{
    self = [super init];
    parentTable = table;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuImportPhoto label:@"Import photo"];
    [lmi addItem:menuMakePhoto label:@"Make photo"];
    [lmi addItem:menuDownloadImages label:@"Download photos"];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        [lmi disableItem:menuImportPhoto];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        [lmi disableItem:menuMakePhoto];

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

#pragma mark - Functions for downloading of images

- (void)downloadImage:(dbImage *)img
{
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Downloading image"];
    [imagesDownloadManager addDelegate:self];
    [ImagesDownloadManager addToQueueImmediately:img];
}

- (void)downloadImages
{
    __block NSInteger i = 0;
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Downloading images\nDownloaded 1/1\nPending"];

    [imagesDownloadManager addDelegate:self];
    [userImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL *stop) {
        if ([img imageHasBeenDowloaded] == NO) {
            [ImagesDownloadManager addToQueueImmediately:img];
            i++;
        }
    }];
    [logImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL *stop) {
        if ([img imageHasBeenDowloaded] == NO) {
            [ImagesDownloadManager addToQueueImmediately:img];
            i++;
        }
    }];
    [cacheImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL *stop) {
        if ([img imageHasBeenDowloaded] == NO) {
            [ImagesDownloadManager addToQueueImmediately:img];
            i++;
        }
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Downloading images\nScheduled %ld\n   ", (long)i];
    }];
}

- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];

    if (queuedImages != 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Downloading images\nDownloaded %ld, pending %ld", (long)downloadedImages, (long)queuedImages];
        }];
    }

    if (queuedImages == 0) {
        [imagesDownloadManager removeDelegate:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [DejalBezelActivityView removeViewAnimated:YES];
        }];
    }
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_USER: return [userImages count];
        case SECTION_WAYPOINT: return [cacheImages count];
        case SECTION_LOG: return [logImages count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_USER: return @"User Images";
        case SECTION_WAYPOINT: return @"Waypoint Images";
        case SECTION_LOG: return @"Log Images";
    }
    return @"Images???";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    if (indexPath.section == SECTION_USER)
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section != SECTION_USER)
            return;
        dbImage *img = [userImages objectAtIndex:indexPath.row];

        [img dbUnlinkFromWaypoint:waypoint._id];

        userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGETYPE_USER];
        [self.tableView reloadData];
        [parentTable reloadData];
    }
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbImage *img;
    switch (indexPath.section) {
        case SECTION_USER: img = [userImages objectAtIndex:indexPath.row]; break;
        case SECTION_WAYPOINT: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case SECTION_LOG: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return nil;

    cell.textLabel.text = img.name;
    cell.userInteractionEnabled = YES;

    if ([img imageHasBeenDowloaded] == YES) {
        cell.imageView.image = [img imageGet];
    } else {
        cell.imageView.image = [imageLibrary get:Image_NoImageFile];
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger max = 0;
    dbImage *img = nil;

    currentIndexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];

    switch (currentIndexPath.section) {
        case SECTION_USER: max = [userImages count]; break;
        case SECTION_WAYPOINT: max = [cacheImages count]; break;
        case SECTION_LOG: max = [logImages count]; break;
    }

    switch (indexPath.section) {
        case SECTION_USER: img = [userImages objectAtIndex:indexPath.row]; break;
        case SECTION_WAYPOINT: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case SECTION_LOG: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return;

    ivc = [[WaypointImageViewController alloc] init];
    ivc.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:ivc animated:YES];
    ivc.delegate = self;

    [ivc setImage:img idx:indexPath.row + 1 totalImages:max];
    return;
}

- (void)swipeToRight
{
    NSInteger max = 0;

    switch (currentIndexPath.section) {
        case SECTION_USER: max = [userImages count]; break;
        case SECTION_WAYPOINT: max = [cacheImages count]; break;
        case SECTION_LOG: max = [logImages count]; break;
    }

    if (currentIndexPath.row != 0) {
        dbImage *img = nil;
        currentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.row - 1 inSection:currentIndexPath.section];
        switch (currentIndexPath.section) {
            case SECTION_USER: img = [userImages objectAtIndex:currentIndexPath.row]; break;
            case SECTION_WAYPOINT: img = [cacheImages objectAtIndex:currentIndexPath.row]; break;
            case SECTION_LOG: img = [logImages objectAtIndex:currentIndexPath.row]; break;
        }

        [ivc setImage:img idx:currentIndexPath.row + 1 totalImages:max];
    }
}

- (void)swipeToLeft
{
    NSInteger max = 0;

    switch (currentIndexPath.section) {
        case SECTION_USER: max = [userImages count]; break;
        case SECTION_WAYPOINT: max = [cacheImages count]; break;
        case SECTION_LOG: max = [logImages count]; break;
    }

    if (currentIndexPath.row != max - 1) {
        dbImage *img = nil;
        currentIndexPath = [NSIndexPath indexPathForItem:currentIndexPath.row + 1 inSection:currentIndexPath.section];
        switch (currentIndexPath.section) {
            case SECTION_USER: img = [userImages objectAtIndex:currentIndexPath.row]; break;
            case SECTION_WAYPOINT: img = [cacheImages objectAtIndex:currentIndexPath.row]; break;
            case SECTION_LOG: img = [logImages objectAtIndex:currentIndexPath.row]; break;
        }

        [ivc setImage:img idx:currentIndexPath.row + 1 totalImages:max];
    }
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuImportPhoto:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            return;
        case menuDownloadImages:
            [self downloadImages];
            return;
        case menuMakePhoto:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

#pragma mark - Camera import related functions

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;

    self.imagePickerController = imagePickerController;
    [ALERT_VC_RVC(self) presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    dbImage *img = nil;

    NSURL *imgURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    if (imgURL != nil) {
        // From Library.
        NSString *imgtag = imgURL.absoluteString;
        img = [dbImage dbGetByURL:imgtag];
        NSString *datafile = [dbImage createDataFilename:imgtag];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], datafile] atomically:NO];

        if (img == nil) {
            img = [[dbImage alloc] init:imgtag name:[dbImage filename:imgtag] datafile:datafile];
            [dbImage dbCreate:img];
        } else {
            NSLog(@"%@/parse: Image already seen", [self class]);
        }
    } else {
        // From camera
        NSDictionary *exif = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
        exif = [exif objectForKey:@"{Exif}"];
        NSString *datecreated = [exif objectForKey:@"DateTimeOriginal"];
        NSString *datafile = [dbImage createDataFilename:datecreated];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], datafile] atomically:NO];
        img = [[dbImage alloc] init:datecreated name:[dbImage filename:datecreated] datafile:datafile];
        [dbImage dbCreate:img];
    }

    if ([img dbLinkedtoWaypoint:waypoint._id] == NO)
        [img dbLinkToWaypoint:waypoint._id type:IMAGETYPE_USER];


    userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGETYPE_USER];
    [self.tableView reloadData];
    [parentTable reloadData];

    [self finishAndUpdate];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [parentTable reloadData];
}

@end
