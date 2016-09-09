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

@interface IOSFileTransfers ()
{
    NSInteger currentICloud;
    UIViewController *ICloudVC;
}

@end

@implementation IOSFileTransfers

@synthesize delegate;

enum {
    iCloudNone = 0,
    iCloudUpload,
    iCloudDownload,
    iCloudMax,
};

- (instancetype)init
{
    self = [super init];

    currentICloud = iCloudNone;
    ICloudVC = nil;
    delegate = nil;

    return self;
}

#pragma mark - iCloud related functions

- (void)uploadAirdrop:(NSString *)path vc:(UIViewController *)vc
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    NSArray *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
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
    NSArray *as = [url pathComponents];
    NSString *file = [as objectAtIndex:[as count] - 1];

    NSString *fromFile = [NSString stringWithFormat:@"%@/Inbox/%@", [MyTools DocumentRoot], file];
    NSString *toFile = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], file];
    [fileManager removeItemAtPath:toFile error:nil];
    [fileManager moveItemAtPath:fromFile toPath:toFile error:nil];
    NSLog(@"Importing from AirDrop or attachment: %@", file);

    [delegate refreshFilelist];
}

#pragma mark - iTunes related functions

- (void)cleanupITunes
{
    NSArray *files = [fileManager contentsOfDirectoryAtPath:[MyTools DocumentRoot] error:nil];

    [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL *stop) {
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

    [delegate refreshFilelist];
}

#pragma mark - iCloud related functions

- (void)uploadICloud:(NSString *)path vc:(UIViewController *)vc
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    UIDocumentMenuViewController *exportICloudMenu = [[UIDocumentMenuViewController alloc] initWithURL:url inMode:UIDocumentPickerModeExportToService];
    exportICloudMenu.delegate = self;
    currentICloud = iCloudUpload;
    ICloudVC = vc;
    [ALERT_VC_RVC(vc) presentViewController:exportICloudMenu animated:YES completion:nil];
}

- (void)downloadICloud:(UIViewController *)vc
{
    UIDocumentMenuViewController *importICloudMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
    importICloudMenu.delegate = self;
    currentICloud = iCloudDownload;
    ICloudVC = vc;
    [ALERT_VC_RVC(vc) presentViewController:importICloudMenu animated:YES completion:nil];
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [ALERT_VC_RVC(ICloudVC) presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu
{
    NSLog(@"Foo");
    currentICloud = iCloudNone;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    if (currentICloud == iCloudDownload) {
        NSError *error = nil;
        NSURL *destinationName = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], [url lastPathComponent]] isDirectory:NO];

        /* Remove this file is it already exists. Ignore the error. */
        [fileManager removeItemAtURL:destinationName error:&error];
        error = nil;

        if ([fileManager copyItemAtURL:url toURL:destinationName error:&error] == YES) {
            [MyTools messageBox:ICloudVC header:@"Download complete" text:@"You can find the saved file in the Files menu"];
            [delegate refreshFilelist];
        } else {
            [MyTools messageBox:ICloudVC header:@"Download failed" text:[NSString stringWithFormat:@"Error message: %@", error]];
        }
        currentICloud = iCloudNone;
    }

    if (currentICloud == iCloudUpload) {
        [MyTools messageBox:ICloudVC header:@"Upload complete" text:@"Your other iCloud devices should be seeing this file now"];
        currentICloud = iCloudNone;
    }
}

@end
