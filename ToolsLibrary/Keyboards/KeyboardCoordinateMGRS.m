//
//  KeyboardCoordinateDecimalDegreesSigned.m
//  Geocube
//
//  Created by Edwin Groothuis on 22/3/18.
//  Copyright © 2018 Edwin Groothuis. All rights reserved.
//


@interface KeyboardCoordinateMGRS ()

@property (nonatomic, retain) IBOutlet UIButton *buttonSpace;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueA, *buttonValueB, *buttonValueC, *buttonValueD;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueE, *buttonValueF, *buttonValueG;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueH, *buttonValueI, *buttonValueJ, *buttonValueK;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueL, *buttonValueM, *buttonValueN;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueO, *buttonValueP, *buttonValueQ, *buttonValueR;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueS, *buttonValueT, *buttonValueU;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueV, *buttonValueW, *buttonValueX;
@property (nonatomic, retain) IBOutlet UIButton *buttonValueY, *buttonValueZ;

// 0 1 2 3 4
// 5 6 7 8 9
// A B C D E F G
// H I J K L M N
// O P Q R S T U
// V W X Y Z
// _           ⌫

@end

@implementation KeyboardCoordinateMGRS

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame nibName:@"KeyboardCoordinateMGRS"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    KEYBOARD_TARGET(buttonSpace, clickButton)
    KEYBOARD_TARGET(buttonValueA, clickButton)
    KEYBOARD_TARGET(buttonValueB, clickButton)
    KEYBOARD_TARGET(buttonValueC, clickButton)
    KEYBOARD_TARGET(buttonValueD, clickButton)
    KEYBOARD_TARGET(buttonValueE, clickButton)
    KEYBOARD_TARGET(buttonValueF, clickButton)
    KEYBOARD_TARGET(buttonValueG, clickButton)
    KEYBOARD_TARGET(buttonValueH, clickButton)
    KEYBOARD_TARGET(buttonValueI, clickButton)
    KEYBOARD_TARGET(buttonValueJ, clickButton)
    KEYBOARD_TARGET(buttonValueK, clickButton)
    KEYBOARD_TARGET(buttonValueL, clickButton)
    KEYBOARD_TARGET(buttonValueM, clickButton)
    KEYBOARD_TARGET(buttonValueN, clickButton)
    KEYBOARD_TARGET(buttonValueO, clickButton)
    KEYBOARD_TARGET(buttonValueP, clickButton)
    KEYBOARD_TARGET(buttonValueQ, clickButton)
    KEYBOARD_TARGET(buttonValueR, clickButton)
    KEYBOARD_TARGET(buttonValueS, clickButton)
    KEYBOARD_TARGET(buttonValueT, clickButton)
    KEYBOARD_TARGET(buttonValueU, clickButton)
    KEYBOARD_TARGET(buttonValueV, clickButton)
    KEYBOARD_TARGET(buttonValueW, clickButton)
    KEYBOARD_TARGET(buttonValueX, clickButton)
    KEYBOARD_TARGET(buttonValueY, clickButton)
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
    KEYBOARD_ACTION(buttonValueB, @"B")
    KEYBOARD_ACTION(buttonValueC, @"C")
    KEYBOARD_ACTION(buttonValueD, @"D")
    KEYBOARD_ACTION(buttonValueE, @"E")
    KEYBOARD_ACTION(buttonValueF, @"F")
    KEYBOARD_ACTION(buttonValueG, @"G")
    KEYBOARD_ACTION(buttonValueH, @"H")
    KEYBOARD_ACTION(buttonValueI, @"I")
    KEYBOARD_ACTION(buttonValueJ, @"J")
    KEYBOARD_ACTION(buttonValueK, @"K")
    KEYBOARD_ACTION(buttonValueL, @"L")
    KEYBOARD_ACTION(buttonValueM, @"M")
    KEYBOARD_ACTION(buttonValueN, @"N")
    KEYBOARD_ACTION(buttonValueO, @"O")
    KEYBOARD_ACTION(buttonValueP, @"P")
    KEYBOARD_ACTION(buttonValueQ, @"Q")
    KEYBOARD_ACTION(buttonValueR, @"R")
    KEYBOARD_ACTION(buttonValueS, @"S")
    KEYBOARD_ACTION(buttonValueT, @"T")
    KEYBOARD_ACTION(buttonValueU, @"U")
    KEYBOARD_ACTION(buttonValueV, @"V")
    KEYBOARD_ACTION(buttonValueW, @"W")
    KEYBOARD_ACTION(buttonValueX, @"X")
    KEYBOARD_ACTION(buttonValueY, @"Y")
    KEYBOARD_ACTION(buttonValueZ, @"Z")

    NSAssert(NO, @"clickButton");
}

@end
