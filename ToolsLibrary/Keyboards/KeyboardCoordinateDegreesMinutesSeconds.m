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

    [self.buttonSpace addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDot addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonSeconds addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonMinutes addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDegrees addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDirNE addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDirSW addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];

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

    if (b == self.buttonDot)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"."];
    else if (b == self.buttonSpace)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@" "];
    else if (b == self.buttonDegrees)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"°"];
    else if (b == self.buttonMinutes)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"′"];
    else if (b == self.buttonSeconds)
        [self textInput:self.targetTextInput replaceTextAtTextRange:selectedTextRange withString:@"″"];
    else if (b == self.buttonDirNE) {
        [self textInput:self.targetTextInput replaceTextAtTextRange:[self textRangeForRange:NSMakeRange(0, 1)] withString:(self.isLatitude == YES) ? _(@"N") : _(@"E")];
    } else if (b == self.buttonDirSW) {
        [self textInput:self.targetTextInput replaceTextAtTextRange:[self textRangeForRange:NSMakeRange(0, 1)] withString:(self.isLatitude == YES) ? _(@"S") : _(@"W")];
    } else
        NSAssert(NO, @"clickButton");
}

@end
