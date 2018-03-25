/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) NSArray<dbLogString *> *logstrings;
@property (nonatomic, retain) dbLogString *logstring;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSString *date;

@property (nonatomic, retain) dbImage *image;
@property (nonatomic, retain) NSString *imageCaption;
@property (nonatomic, retain) NSString *imageLongText;

@property (nonatomic, retain) NSMutableArray<dbTrackable *> *trackables;
@property (nonatomic, retain) UIAlertAction *coordsOkButton;
@property (nonatomic, retain) UITextField *coordsField1;
@property (nonatomic, retain) UITextField *coordsField2;
@property (nonatomic        ) CoordinatesType coordType;

@property (nonatomic        ) CLLocationCoordinate2D coordinates;
@property (nonatomic        ) NSInteger ratingSelected;
@property (nonatomic        ) BOOL fp, upload;

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

- (instancetype)init:(dbWaypoint *)waypoint
{
    self = [super init];

    self.waypoint = waypoint;
    self.fp = NO;
    self.upload = self.waypoint.account.remoteAPI.supportsLogging;
    self.image = nil;
    self.ratingSelected = 0;
    self.delegateWaypoint = nil;
    self.coordType = configManager.coordinatesTypeEdit;

    LogStringWPType wptype = [dbLogString wptTypeToWPType:self.waypoint.wpt_type.type_full];
    self.logstrings = [dbLogString dbAllByProtocolWPType_LogOnly:self.waypoint.account.protocol wptype:wptype];
    [self.logstrings enumerateObjectsUsingBlock:^(dbLogString * _Nonnull ls, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ls.defaultFound == YES) {
            self.logstring = ls;
            *stop = YES;
        }
    }];

    self.trackables = [NSMutableArray arrayWithArray:[dbTrackable dbAllInventory]];

    NSDate *d = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    self.date = [dateFormatter stringFromDate:d];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLRIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSWITCH bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLKEYVALUE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];

    self.hasCloseButton = YES;
    self.lmi = nil;

    return self;
}

- (void)importLog:(dbLog *)log
{
    self.note = log.log;
    self.date = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:log.datetime_epoch];
    self.logstring = log.logstring;
    [self reloadDataMainQueue];
}

