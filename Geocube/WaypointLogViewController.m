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

@interface WaypointLogViewController ()
{
    dbWaypoint *waypoint;
    NSArray *logstrings;
    dbLogString *logstring;
    NSString *note;
    NSString *date;

    dbImage *image;
    NSString *imageCaption;
    NSString *imageLongText;

    NSMutableArray *trackables;

    NSInteger ratingSelected;
    BOOL fp, upload;
}

@end

@implementation WaypointLogViewController

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

#define THISCELL_ALL @"CacheLogViewControllerCellAll"
#define THISCELL_PHOTO @"CacheLogViewControllerCellPhoto"
#define THISCELL_SUBTITLE @"CacheLogViewControllerCellSubtitle"

- (instancetype)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    fp = NO;
    upload = YES;
    image = nil;
    ratingSelected = 0;
    self.delegateWaypoint = nil;

    NSInteger type = [dbLogString wptTypeToLogType:waypoint.wpt_type.type_full];
    logstrings = [dbLogString dbAllByProtocolLogtype_LogOnly:waypoint.account.protocol logtype:type];
    [logstrings enumerateObjectsUsingBlock:^(dbLogString *ls, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ls.defaultFound == YES) {
            logstring = ls;
            *stop = YES;
        }
    }];

    trackables = [NSMutableArray arrayWithArray:[dbTrackable dbAllInventory]];

    NSDate *d = [NSDate date];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    date = [dateFormatter stringFromDate:d];

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL_SUBTITLE];
    [self.tableView registerClass:[GCTableViewCellKeyValue class] forCellReuseIdentifier:THISCELL_ALL];
    [self.tableView registerClass:[GCTableViewCellRightImage class] forCellReuseIdentifier:THISCELL_PHOTO];
    self.hasCloseButton = YES;
    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = YES;
    [super viewDidLoad];
}

