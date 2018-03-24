//
//  KeyboardCoordinateDecimalDegreesSigned.m
//  Geocube
//
//  Created by Edwin Groothuis on 22/3/18.
//  Copyright © 2018 Edwin Groothuis. All rights reserved.
//


@interface KeyboardCoordinateUTM ()

@property (nonatomic, retain) IBOutlet UIButton *buttonSpace;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueA, *buttonValueC, *buttonValueD;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueE, *buttonValueF, *buttonValueG;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueH, *buttonValueJ, *buttonValueK;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueL, *buttonValueM, *buttonValueN;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueP, *buttonValueQ, *buttonValueR;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueS, *buttonValueT, *buttonValueU;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueV, *buttonValueW, *buttonValueX;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueZ;

// 0 1 2 3 4
// 5 6 7 8 9
// A C D E F G
// H J K L M N
// P Q R S T U
// V W X Z
// _       ⌫

@end

@implementation KeyboardCoordinateUTM

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateUTM"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    KEYBOARD_TARGET(buttonSpace, clickButton)
    KEYBOARD_TARGET(buttonValueA, clickButton)
    KEYBOARD_TARGET(buttonValueC, clickButton)
    KEYBOARD_TARGET(buttonValueD, clickButton)
    KEYBOARD_TARGET(buttonValueE, clickButton)
    KEYBOARD_TARGET(buttonValueF, clickButton)
    KEYBOARD_TARGET(buttonValueG, clickButton)
    KEYBOARD_TARGET(buttonValueH, clickButton)
    KEYBOARD_TARGET(buttonValueJ, clickButton)
    KEYBOARD_TARGET(buttonValueK, clickButton)
    KEYBOARD_TARGET(buttonValueL, clickButton)
    KEYBOARD_TARGET(buttonValueM, clickButton)
    KEYBOARD_TARGET(buttonValueN, clickButton)
    KEYBOARD_TARGET(buttonValueP, clickButton)
    KEYBOARD_TARGET(buttonValueQ, clickButton)
    KEYBOARD_TARGET(buttonValueR, clickButton)
    KEYBOARD_TARGET(buttonValueS, clickButton)
    KEYBOARD_TARGET(buttonValueT, clickButton)
    KEYBOARD_TARGET(buttonValueU, clickButton)
    KEYBOARD_TARGET(buttonValueV, clickButton)
    KEYBOARD_TARGET(buttonValueW, clickButton)
    KEYBOARD_TARGET(buttonValueX, clickButton)
    KEYBOARD_TARGET(buttonValueZ, clickButton)

    [self addObservers];
}

- (void)clickButton:(UIButton *)b
{
    if (self.targetTextInput == nil)
        return;

    UITextRange *selectedTextRange = self.targetTextInput.selectedTextRange;
    if (selectedTextRange == nil)
        return;

    KEYBOARD_ACTION(buttonSpace, @" ")
    KEYBOARD_ACTION(buttonValueA, @"A")
    KEYBOARD_ACTION(buttonValueC, @"C")
    KEYBOARD_ACTION(buttonValueD, @"D")
    KEYBOARD_ACTION(buttonValueE, @"E")
    KEYBOARD_ACTION(buttonValueF, @"F")
    KEYBOARD_ACTION(buttonValueG, @"G")
    KEYBOARD_ACTION(buttonValueH, @"H")
    KEYBOARD_ACTION(buttonValueJ, @"J")
    KEYBOARD_ACTION(buttonValueK, @"K")
    KEYBOARD_ACTION(buttonValueL, @"L")
    KEYBOARD_ACTION(buttonValueM, @"M")
    KEYBOARD_ACTION(buttonValueN, @"N")
    KEYBOARD_ACTION(buttonValueP, @"P")
    KEYBOARD_ACTION(buttonValueQ, @"Q")
    KEYBOARD_ACTION(buttonValueR, @"R")
    KEYBOARD_ACTION(buttonValueS, @"S")
    KEYBOARD_ACTION(buttonValueT, @"T")
    KEYBOARD_ACTION(buttonValueU, @"U")
    KEYBOARD_ACTION(buttonValueV, @"V")
    KEYBOARD_ACTION(buttonValueW, @"W")
    KEYBOARD_ACTION(buttonValueX, @"X")
    KEYBOARD_ACTION(buttonValueZ, @"Z")

    NSAssert(NO, @"clickButton");
}

@end