- (void)fakeLog
{
    self.note = @"Foo bar\nQuux";
    self.date = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:time(NULL)];
    [self submitLog];
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
        case SECTION_LOGDETAILS: return _(@"waypointlogviewcontroller-Log details");
        case SECTION_EXTRADETAILS: return _(@"waypointlogviewcontroller-Extra details");
        case SECTION_SUBMIT: return _(@"waypointlogviewcontroller-Submit");
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
                    c.keyLabel.text = _(@"waypointlogviewcontroller-Type");
                    NSString *s = [NSString stringWithFormat:@"logstring-%@", self.logstring.displayString];
                    c.valueLabel.text = _(s);
                    cell = c;
                    break;
                }

                case SECTION_LOGDETAILS_DATE: {
                    GCTableViewCellKeyValue *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];
                    c.keyLabel.text = _(@"waypointlogviewcontroller-Date");
                    c.valueLabel.text = self.date;
                    cell = c;
                    break;
                }

                case SECTION_LOGDETAILS_COMMENT: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = _(@"waypointlogviewcontroller-Comment");
                    c.detailTextLabel.text = self.note;
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
                    c.textLabel.text = _(@"waypointlogviewcontroller-Photo");
                    if (self.image != nil)
                        c.imageView.image = self.image.imageGet;
                    else
                        c.imageView.image = [imageManager get:Image_NoImageFile];
                    if ([self.waypoint.account.remoteAPI supportsLoggingPhotos] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_FAVOURITE: {
                    GCTableViewCellSwitch *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
                    c.textLabel.text = _(@"waypointlogviewcontroller-Favourite Point");
                    c.optionSwitch.on = self.fp;

                    BOOL supported = YES;
                    if ([self.waypoint.account.remoteAPI supportsLoggingFavouritePoint] == NO)
                        supported = NO;
                    if (self.waypoint.account.protocol._id == PROTOCOL_GGCW && configManager.loggingGGCWOfferFavourites == NO)
                        supported = NO;
                    if (self.waypoint.account.protocol._id == PROTOCOL_LIVEAPI && configManager.loggingGGCWOfferFavourites == NO)
                        supported = NO;

                    if (supported == NO) {
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
                    c.keyLabel.text = _(@"waypointlogviewcontroller-Rating");
                    if ([self.waypoint.account.remoteAPI supportsLoggingRating] == NO) {
                        c.userInteractionEnabled = NO;
                        c.keyLabel.textColor = currentTheme.labelTextColorDisabled;
                        c.valueLabel.text = @"";
                    } else {
                        NSRange r = self.waypoint.account.remoteAPI.supportsLoggingRatingRange;
                        if (self.ratingSelected != 0)
                            c.valueLabel.text = [NSString stringWithFormat:_(@"waypointlogviewcontroller-%ld out of %ld"), (long)self.ratingSelected, (unsigned long)r.length];
                        else
                            c.valueLabel.text = _(@"waypointlogviewcontroller-No rating selected");
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_TRACKABLE: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = _(@"waypointlogviewcontroller-Trackables");
                    if ([self.waypoint.account.remoteAPI supportsLoggingTrackables] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                        c.detailTextLabel.text = @"";
                    } else {
                        __block NSInteger visited = 0;
                        __block NSInteger discovered = 0;
                        __block NSInteger pickedup = 0;
                        __block NSInteger droppedoff = 0;
                        __block NSInteger noaction = 0;
                        [self.trackables enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
                            switch (tb.logtype) {
                                case TRACKABLE_LOG_NONE: noaction++; break;
                                case TRACKABLE_LOG_DISCOVER: discovered++; break;
                                case TRACKABLE_LOG_PICKUP: pickedup++; break;
                                case TRACKABLE_LOG_DROPOFF: droppedoff++; break;
                                case TRACKABLE_LOG_VISIT: visited++; break;
                                default: NSAssert1(NO, @"unknown logtype: %ld", (long)tb.logtype);
                            }
                        }];
                        NSMutableString *s = [NSMutableString stringWithString:_(@"waypointlogviewcontroller-Actions: ")];
                        BOOL first = YES;
#define ACTION(__s__, __v__) \
    if (__v__ != 0) { \
        if (first == NO) \
            [s appendFormat:@", "]; \
        [s appendFormat: @"%ld %@", (long)__v__, __s__]; \
        first = NO; \
    }
                        ACTION(_(@"waypointlogviewcontroller-visited"), visited);
                        ACTION(_(@"waypointlogviewcontroller-discovered"), discovered);
                        ACTION(_(@"waypointlogviewcontroller-picked up"), pickedup);
                        ACTION(_(@"waypointlogviewcontroller-dropped off"), droppedoff);
                        if (first == YES)
                            [s appendString:_(@"waypointlogviewcontroller-none")];
                        c.detailTextLabel.text = s;
                    }
                    cell = c;
                    break;
                }

                case SECTION_EXTRADETAILS_COORDINATES: {
                    GCTableViewCellWithSubtitle *c = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
                    c.textLabel.text = _(@"waypointlogviewcontroller-Coordinates");
                    if ([self.waypoint.account.remoteAPI supportsLoggingCoordinates] == NO) {
                        c.userInteractionEnabled = NO;
                        c.textLabel.textColor = currentTheme.labelTextColorDisabled;
                        c.detailTextLabel.text = @"";
                    } else {
                        if (self.coordinates.latitude == 0 && self.coordinates.longitude == 0)
                            c.detailTextLabel.text = _(@"waypointlogviewcontroller-(None set)");
                        else
                            c.detailTextLabel.text = [Coordinates niceCoordinates:self.coordinates];
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
                    c.textLabel.text = _(@"waypointlogviewcontroller-Upload");
                    if (self.waypoint.account.remoteAPI.supportsLogging == YES && self.waypoint.account.canDoRemoteStuff == YES) {
                        c.optionSwitch.on = self.upload;
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
                    if (self.waypoint.account.canDoRemoteStuff == YES && self.upload == YES) {
                        cell.textLabel.text = _(@"waypointlogviewcontroller-Submit");
                        cell.userInteractionEnabled = (IS_EMPTY(self.note) == YES) ? NO : YES;
                        cell.textLabel.textColor = cell.userInteractionEnabled == YES ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled;
                    } else {
                        cell.textLabel.text = _(@"Save");
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
    self.fp = s.on;
}

- (void)updateUploadSwitch:(GCSwitch *)s
{
    self.upload = s.on;
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
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:[self.logstrings count]];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LOGDETAILS_TYPE inSection:SECTION_LOGDETAILS]];

    [self.logstrings enumerateObjectsUsingBlock:^(dbLogString * _Nonnull ls, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ls == self.logstring)
            selected = idx;
        NSString *s = [NSString stringWithFormat:@"logstring-%@", ls.displayString];
        [as addObject:_(s)];
    }];
    [ActionSheetStringPicker
        showPickerWithTitle:_(@"waypointlogviewcontroller-Select a Logtype")
        rows:as
        initialSelection:selected
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.logstring = [self.logstrings objectAtIndex:selectedIndex];
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
                                alertControllerWithTitle:_(@"waypointlogviewcontroller-Update coordinates")
                                message:[NSString stringWithFormat:_(@"waypointlogviewcontroller-Please enter the coordinates.__Expected format: %@"), [Coordinates coordinateExample:self.coordType]]
                                preferredStyle:UIAlertControllerStyleAlert];

    self.coordsOkButton = [UIAlertAction
                      actionWithTitle:_(@"OK")
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction *action) {
                          //Do Some action
                          UITextField *tf = [alert.textFields objectAtIndex:0];
                          NSString *field1 = tf.text;
                          NSLog(@"Field 1: '%@'", field1);

                          tf = [alert.textFields objectAtIndex:1];
                          NSString *field2 = tf.text;
                          NSLog(@"Field 2: '%@'", field2);

                          Coordinates *c;
                          if (self.coordsField2 == nil)
                              c = [Coordinates parseCoordinatesWithString:field1 coordType:self.coordType];
                          else
                              c = [Coordinates parseCoordinatesWithString:[NSString stringWithFormat:@"%@ %@", field1, field2] coordType:self.coordType];
                          self.coordinates = CLLocationCoordinate2DMake(c.latitude, c.longitude);

                          [self.tableView reloadData];
                      }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *changeFormat = [UIAlertAction
                                   actionWithTitle:_(@"coordinates-Change Format") style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       self.coordType = (self.coordType + 1) % COORDINATES_MAX;
                                       [self changeCoordinates];
                                   }];


    [alert addAction:self.coordsOkButton];
    [alert addAction:changeFormat];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates niceLatitudeForEditing:self.coordinates.latitude coordType:self.coordType];
        textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", _(@"Latitude"), _(@"waypointaddviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
        KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
        [kb.firstView showsLatitude:YES];
        textField.inputView = kb;
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.coordsField1 = textField;
    }];

    self.coordsField2 = nil;
    if (self.coordType != COORDINATES_UTM &&
        self.coordType != COORDINATES_MGRS &&
        self.coordType != COORDINATES_OPENLOCATIONCODE) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = [Coordinates niceLongitudeForEditing:self.coordinates.longitude coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", _(@"Longitude"), _(@"waypointaddviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
            KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
            [kb.firstView showsLatitude:NO];
            textField.inputView = kb;
            [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.coordsField2 = textField;
        }];
    }

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    NSString *s;
    if (self.coordsField2 == nil)
        s = self.coordsField1.text;
    else
        s = [NSString stringWithFormat:@"%@ %@", self.coordsField1.text, self.coordsField2.text];
    if ([Coordinates checkCoordinate:s coordType:self.coordType] == YES)
        self.coordsOkButton.enabled = YES;
    else
        self.coordsOkButton.enabled = NO;
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
    self.date = [dateFormatter stringFromDate:d];
    [self.tableView reloadData];
}