- (void)refreshTable
{
    [self.tableView reloadData];
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
    GCTableViewCellKeyValue *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL_ALL];
    cell.accessoryType = UITableViewCellStyleDefault;
    cell.accessoryView = nil;
    cell.userInteractionEnabled = YES;
    cell.keyLabel.text = @"";
    cell.valueLabel.text = @"";

    switch (indexPath.section) {
        case SECTION_LOGDETAILS: {
            switch (indexPath.row) {
                case SECTION_LOGDETAILS_TYPE:
                    cell.keyLabel.text = @"Type";
                    cell.valueLabel.text = logstring.text;
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
                case SECTION_EXTRADETAILS_PHOTO: {
                    cell = nil;
                    GCTableViewCellRightImage *c = [aTableView dequeueReusableCellWithIdentifier:THISCELL_PHOTO];
                    c.textLabel.text = @"Photo";
                    if (image != nil)
                        c.imageView.image = image.imageGet;
                    else
                        c.imageView.image = [imageLibrary get:Image_NoImageFile];
                    if ([waypoint.account.remoteAPI commentSupportsPhotos] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    }
                    // Only place to return because the return format has changed.
                    return c;
                }
                case SECTION_EXTRADETAILS_FAVOURITE: {
                    cell.keyLabel.text = @"Favourite Point";
                    GCSwitch *fpSwitch = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    fpSwitch.on = fp;
                    cell.accessoryView = fpSwitch;
                    if ([waypoint.account.remoteAPI commentSupportsFavouritePoint] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = currentTheme.labelTextColorDisabled;
                    } else {
                        [fpSwitch addTarget:self action:@selector(updateFPSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    break;
                }
                case SECTION_EXTRADETAILS_RATING: {
                    cell.keyLabel.text = @"Rating";
                    if ([waypoint.account.remoteAPI commentSupportsRating] == NO) {
                        cell.userInteractionEnabled = NO;
                        cell.keyLabel.textColor = currentTheme.labelTextColorDisabled;
                    } else {
                        NSRange r = waypoint.account.remoteAPI.commentSupportsRatingRange;
                        if (ratingSelected != 0)
                            cell.valueLabel.text = [NSString stringWithFormat:@"%ld out of %ld", (long)ratingSelected, (unsigned long)r.length];
                        else
                            cell.valueLabel.text = @"No rating selected";
                    }
                    break;
                }
                case SECTION_EXTRADETAILS_TRACKABLE:
                    cell = nil;
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE];
                    c.textLabel.text = @"Trackables";
                    if ([waypoint.account.remoteAPI commentSupportsTrackables] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    } else {
                        __block NSInteger visited = 0;
                        __block NSInteger discovered = 0;
                        __block NSInteger pickedup = 0;
                        __block NSInteger droppedoff = 0;
                        __block NSInteger noaction = 0;
                        [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
                            switch (tb.logtype) {
                                case TRACKABLE_LOG_NONE: noaction++; break;
                                case TRACKABLE_LOG_DISCOVER: discovered++; break;
                                case TRACKABLE_LOG_PICKUP: pickedup++; break;
                                case TRACKABLE_LOG_DROPOFF: droppedoff++; break;
                                case TRACKABLE_LOG_VISIT: visited++; break;
                                default: NSAssert1(NO, @"unknown logtype: %ld", (long)tb.logtype);
                            }
                        }];
                        NSMutableString *s = [NSMutableString stringWithString:@"Actions: "];
                        BOOL first = YES;
#define ACTION(__s__, __v__) \
    if (__v__ != 0) { \
        if (first == NO) \
            [s appendFormat:@", "]; \
        [s appendFormat: @"%ld %@", (long)__v__, __s__]; \
        first = NO; \
    }
                        ACTION(@"visited", visited);
                        ACTION(@"discovered", discovered);
                        ACTION(@"picked up", pickedup);
                        ACTION(@"dropped off", droppedoff);
                        if (first == YES)
                            [s appendString:@" none"];
                        c.detailTextLabel.text = s;
                    }
                    // Only place to return because the return format has changed.
                    return c;
            }
            break;
        }
        case SECTION_SUBMIT: {
            switch (indexPath.row) {
                case SECTION_SUBMIT_UPLOAD: {
                    cell.keyLabel.text = @"Upload";
                    GCSwitch *uploadSwitch = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    if (waypoint.account.canDoRemoteStuff == YES) {
                        uploadSwitch.on = upload;
                        [uploadSwitch addTarget:self action:@selector(updateUploadSwitch:) forControlEvents:UIControlEventTouchUpInside];
                        cell.userInteractionEnabled = YES;
                    } else {
                        uploadSwitch.on = NO;
                        cell.userInteractionEnabled = NO;
                    }
                    cell.accessoryView = uploadSwitch;
                    break;
                }
                case SECTION_SUBMIT_SUBMIT:
                    if (waypoint.account.canDoRemoteStuff == YES && upload == YES) {
                        cell.keyLabel.text = @"Submit";
                        cell.userInteractionEnabled = (note == nil || [note isEqualToString:@""] == YES) ? NO : YES;
                        cell.keyLabel.textColor = cell.userInteractionEnabled == YES ? [UIColor blackColor] : [UIColor lightGrayColor];
                        cell.keyLabel.textColor = cell.userInteractionEnabled == YES ? [currentTheme labelTextColor] : [currentTheme labelTextColorDisabled];
                    } else {
                        cell.keyLabel.text = @"Save";
                        cell.userInteractionEnabled = YES;
                        cell.keyLabel.textColor = [currentTheme labelTextColor];
                    }
                    break;
            }
            break;
        }
    }

    return cell;
}

- (void)updateFPSwitch:(GCSwitch *)s
{
    fp = s.on;
}

