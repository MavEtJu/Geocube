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

@interface SettingsColourViewController ()

@property (nonatomic, retain) UIButton *chooseButton, *resetButton;
@property (nonatomic, retain) dbPin *pin;

@property (nonatomic, retain) UIImageView *previewColour;
@property (nonatomic, retain) UILabel *hexLabel;
@property (nonatomic, retain) NKOColorPickerView *colorPickerView;

@end

@implementation SettingsColourViewController

- (instancetype)init:(dbPin *)pin
{
    self = [super init];

    self.pin = pin;
    self.lmi = nil;

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
    l.text = self.pin.desc;
    [self.view addSubview:l];
    y += 20;

    /* Create pin data */

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *colour){
        self.pin.colour = colour;
        self.pin.rgb = [ImageManager ColorToRGB:colour];
        self.pin.img = [ImageManager newPinHead:colour];
        self.hexLabel.text = self.pin.rgb;
        self.previewColour.image = self.pin.img;
    };
    self.colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 340) color:self.pin.colour andDidChangeColorBlock:colorDidChangeBlock];
    [self.colorPickerView setColor:self.pin.colour];
    [self.view addSubview:self.colorPickerView];
    y += 340;

    UIImage *img = self.pin.img;
    self.previewColour = [[UIImageView alloc] initWithFrame:CGRectMake((15 + frame.size.width / 5 - img.size.width * 1.5) / 2, y, img.size.width * 1.5, img.size.height * 1.5)];
    self.previewColour.image = img;
    [self.view addSubview:self.previewColour];

    self.chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.chooseButton.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [self.chooseButton setTitle:_(@"settingscolourviewcontroller-Choose this colour") forState:UIControlStateNormal];
    [self.chooseButton addTarget:self action:@selector(chooseColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.chooseButton];
    y += 30;

    self.hexLabel = [[GCLabel alloc] initWithFrame:CGRectMake(5, y, 10 + frame.size.width / 5, 20)];
    self.hexLabel.text = self.pin.rgb;
    self.hexLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.hexLabel];

    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [self.resetButton setTitle:_(@"Reset") forState:UIControlStateNormal];
    [self.resetButton addTarget:self action:@selector(resetColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.resetButton];
    y += 30;

    contentView.contentSize = CGSizeMake(frame.size.width, y);
}

- (void)chooseColour
{
    NSString *hexString = [ImageManager ColorToRGB:self.pin.colour];

    self.pin.rgb = hexString;
    [self.pin dbUpdateRGB];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetColour
{
    self.pin.rgb = self.pin.rgb_default;
    [self.pin finish];
    [self.colorPickerView setColor:self.pin.colour];
}

@end
