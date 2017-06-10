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

@interface SettingsLogTemplatesViewController ()
{
    NSMutableArray<dbLogTemplate *> *logtemplates;
    dbLogTemplate *currentLT;
}

@end

@implementation SettingsLogTemplatesViewController

#define THISCELL @"SettingsLogTemplateTableViewCell"

enum {
      menuAdd = 0,
      menuMax,
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadLogTemplates];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAdd label:@"Add Template"];
}

- (void)reloadLogTemplates
{
    logtemplates = [NSMutableArray arrayWithArray:[dbLogTemplate dbAll]];
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
    return [logtemplates count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbLogTemplate *lt = [logtemplates objectAtIndex:indexPath.row];

    cell.textLabel.text = lt.name;
    cell.userInteractionEnabled = YES;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentLT = [logtemplates objectAtIndex:indexPath.row];

    YIPopupTextView *tv = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your log template here" maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    tv.delegate = self;
    tv.caretShiftGestureEnabled = YES;
    tv.maxCount = 4000;
    tv.text = currentLT.text;

    [tv showInViewController:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)
indexPath
{
    return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbLogTemplate *lt = [logtemplates objectAtIndex:indexPath.row];
        [lt dbDelete];
        [logtemplates removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    }
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    currentLT.text = text;
    [currentLT dbUpdate];
    [self.tableView reloadData];
}

#pragma mark - Local menu related functions

- (void)addLogTemplate
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Create a new log template"
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *name = tf.text;

                             NSLog(@"Creating new log template '%@'", name);
                             [dbLogTemplate dbCreate:name];
                             [self reloadLogTemplates];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of the log template";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuAdd:
            [self addLogTemplate];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
