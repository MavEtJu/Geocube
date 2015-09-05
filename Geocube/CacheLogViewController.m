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

@implementation CacheLogViewController

#define THISCELL @"CacheLogViewControllerCell"

- (id)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    logtype = @"Found it";
    fp = NO;
    upload = YES;

    NSDate *d = [NSDate date];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    date = [dateFormatter stringFromDate:d];

    [self.tableView registerClass:[GCTableViewCellKeyValue class] forCellReuseIdentifier:THISCELL];
    hasCloseButton = YES;
    menuItems = nil;

    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 3;
        case 1: return 3;
        case 2: return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Log details";
        case 1: return @"Extra details";
        case 2: return @"Submit";
    }
    return @"???";
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellKeyValue *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[GCTableViewCellKeyValue alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.userInteractionEnabled = YES;

    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.keyLabel.text = @"Type";
                    cell.valueLabel.text = logtype;
                    break;
                case 1:
                    cell.keyLabel.text = @"Date";
                    cell.valueLabel.text = date;
                    break;
                case 2:
                    cell.keyLabel.text = @"Comment";
                    cell.valueLabel.text = note;
                    break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0:
                    cell.keyLabel.text = @"Photo";
                    if ([waypoint.account.remoteAPI commentSupportsPhotos] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    }
                    break;
                case 1: {
                    cell.keyLabel.text = @"Favourite Point";
                    UISwitch *fpSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    fpSwitch.on = fp;
                    [fpSwitch addTarget:self action:@selector(updateFPSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = fpSwitch;
                    cell.userInteractionEnabled = NO;
                    break;
                }
                case 2:
                    cell.keyLabel.text = @"Trackable";
                    if ([waypoint.account.remoteAPI commentSupportsTrackables] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    }
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    cell.keyLabel.text = @"Upload";
                    UISwitch *fpSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    fpSwitch.on = upload;
                    [fpSwitch addTarget:self action:@selector(updateUploadSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = fpSwitch;
                    cell.userInteractionEnabled = NO;
                    break;
                }
                case 1:
                    cell.keyLabel.text = @"Submit!";
                    break;
            }
            break;
        }
    }

    cell.userInteractionEnabled = YES;

    return cell;
}

- (void)updateFPSwitch:(UISwitch *)s
{
    fp = s.on;
}

- (void)updateUploadSwitch:(UISwitch *)s
{
    upload = s.on;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    [self changeType];
                    break;
                case 1:
                    [self changeDate];
                    break;
                case 2:
                    [self changeNote];
                    break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0:
                    [self changePhoto];
                    break;
                case 1:
                    [self changeFP];
                    break;
                case 2:
                    [self changeTrackable];
                    break;
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 1:
                    [self submitLog];
                    break;
            }
            break;
        }
    }
    return;
}

- (void)changeType
{
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:10];
    __block NSInteger selected;

    NSString *type = @"other";
    if ([waypoint.type.type isEqualToString:@"Geocache|Event Cache"] == YES ||
        [waypoint.type.type isEqualToString:@"Geocache|Giga"] == YES ||
        [waypoint.type.type isEqualToString:@"Geocache|Mega"] == YES)
        type = @"event";

    [[waypoint.account.remoteAPI logtypes:type] enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL *stop) {
        if ([l isEqualToString:logtype] == YES)
            selected = idx;
        [as addObject:l];
    }];
    [ActionSheetStringPicker
        showPickerWithTitle:@"Select a Logtype"
        rows:as
        initialSelection:selected
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            logtype = [as objectAtIndex:selectedIndex];
            [self.tableView reloadData];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
        }
        origin:self.view
    ];
}

- (void)changeDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:2000];
    [minimumDateComponents setMonth:1];
    [minimumDateComponents setDay:1];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];

    NSDate *d = [NSDate date];

    ActionSheetDatePicker *asdp =
        [[ActionSheetDatePicker alloc]
         initWithTitle:@"Date" datePickerMode:UIDatePickerModeDate
         selectedDate:d
         minimumDate:minDate
         maximumDate:maxDate
         target:self
         action:@selector(dateWasSelected:element:)
         origin:self.tableView];

    [asdp showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)d element:(UIButton *)b
{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    date = [dateFormatter stringFromDate:d];
    [self.tableView reloadData];
}


- (void)changeNote
{
    YIPopupTextView *tv = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your log here" maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    tv.delegate = self;
    tv.caretShiftGestureEnabled = YES;
    tv.text = note;

    [tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView*)textView didDismissWithText:(NSString*)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    note = text;
    [self.tableView reloadData];
}


- (void)changePhoto
{
}

- (void)changeFP
{
}

- (void)changeTrackable
{
}

- (void)submitLog
{
    if ([note length] == 0) {
        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Please fill in the comment"
                                   message:@"Even TFTC is better than nothing at all"
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                             ];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    // Do not upload, save it locally for later
    if (upload == NO) {
        [dbLog CreateLogNote:logtype waypoint:waypoint dateLogged:date note:note needstobelogged:YES];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    NSInteger gc_id = [waypoint.account.remoteAPI CreateLogNote:logtype waypoint:waypoint dateLogged:date note:note favourite:fp];

    // Successful but not log id returned
    if (gc_id == -1) {
        [self.navigationController popViewControllerAnimated:YES];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Submission successful"
                                   message:@"However, because of the system used the logs are not directly updated. Select the 'refresh waypoint' options from the menu here to refresh it."
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                             ];
        [alert addAction:ok];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
        return;
    }

    // Successful and a log id returned
    if (gc_id > 0) {
        dbLog *log = [dbLog CreateLogNote:logtype waypoint:waypoint dateLogged:date note:note needstobelogged:NO];
        log.gc_id = gc_id;
        [log dbUpdate];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // Unsuccessful
    NSMutableString *s = [NSMutableString stringWithFormat:@"Unable to submit the note: %@", waypoint.account.remoteAPI.clientMsg];
    if (waypoint.account.remoteAPI.clientError != nil)
        [s appendFormat:@" (%@)", waypoint.account.remoteAPI.clientError];

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Submission failed"
                               message:s
                               preferredStyle:UIAlertControllerStyleAlert
                               ];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:nil
                         ];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}


@end
