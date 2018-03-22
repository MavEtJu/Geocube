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

@property (nonatomic, retain) IBOutlet UIButton *buttonDot, *buttonMinus;

@end

@implementation KeyboardCoordinateDecimalDegreesSigned

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateDecimalDegreesSigned"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonMinus addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];

    [self addObservers];
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
    else
        NSAssert(NO, @"clickButton");
}

@end
