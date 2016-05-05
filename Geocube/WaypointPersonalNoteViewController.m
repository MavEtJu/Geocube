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
    menuMax,
};

- (instancetype)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    self.delegateWaypoint = nil;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuScanForWaypoints label:@"Extract Waypoints"];

    note = [dbPersonalNote dbGetByWaypointID:waypoint._id];

    return self;
}

- (void)loadView
{
    hasCloseButton = YES;
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
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
}

- (void)labelTapped
{
    tv = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your personal note here" maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    tv.delegate = self;
    tv.caretShiftGestureEnabled = YES;
    tv.text = l.text;

    [tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView*)textView didDismissWithText:(NSString*)text cancelled:(BOOL)cancelled
{
    if (cancelled == YES)
        return;
    l.text = text;
    [l sizeToFit];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect frame = l.frame;
    frame.size.width = applicationFrame.size.width;
    l.frame = frame;

    if (note == nil) {
        note = [[dbPersonalNote alloc] init];
        note.note = text;
        note.waypoint_id = waypoint._id;
        note.wp_name = waypoint.wpt_name;
        [note dbCreate];
    } else {
        note.note = text;
        [note dbUpdate];
    }

    if ([waypoint.account.remoteAPI waypointSupportsPersonalNotes] == YES) {
        if ([waypoint.account.remoteAPI updatePersonalNote:note] == NO) {
            [MyTools messageBox:self header:@"Personal Note" text:@"Update of personal note has failed" error:waypoint.account.lastError];
        }
    }
    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint refreshView];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuScanForWaypoints:
            [self scanForWaypoints];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)scanForWaypoints
{
    NSError *e = nil;

    NSRegularExpression *rns = [NSRegularExpression regularExpressionWithPattern:@"([NSns] +\\d{1,3}[º°]? ?\\d{1,2}\\.\\d{1,3})" options:0 error:&e];
    NSRegularExpression *rew = [NSRegularExpression regularExpressionWithPattern:@"([EWew] +\\d{1,3}[º°]? ?\\d{1,2}\\.\\d{1,3})" options:0 error:&e];

    NSArray *lines = [note.note componentsSeparatedByString:@"\n"];
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *NS = nil;
        NSString *EW = nil;

        NSArray *matches = [rns matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match rangeAtIndex:1];
            NS = [line substringWithRange:range];
        }

        matches = [rew matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match rangeAtIndex:1];
            EW = [line substringWithRange:range];
        }

        if (NS != nil && EW != nil) {
            NSLog(@"%@ - %@", NS, EW);
            Coordinates *c = [[Coordinates alloc] initString:NS lon:EW];

            dbWaypoint *wp = [[dbWaypoint alloc] init:0];
            wp.wpt_lat = [c lat_decimalDegreesSigned];
            wp.wpt_lon = [c lon_decimalDegreesSigned];
            wp.wpt_lat_int = [c lat] * 1000000;
            wp.wpt_lon_int = [c lon] * 1000000;
            wp.wpt_name = [dbWaypoint makeName:[waypoint.wpt_name substringFromIndex:2]];
            wp.wpt_description = wp.wpt_name;
            wp.wpt_date_placed_epoch = time(NULL);
            wp.wpt_date_placed = [MyTools dateTimeString:wp.wpt_date_placed_epoch];
            wp.wpt_url = nil;
            wp.wpt_urlname = wp.wpt_name;
            wp.wpt_symbol_id = 1;
            wp.wpt_type_id = [dbc Type_Unknown]._id;
            [dbWaypoint dbCreate:wp];

            [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
            [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

            [waypointManager needsRefresh];

            [MyTools messageBox:self header:[NSString stringWithFormat:@"Imported %@", wp.wpt_name] text:@"Succesfully added this waypoint"];
        }
    }];

}

@end
