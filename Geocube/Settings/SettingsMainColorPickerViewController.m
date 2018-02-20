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

@interface SettingsMainColorPickerViewController ()

@property (nonatomic        ) SettingsPicker type;
@property (nonatomic, retain) UIButton *chooseButton, *resetButton;
@property (nonatomic, retain) dbPin *dummyPin;
@property (nonatomic, retain) UIColor *currentColour;
@property (nonatomic, retain) UIImageView *previewColour;
@property (nonatomic, retain) UILabel *hexLabel;
@property (nonatomic, retain) NKOColorPickerView *colorPickerView;

@end

@implementation SettingsMainColorPickerViewController

- (instancetype)init:(SettingsPicker)type
{
    self = [super init];

    self.type = type;
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
    switch (self.type) {
        case SettingsMainColorPickerTrack:
            l.text = _(@"settingsmaincolorpickerviewcontroller-Track");
            self.currentColour = configManager.mapTrackColour;
            break;
        case SettingsMainColorPickerDestination:
            l.text = _(@"settingsmaincolorpickerviewcontroller-Destination");
            self.currentColour = configManager.mapDestinationColour;
            break;
        case SettingsMainColorPickerCircleRing:
            l.text = _(@"settingsmaincolorpickerviewcontroller-Boundary Circle Ring");
            self.currentColour = configManager.mapCircleRingColour;
            break;
        case SettingsMainColorPickerCircleFill:
            l.text = _(@"settingsmaincolorpickerviewcontroller-Boundary Circle Fill");
            self.currentColour = configManager.mapCircleFillColour;
            break;
        default:
            l.text = _(@"settingsmaincolorpickerviewcontroller-Wot?");
            break;
    }
    [self.view addSubview:l];
    y += 20;

    /* Create pin data */

    self.dummyPin = [[dbPin alloc] init];
    self.dummyPin.rgb_default = [ImageManager ColorToRGB:self.currentColour];
    [self.dummyPin finish];
    self.dummyPin.img = [ImageManager newPinHead:self.dummyPin.colour];

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *colour){
        self.dummyPin.img = [ImageManager newPinHead:colour];
        self.dummyPin.rgb = [ImageManager ColorToRGB:colour];
        self.hexLabel.text = self.dummyPin.rgb;
        self.currentColour = colour;
        self.previewColour.image = self.dummyPin.img;
    };
    self.colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 340) color:self.currentColour andDidChangeColorBlock:colorDidChangeBlock];
    [self.colorPickerView setColor:self.currentColour];
    [self.view addSubview:self.colorPickerView];
    y += 340;

    UIImage *img = self.dummyPin.img;
    self.previewColour = [[UIImageView alloc] initWithFrame:CGRectMake((15 + frame.size.width / 5 - img.size.width * 1.5) / 2, y, img.size.width * 1.5, img.size.height * 1.5)];
    self.previewColour.image = img;
    [self.view addSubview:self.previewColour];

    self.chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.chooseButton.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [self.chooseButton setTitle:_(@"settingsmaincolorpickerviewcontroller-Choose this colour") forState:UIControlStateNormal];
    [self.chooseButton addTarget:self action:@selector(chooseColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.chooseButton];
    y += 30;

    self.hexLabel = [[GCLabel alloc] initWithFrame:CGRectMake(5, y, 10 + frame.size.width / 5, 20)];
    self.hexLabel.text = self.dummyPin.rgb;
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
    NSString *hexString = [ImageManager ColorToRGB:self.currentColour];

    /* Write to database */
    switch (self.type) {
        case SettingsMainColorPickerTrack:
            [configManager mapTrackColourUpdate:hexString];
            break;
        case SettingsMainColorPickerDestination:
            [configManager mapDestinationColourUpdate:hexString];
            break;
        case SettingsMainColorPickerCircleRing:
            [configManager mapCircleRingColourUpdate:hexString];
            break;
        case SettingsMainColorPickerCircleFill:
            [configManager mapCircleFillColourUpdate:hexString];
            break;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetColour
{
    /* Reset the colour */
    switch (self.type) {
        case SettingsMainColorPickerTrack:
            [self.colorPickerView setColor:configManager.mapTrackColour];
            break;
        case SettingsMainColorPickerDestination:
            [self.colorPickerView setColor:configManager.mapDestinationColour];
            break;
        case SettingsMainColorPickerCircleRing:
            [self.colorPickerView setColor:configManager.mapCircleRingColour];
            break;
        case SettingsMainColorPickerCircleFill:
            [self.colorPickerView setColor:configManager.mapCircleFillColour];
            break;
    }
}

@end
