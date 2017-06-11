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
    NSMutableArray<dbLogMacro *> *logmacros;
}

@end

@implementation SettingsLogTemplatesViewController

#define THISCELL_TEMPLATE @"SettingsLogTemplateTableViewCell"
#define THISCELL_MACRO @"SettingsLogMacroTableViewCell"

enum {
    SECTION_LOGTEMPLATES = 0,
    SECTION_LOGMACROS,
    SECTION_MAX,
};

enum {
      menuAddTemplate = 0,
      menuAddMacro,
      menuMax,
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadLogXxx];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_TEMPLATE];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL_MACRO];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddTemplate label:@"Add Template"];
    [lmi addItem:menuAddMacro label:@"Add Macro"];
}

- (void)reloadLogXxx
{
    logtemplates = [NSMutableArray arrayWithArray:[dbLogTemplate dbAll]];
    logmacros = [NSMutableArray arrayWithArray:[dbLogMacro dbAll]];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_LOGTEMPLATES:
            return [NSString stringWithFormat:@"%ld log templates", (long)[logtemplates count]];
        case SECTION_LOGMACROS:
            return [NSString stringWithFormat:@"%ld log macros", (long)[logmacros count]];
        default:
            return @"";
    }
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_LOGTEMPLATES:
            return [logtemplates count];
        case SECTION_LOGMACROS:
            return [logmacros count];
        default:
            return 0;
    }
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell;

    switch (indexPath.section) {
        case SECTION_LOGTEMPLATES: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_TEMPLATE forIndexPath:indexPath];
            dbLogTemplate *lt = [logtemplates objectAtIndex:indexPath.row];
            cell.textLabel.text = lt.name;
            break;
        }
        case SECTION_LOGMACROS: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_MACRO forIndexPath:indexPath];
            dbLogMacro *lm = [logmacros objectAtIndex:indexPath.row];
            cell.textLabel.text = lm.name;
            cell.detailTextLabel.text = lm.text;
            break;
        }
    }

    cell.userInteractionEnabled = YES;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YIPopupTextView *tv;
    currentLT = nil;

    switch (indexPath.section) {
        case SECTION_LOGTEMPLATES: {
            currentLT = [logtemplates objectAtIndex:indexPath.row];
            tv = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your log template here" maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];
            tv.text = currentLT.text;
            tv.delegate = self;
            tv.caretShiftGestureEnabled = YES;
            tv.maxCount = 4000;
            [tv showInViewController:self];
            break;
        }
        case SECTION_LOGMACROS: {
            [self updateLogMacro:[logmacros objectAtIndex:indexPath.row]];
            break;
        }
    }
}
- (void)updateLogMacro:(dbLogMacro *)macro
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Update log macro"
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tfname = [alert.textFields objectAtIndex:0];
                             UITextField *tftext = [alert.textFields objectAtIndex:1];

                             dbLogMacro *lm = [dbLogMacro dbGet:macro._id];
                             lm.name = tfname.text;
                             lm.text = tftext.text;
                             NSLog(@"Updating log macro '%@'", lm.name);
                             [lm dbUpdate];
                             [self reloadLogXxx];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of the log macro";
        textField.text = macro.name;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Text of the log macro";
        textField.text = macro.text;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    if (currentLT != nil) {
        currentLT.text = text;
        [currentLT dbUpdate];
    }
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)
indexPath
{
    return @"Remove";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        switch (indexPath.section) {
            case SECTION_LOGMACROS: {
                dbLogMacro *lm = [logmacros objectAtIndex:indexPath.row];
                [lm dbDelete];
                [logmacros removeObjectAtIndex:indexPath.row];
                break;
            }
            case SECTION_LOGTEMPLATES: {
                dbLogTemplate *lt = [logtemplates objectAtIndex:indexPath.row];
                [lt dbDelete];
                [logtemplates removeObjectAtIndex:indexPath.row];
                break;
            }
        }
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    }
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
                             [self reloadLogXxx];
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

- (void)addLogMacro
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Create a new log macro"
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tfname = [alert.textFields objectAtIndex:0];
                             UITextField *tfmacro = [alert.textFields objectAtIndex:1];
                             NSString *name = tfname.text;
                             NSString *text = tfmacro.text;

                             NSLog(@"Creating new log macro '%@'", name);
                             [dbLogMacro dbCreate:name text:text];
                             [self reloadLogXxx];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of the log macro";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Text of the log macro";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuAddTemplate:
            [self addLogTemplate];
            return;
        case menuAddMacro:
            [self addLogMacro];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