- (void)updateUploadSwitch:(GCSwitch *)s
{
    upload = s.on;
    [self.tableView reloadData];
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
                case SECTION_EXTRADETAILS_TRACKABLE:
                    [self changeTrackable];
                    break;
                case SECTION_EXTRADETAILS_RATING:
                    [self changeRating];
                    break;
            }
            break;
        }
        case SECTION_SUBMIT: {
            switch (indexPath.row) {
                case SECTION_SUBMIT_SUBMIT:
                    [self submitLog];
                    if (self.delegateWaypoint != nil)
                        [self.delegateWaypoint WaypointLog_refreshTable];
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
    __block NSInteger selected;
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:[logstrings count]];

    [logstrings enumerateObjectsUsingBlock:^(dbLogString *ls, NSUInteger idx, BOOL *stop) {
        if (ls == logstring)
            selected = idx;
        [as addObject:ls.text];
    }];
    [ActionSheetStringPicker
        showPickerWithTitle:@"Select a Logtype"
        rows:as
        initialSelection:selected
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            logstring = [logstrings objectAtIndex:selectedIndex];
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
    tv.maxCount = 4000;
    tv.text = note;

    [tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    note = text;
    [self.tableView reloadData];
}

- (void)imageSelected:(dbImage *)img caption:(NSString *)caption longtext:(NSString *)longtext;
{
    image = img;
    imageCaption = caption;
    imageLongText = longtext;
    [self.tableView reloadData];
}

- (void)changePhoto
{
    WaypointLogImagesViewController *newController = [[WaypointLogImagesViewController alloc] init:waypoint table:self.tableView];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegate = self;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

- (void)changeRating
{
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:5];
    NSRange r = waypoint.account.remoteAPI.commentSupportsRatingRange;
    [as addObject:@"No rating selected"];
    for (NSInteger i = r.location; i <= r.length; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld out of %lu", (long)i, (unsigned long)r.length]];
    }

    [ActionSheetStringPicker
     showPickerWithTitle:@"Select a Rating"
     rows:as
     initialSelection:ratingSelected
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
         ratingSelected = selectedIndex;
         [self.tableView reloadData];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
     }
     origin:self.view
     ];
}

- (void)changeTrackable
{
    WaypointLogTrackablesViewController *newController = [[WaypointLogTrackablesViewController alloc] init:waypoint trackables:trackables];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    newController.delegate = self;
}

- (void)submitLog
{
    // Do not upload, save it locally for later
    if (upload == NO) {
        [dbLog CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note needstobelogged:YES];
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

    [self performSelectorInBackground:@selector(submitLogBackground) withObject:nil];
}

- (void)submitLogBackground
{
    [menuGlobal enableMenus:NO];
    [MHTabBarController enableMenus:NO controllerFrom:self];

    [bezelManager showBezel:self];
    [bezelManager setText:@"Uploading log"];

    NSInteger retValue = [waypoint.account.remoteAPI CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note favourite:fp image:image imageCaption:imageCaption imageDescription:imageLongText rating:ratingSelected trackables:trackables infoViewer:nil ivi:0];

    [bezelManager removeBezel];

    if ([waypoint.account.remoteAPI commentSupportsTrackables] == YES) {
        [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tb.logtype == TRACKABLE_LOG_DROPOFF) {
                tb.logtype = TRACKABLE_LOG_NONE;
                tb.carrier_id = 0;
                tb.carrier = nil;
                tb.carrier_str = @"";
                tb.waypoint_name = waypoint.wpt_name;
            }
            if (tb.logtype == TRACKABLE_LOG_PICKUP) {
                tb.logtype = TRACKABLE_LOG_VISIT;
                tb.carrier_id = waypoint.account.accountname_id;
                tb.carrier = [dbName dbGet:tb.carrier_id];
                tb.carrier_str = tb.carrier.name;
                tb.waypoint_name = @"";
            }
            [tb dbUpdate];
        }];
    }

    [menuGlobal enableMenus:YES];
    [MHTabBarController enableMenus:YES controllerFrom:self];

    if (retValue == REMOTEAPI_OK) {
        dbLog *log = [dbLog CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note needstobelogged:NO];
        [log dbUpdate];

        if (configManager.loggingRemovesMarkedAsFoundDNF == YES) {
            waypoint.flag_markedfound = NO;
            waypoint.flag_dnf = NO;
            [waypoint dbUpdateMarkedDNF];
            [waypoint dbUpdateMarkedFound];
        }

        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointLog_refreshWaypointData];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [MyTools messageBox:self.parentViewController header:@"Log successful" text:@"This log has been successfully submitted."];

        return;
    } else {
        [MyTools messageBox:self header:@"Log failed" text:@"This log has not been submitted yet." error:waypoint.account.remoteAPI.lastError];
    }
}

@end
