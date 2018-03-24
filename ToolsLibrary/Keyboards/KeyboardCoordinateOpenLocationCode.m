//
//  KeyboardCoordinateDecimalDegreesSigned.m
//  Geocube
//
//  Created by Edwin Groothuis on 22/3/18.
//  Copyright © 2018 Edwin Groothuis. All rights reserved.
//


@interface KeyboardCoordinateOpenLocationCode ()

@property (nonatomic, retain) IBOutlet UIButton *buttonPlus;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueC, *buttonValueF, *buttonValueG;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueH, *buttonValueJ, *buttonValueM;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueP, *buttonValueQ, *buttonValueR;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueV, *buttonValueW, *buttonValueX;

// 0 2 3 4 5
// 6 7 8 9
// C F G H J
// M P Q R V
// W X   + ⌫

@end

@implementation KeyboardCoordinateOpenLocationCode

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateOpenLocationCode"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    KEYBOARD_TARGET(buttonPlus, clickButton)
    KEYBOARD_TARGET(buttonValueC, clickButton)
    KEYBOARD_TARGET(buttonValueF, clickButton)
    KEYBOARD_TARGET(buttonValueG, clickButton)
    KEYBOARD_TARGET(buttonValueH, clickButton)
    KEYBOARD_TARGET(buttonValueJ, clickButton)
    KEYBOARD_TARGET(buttonValueM, clickButton)
    KEYBOARD_TARGET(buttonValueP, clickButton)
    KEYBOARD_TARGET(buttonValueQ, clickButton)
    KEYBOARD_TARGET(buttonValueR, clickButton)
    KEYBOARD_TARGET(buttonValueV, clickButton)
    KEYBOARD_TARGET(buttonValueW, clickButton)
    KEYBOARD_TARGET(buttonValueX, clickButton)

    [self addObservers];
}

- (void)clickButton:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    KEYBOARD_ACTION(buttonPlus, @"+")
    KEYBOARD_ACTION(buttonValueC, @"C")
    KEYBOARD_ACTION(buttonValueF, @"F")
    KEYBOARD_ACTION(buttonValueG, @"G")
    KEYBOARD_ACTION(buttonValueH, @"H")
    KEYBOARD_ACTION(buttonValueJ, @"J")
    KEYBOARD_ACTION(buttonValueM, @"M")
    KEYBOARD_ACTION(buttonValueP, @"P")
    KEYBOARD_ACTION(buttonValueQ, @"Q")
    KEYBOARD_ACTION(buttonValueR, @"R")
    KEYBOARD_ACTION(buttonValueV, @"V")
    KEYBOARD_ACTION(buttonValueW, @"W")
    KEYBOARD_ACTION(buttonValueX, @"X")

    NSAssert(NO, @"clickButton");
}

@end