- (void)changeNote
{
    WaypointLogEditViewController *newController = [[WaypointLogEditViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegate = self;
    newController.text = self.note;
    newController.waypoint = self.waypoint;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)didFinishEditing:(NSString *)text
{
    self.note = text;
    [self reloadDataMainQueue];
}

- (void)imageSelected:(dbImage *)img caption:(NSString *)caption longtext:(NSString *)longtext;
{
    self.image = img;
    self.imageCaption = caption;
    self.imageLongText = longtext;
    [self.tableView reloadData];
}

- (void)changePhoto
{
    WaypointLogImagesViewController *newController = [[WaypointLogImagesViewController alloc] init:self.waypoint table:self.tableView];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegate = self;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

- (void)changeRating
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:5];
    NSRange r = self.waypoint.account.remoteAPI.supportsLoggingRatingRange;
    [as addObject:_(@"waypointlogviewcontroller-No rating selected")];
    for (NSInteger i = r.location; i <= r.length; i++) {
        [as addObject:[NSString stringWithFormat:_(@"waypointlogviewcontroller-%ld out of %lu"), (long)i, (unsigned long)r.length]];
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_EXTRADETAILS_RATING inSection:SECTION_EXTRADETAILS]];

    [ActionSheetStringPicker
     showPickerWithTitle:_(@"waypointlogviewcontroller-Select a Rating")
     rows:as
     initialSelection:self.ratingSelected
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
         self.ratingSelected = selectedIndex;
         [self.tableView reloadData];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
     }
     origin:cell.contentView
     ];
}

