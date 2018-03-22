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
{
    UIButton *value[10];
}

@property (nonatomic        ) BOOL isLatitude;

@property (nonatomic, retain) IBOutlet UIButton *dirNorth, *dirEast, *dirSouth, *dirWest;
@property (nonatomic, retain) IBOutlet UIButton *buttonSpace, *buttonDot, *buttonDegree;
@property (nonatomic, retain) IBOutlet UIButton *buttonBackspace, *buttonTick, *buttonDoubleTick;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue0, *buttonValue1, *buttonValue2;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue3, *buttonValue4, *buttonValue5;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue6, *buttonValue7, *buttonValue8;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue9;

@property (nonatomic, weak) UITextField <UITextInput> *targetTextInput;

@property (nonatomic, retain) UIView *firstView;

@end

@implementation KeyboardCoordinateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    self.firstView = [[[NSBundle mainBundle] loadNibNamed:@"KeyboardCoordinateView" owner:self options:nil] firstObject];
    self.firstView.frame = CGRectMake((frame.size.width - self.firstView.frame.size.width) / 2, 0, self.firstView.frame.size.width, self.firstView.frame.size.height);
    [self addSubview:self.firstView];

    return self;
}

- (instancetype)initWithIsLatitude:(BOOL)isLatitude
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    self = [self initWithFrame:CGRectMake(0, 0, width, 160)];

    self.isLatitude = isLatitude;

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

    [self.dirNorth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
    [self.dirSouth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
    [self.dirEast addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
    [self.dirWest addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue0 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue1 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue2 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue3 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue4 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue5 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue6 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue7 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue8 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonValue9 addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
    [self.buttonSpace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDegree addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonTick addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDoubleTick addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonBackspace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];

    [self addObservers];
}

- (void)clickDirection:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    NSString *new = nil;

    if (b == self.dirNorth)
        new = _(@"compass-N");
    if (b == self.dirEast)
        new = _(@"compass-E");
    if (b == self.dirSouth)
        new = _(@"compass-S");
    if (b == self.dirWest)
        new = _(@"compass-W");
    else
        NSAssert(NO, @"clickDirection");
    new = [NSString stringWithFormat:@"%@ ", new];

    UITextPosition *firstTP = [self.targetTextInput beginningOfDocument];

    UITextRange *firstCharacterRange;
    if ([self.targetTextInput.text length] > 1) {
        firstCharacterRange = [self.targetTextInput textRangeFromPosition:firstTP toPosition:[self.targetTextInput positionFromPosition:firstTP offset:2]];
    } else {
        firstCharacterRange = [self.targetTextInput textRangeFromPosition:firstTP toPosition:[self.targetTextInput positionFromPosition:firstTP offset:1]];
    }

    [self textInput:self.targetTextInput replaceTextAtTextRange:firstCharacterRange withString:new];
}

- (void)clickValue:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    NSString *new = nil;
    if (b == self.buttonValue0)
        new = @"0";
    else if (b == self.buttonValue1)
        new = @"1";
    else if (b == self.buttonValue2)
        new = @"2";
    else if (b == self.buttonValue3)
        new = @"3";
    else if (b == self.buttonValue4)
        new = @"4";
    else if (b == self.buttonValue5)
        new = @"5";
    else if (b == self.buttonValue6)
        new = @"6";
    else if (b == self.buttonValue7)
        new = @"7";
    else if (b == self.buttonValue8)
        new = @"8";
    else if (b == self.buttonValue9)
        new = @"9";
    else
        NSAssert(NO, @"clickValue");

    [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:new];
}

- (void)clickButton:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    if (b == self.buttonSpace)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@" "];
    else if (b == self.buttonDot)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"."];
    else if (b == self.buttonDegree)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"° "];
    else if (b == self.buttonBackspace) {
        if (selectedTextRange.empty == YES && selectedTextRange.start != 0) {
            NSRange r = [self rangeForTextRange:selectedTextRange];
            r.location--;
            r.length = 1;
            selectedTextRange = [self textRangeForRange:r];
        }
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@""];
    } else
        NSAssert(NO, @"clickButton");
}

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

@end
