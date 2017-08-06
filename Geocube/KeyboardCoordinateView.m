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

@interface KeyboardCoordinateView ()
{
    BOOL isLatitude;

    UIButton *dirNorth, *dirEast, *dirSouth, *dirWest;
    UIButton *value[10];
    UIButton *buttonSpace, *buttonDot, *buttonDegree, *buttonBackspace;
}

@property (nonatomic, weak) UITextField <UITextInput> *targetTextInput;

@end

@implementation KeyboardCoordinateView

- (instancetype)initWithIsLatitude:(BOOL)_isLatitude
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 160)];

    isLatitude = _isLatitude;

    /*
     * +----------------------------------+
     * | North    0 1 2 3 4 5 6 7 8 9     |
     * | South        ⎵  .   °  ⌫        |
     * +----------------------------------+
     */

    NSInteger y = 3;

    if (isLatitude == YES) {
        dirNorth = [UIButton buttonWithType:UIButtonTypeSystem];
        dirNorth.frame = CGRectMake(0, y, 100, 80);
        [dirNorth setTitle:_(@"compass-north") forState:UIControlStateNormal];
        [dirNorth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:dirNorth];
        y += 80;

        dirSouth = [UIButton buttonWithType:UIButtonTypeSystem];
        dirSouth.frame = CGRectMake(0, y, 100, 80);
        [dirSouth setTitle:_(@"compass-south") forState:UIControlStateNormal];
        [dirSouth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:dirSouth];
        y += 80;
    } else {
        dirEast = [UIButton buttonWithType:UIButtonTypeSystem];
        dirEast.frame = CGRectMake(0, y, 100, 80);
        [dirEast setTitle:_(@"compass-east") forState:UIControlStateNormal];
        [dirEast addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:dirEast];
        y += 80;

        dirWest = [UIButton buttonWithType:UIButtonTypeSystem];
        dirWest.frame = CGRectMake(0, y, 100, 80);
        [dirWest setTitle:_(@"compass-west") forState:UIControlStateNormal];
        [dirWest addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:dirWest];
        y += 80;
    }

    y = 6;
    for (NSInteger i = 0; i < 5; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(100 + i * 40, y, 40, 48);
        [b setTitle:[NSString stringWithFormat:@"%lu", (long)i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:b];
        value[i] = b;
    }
    y += 48;

    for (NSInteger i = 5; i < 10; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(100 + (i - 5) * 40, y, 40, 48);
        [b setTitle:[NSString stringWithFormat:@"%ld", (long)i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickValue:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:b];
        value[i] = b;
    }

    NSInteger x = 100;
    y += 48;

    buttonSpace = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSpace.frame = CGRectMake(x, y, 40, 48);
    [buttonSpace setTitle:@"_" forState:UIControlStateNormal];
    [buttonSpace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:buttonSpace];
    x += 45;

    buttonDot = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDot.frame = CGRectMake(x, y, 40, 48);
    [buttonDot setTitle:@"." forState:UIControlStateNormal];
    [buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:buttonDot];
    x += 45;

    buttonDegree = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDegree.frame = CGRectMake(x, y, 40, 48);
    [buttonDegree setTitle:@"°" forState:UIControlStateNormal];
    [buttonDegree addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:buttonDegree];
    x += 45;

    buttonBackspace = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonBackspace.frame = CGRectMake(x, y, 40, 48);
    [buttonBackspace setTitle:@"⌫" forState:UIControlStateNormal];
    [buttonBackspace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:buttonBackspace];
    x += 45;

    [self addObservers];

    return self;
}

- (void)clickDirection:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    NSString *new = nil;

    if (b == dirNorth)
        new = _(@"compass-N");
    if (b == dirEast)
        new = _(@"compass-E");
    if (b == dirSouth)
        new = _(@"compass-S");
    if (b == dirWest)
        new = _(@"compass-W");
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
    for (NSInteger i = 0; i < 10; i++) {
        if (value[i] == b) {
            new = [NSString stringWithFormat:@"%ld", (long)i];
            break;
        }
    }
    if (new == nil)
        return;

    [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:new];
}

- (void)clickButton:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    if (b == buttonSpace)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@" "];
    if (b == buttonDot)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"."];
    if (b == buttonDegree)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"° "];

    if (b == buttonBackspace) {
        if (selectedTextRange.empty == YES && selectedTextRange.start != 0) {
            NSRange r = [self rangeForTextRange:selectedTextRange];
            r.location--;
            r.length = 1;
            selectedTextRange = [self textRangeForRange:r];
        }
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@""];
    }
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
