/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

@interface ToolsRot13ViewController ()
{
    UITextView *labelInput;
    UITextView *labelOutput;
    GCButton *buttonClear;
    CGRect rectInput;
    CGRect rectOutput;
    CGRect rectButtonClear;
}

@end

@implementation ToolsRot13ViewController

- (instancetype)init
{
    self = [super init];

    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

    labelInput = [[UITextView alloc] initWithFrame:rectInput];
    labelInput.text = _(@"toolsrot13viewcontroller-Enter your text here...");
    labelInput.backgroundColor = [UIColor lightGrayColor];
    labelInput.delegate = self;
    [labelInput selectAll:self];
    [self.view addSubview:labelInput];

    labelOutput = [[UITextView alloc] initWithFrame:rectOutput];
    labelOutput.text = _(@"toolsrot13viewcontroller-Ragre lbhe grkg urer...");
    labelOutput.backgroundColor = [UIColor lightGrayColor];
    labelOutput.userInteractionEnabled = YES;
    labelOutput.delegate = self;
    [self.view addSubview:labelOutput];

    buttonClear = [GCButton buttonWithType:UIButtonTypeSystem];
    buttonClear.frame = rectButtonClear;
    [buttonClear setTitle:_(@"Clear") forState:UIControlStateNormal];
    [buttonClear addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchDown];
    buttonClear.userInteractionEnabled = YES;
    [self.view addSubview:buttonClear];

    [self changeTheme];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    NSInteger height36 = height / 36;

    /*
     * +---------------------------------+
     * | +-----------------------------+ |
     * | | Input                       | |
     * | |                             | |
     * | +-----------------------------+ |
     * | +-----------------------------+ |
     * | | Output                      | |
     * | |                             | |
     * | +-----------------------------+ |
     * | +-------+                       |
     * | | Clear |                       |
     * | +-------+                       |
     * +---------------------------------+
     */
#define BORDER  10

    rectInput = CGRectMake(BORDER, 1 * height36, width - 2 * BORDER, 6 * height36);
    rectOutput = CGRectMake(BORDER, 8 * height36, width - 2 * BORDER, 6 * height36);
    rectButtonClear = CGRectMake(BORDER, 15 * height36, width - 2 * BORDER, 1 * height36);
}

- (void)viewWilltransitionToSize
{
    labelInput.frame = rectInput;
    labelOutput.frame = rectOutput;
    buttonClear.frame = rectButtonClear;
}

- (void)clear:(UIButton *)b
{
    labelInput.text = @"";
    labelOutput.text = @"";
}

- (void)textViewDidChange:(UITextView *)textView
{
    labelOutput.text = [self rot13:labelInput.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == labelOutput)
        return NO;
    return YES;
}

- (NSString *)rot13:(NSString *)input
{
    NSString *rot13string = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableDictionary *rot13map = [NSMutableDictionary dictionaryWithCapacity:[rot13string length] * 2];

    for (NSInteger i = 0; i < [rot13string length]; i++) {
        [rot13map setObject:[rot13string substringWithRange:NSMakeRange((i + 13) % 26, 1)] forKey:[rot13string substringWithRange:NSMakeRange(i, 1)]];
        [rot13map setObject:[[rot13string substringWithRange:NSMakeRange((i + 13) % 26, 1)] uppercaseStringWithLocale:nil] forKey:[[rot13string substringWithRange:NSMakeRange(i, 1)] uppercaseStringWithLocale:nil]];
    }
    NSMutableString *output = [NSMutableString stringWithString:@""];

    for (NSInteger i = 0; i < [input length]; i++ ) {
        NSString *old = [input substringWithRange:NSMakeRange(i, 1)];
        NSString *new = [rot13map objectForKey:old];
        if (new == nil)
            [output appendString:old];
        else
            [output appendString:new];
    }
    return output;
}

@end
