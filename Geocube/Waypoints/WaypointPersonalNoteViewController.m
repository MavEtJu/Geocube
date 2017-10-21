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

@interface WaypointPersonalNoteViewController ()
{
    dbWaypoint *waypoint;
    GCTextblock *l;
    YIPopupTextView *tv;
    dbPersonalNote *note;
}

@end

@implementation WaypointPersonalNoteViewController

enum {
    menuScanForWaypoints,
    menuCopyLog,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    self.delegateWaypoint = nil;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuScanForWaypoints label:_(@"waypointpersonalnoteviewcontroller-Extract waypoints")];
    [self.lmi addItem:menuCopyLog label:_(@"waypointpersonalnoteviewcontroller-Copy note to clipboard")];

    note = [dbPersonalNote dbGetByWaypointName:waypoint.wpt_name];

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

    l = [[GCTextblock alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 0)];
    l.text = note.note;
    [l sizeToFit];
    l.userInteractionEnabled = YES;

    CGRect frame = l.frame;
    frame.size.width = applicationFrame.size.width;
    l.frame = frame;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [l addGestureRecognizer:tapGestureRecognizer];

    [self.view addSubview:l];

    view.contentSize = l.frame.size;
    [self.view sizeToFit];

    if (l.text == nil || [l.text isEqualToString:@""] == YES)
        [self labelTapped];

    [self prepareCloseButton:self.view];
}

- (void)labelTapped
{
    tv = [[YIPopupTextView alloc] initWithPlaceHolder:_(@"waypointpersonalnoteviewcontroller-Enter your personal note here") maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    tv.delegate = self;
    tv.caretShiftGestureEnabled = YES;
    tv.text = l.text;

    [tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    l.text = text;
    [l sizeToFit];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    CGRect frame = l.frame;
    frame.size.width = applicationFrame.size.width;
    l.frame = frame;

    if (note == nil) {
        note = [[dbPersonalNote alloc] init];
        note.note = text;
        note.wp_name = waypoint.wpt_name;
        [note dbCreate];
    } else {
        note.note = text;
        [note dbUpdate];
    }
    BACKGROUND(updatePersonalNote, nil);

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointPersonalNote_refreshTable];
}

- (void)updatePersonalNote
{
    if ([waypoint.account.remoteAPI supportsWaypointPersonalNotes] == YES) {
        [bezelManager showBezel:self];
        [bezelManager setText:_(@"waypointpersonalnoteviewcontroller-Updating personal note")];
        if ([waypoint.account.remoteAPI updatePersonalNote:note infoViewer:nil iiDownload:0] != REMOTEAPI_OK) {
            [MyTools messageBox:self header:_(@"waypointpersonalnoteviewcontroller-Personal note") text:_(@"waypointpersonalnoteviewcontroller-Update of personal note has failed") error:waypoint.account.remoteAPI.lastError];
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
            [self.delegateWaypoint WaypointPersonalNote_refreshTable];
            return;
        case menuCopyLog:
            [self menuCopyLog];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)scanForWaypoints
{
    NSArray<NSString *> *lines = [note.note componentsSeparatedByString:@"\n"];
    [Coordinates scanForWaypoints:lines waypoint:waypoint view:self];
}

- (void)menuCopyLog
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = note.note;
    [MyTools messageBox:self header:_(@"waypointpersonalnoteviewcontroller-Copy successful") text:_(@"waypointpersonalnoteviewcontroller-The text of the personal note has been copied to the clipboard")];
}

@end