- (void)changeTrackable
{
    if (self.waypoint.account.remoteAPI.supportsTrackablesLog == YES && self.waypoint.account.canDoRemoteStuff == YES) {
        WaypointLogTrackablesViewController *newController = [[WaypointLogTrackablesViewController alloc] init:self.waypoint trackables:self.trackables];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController pushViewController:newController animated:YES];
        newController.delegate = self;
    }
}

- (void)submitLog
{
    // Keep record of logged waypoints
    if (self.logstring.defaultFound == YES)
        [dbLogData addEntry:self.waypoint type:LOGDATATYPE_FOUND datetime:[MyTools secondsSinceEpochFromISO8601:self.date]];
    if (self.logstring.defaultDNF == YES)
        [dbLogData addEntry:self.waypoint type:LOGDATATYPE_DNF datetime:[MyTools secondsSinceEpochFromISO8601:self.date]];

    // Do not upload, save it locally for later
    if (self.upload == NO) {
        NSInteger date_epoch = [MyTools secondsSinceEpochFromISO8601:self.date];
        [dbLog CreateLogNote:self.logstring waypoint:self.waypoint dateLogged:date_epoch note:self.note needstobelogged:YES locallog:NO coordinates:self.coordinates];
        self.waypoint.logStatus = LOGSTATUS_FOUND;
        [self.waypoint dbUpdateLogStatus];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // Check length
    if ([self.note length] == 0) {
        [MyTools messageBox:self header:_(@"waypointlogviewcontroller-Please fill in the comment") text:_(@"waypointlogviewcontroller-Even TFTC is better than nothing at all.")];
        return;
    }

    self.note = [self replaceMacros:self.note];

    BACKGROUND(submitLogBackground, nil);
}

- (void)submitLogBackground
{
    [menuGlobal enableMenus:NO];
    [MHTabBarController enableMenus:NO controllerFrom:self];

    [bezelManager showBezel:self];
    [bezelManager setText:_(@"waypointlogviewcontroller-Uploading log")];

    NSInteger retValue = [self.waypoint.account.remoteAPI CreateLogNote:self.logstring waypoint:self.waypoint dateLogged:self.date note:self.note favourite:self.fp image:self.image imageCaption:self.imageCaption imageDescription:self.imageLongText rating:self.ratingSelected trackables:self.trackables coordinates:self.coordinates infoItem:nil];

    [bezelManager removeBezel];

    if ([self.waypoint.account.remoteAPI supportsTrackablesLog] == YES) {
        [self.trackables enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tb.logtype == TRACKABLE_LOG_DROPOFF) {
                tb.logtype = TRACKABLE_LOG_NONE;
                tb.carrier = nil;
                tb.waypoint_name = self.waypoint.wpt_name;
            }
            if (tb.logtype == TRACKABLE_LOG_PICKUP) {
                tb.logtype = TRACKABLE_LOG_VISIT;
                tb.carrier = [dbName dbGet:tb.carrier._id];
                tb.waypoint_name = @"";
            }
            [tb dbUpdate];
        }];
    }

    [menuGlobal enableMenus:YES];
    [MHTabBarController enableMenus:YES controllerFrom:self];

    if (retValue == REMOTEAPI_OK) {
        NSInteger date_epoch = [MyTools secondsSinceEpochFromISO8601:self.date];
        dbLog *log = [dbLog CreateLogNote:self.logstring waypoint:self.waypoint dateLogged:date_epoch note:self.note needstobelogged:NO locallog:YES coordinates:self.coordinates];
        [log dbUpdate];

        if (configManager.loggingRemovesMarkedAsFoundDNF == YES) {
            self.waypoint.flag_markedfound = NO;
            self.waypoint.flag_dnf = NO;
            [self.waypoint dbUpdateMarkedDNF];
            [self.waypoint dbUpdateMarkedFound];
        }

        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointLog_refreshWaypointData];

        MAINQUEUE(
            [self.navigationController popViewControllerAnimated:YES];
        )
        [MyTools messageBox:self.parentViewController header:_(@"waypointlogviewcontroller-Log successful") text:_(@"waypointlogviewcontroller-This log has been successfully submitted.")];

        return;
    } else {
        [MyTools messageBox:self header:_(@"waypointlogviewcontroller-Log failed") text:_(@"waypointlogviewcontroller-This log has not been submitted yet.") error:self.waypoint.account.remoteAPI.lastError];
    }
}

