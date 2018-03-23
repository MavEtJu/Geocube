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

@interface KeyboardCoordinateView : UIView

@property (nonatomic, weak) UITextField <UITextInput> *targetTextInput;
@property (nonatomic, retain) UIView *firstView;

@property (nonatomic, retain) IBOutlet UIButton *buttonBackspace;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue0, *buttonValue1, *buttonValue2;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue3, *buttonValue4, *buttonValue5;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue6, *buttonValue7, *buttonValue8;
@property (nonatomic, retain) IBOutlet UIButton *buttonValue9;

+ (KeyboardCoordinateView *)pickKeyboard:(CoordinatesType)coordType;

- (instancetype)initWithFrame:(CGRect)frame nibName:(NSString *)nibName;

- (void)addObservers;
- (void)textInput:(UITextField <UITextInput> *)textInput replaceTextAtTextRange:(UITextRange *)textRange withString:(NSString *)string;
- (UITextRange *)textRangeForRange:(NSRange)range;
- (NSRange)rangeForTextRange:(UITextRange *)textRange;

- (void)clickValue:(UIButton *)b;
- (void)clickBackspace:(UIButton *)b;

@end
