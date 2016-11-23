/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

    labelInput = [[UITextView alloc] initWithFrame:rectInput];
    labelInput.text = @"Enter your text here...";
    labelInput.backgroundColor = [UIColor lightGrayColor];
    labelInput.delegate = self;
    [labelInput selectAll:self];
    [self.view addSubview:labelInput];

    labelOutput = [[UITextView alloc] initWithFrame:rectOutput];
    labelOutput.text = @"Ragre lbhe grkg urer...";
    labelOutput.backgroundColor = [UIColor lightGrayColor];
    labelOutput.userInteractionEnabled = NO;
    [self.view addSubview:labelOutput];

    buttonClear = [GCButton buttonWithType:UIButtonTypeSystem];
    buttonClear.frame = rectButtonClear;
    [buttonClear setTitle:@"Clear" forState:UIControlStateNormal];
    [buttonClear addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchDown];
    buttonClear.userInteractionEnabled = YES;
    [self.view addSubview:buttonClear];
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

- (NSString *)rot13:(NSString *)input
{
    const char *in = [input cStringUsingEncoding:NSASCIIStringEncoding];
    NSInteger inlen = [input length];
    char out[inlen + 1];

    int x;
    for (x = 0; x < inlen; x++ ) {
        unsigned int aCharacter = in[x];

        if( 'A' <= aCharacter && aCharacter <= 'Z' ) // A - Z
            out[x] = (((aCharacter - 'A') + 13) % 26) + 'A';
        else if( 'a' <= aCharacter && aCharacter <= 'z' ) // a-z
            out[x] = (((aCharacter - 'a') + 13) % 26) + 'a';
        else  // Not a rot13-able character
            out[x] = aCharacter;
    }
    out[x] = '\0';

    NSString *output = [NSString stringWithCString:out encoding:NSASCIIStringEncoding];
    return (output);
}

@end
