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
    NSArray<dbLogString *> *logstrings;
    dbLogString *logstring;
    NSString *note;
    NSString *date;

    dbImage *image;
    NSString *imageCaption;
    NSString *imageLongText;

    NSMutableArray<dbTrackable *> *trackables;
    UIAlertAction *coordsOkButton;
    UITextField *coordsLatitude, *coordsLongitude;

    CLLocationCoordinate2D coordinates;
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
    SECTION_EXTRADETAILS_COORDINATES,
    SECTION_EXTRADETAILS_MAX,

    SECTION_SUBMIT_UPLOAD = 0,
    SECTION_SUBMIT_SUBMIT,
    SECTION_SUBMIT_MAX,
};

- (instancetype)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    fp = NO;
    upload = waypoint.account.remoteAPI.supportsLogging;
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    date = [dateFormatter stringFromDate:d];

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLRIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSWITCH bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLKEYVALUE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];

    self.hasCloseButton = YES;
    lmi = nil;

    return self;
}

- (void)importLog:(dbLog *)log
{
    note = log.log;
    date = log.datetime;
    logstring = log.logstring;
    [self reloadDataMainQueue];
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
    GCTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellStyleDefault;
    cell.accessoryView = nil;
    cell.userInteractionEnabled = YES;

    switch (indexPath.section) {
        case SECTION_LOGDETAILS: {
            switch (indexPath.row) {
                case SECTION_LOGDETAILS_TYPE: {
                    GCTableViewCellKeyValue *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];
                    c.keyLabel.text = @"Type";
                    c.valueLabel.text = logstring.text;
                    cell = c;
                    break;
                }

                case SECTION_LOGDETAILS_DATE: {
                    GCTableViewCellKeyValue *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];
                    c.keyLabel.text = @"Date";
                    c.valueLabel.text = date;
                    cell = c;
                    break;
                }

                case SECTION_LOGDETAILS_COMMENT: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = @"Comment";
                    c.detailTextLabel.text = note;
                    cell = c;
                    break;
                }
            }
            break;
        }

        case SECTION_EXTRADETAILS: {
            switch (indexPath.row) {
                case SECTION_EXTRADETAILS_PHOTO: {
                    GCTableViewCellRightImage *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE];
                    c.textLabel.text = @"Photo";
                    if (image != nil)
                        c.imageView.image = image.imageGet;
                    else
                        c.imageView.image = [imageLibrary get:Image_NoImageFile];
                    if ([waypoint.account.remoteAPI supportsLoggingPhotos] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_FAVOURITE: {
                    GCTableViewCellSwitch *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
                    c.textLabel.text = @"Favourite Point";
                    c.optionSwitch.on = fp;
                    if ([waypoint.account.remoteAPI supportsLoggingFavouritePoint] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    } else {
                        [c.optionSwitch addTarget:self action:@selector(updateFPSwitch:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_RATING: {
                    GCTableViewCellKeyValue *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];
                    c.keyLabel.text = @"Rating";
                    if ([waypoint.account.remoteAPI supportsLoggingRating] == NO) {
                        c.userInteractionEnabled = NO;
                        c.keyLabel.textColor = currentTheme.labelTextColorDisabled;
                        c.valueLabel.text = @"";
                    } else {
                        NSRange r = waypoint.account.remoteAPI.supportsLoggingRatingRange;
                        if (ratingSelected != 0)
                            c.valueLabel.text = [NSString stringWithFormat:@"%ld out of %ld", (long)ratingSelected, (unsigned long)r.length];
                        else
                            c.valueLabel.text = @"No rating selected";
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_TRACKABLE: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = @"Trackables";
                    if ([waypoint.account.remoteAPI supportsTrackables] == NO) {
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
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_COORDINATES: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = @"Coordinates";
                    if ([waypoint.account.remoteAPI supportsLoggingCoordinates] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    } else {
                        if (coordinates.latitude == 0 && coordinates.longitude == 0)
                            c.detailTextLabel.text = @"(None set)";
                        else
                            c.detailTextLabel.text = [Coordinates NiceCoordinates:coordinates];
                    }

                    cell = c;
                    break;
                }

            }
            break;
        }

        case SECTION_SUBMIT: {
            switch (indexPath.row) {
                case SECTION_SUBMIT_UPLOAD: {
                    GCTableViewCellSwitch *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
                    c.textLabel.text = @"Upload";
                    if (waypoint.account.remoteAPI.supportsLogging == YES && waypoint.account.canDoRemoteStuff == YES) {
                        c.optionSwitch.on = upload;
                        [c.optionSwitch addTarget:self action:@selector(updateUploadSwitch:) forControlEvents:UIControlEventTouchUpInside];
                        c.userInteractionEnabled = YES;
                    } else {
                        c.optionSwitch.on = NO;
                        c.userInteractionEnabled = NO;
                    }

                    cell = c;
                    break;
                }

                case SECTION_SUBMIT_SUBMIT:
                    if (waypoint.account.canDoRemoteStuff == YES && upload == YES) {
                        cell.textLabel.text = @"Submit";
                        cell.userInteractionEnabled = (note == nil || [note isEqualToString:@""] == YES) ? NO : YES;
                        cell.textLabel.textColor = cell.userInteractionEnabled == YES ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled;
                    } else {
                        cell.textLabel.text = @"Save";
                        cell.userInteractionEnabled = YES;
                        cell.textLabel.textColor = [currentTheme labelTextColor];
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
                case SECTION_EXTRADETAILS_COORDINATES:
                    [self changeCoordinates];
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
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:[logstrings count]];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LOGDETAILS_TYPE inSection:SECTION_LOGDETAILS]];

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
        origin:cell.contentView
    ];
}

- (void)changeCoordinates
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Update coordinates"
                                message:@"Please enter the coordinates"
                                preferredStyle:UIAlertControllerStyleAlert];

    coordsOkButton = [UIAlertAction
                      actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction *action) {
                          //Do Some action
                          UITextField *tf = [alert.textFields objectAtIndex:0];
                          NSString *lat = tf.text;
                          NSLog(@"Latitude '%@'", lat);

                          tf = [alert.textFields objectAtIndex:1];
                          NSString *lon = tf.text;
                          NSLog(@"Longitude '%@'", lon);

                          Coordinates *c;
                          c = [[Coordinates alloc] initString:lat lon:lon];
                          coordinates.latitude = c.lat;
                          coordinates.longitude = c.lon;

                          [self.tableView reloadData];
                      }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:coordsOkButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates NiceLatitudeForEditing:coordinates.latitude];
        textField.placeholder = @"Latitude (like S 12 34.567)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        coordsLatitude = textField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates NiceLongitudeForEditing:coordinates.longitude];
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        coordsLongitude = textField;
    }];

    if ([Coordinates checkCoordinate:coordsLatitude.text] == YES &&
        [Coordinates checkCoordinate:coordsLongitude.text] == YES)
        coordsOkButton.enabled = YES;
    else
        coordsOkButton.enabled = NO;

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    if ([Coordinates checkCoordinate:coordsLatitude.text] == YES &&
        [Coordinates checkCoordinate:coordsLongitude.text] == YES)
        coordsOkButton.enabled = YES;
    else
        coordsOkButton.enabled = NO;
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

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LOGDETAILS_DATE inSection:SECTION_LOGDETAILS]];

    ActionSheetDatePicker *asdp =
        [[ActionSheetDatePicker alloc]
         initWithTitle:@"Date" datePickerMode:UIDatePickerModeDate
         selectedDate:d
         minimumDate:minDate
         maximumDate:maxDate
         target:self
         action:@selector(dateWasSelected:element:)
         origin:cell.contentView];

    [asdp showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)d element:(UIButton *)b
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    date = [dateFormatter stringFromDate:d];
    [self.tableView reloadData];
}

