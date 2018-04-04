/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@interface WaypointLogImagesViewController ()

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) NSArray<dbImage *> *images;

@property (nonatomic, retain) UITableView *parentTable;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

@end

@implementation WaypointLogImagesViewController

enum {
    menuImportPhoto,
    menuMakePhoto,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp table:(UITableView *)table
{
    self = [super init];
    self.parentTable = table;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuImportPhoto label:_(@"waypointlogimagesviewcontroller-Import photo")];
    [self.lmi addItem:menuMakePhoto label:_(@"waypointlogimagesviewcontroller-Make photo")];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        [self.lmi disableItem:menuImportPhoto];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        [self.lmi disableItem:menuMakePhoto];

    self.hasCloseButton = YES;
    _delegate = nil;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];

    self.waypoint = wp;
    self.images = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_USER];

    return self;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.images count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbImage *img = [self.images objectAtIndex:indexPath.row];
    if (img == nil)
        return nil;

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
    dbImage *img = [self.images objectAtIndex:indexPath.row];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointlogimagesviewcontroller-Photo details")
                                message:_(@"waypointlogimagesviewcontroller-Edit the photo caption and description")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *caption = [alert.textFields objectAtIndex:0];
                             UITextField *longtext = [alert.textFields objectAtIndex:1];
                             [_delegate waypointLogImageSelected:img caption:caption.text longtext:longtext.text];

                             [self.navigationController popViewControllerAnimated:YES];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointlogimagesviewcontroller-Caption");
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointlogimagesviewcontroller-Long description");
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuImportPhoto:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            return;
        case menuMakePhoto:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            return;
    }

    [super performLocalMenuAction:index];
}

#pragma mark - Camera import related functions

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePickerController.sourceType = sourceType;
    self.imagePickerController.delegate = self;

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
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[MyTools ImageFile:datafile] atomically:NO];

        if (img == nil) {
            img = [[dbImage alloc] init];
            img.url = imgtag;
            img.name = [dbImage filename:imgtag];
            img.datafile = datafile;
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
        img.name = [dbImage filename:datecreated];
        img.datafile = datafile;
        [img dbCreate];
    }

    if ([img dbLinkedtoWaypoint:self.waypoint] == NO)
        [img dbLinkToWaypoint:self.waypoint type:IMAGECATEGORY_USER];

    self.images = [dbImage dbAllByWaypoint:self.waypoint type:IMAGECATEGORY_USER];
    [self.tableView reloadData];
    [self.parentTable reloadData];

    [self finishAndUpdate];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.parentTable reloadData];
}

@end
