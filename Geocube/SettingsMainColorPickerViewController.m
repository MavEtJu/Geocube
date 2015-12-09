/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface SettingsMainColorPickerViewController ()
{
    NSInteger type;
    UIButton *chose, *reset;
    UIImageView *pin1;
    UIColor *pinColor;
    UIColor *chosenColor;
    NSString *hexString;
    UILabel *hexLabel;
    NKOColorPickerView *colorPickerView;
}

@end

@implementation SettingsMainColorPickerViewController

- (instancetype)init:(NSInteger)_type
{
    self = [super init];

    type = _type;
    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    NSInteger y = 10;

    GCScrollView *contentView = [[GCScrollView alloc] initWithFrame:frame];
    self.view = contentView;

    GCLabel *l = [[GCLabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 20)];
    switch (type) {
        case SettingsMainColorPickerTrack:
            l.text = @"Track";
            pinColor = myConfig.mapTrackColour;
            break;
        case SettingsMainColorPickerDestination:
            l.text = @"Destination";
            pinColor = myConfig.mapDestinationColour;
            break;
        default:
            l.text = @"Wot?";
            break;
    }
    [self.view addSubview:l];
    y += 20;

    /* Create pin data */
    [imageLibrary recreatePin:ImageMap_pinEdit color:pinColor];
    chosenColor = pinColor;
    hexString = [ImageLibrary ColorToRGB:pinColor];

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
        [imageLibrary recreatePin:ImageMap_pinEdit color:color];
        pin1.image = [imageLibrary get:ImageMap_pinEdit];
        hexString = [ImageLibrary ColorToRGB:color];
        hexLabel.text = hexString;
        chosenColor = color;
    };
    colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 340) color:pinColor andDidChangeColorBlock:colorDidChangeBlock];
    [colorPickerView setColor:pinColor];
    [self.view addSubview:colorPickerView];
    y += 340;

    UIImage *img = [imageLibrary get:ImageMap_pinEdit];
    pin1 = [[UIImageView alloc] initWithFrame:CGRectMake((15 + frame.size.width / 5 - img.size.width * 1.5) / 2, y, img.size.width * 1.5, img.size.height * 1.5)];
    pin1.image = [imageLibrary get:ImageMap_pinEdit];
    [self.view addSubview:pin1];

    chose = [UIButton buttonWithType:UIButtonTypeSystem];
    chose.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [chose setTitle:@"Chose this colour" forState:UIControlStateNormal];
    [chose addTarget:self action:@selector(choseColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:chose];
    y += 30;

    hexLabel = [[GCLabel alloc] initWithFrame:CGRectMake(5, y, 10 + frame.size.width / 5, 20)];
    hexLabel.text = hexString;
    hexLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:hexLabel];

    reset = [UIButton buttonWithType:UIButtonTypeSystem];
    reset.frame = CGRectMake(frame.size.width / 5, y, 3 * frame.size.width / 5, 20);
    [reset setTitle:@"Reset" forState:UIControlStateNormal];
    [reset addTarget:self action:@selector(resetColour) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reset];
    y += 30;

    contentView.contentSize = CGSizeMake(frame.size.width, y);
}

- (void)choseColour
{
    hexString = [ImageLibrary ColorToRGB:chosenColor];
    /* Write to database */

    switch (type) {
        case SettingsMainColorPickerTrack:
            [myConfig mapTrackColourUpdate:hexString];
            break;
        case SettingsMainColorPickerDestination:
            [myConfig mapDestinationColourUpdate:hexString];
            break;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetColour
{
    /* Reset the colour */
    switch (type) {
        case SettingsMainColorPickerTrack:
            [colorPickerView setColor:myConfig.mapTrackColour];
            break;
        case SettingsMainColorPickerDestination:
            [colorPickerView setColor:myConfig.mapDestinationColour];
            break;
    }
}

@end