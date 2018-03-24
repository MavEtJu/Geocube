//
//  KeyboardCoordinateDecimalDegreesSigned.m
//  Geocube
//
//  Created by Edwin Groothuis on 22/3/18.
//  Copyright © 2018 Edwin Groothuis. All rights reserved.
//


@interface KeyboardCoordinateDegreesMinutesSeconds ()

@property (nonatomic, retain) IBOutlet UIButton *buttonDot, *buttonSpace;
@property (nonatomic, retain) IBOutlet UIButton *buttonDegrees, *buttonMinutes, *buttonSeconds;
@property (nonatomic, retain) IBOutlet UIButton *buttonDirNE, *buttonDirSW;

@end

@implementation KeyboardCoordinateDegreesMinutesSeconds

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateDegreesMinutesSeconds"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    KEYBOARD_TARGET(buttonSpace, clickButton)
    KEYBOARD_TARGET(buttonDot, clickButton)
    KEYBOARD_TARGET(buttonSeconds, clickButton)
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
    KEYBOARD_ACTION(buttonSeconds, @"″")

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
