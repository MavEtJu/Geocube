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

@implementation SettingsColourViewController

- (instancetype)init:(dbType *)_type
{
    self = [super init];

    type = _type;

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

    rect = [[GCView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 10)];
    rect.backgroundColor = [UIColor greenColor];
    [self.view addSubview:rect];
    y += 10;

    NKOColorPickerDidChangeColorBlock colorDidChangeBlock = ^(UIColor *color){
        [rect setBackgroundColor:color];
    };
    NKOColorPickerView *colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 340) color:[UIColor blueColor] andDidChangeColorBlock:colorDidChangeBlock];
    y += 340;
    [self.view addSubview:colorPickerView];

    chose = [UIButton buttonWithType:UIButtonTypeSystem];
    chose.frame = CGRectMake(frame.size.width / 8, y, 3 * frame.size.width / 4, 20);
    [chose setTitle:@"Chose this colour" forState:UIControlStateNormal];
    [self.view addSubview:chose];
    y += 20;

    contentView.contentSize = CGSizeMake(frame.size.width, y);
}

@end
