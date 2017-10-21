/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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
    NSArray<dbImage *> *userImages;
    NSArray<dbImage *> *logImages;
    NSArray<dbImage *> *cacheImages;

    NSIndexPath *currentIndexPath;
    WaypointImageViewController *ivc;
}

@end

@implementation WaypointImagesViewController

enum {
    SECTION_USER = 0,
    SECTION_WAYPOINT,
    SECTION_LOG,
    SECTION_MAX
};

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

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuImportPhoto label:_(@"waypointimagesviewcontroller-Import photo")];
    [self.lmi addItem:menuMakePhoto label:_(@"waypointimagesviewcontroller-Make photo")];
    [self.lmi addItem:menuDownloadImages label:_(@"waypointimagesviewcontroller-Download photos")];
    [self.lmi addItem:menuDeleteAllPhotos label:_(@"waypointimagesviewcontroller-Delete all photos")];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        [self.lmi disableItem:menuImportPhoto];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        [self.lmi disableItem:menuMakePhoto];

    self.hasCloseButton = YES;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];

    waypoint = wp;
    userImages = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_USER];
    cacheImages = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_CACHE];
    logImages = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_LOG];

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
    [userImages enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    [cacheImages enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    [logImages enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([img imageHasBeenDowloaded] == NO)
            needsDownload = YES;
        else
            needsDelete = YES;
    }];
    if (needsDownload == NO)
        [self.lmi disableItem:menuDownloadImages];
    else
        [self.lmi enableItem:menuDownloadImages];
    if (needsDelete == NO)
        [self.lmi disableItem:menuDeleteAllPhotos];
    else
        [self.lmi enableItem:menuDeleteAllPhotos];
}

#pragma mark - Functions for downloading of images

- (void)downloadImage:(dbImage *)image
{
    [self showInfoView];
    NSNumber *iiiImage = [NSNumber numberWithInteger:[self.infoView addImage]];
    NSDictionary *d = @{@"iii": iiiImage, @"image": image };
    BACKGROUND(downloadImageBG:, d);
}

- (void)downloadImageBG:(NSDictionary *)dict
{
    InfoItemID iii = [[dict objectForKey:@"iii"]  integerValue];
    dbImage *img = [dict objectForKey:@"image"];
    [self.infoView setDescription:iii description:_(@"waypointimagesviewcontroller-Images")];
    [self downloadImage:img infoViewer:self.infoView iiImage:iii];
    [self.infoView setQueueSize:iii queueSize:0];
    [self.infoView removeItem:iii];
    if ([self.infoView hasItems] == NO) {
        [self hideInfoView];
        [self needsDownloadMenu];
    }
}

- (void)downloadImages
{
    [self showInfoView];
    NSNumber *iiiLogs = [NSNumber numberWithInteger:[self.infoView addImage]];
    NSNumber *iiiCache = [NSNumber numberWithInteger:[self.infoView addImage]];
    BACKGROUND(downloadImagesLogs:, iiiLogs);
    BACKGROUND(downloadImagesCache:, iiiCache);
}

- (void)downloadImagesLogs:(NSNumber *)iii_
{
    InfoItemID iii = [iii_ integerValue];
    [self.infoView setDescription:iii description:_(@"waypointimagesviewcontroller-Images from the logs")];

    [logImages enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.infoView setQueueSize:iii queueSize:[logImages count] - idx];
        if ([img imageHasBeenDowloaded] == NO) {
            [self downloadImage:img infoViewer:self.infoView iiImage:iii];
        }
    }];

    [self.infoView setQueueSize:iii queueSize:0];
    [self.infoView removeItem:iii];
    if ([self.infoView hasItems] == NO) {
        [self hideInfoView];
        [self needsDownloadMenu];
    }
}

- (void)downloadImagesCache:(NSNumber *)iii_
{
    InfoItemID iii = [iii_ integerValue];
    [self.infoView setDescription:iii description:_(@"waypointimagesviewcontroller-Images from the waypoint")];

    [cacheImages enumerateObjectsUsingBlock:^(dbImage * _Nonnull img, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.infoView setQueueSize:iii queueSize:[cacheImages count] - idx];
        if ([img imageHasBeenDowloaded] == NO)
            [self downloadImage:img infoViewer:self.infoView iiImage:iii];
    }];

    [self.infoView setQueueSize:iii queueSize:0];
    [self.infoView removeItem:iii];

    if ([self.infoView hasItems] == NO) {
        [self hideInfoView];
        [self needsDownloadMenu];
    }
}

