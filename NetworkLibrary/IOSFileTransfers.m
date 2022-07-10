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

@interface IOSFileTransfers ()

@property (nonatomic        ) NSInteger currentICloud;
@property (nonatomic, retain) UIViewController *ICloudVC;

@end

@implementation IOSFileTransfers

enum {
    iCloudNone = 0,
    iCloudUpload,
    iCloudDownload,
    iCloudMax,
};

- (instancetype)init
{
    self = [super init];

    self.currentICloud = iCloudNone;
    self.ICloudVC = nil;
    self.delegate = nil;

    return self;
}

#pragma mark - iCloud related functions

- (void)uploadAirdrop:(NSString *)path vc:(UIViewController *)vc
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    NSArray<NSURL *> *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    controller.popoverPresentationController.sourceView = vc.view;
    controller.popoverPresentationController.sourceRect = vc.view.bounds;

    // Exclude all activities except AirDrop.
    NSArray<UIActivityType> *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                                    UIActivityTypePostToWeibo,
                                                    UIActivityTypeMessage, UIActivityTypeMail,
                                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;

    // Present the controller
    [ALERT_VC_RVC(vc) presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Airdrop or attachment action

- (void)importAirdropAttachment:(NSURL *)url
{
    NSError *error = nil;
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:[url pathComponents]];
    NSString *file = [as objectAtIndex:[as count] - 1];

    [as removeObjectAtIndex:1];

    NSString *fromFile = [as componentsJoinedByString:@"/"];
    //NSString *fromFile = [NSString stringWithFormat:@"%@/Inbox/%@", [MyTools DocumentRoot], file];
    NSString *toFile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file];
    [fileManager removeItemAtPath:toFile error:&error];
    if ([fileManager moveItemAtPath:fromFile toPath:toFile error:&error] == FALSE)
        NSLog(@"moveItemAtPath: %@", error);
    NSLog(@"Importing from AirDrop or attachment: %@", file);

    [self.delegate IOSFileTransferRefreshFilelist];
}

#pragma mark - iTunes related functions

- (void)cleanupITunes
{
    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:[MyTools DocumentRoot] error:nil];

    [files enumerateObjectsUsingBlock:^(NSString * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
        /*
         * Do not move directories.
         * Do not move database.
         */
        NSString *fromFile = [NSString stringWithFormat:@"%@/%@", [MyTools DocumentRoot], file];
        NSDictionary *a = [fileManager attributesOfItemAtPath:fromFile error:nil];
        if ([[a objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            return;
        if ([file isEqualToString:@"database.db"] == YES)
            return;

        // Move this file into the files directory
        NSString *toFile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file];
        [fileManager removeItemAtPath:toFile error:nil];
        [fileManager moveItemAtPath:fromFile toPath:toFile error:nil];
        NSLog(@"Importing from iTunes: %@", file);
    }];

    [self.delegate IOSFileTransferRefreshFilelist];
}

#pragma mark - iCloud related functions

- (void)uploadICloud:(NSString *)path vc:(UIViewController *)vc
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    UIDocumentPickerViewController *exportICloudMenu = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:UIDocumentPickerModeExportToService];
    exportICloudMenu.delegate = self;
    exportICloudMenu.popoverPresentationController.sourceView = vc.view;
    exportICloudMenu.popoverPresentationController.sourceRect = vc.view.bounds;
    self.currentICloud = iCloudUpload;
    self.ICloudVC = vc;
    [ALERT_VC_RVC(vc) presentViewController:exportICloudMenu animated:YES completion:nil];
}

- (void)downloadICloud:(UIViewController *)vc
{
    UIDocumentPickerViewController *importICloudMenu = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
    importICloudMenu.delegate = self;
    importICloudMenu.popoverPresentationController.sourceView = vc.view;
    importICloudMenu.popoverPresentationController.sourceRect = vc.view.bounds;
    self.currentICloud = iCloudDownload;
    self.ICloudVC = vc;
    UIViewController *tmc = [MyTools topMostController];
    [ALERT_VC_RVC(tmc) presentViewController:importICloudMenu animated:YES completion:nil];
}

- (void)documentMenu:(UIDocumentPickerViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [ALERT_VC_RVC(self.ICloudVC) presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentMenuWasCancelled:(UIDocumentPickerViewController *)documentMenu
{
    NSLog(@"Foo");
    self.currentICloud = iCloudNone;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    if (self.currentICloud == iCloudDownload) {
        [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
            NSError *error = nil;
            NSURL *destinationName = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], [url lastPathComponent]] isDirectory:NO];

            /* Remove this file is it already exists. Ignore the error. */
            [fileManager removeItemAtURL:destinationName error:&error];
            error = nil;

            if ([fileManager copyItemAtURL:url toURL:destinationName error:&error] == YES) {
                [MyTools messageBox:self.ICloudVC header:_(@"iosfiletransfers-Download complete") text:_(@"iosfiletransfers-You can find the saved file in the Files menu")];
                [self.delegate IOSFileTransferRefreshFilelist];
            } else {
                [MyTools messageBox:self.ICloudVC header:_(@"iosfiletransfers-Download failed") text:[NSString stringWithFormat:(@"iosfiletransfers-Error message: %@"), error]];
            }
        }];
        self.currentICloud = iCloudNone;
    }

    if (self.currentICloud == iCloudUpload) {
        [MyTools messageBox:self.ICloudVC header:_(@"iosfiletransfers-Upload complete") text:_(@"iosfiletransfers-Your other iCloud devices should be seeing this file now")];
        self.currentICloud = iCloudNone;
    }
}

@end
