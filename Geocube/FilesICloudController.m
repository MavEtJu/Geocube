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

@interface FilesICloudController ()

@end

@implementation FilesICloudController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIDocumentMenuViewController *importMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];

    importMenu.delegate = self;

    [self presentViewController:importMenu animated:YES completion:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    NSLog(@"didPickDocumentPicker");

    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    NSLog(@"didPickDocumentAtURL");

    if ([url isFileReferenceURL] == NO)
        return;

    NSError *error = nil;
    UIAlertController *alert;
    NSURL *destinationURL = [NSURL URLWithString:[MyTools FilesDir]];
    if ([fm copyItemAtURL:url toURL:destinationURL error:&error] == YES) {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Download complete"
                 message:@"You can find them in the Files menu."
                 preferredStyle:UIAlertControllerStyleAlert
                 ];
    } else {
        alert = [UIAlertController
                 alertControllerWithTitle:@"Download failed"
                 message:[NSString stringWithFormat:@"Error message: %@", error]
                 preferredStyle:UIAlertControllerStyleAlert
                 ];
    }

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:nil];

    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
