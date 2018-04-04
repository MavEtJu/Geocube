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

@interface WaypointPersonalNoteViewController ()

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) GCTextblock *l;
@property (nonatomic, retain) YIPopupTextView *tv;
@property (nonatomic, retain) dbPersonalNote *note;

@end

@implementation WaypointPersonalNoteViewController

enum {
    menuScanForWaypoints,
    menuCopyLog,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)waypoint
{
    self = [super init];

    self.waypoint = waypoint;
    self.delegateWaypoint = nil;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuScanForWaypoints label:_(@"waypointpersonalnoteviewcontroller-Extract waypoints")];
    [self.lmi addItem:menuCopyLog label:_(@"waypointpersonalnoteviewcontroller-Copy note to clipboard")];

    self.note = [dbPersonalNote dbGetByWaypointName:self.waypoint.wpt_name];

    return self;
}

- (void)loadView
{
    self.hasCloseButton = YES;
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:applicationFrame];
    self.view = view;

    self.l = [[GCTextblock alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 0)];
    self.l.text = self.note.note;
    [self.l sizeToFit];
    self.l.userInteractionEnabled = YES;

    CGRect frame = self.l.frame;
    frame.size.width = applicationFrame.size.width;
    self.l.frame = frame;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.l addGestureRecognizer:tapGestureRecognizer];

    [self.view addSubview:self.l];

    view.contentSize = self.l.frame.size;
    [self.view sizeToFit];

    if (self.l.text == nil || [self.l.text isEqualToString:@""] == YES)
        [self labelTapped];

    [self prepareCloseButton:self.view];
}

- (void)labelTapped
{
    self.tv = [[YIPopupTextView alloc] initWithPlaceHolder:_(@"waypointpersonalnoteviewcontroller-Enter your personal note here") maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    self.tv.delegate = self;
    self.tv.caretShiftGestureEnabled = YES;
    self.tv.text = self.l.text;

    [self.tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    self.l.text = text;
    [self.l sizeToFit];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGRect frame = self.l.frame;
    frame.size.width = applicationFrame.size.width;
    self.l.frame = frame;

    if (self.note == nil) {
        self.note = [[dbPersonalNote alloc] init];
        self.note.note = text;
        self.note.wp_name = self.waypoint.wpt_name;
        [self.note dbCreate];
    } else {
        self.note.note = text;
        [self.note dbUpdate];
    }
    BACKGROUND(updatePersonalNote, nil);

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint waypointPersonalNoteRefreshTable];
}

- (void)updatePersonalNote
{
    if ([self.waypoint.account.remoteAPI supportsWaypointPersonalNotes] == YES) {
        [bezelManager showBezel:self];
        [bezelManager setText:_(@"waypointpersonalnoteviewcontroller-Updating personal note")];
        if ([self.waypoint.account.remoteAPI updatePersonalNote:self.note infoItem:nil] != REMOTEAPI_OK) {
            [MyTools messageBox:self header:_(@"waypointpersonalnoteviewcontroller-Personal note") text:_(@"waypointpersonalnoteviewcontroller-Update of personal note has failed") error:self.waypoint.account.remoteAPI.lastError];
        }
        [bezelManager removeBezel];
    }
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuScanForWaypoints:
            [self scanForWaypoints];
            [self.delegateWaypoint waypointPersonalNoteRefreshTable];
            return;
        case menuCopyLog:
            [self menuCopyLog];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)scanForWaypoints
{
    NSArray<NSString *> *lines = [self.note.note componentsSeparatedByString:@"\n"];
    [Coordinates scanForWaypoints:lines waypoint:self.waypoint view:self];
}

- (void)menuCopyLog
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.note.note;
    [MyTools messageBox:self header:_(@"waypointpersonalnoteviewcontroller-Copy successful") text:_(@"waypointpersonalnoteviewcontroller-The text of the personal note has been copied to the clipboard")];
}

@end
