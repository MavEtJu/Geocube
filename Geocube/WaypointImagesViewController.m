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

@interface WaypointImagesViewController ()
{
    dbWaypoint *waypoint;
    NSArray *userImages;
    NSArray *logImages;
    NSArray *cacheImages;

    NSIndexPath *currentIndexPath;
    WaypointImageViewController *ivc;
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
    menuDeleteAllPhotos,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuImportPhoto label:@"Import photo"];
    [lmi addItem:menuMakePhoto label:@"Make photo"];
    [lmi addItem:menuDownloadImages label:@"Download photos"];
    [lmi addItem:menuDeleteAllPhotos label:@"Delete all photos"];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        [lmi disableItem:menuImportPhoto];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        [lmi disableItem:menuMakePhoto];

    hasCloseButton = YES;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];

    waypoint = wp;
    userImages = [dbImage dbAllByWaypoint:wp._id type:IMAGECATEGORY_USER];
    cacheImages = [dbImage dbAllByWaypoint:wp._id type:IMAGECATEGORY_CACHE];
    logImages = [dbImage dbAllByWaypoint:wp._id type:IMAGECATEGORY_LOG];

    currentIndexPath = [[NSIndexPath alloc] init];

    [self needsDownloadMenu];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeInfoView];
}

- (void)needsDownloadMenu
{
    __block NSInteger needsDownload = NO;
    __block NSInteger needsDelete = NO;
    [userImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    [cacheImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    [logImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    if (needsDownload == NO)
        [lmi disableItem:menuDownloadImages];
    else
        [lmi enableItem:menuDownloadImages];
    if (needsDelete == NO)
        [lmi disableItem:menuDeleteAllPhotos];
    else
        [lmi enableItem:menuDeleteAllPhotos];
}

#pragma mark - Functions for downloading of images

- (void)downloadImages
{
    [self showInfoView];
    [self performSelectorInBackground:@selector(downloadImagesLogs) withObject:nil];
    [self performSelectorInBackground:@selector(downloadImagesCache) withObject:nil];
}

- (void)downloadImagesLogs
{
    InfoItemImage *iii = [infoView addImage];
    [iii setDescription:@"Images from the logs"];

    [logImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL *stop) {
        [iii setQueueSize:[logImages count] - idx];
        if ([img imageHasBeenDowloaded] == NO) {
            [self downloadImage:img infoImageItem:iii];
        }
    }];

    [iii setQueueSize:0];
    iii.view.backgroundColor = [UIColor redColor];
    [infoView removeItem:iii];
    if ([infoView hasItems] == NO) {
        [self hideInfoView];
        [self needsDownloadMenu];
    }
}

- (void)downloadImagesCache
{
    InfoItemImage *iii = [infoView addImage];
    [iii setDescription:@"Images from the waypoint"];

    [cacheImages enumerateObjectsUsingBlock:^(dbImage *img, NSUInteger idx, BOOL *stop) {
        [iii setQueueSize:[cacheImages count] - idx];
        if ([img imageHasBeenDowloaded] == NO)
            [self downloadImage:img infoImageItem:iii];
    }];

    [iii setQueueSize:0];
    iii.view.backgroundColor = [UIColor greenColor];
    [infoView removeItem:iii];

    if ([infoView hasItems] == NO) {
        [self hideInfoView];
        [self needsDownloadMenu];
    }
}

- (void)downloadImage:(dbImage *)image infoImageItem:iii
{
    NSURL *url = [NSURL URLWithString:image.url];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error downloadInfoItem:iii];

    if (data == nil || response.statusCode != 200)
        return;

    [data writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], image.datafile] atomically:NO];
    [self reloadDataMainQueue];
}

- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages
{
    [self reloadDataMainQueue];

    if (queuedImages != 0) {
        [bezelManager setText:[NSString stringWithFormat:@"Downloading images\nDownloaded %ld, pending %ld", (long)downloadedImages, (long)queuedImages]];
    }

    if (queuedImages == 0) {
        [bezelManager removeBezel];
        [self needsDownloadMenu];
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

        userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGECATEGORY_USER];
        [self.tableView reloadData];
        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointImages_refreshTable];
    }
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
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

- (void)WaypointImage_refreshTable
{
    [self.tableView reloadData];
    [self needsDownloadMenu];
}

- (void)WaypointImage_swipeToDown
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

- (void)WaypointImage_swipeToUp
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

- (void)performLocalMenuAction:(NSInteger)index
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
        case menuDeleteAllPhotos:
            [self deleteAllPhotos];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)deleteAllPhotos
{
    [self deleteAllPhotos:cacheImages];
    [self deleteAllPhotos:userImages];
    [self deleteAllPhotos:logImages];

    [self needsDownloadMenu];
    [self.tableView reloadData];
}

- (void)deleteAllPhotos:(NSArray *)images
{
    [images enumerateObjectsUsingBlock:^(dbImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], image.datafile] error:nil];
    }];
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

        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

    if ([img dbLinkedtoWaypoint:waypoint._id] == NO)
        [img dbLinkToWaypoint:waypoint._id type:IMAGECATEGORY_USER];

    userImages = [dbImage dbAllByWaypoint:waypoint._id type:IMAGECATEGORY_USER];
    [self.tableView reloadData];
    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointImages_refreshTable];

    [self finishAndUpdate];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointImages_refreshTable];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // do what you need to do after saving
}

@end
