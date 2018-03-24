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

@interface KeyboardCoordinateDegreesDecimalMinutes ()

@property (nonatomic, retain) IBOutlet UIButton *buttonDot, *buttonSpace;
@property (nonatomic, retain) IBOutlet UIButton *buttonDegrees, *buttonMinutes;
@property (nonatomic, retain) IBOutlet UIButton *buttonDirNE, *buttonDirSW;

@end

@implementation KeyboardCoordinateDegreesDecimalMinutes

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateDegreesDecimalMinutes"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    KEYBOARD_TARGET(buttonSpace, clickButton)
    KEYBOARD_TARGET(buttonDot, clickButton)
    KEYBOARD_TARGET(buttonMinutes, clickButton)
    KEYBOARD_TARGET(buttonDegrees, clickButton)
    KEYBOARD_TARGET(buttonDirNE, clickButton)
    KEYBOARD_TARGET(buttonDirSW, clickButton)

    [self addObservers];
}

- (void)showsLatitude:(BOOL)l
{
    [super showsLatitude:l];
    if (self.isLatitude == YES) {
        [self.buttonDirNE setTitle:@"N" forState:UIControlStateNormal];
        [self.buttonDirSW setTitle:@"S" forState:UIControlStateNormal];
    } else {
        [self.buttonDirNE setTitle:@"E" forState:UIControlStateNormal];
        [self.buttonDirSW setTitle:@"W" forState:UIControlStateNormal];
    }
}

- (void)clickButton:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    KEYBOARD_ACTION(buttonDot, @".")
    KEYBOARD_ACTION(buttonSpace, @" ")
    KEYBOARD_ACTION(buttonDegrees, @"°")
    KEYBOARD_ACTION(buttonMinutes, @"′")

    if (b == self.buttonDirNE) {
        [self textInput:self.targetTextInput replaceTextAtTextRange:[self textRangeForRange:NSMakeRange(0, 1)] withString:(self.isLatitude == YES) ? _(@"N") : _(@"E")];
        return;
    }
    if (b == self.buttonDirSW) {
        [self textInput:self.targetTextInput replaceTextAtTextRange:[self textRangeForRange:NSMakeRange(0, 1)] withString:(self.isLatitude == YES) ? _(@"S") : _(@"W")];
        return;
    }
    NSAssert(NO, @"clickButton");
}

@end
