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

@interface WaypointLogEditViewController ()
{
    YIPopupTextView *tv;
}

@end

@implementation WaypointLogEditViewController

enum {
    menuUseTemplate,
    menuInsertTemplate,
    menuSaveTemporary,
    menuUseTemporary,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUseTemplate label:@"Use Template"];
    [lmi addItem:menuInsertTemplate label:@"Insert Template"];
    [lmi addItem:menuSaveTemporary label:@"Save Temporary"];
    [lmi addItem:menuUseTemporary label:@"Use Temporary"];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    tv = [[YIPopupTextView alloc] initWithPlaceHolder:@"Enter your log here" maxCount:20000 buttonStyle:YIPopupTextViewButtonStyleRightCancelAndDone];

    tv.delegate = self;
    tv.caretShiftGestureEnabled = YES;
    tv.maxCount = 4000;
    tv.text = self.text;

    [tv showInViewController:self];
}

- (void)popupTextView:(YIPopupTextView *)textView didDismissWithText:(NSString *)text cancelled:(BOOL)cancelled
{
    if (cancelled == NO) {
        self.text = text;
        if (self.delegate != nil)
            [self.delegate didFinishEditing:text];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertTemplate
{
    NSArray<dbLogTemplate *> *lts = [dbLogTemplate dbAll];
    NSMutableArray<NSString *> *ltnames = [NSMutableArray arrayWithCapacity:20];
    [lts enumerateObjectsUsingBlock:^(dbLogTemplate * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
        [ltnames addObject:lt.name];
    }];

    [ActionSheetStringPicker
     showPickerWithTitle:@"Select a template"
                    rows:ltnames
        initialSelection:0
               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                   dbLogTemplate *lt = [lts objectAtIndex:selectedIndex];
                   NSMutableString *s = [NSMutableString stringWithString:tv.text];
                   [s insertString:lt.text atIndex:tv.selectedRange.location];
                   tv.text = s;
               }
               cancelBlock:^(ActionSheetStringPicker *picker) {
               }
               origin:self.view
     ];
}

- (void)useTemplate
{
    NSArray<dbLogTemplate *> *lts = [dbLogTemplate dbAll];
    NSMutableArray<NSString *> *ltnames = [NSMutableArray arrayWithCapacity:20];
    [lts enumerateObjectsUsingBlock:^(dbLogTemplate * _Nonnull lt, NSUInteger idx, BOOL * _Nonnull stop) {
        [ltnames addObject:lt.name];
    }];

    [ActionSheetStringPicker
     showPickerWithTitle:@"Select a template"
                    rows:ltnames
        initialSelection:0
               doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                   dbLogTemplate *lt = [lts objectAtIndex:selectedIndex];
                   tv.text = lt.text;
               }
               cancelBlock:^(ActionSheetStringPicker *picker) {
               }
               origin:self.view
     ];
}

- (void)saveTemporary
{
    [configManager logTemporaryTextUpdate:tv.text];
}

- (void)useTemporary
{
    tv.text = configManager.logTemporaryText;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuSaveTemporary:
            [self saveTemporary];
            return;
        case menuUseTemporary:
            [self useTemporary];
            return;
        case menuInsertTemplate:
            [self insertTemplate];
            return;
        case menuUseTemplate:
            [self useTemplate];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
