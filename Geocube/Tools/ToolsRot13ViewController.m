/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) UITextView *labelInput;
@property (nonatomic, retain) UITextView *labelOutput;
@property (nonatomic, retain) GCButton *buttonClear;
@property (nonatomic        ) CGRect rectInput;
@property (nonatomic        ) CGRect rectOutput;
@property (nonatomic        ) CGRect rectButtonClear;

@end

@implementation ToolsRot13ViewController

- (instancetype)init
{
    self = [super init];

    self.lmi = nil;

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

    self.labelInput = [[UITextView alloc] initWithFrame:self.rectInput];
    self.labelInput.text = _(@"toolsrot13viewcontroller-Enter your text here...");
    self.labelInput.backgroundColor = [UIColor lightGrayColor];
    self.labelInput.delegate = self;
    [self.labelInput selectAll:self];
    [self.view addSubview:self.labelInput];

    self.labelOutput = [[UITextView alloc] initWithFrame:self.rectOutput];
    self.labelOutput.text = _(@"toolsrot13viewcontroller-Ragre lbhe grkg urer...");
    self.labelOutput.backgroundColor = [UIColor lightGrayColor];
    self.labelOutput.userInteractionEnabled = YES;
    self.labelOutput.delegate = self;
    [self.view addSubview:self.labelOutput];

    self.buttonClear = [GCButton buttonWithType:UIButtonTypeSystem];
    self.buttonClear.frame = self.rectButtonClear;
    [self.buttonClear setTitle:_(@"Clear") forState:UIControlStateNormal];
    [self.buttonClear addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchDown];
    self.buttonClear.userInteractionEnabled = YES;
    [self.view addSubview:self.buttonClear];

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

    self.rectInput = CGRectMake(BORDER, 1 * height36, width - 2 * BORDER, 6 * height36);
    self.rectOutput = CGRectMake(BORDER, 8 * height36, width - 2 * BORDER, 6 * height36);
    self.rectButtonClear = CGRectMake(BORDER, 15 * height36, width - 2 * BORDER, 1 * height36);
}

- (void)viewWilltransitionToSize
{
    self.labelInput.frame = self.rectInput;
    self.labelOutput.frame = self.rectOutput;
    self.buttonClear.frame = self.rectButtonClear;
}

- (void)clear:(UIButton *)b
{
    self.labelInput.text = @"";
    self.labelOutput.text = @"";
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.labelOutput.text = [self rot13:self.labelInput.text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.labelOutput)
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