- (NSString *)replaceMacros:(NSString *)text
{
    NSMutableString *s = [NSMutableString stringWithString:text];
    NSString *old;

#define REPLACE(__macro__, __text__) \
    [s replaceOccurrencesOfString:[NSString stringWithFormat:@"%%%@%%", __macro__] withString:[NSString stringWithFormat:@"%@", __text__] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];

    NSInteger count = 0;

    do {
        old = text;

        REPLACE(@"waypoint.name", self.waypoint.wpt_urlname)
        REPLACE(@"waypoint.code", self.waypoint.wpt_name)
        REPLACE(@"waypoint.owner", self.waypoint.gs_owner.name)
        REPLACE(@"waypoint.ratingD", [NSNumber numberWithInteger:self.waypoint.gs_rating_difficulty])
        REPLACE(@"waypoint.ratingT", [NSNumber numberWithInteger:self.waypoint.gs_rating_terrain])

        dbListData *ld = [dbListData dbGetByWaypoint:self.waypoint flag:FLAGS_MARKEDFOUND];
        NSInteger foundtime;
        if (ld != nil)
            foundtime = ld.datetime;
        else
            foundtime = [MyTools secondsSinceEpochFromISO8601:self.date];
        REPLACE(@"found.time", [MyTools dateTimeString_hh_mm_ss:foundtime])
        REPLACE(@"found.date", [MyTools dateTimeString_YYYY_MM_DD:foundtime])
        REPLACE(@"found.datetime", [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:foundtime])
        REPLACE(@"found.dow", [MyTools dateTimeString_dow:foundtime])

        REPLACE(@"now.dow", [MyTools dateTimeString_dow])
        REPLACE(@"now.foundtime", [MyTools dateTimeString_hh_mm_ss])
        REPLACE(@"now.founddate", [MyTools dateTimeString_YYYY_MM_DD])
        REPLACE(@"now.founddatetime", [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss])

        REPLACE(@"cacher.name", self.waypoint.account.accountname.name)

        REPLACE(@"stats.found.today", [NSNumber numberWithInteger:[[dbLogData dbAllByType:LOGDATATYPE_FOUND datetime:time(NULL)] count]])
        REPLACE(@"stats.found.logdate", [NSNumber numberWithInteger:[[dbLogData dbAllByType:LOGDATATYPE_FOUND datetime:foundtime] count]])
        REPLACE(@"stats.dnf.today", [NSNumber numberWithInteger:[[dbLogData dbAllByType:LOGDATATYPE_DNF datetime:time(NULL)] count]])
        REPLACE(@"stats.dnf.logdate", [NSNumber numberWithInteger:[[dbLogData dbAllByType:LOGDATATYPE_DNF datetime:foundtime] count]])

        [[dbLogMacro dbAll] enumerateObjectsUsingBlock:^(dbLogMacro * _Nonnull macro, NSUInteger idx, BOOL * _Nonnull stop) {
            REPLACE(macro.name, macro.text)
        }];

        // Easy way to get out of (semi-)recursive definitions
        if (++count == 10)
            break;
    } while ([old isEqualToString:s] == NO);

    return s;
}

@end
