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

@interface CacheLogViewController ()
{
    dbWaypoint *waypoint;
    NSString *logtype;
    NSString *note;
    NSString *date;
    BOOL fp, upload;
}

@end

@implementation CacheLogViewController

enum {
    SECTION_LOGDETAILS,
    SECTION_EXTRADETAILS,
    SECTION_SUBMIT,
    SECTION_MAX,

    SECTION_LOGDETAILS_TYPE = 0,
    SECTION_LOGDETAILS_DATE,
    SECTION_LOGDETAILS_COMMENT,
    SECTION_LOGDETAILS_MAX,

    SECTION_EXTRADETAILS_PHOTO = 0,
    SECTION_EXTRADETAILS_FAVOURITE,
    SECTION_EXTRADETAILS_RATING,
    SECTION_EXTRADETAILS_TRACKABLE,
    SECTION_EXTRADETAILS_MAX,

    SECTION_SUBMIT_UPLOAD = 0,
    SECTION_SUBMIT_SUBMIT,
    SECTION_SUBMIT_MAX,
};

#define THISCELL @"CacheLogViewControllerCell"

- (instancetype)init:(dbWaypoint *)_waypoint
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
    lmi = nil;

    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_MAX;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_EXTRADETAILS: return SECTION_EXTRADETAILS_MAX;
        case SECTION_LOGDETAILS: return SECTION_LOGDETAILS_MAX;
        case SECTION_SUBMIT: return SECTION_SUBMIT_MAX;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_LOGDETAILS: return @"Log details";
        case SECTION_EXTRADETAILS: return @"Extra details";
        case SECTION_SUBMIT: return @"Submit";
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
        case SECTION_LOGDETAILS: {
            switch (indexPath.row) {
                case SECTION_LOGDETAILS_TYPE:
                    cell.keyLabel.text = @"Type";
                    cell.valueLabel.text = logtype;
                    break;
                case SECTION_LOGDETAILS_DATE:
                    cell.keyLabel.text = @"Date";
                    cell.valueLabel.text = date;
                    break;
                case SECTION_LOGDETAILS_COMMENT:
                    cell.keyLabel.text = @"Comment";
                    cell.valueLabel.text = note;
                    break;
            }
            break;
        }
        case SECTION_EXTRADETAILS: {
            switch (indexPath.row) {
                case SECTION_EXTRADETAILS_PHOTO:
                    cell.keyLabel.text = @"Photo";
                    if ([waypoint.account.remoteAPI commentSupportsPhotos] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    }
                    break;
                case SECTION_EXTRADETAILS_FAVOURITE: {
                    cell.keyLabel.text = @"Favourite Point";
                    UISwitch *fpSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    fpSwitch.on = fp;
                    cell.accessoryView = fpSwitch;
                    if ([waypoint.account.remoteAPI commentSupportsFavouritePoint] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    } else {
                        [fpSwitch addTarget:self action:@selector(updateFPSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    break;
                }
                case SECTION_EXTRADETAILS_RATING: {
                    cell.keyLabel.text = @"Rating";
                    if ([waypoint.account.remoteAPI commentSupportsRating] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    }
                    break;
                }
                case SECTION_EXTRADETAILS_TRACKABLE:
                    cell.keyLabel.text = @"Trackable";
                    if ([waypoint.account.remoteAPI commentSupportsTrackables] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = [UIColor lightGrayColor];
                    }
                    break;
            }
            break;
        }
        case SECTION_SUBMIT: {
            switch (indexPath.row) {
                case SECTION_SUBMIT_UPLOAD: {
                    cell.keyLabel.text = @"Upload";
                    UISwitch *fpSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                    fpSwitch.on = upload;
                    [fpSwitch addTarget:self action:@selector(updateUploadSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = fpSwitch;
                    break;
                }
                case SECTION_SUBMIT_SUBMIT:
                    cell.keyLabel.text = @"Submit!";
                    break;
            }
            break;
        }
    }

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
        case SECTION_LOGDETAILS: {
            switch (indexPath.row) {
                case SECTION_LOGDETAILS_TYPE:
                    [self changeType];
                    break;
                case SECTION_LOGDETAILS_DATE:
                    [self changeDate];
                    break;
                case SECTION_LOGDETAILS_COMMENT:
                    [self changeNote];
                    break;
            }
            break;
        }
        case SECTION_EXTRADETAILS: {
            switch (indexPath.row) {
                case SECTION_EXTRADETAILS_PHOTO:
                    [self changePhoto];
                    break;
                case SECTION_EXTRADETAILS_FAVOURITE:
                    [self changeFP];
                    break;
                case SECTION_EXTRADETAILS_TRACKABLE:
                    [self changeTrackable];
                    break;
            }
            break;
        }
        case SECTION_SUBMIT: {
            switch (indexPath.row) {
                case SECTION_SUBMIT_SUBMIT:
                    [self submitLog];
                    break;
            }
            break;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}

- (void)changeType
{
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:10];
    __block NSInteger selected;

    NSString *type = @"other";
    if ([waypoint.wpt_type.type_full isEqualToString:@"Geocache|Event Cache"] == YES ||
        [waypoint.wpt_type.type_full isEqualToString:@"Geocache|Giga"] == YES ||
        [waypoint.wpt_type.type_full isEqualToString:@"Geocache|Mega"] == YES)
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
//  tv.backgroundColor = currentTheme.backgroundColor;
//  tv.textColor = currentTheme.textColor;
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
    // Do not upload, save it locally for later
    if (upload == NO) {
        [dbLog CreateLogNote:logtype waypoint:waypoint dateLogged:date note:note needstobelogged:YES];
        waypoint.logStatus = LOGSTATUS_FOUND;
        [waypoint dbUpdateLogStatus];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // Check length
    if ([note length] == 0) {
        [MyTools messageBox:self header:@"Please fill in the comment" text:@"Even TFTC is better than nothing at all."];
        return;
    }

    NSInteger gc_id = [waypoint.account.remoteAPI CreateLogNote:logtype waypoint:waypoint dateLogged:date note:note favourite:fp];

    // Successful but not log id returned
    if (gc_id == -1) {
        [self.navigationController popViewControllerAnimated:YES];

        [MyTools messageBox:self.parentViewController header:@"Submission successful" text:@"However, because of the system used the logs are not directly updated. Select the 'refresh waypoint' options from the menu here to refresh it."];

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

    [MyTools messageBox:self header:@"Submission failed" text:s];
}


@end
