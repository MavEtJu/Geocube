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
    UIButton *value[10];
}

@property (nonatomic        ) BOOL isLatitude;

@property (nonatomic, retain) UIButton *dirNorth, *dirEast, *dirSouth, *dirWest;
@property (nonatomic, retain) UIButton *buttonSpace, *buttonDot, *buttonDegree, *buttonBackspace;

@property (nonatomic, weak) UITextField <UITextInput> *targetTextInput;

@end

@implementation KeyboardCoordinateView

- (instancetype)initWithIsLatitude:(BOOL)isLatitude
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 160)];

    self.isLatitude = isLatitude;

    /*
     * +----------------------------------+
     * | North    0 1 2 3 4 5 6 7 8 9     |
     * | South        ⎵  .   °  ⌫        |
     * +----------------------------------+
     */

    NSInteger y = 3;

    if (self.isLatitude == YES) {
        self.dirNorth = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dirNorth.frame = CGRectMake(0, y, 100, 80);
        [self.dirNorth setTitle:_(@"compass-north") forState:UIControlStateNormal];
        [self.dirNorth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.dirNorth];
        y += 80;

        self.dirSouth = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dirSouth.frame = CGRectMake(0, y, 100, 80);
        [self.dirSouth setTitle:_(@"compass-south") forState:UIControlStateNormal];
        [self.dirSouth addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.dirSouth];
        y += 80;
    } else {
        self.dirEast = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dirEast.frame = CGRectMake(0, y, 100, 80);
        [self.dirEast setTitle:_(@"compass-east") forState:UIControlStateNormal];
        [self.dirEast addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.dirEast];
        y += 80;

        self.dirWest = [UIButton buttonWithType:UIButtonTypeSystem];
        self.dirWest.frame = CGRectMake(0, y, 100, 80);
        [self.dirWest setTitle:_(@"compass-west") forState:UIControlStateNormal];
        [self.dirWest addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.dirWest];
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

    self.buttonSpace = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonSpace.frame = CGRectMake(x, y, 40, 48);
    [self.buttonSpace setTitle:@"_" forState:UIControlStateNormal];
    [self.buttonSpace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.buttonSpace];
    x += 45;

    self.buttonDot = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonDot.frame = CGRectMake(x, y, 40, 48);
    [self.buttonDot setTitle:@"." forState:UIControlStateNormal];
    [self.buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.buttonDot];
    x += 45;

    self.buttonDegree = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonDegree.frame = CGRectMake(x, y, 40, 48);
    [self.buttonDegree setTitle:@"°" forState:UIControlStateNormal];
    [self.buttonDegree addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.buttonDegree];
    x += 45;

    self.buttonBackspace = [UIButton buttonWithType:UIButtonTypeSystem];
    self.buttonBackspace.frame = CGRectMake(x, y, 40, 48);
    [self.buttonBackspace setTitle:@"⌫" forState:UIControlStateNormal];
    [self.buttonBackspace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.buttonBackspace];
    x += 45;

    [self addObservers];

    return self;
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

    if (b == self.buttonSpace)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@" "];
    if (b == self.buttonDot)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"."];
    if (b == self.buttonDegree)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"° "];

    if (b == self.buttonBackspace) {
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
