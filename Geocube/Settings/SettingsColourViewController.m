/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface SettingsColourViewController ()
{
    UIButton *chooseButton, *resetButton;
    dbPin *pin;
//    UIColor *currentColour;
    UIImageView *previewColour;
    UILabel *hexLabel;
    NKOColorPickerView *colorPickerView;
}

@end

@implementation SettingsColourViewController

- (instancetype)init:(dbPin *)_pin
{
    self = [super init];

    pin = _pin;
    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = [[UIScreen mainScreen] bounds];
    NSInteger y = 10;

    GCScrollView *contentView = [[GCScrollView alloc] initWithFrame:frame];
    self.view = contentView;

    GCLabel *l = [[GCLabel alloc] initWithFrame:CGRectMake(10, y, frame.size.width, 20)];
    l.text = pin.desc;
    [self.view addSubview:l];
    y += 20;

    /* Create pin data */

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *colour){
        pin.colour = colour;
        pin.rgb = [ImageLibrary ColorToRGB:colour];
        pin.img = [ImageLibrary newPinHead:colour];
        hexLabel.text = pin.rgb;
        previewColour.image = pin.img;
    };
    colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 340) color:pin.colour andDidChangeColorBlock:colorDidChangeBlock];
    [colorPickerView setColor:pin.colour];
    [self.view addSubview:colorPickerView];
    y += 340;

    UIImage *img = pin.img;
    previewColour = [[UIImageView alloc] initWithFrame:CGRectMake((15 + frame.size.width / 5 - img.size.width * 1.5) / 2, y, img.size.width * 1.5, img.size.height * 1.5)];
    previewColour.image = img;
    [self.view addSubview:previewColour];

    chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    chooseButton.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [chooseButton setTitle:_(@"settingscolourviewcontroller-Choose this colour") forState:UIControlStateNormal];
    [chooseButton addTarget:self action:@selector(chooseColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:chooseButton];
    y += 30;

    hexLabel = [[GCLabel alloc] initWithFrame:CGRectMake(5, y, 10 + frame.size.width / 5, 20)];
    hexLabel.text = pin.rgb;
    hexLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hexLabel];

    resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [resetButton setTitle:_(@"Reset") forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:resetButton];
    y += 30;

    contentView.contentSize = CGSizeMake(frame.size.width, y);
}

- (void)chooseColour
{
    NSString *hexString = [ImageLibrary ColorToRGB:pin.colour];

    pin.rgb = hexString;
    [pin dbUpdateRGB];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetColour
{
    pin.rgb = pin.rgb_default;
    [pin finish];
    [colorPickerView setColor:pin.colour];
}

@end