- (void)downloadImage:(dbImage *)image infoViewer:(InfoViewer *)iv iiImage:(InfoItemID)iii
{
    NSURL *url = [NSURL URLWithString:image.url];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error infoViewer:iv iiDownload:iii];

    if (response.statusCode == 301) {
        url = [NSURL URLWithString:[response.allHeaderFields objectForKey:@"Location"]];
        req = [GCURLRequest requestWithURL:url];
        response = nil;
        error = nil;
        data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error infoViewer:iv iiDownload:iii];
    }

    if (data == nil || response.statusCode != 200)
        return;

    [data writeToFile:[MyTools ImageFile:image.datafile] atomically:NO];
    [self reloadDataMainQueue];
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
        case SECTION_USER: return _(@"waypointimagesviewcontroller-User images");
        case SECTION_WAYPOINT: return _(@"waypointimagesviewcontroller-Waypoint images");
        case SECTION_LOG: return _(@"waypointimagesviewcontroller-Log images");
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

        [img dbUnlinkFromWaypoint:waypoint];

        userImages = [dbImage dbAllByWaypoint:waypoint type:IMAGECATEGORY_USER];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointImages_refreshTable];
    }
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = @"";    // clear by default

    dbImage *img;
    switch (indexPath.section) {
        case SECTION_USER: img = [userImages objectAtIndex:indexPath.row]; break;
        case SECTION_WAYPOINT: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case SECTION_LOG: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        abort();

    if ([img imageHasBeenDowloaded] == YES) {
        NSDictionary *exif = [MyTools imageEXIFDataFile:[MyTools ImageFile:img.datafile]];
        NSDictionary *exifgps = [exif objectForKey:@"{GPS}"];
        NSString *lats = [exifgps objectForKey:@"Latitude"];
        NSString *latref = [exifgps objectForKey:@"LatitudeRef"];
        NSString *lons = [exifgps objectForKey:@"Longitude"];
        NSString *lonref = [exifgps objectForKey:@"LongitudeRef"];

        if (lats != nil) {
            CLLocationDegrees lat = [lats floatValue];
            if ([latref isEqualToString:@"S"] == YES)
                lat *= -1;
            CLLocationDegrees lon = [lons floatValue];
            if ([lonref isEqualToString:@"W"] == YES)
                lon *= -1;
            cell.detailTextLabel.text = [Coordinates niceCoordinates:lat longitude:lon];
        } else if (img.lat != 0 && img.lon != 0)
            cell.detailTextLabel.text = [Coordinates niceCoordinates:img.lat longitude:img.lon];
        else
            cell.detailTextLabel.text = @"";
    }

    cell.textLabel.text = img.name;
    cell.userInteractionEnabled = YES;

    if ([img imageHasBeenDowloaded] == YES) {
        cell.imageView.image = [img imageGet];
    } else {
        cell.imageView.image = [imageManager get:Image_NoImageFile];
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

    if ([img imageHasBeenDowloaded] == NO) {
        [self downloadImage:img];
        return;
    }

    ivc = [[WaypointImageViewController alloc] init];
    ivc.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:ivc animated:YES];
    ivc.delegate = self;

    [ivc setImage:img idx:indexPath.row + 1 totalImages:max waypoint:waypoint];
    return;
}

- (void)WaypointImage_refreshTable
{
    [self.tableView reloadData];
    [self needsDownloadMenu];
}

- (void)WaypointImage_refreshWaypoint
{
    [self.delegateWaypoint WaypointImages_refreshTable];
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

        [ivc setImage:img idx:currentIndexPath.row + 1 totalImages:max waypoint:waypoint];
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

        [ivc setImage:img idx:currentIndexPath.row + 1 totalImages:max waypoint:waypoint];
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

- (void)deleteAllPhotos:(NSArray<dbImage *> *)images
{
    [images enumerateObjectsUsingBlock:^(dbImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileManager removeItemAtPath:[MyTools ImageFile:image.datafile] error:nil];
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

        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[imgURL] options:nil];
        PHAsset *asset = fetchResult.firstObject;

        NSString *imgtag = imgURL.absoluteString;
        img = [dbImage dbGetByURL:imgtag];
        NSString *datafile = [dbImage createDataFilename:imgtag];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[MyTools ImageFile:datafile] atomically:NO];

        if (img == nil) {
            img = [[dbImage alloc] init];
            img.url = imgtag;
            img.name = [dbImage filename:imgtag];
            img.datafile = datafile;
            img.lat = asset.location.coordinate.latitude;
            img.lon = asset.location.coordinate.longitude;
            [img dbCreate];
        } else {
            NSLog(@"%@/parse: Image already seen", [self class]);
        }
    } else {
        // From camera
        NSDictionary *exif = [info objectForKey:@"UIImagePickerControllerMediaMetadata"];
        exif = [exif objectForKey:@"{Exif}"];
        NSString *datecreated = [exif objectForKey:@"DateTimeOriginal"];
        NSString *datafile = [dbImage createDataFilename:datecreated];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[MyTools ImageFile:datafile] atomically:NO];
        img = [[dbImage alloc] init];
        img.url = datecreated;
        img.name= [dbImage filename:datecreated];
        img.datafile = datafile;
        img.lat = LM.coords.latitude;
        img.lon = LM.coords.longitude;
        [img dbCreate];

        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }

    if ([img dbLinkedtoWaypoint:waypoint] == NO)
        [img dbLinkToWaypoint:waypoint type:IMAGECATEGORY_USER];

    userImages = [dbImage dbAllByWaypoint:waypoint type:IMAGECATEGORY_USER];
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