- (void)changeNote
{
    WaypointLogEditViewController *newController = [[WaypointLogEditViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegate = self;
    newController.text = note;
    newController.waypoint = waypoint;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)didFinishEditing:(NSString *)text
{
    note = text;
    [self reloadDataMainQueue];
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
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:5];
    NSRange r = waypoint.account.remoteAPI.supportsLoggingRatingRange;
    [as addObject:@"No rating selected"];
    for (NSInteger i = r.location; i <= r.length; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld out of %lu", (long)i, (unsigned long)r.length]];
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_EXTRADETAILS_RATING inSection:SECTION_EXTRADETAILS]];

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
     origin:cell.contentView
     ];
}

- (void)changeTrackable
{
    if (waypoint.account.remoteAPI.supportsTrackables == YES && waypoint.account.canDoRemoteStuff == YES) {
        WaypointLogTrackablesViewController *newController = [[WaypointLogTrackablesViewController alloc] init:waypoint trackables:trackables];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController pushViewController:newController animated:YES];
        newController.delegate = self;
    }
}

- (void)submitLog
{
    // Do not upload, save it locally for later
    if (upload == NO) {
        [dbLog CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note needstobelogged:YES locallog:NO coordinates:coordinates];
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

    NSInteger retValue = [waypoint.account.remoteAPI CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note favourite:fp image:image imageCaption:imageCaption imageDescription:imageLongText rating:ratingSelected trackables:trackables coordinates:coordinates infoViewer:nil iiDownload:0];

    [bezelManager removeBezel];

    if ([waypoint.account.remoteAPI supportsTrackables] == YES) {
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
        dbLog *log = [dbLog CreateLogNote:logstring waypoint:waypoint dateLogged:date note:note needstobelogged:NO locallog:YES coordinates:coordinates];
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
