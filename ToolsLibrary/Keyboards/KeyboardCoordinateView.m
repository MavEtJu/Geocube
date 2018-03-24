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

@interface KeyboardCoordinateView ()

@property (nonatomic) BOOL isLatitude;

@end

@implementation KeyboardCoordinateView

- (void)addObservers
{
    // Keep track of the textView/Field that we are editing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidBegin:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editingDidEnd:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

// Editing just began, store a reference to the object that just became the firstResponder
- (void)editingDidBegin:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[UIResponder class]]) {
        if ([notification.object conformsToProtocol:@protocol(UITextInput)]) {
            self.targetTextInput = notification.object;
            return;
        }
    }

    // Not a valid target for us to worry about.
    self.targetTextInput = nil;
}

// Editing just ended.
- (void)editingDidEnd:(NSNotification *)notification
{
    self.targetTextInput = nil;
}

// Replace the text of the textInput in textRange with string if the delegate approves
- (void)textInput:(UITextField <UITextInput> *)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string
{
    if (textInput != nil) {
        if (textRange != nil) {
            NSMutableString *s = [NSMutableString stringWithString:[textInput text]];
            [s replaceCharactersInRange:[self rangeForTextRange:textRange] withString:string];

            [textInput replaceRange:textRange withText:string];
        }
    }
}

- (UITextRange *)textRangeForRange:(NSRange)range
{
    UITextPosition *startPos = [self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:range.location];
    UITextPosition *endPos = [self.targetTextInput positionFromPosition:self.targetTextInput.beginningOfDocument offset:(range.location + range.length)];
    UITextRange *textRange = [self.targetTextInput textRangeFromPosition:startPos toPosition:endPos];
    return textRange;
}

//
// Calculate the location and length -> create NSRange
//
- (NSRange)rangeForTextRange:(UITextRange *)textRange
{
    NSUInteger location = [self.targetTextInput offsetFromPosition:self.targetTextInput.beginningOfDocument toPosition:textRange.start];
    NSUInteger length = [self.targetTextInput offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

// Various general functions

- (void)clickValue:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    KEYBOARD_ACTION(buttonValue0, @"0")
    KEYBOARD_ACTION(buttonValue1, @"1")
    KEYBOARD_ACTION(buttonValue2, @"2")
    KEYBOARD_ACTION(buttonValue3, @"3")
    KEYBOARD_ACTION(buttonValue4, @"4")
    KEYBOARD_ACTION(buttonValue5, @"5")
    KEYBOARD_ACTION(buttonValue6, @"6")
    KEYBOARD_ACTION(buttonValue7, @"7")
    KEYBOARD_ACTION(buttonValue8, @"8")
    KEYBOARD_ACTION(buttonValue9, @"9")

    NSAssert(NO, @"clickValue");
}

- (void)clickBackspace:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    if (b == self.buttonBackspace) {
        if (selectedTextRange.empty == YES && selectedTextRange.start != 0) {
            NSRange r = [self rangeForTextRange:selectedTextRange];
            r.location--;
            r.length = 1;
            selectedTextRange = [self textRangeForRange:r];
        }
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@""];
    } else
        NSAssert(NO, @"clickBackspace");
}

- (instancetype)initWithFrame:(CGRect)frame nibName:(NSString *)nibName
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];

    self.firstView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] firstObject];
    self.firstView.frame = CGRectMake((width - self.firstView.frame.size.width) / 2, 0, self.firstView.frame.size.width, self.firstView.frame.size.height);

    // Adjust to size of keyboard.
    self.frame = CGRectMake(0, 0, width, self.firstView.frame.size.height);

    [self addSubview:self.firstView];

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    /*
     * +----------------------------------+
     * | North    0 1 2 3 4 5 6 7 8 9     |
     * | South        ⎵  .   °  ⌫        |
     * +----------------------------------+
     */

    KEYBOARD_TARGET(buttonValue0, clickValue)
    KEYBOARD_TARGET(buttonValue1, clickValue)
    KEYBOARD_TARGET(buttonValue2, clickValue)
    KEYBOARD_TARGET(buttonValue3, clickValue)
    KEYBOARD_TARGET(buttonValue4, clickValue)
    KEYBOARD_TARGET(buttonValue5, clickValue)
    KEYBOARD_TARGET(buttonValue6, clickValue)
    KEYBOARD_TARGET(buttonValue7, clickValue)
    KEYBOARD_TARGET(buttonValue8, clickValue)
    KEYBOARD_TARGET(buttonValue9, clickValue)
    KEYBOARD_TARGET(buttonBackspace, clickBackspace)
}

- (void)showsLatitude:(BOOL)l
{
    self.isLatitude = l;
}

+ (KeyboardCoordinateView *)pickKeyboard:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [[KeyboardCoordinateDecimalDegreesCardinal alloc] initWithFrame:CGRectZero];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [[KeyboardCoordinateDecimalDegreesSigned alloc] initWithFrame:CGRectZero];
        case COORDINATES_DEGREES_MINUTES_SECONDS:
             return [[KeyboardCoordinateDegreesMinutesSeconds alloc] initWithFrame:CGRectZero];
        case COORDINATES_DEGREES_DECIMALMINUTES:
             return [[KeyboardCoordinateDegreesDecimalMinutes alloc] initWithFrame:CGRectZero];
        case COORDINATES_OPENLOCATIONCODE:
             return [[KeyboardCoordinateOpenLocationCode alloc] initWithFrame:CGRectZero];
        case COORDINATES_UTM:
             return [[KeyboardCoordinateUTM alloc] initWithFrame:CGRectZero];
        case COORDINATES_MGRS:
            // return [[KeyboardCoordinateMGRS alloc] initWithFrame:CGRectZero];
        case COORDINATES_MAX:
            NSAssert(FALSE, @"coordType");
    }
    return nil;
}

@end
