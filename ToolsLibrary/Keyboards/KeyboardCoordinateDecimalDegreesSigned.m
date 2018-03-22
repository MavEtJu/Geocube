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

@interface KeyboardCoordinateDecimalDegreesSigned ()

@property (nonatomic, retain) IBOutlet UIButton *buttonDot, *buttonBackspace, *buttonMinus;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue0, *buttonValue1, *buttonValue2;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue3, *buttonValue4, *buttonValue5;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue6, *buttonValue7, *buttonValue8;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue9;

@property (nonatomic, retain) UIView *firstView;

@end

@implementation KeyboardCoordinateDecimalDegreesSigned

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    self = [super initWithFrame:CGRectMake(0, 0, width, 160)];

    self.firstView = [[[NSBundle mainBundle] loadNibNamed:@"KeyboardCoordinateDecimalDegreesSigned" owner:self options:nil] firstObject];
    self.firstView.frame = CGRectMake((width - self.firstView.frame.size.width) / 2, 0, self.firstView.frame.size.width, self.firstView.frame.size.height);
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
    [self.buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonBackspace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonMinus addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];

    [self addObservers];
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

    if (b == self.buttonDot)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"."];
    else if (b == self.buttonMinus)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"-"];
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

@end
