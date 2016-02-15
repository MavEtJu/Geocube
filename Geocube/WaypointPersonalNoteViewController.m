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

- (instancetype)init:(dbWaypoint *)_waypoint
{
    self = [super init];

    waypoint = _waypoint;
    lmi = nil;
    hasCloseButton = YES;

    note = [dbPersonalNote dbGetByWaypointID:waypoint._id];

    return self;
}

- (void)loadView
{
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

}

@end
