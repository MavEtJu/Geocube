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

enum {
    SECTION_LOGTEMPLATES = 0,
    SECTION_LOGMACROS,
    SECTION_MAX,
};

enum {
      menuAddTemplate = 0,
      menuAddMacro,
      menuBackup,
      menuMax,
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadLogXxx];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddTemplate label:NSLocalizedString(@"settingslogtemplatesviewcontroller-addtemplate", nil)];
    [lmi addItem:menuAddMacro label:NSLocalizedString(@"settingslogtemplatesviewcontroller-addmacro", nil)];
    [lmi addItem:menuBackup label:NSLocalizedString(@"settingslogtemplatesviewcontroller-backup", nil)];
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
            cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];
            dbLogTemplate *lt = [logtemplates objectAtIndex:indexPath.row];
            cell.textLabel.text = lt.name;
            break;
        }
        case SECTION_LOGMACROS: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
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
                             dbLogTemplate *lt = [[dbLogTemplate alloc] init];
                             lt.name = name;
                             lt.text = @"";
                             [lt dbCreate];
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
                             dbLogMacro *lm = [[dbLogMacro alloc] init];
                             lm.name = name;
                             lm.text = text;
                             [lm dbCreate];
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

- (void)backup
{
    NSMutableArray<NSString *> *lines = [NSMutableArray arrayWithCapacity:100];

    [lines addObject:@"; Backup of the Log Templates and Macros."];
    [lines addObject:@"; Lines starting with a ; are considered comments."];
    [lines addObject:@"; The format is: First comes the text 'Macro' or 'Template'."];
    [lines addObject:@"; Then comes a separator, the text of the macro or template and another separator."];
    [lines addObject:@";"];
    [lines addObject:@"; Do not remove"];
    [lines addObject:[NSString stringWithFormat:@"Type: %@", [ImportGeocube type_LogTemplatesAndMacros]]];
    [lines addObject:@"Version: 1"];
    [lines addObject:@""];

    [[dbLogTemplate dbAll] enumerateObjectsUsingBlock:^(dbLogTemplate * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
        [lines addObject:[NSString stringWithFormat:@"; %@", lt.name]];
        [lines addObject:[NSString stringWithFormat:@"Template '%@'", lt.name]];
        [lines addObject:[ImportGeocube blockSeparator]];
        [lines addObject:lt.text];
        [lines addObject:[ImportGeocube blockSeparator]];
    }];

    [[dbLogMacro dbAll] enumerateObjectsUsingBlock:^(dbLogMacro * _Nonnull lm, NSUInteger idx, BOOL * _Nonnull stop) {
        [lines addObject:[NSString stringWithFormat:@"; %@", lm.name]];
        [lines addObject:[NSString stringWithFormat:@"Macro '%@'", lm.name]];
        [lines addObject:[ImportGeocube blockSeparator]];
        [lines addObject:lm.text];
        [lines addObject:[ImportGeocube blockSeparator]];
    }];

    NSString *filename = @"Log Templates and Macros.geocube";

    NSString *fn = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    NSLog(@"Exporting to %@", fn);

    NSMutableString *line = [NSMutableString string];
    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL * _Nonnull stop) {
        [line appendString:l];
        [line appendString:@"\n"];
    }];

    [line writeToFile:fn atomically:NO encoding:NSUTF8StringEncoding error:nil];

    [MyTools messageBox:self header:@"Backup complete" text:[NSString stringWithFormat:@"You can find the backup in the Files tab as '%@'", filename]];
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
        case menuBackup:
            [self backup];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
