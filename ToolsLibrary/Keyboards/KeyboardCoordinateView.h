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

#define KEYBOARD_TARGET(__button__, __sel__) \
    [self.__button__ addTarget:self action:@selector(__sel__:) forControlEvents:UIControlEventTouchDown];

#define KEYBOARD_ACTION(__button__, __string__) \
    if (b == self.__button__) { \
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:__string__]; \
        return; \
    }

@interface KeyboardCoordinateView : UIView

@property (nonatomic, weak) UITextField <UITextInput> *targetTextInput;
@property (nonatomic, retain) KeyboardCoordinateView *firstView;

@property (nonatomic, retain) IBOutlet UIButton *buttonBackspace;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue0, *buttonValue1, *buttonValue2;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue3, *buttonValue4, *buttonValue5;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue6, *buttonValue7, *buttonValue8;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue9;

@property (nonatomic, readonly) BOOL isLatitude;

+ (KeyboardCoordinateView *)pickKeyboard:(CoordinatesType)coordType;

- (instancetype)initWithFrame:(CGRect)frame nibName:(NSString *)nibName;

- (void)showsLatitude:(BOOL)l;

- (void)addObservers;
- (void)textInput:(UITextField <UITextInput> *)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string;
- (UITextRange *)textRangeForRange:(NSRange)range;
- (NSRange)rangeForTextRange:(UITextRange *)textRange;

- (void)clickValue:(UIButton *)b;
- (void)clickBackspace:(UIButton *)b;

@end
