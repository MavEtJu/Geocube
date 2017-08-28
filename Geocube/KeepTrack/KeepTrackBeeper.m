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

@interface KeepTrackBeeper ()
{
    CGRect rectButton;
    GCButton *button;

    BOOL isBeeping;
}

@end

@implementation KeepTrackBeeper

- (instancetype)init
{
    self = [super init];

    lmi = nil;
    isBeeping = NO;

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

    button = [GCButton buttonWithType:UIButtonTypeSystem];
    button.frame = rectButton;
    [button setTitle:_(@"keeptrackbeeper-Start beeping") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleBeeping:) forControlEvents:UIControlEventTouchDown];
    button.userInteractionEnabled = YES;
    [self.view addSubview:button];

    [self changeTheme];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    NSInteger height18 = bounds.size.height / 18;

    /*
     * +---------------------------------+
     * |       Current Coordinates       |
     * |           Curr Coords           |
     * |     Remembered Coordinates      |
     * |         Car coordinates         |
     * |                                 |
     * |         Distance: xxxx          |
     * |         Direction: xxx          |
     * |                                 |
     * |          Set as Target          |
     * |    Remember Current Location    |
     * |                                 |
     * +---------------------------------+
     */

    rectButton = CGRectMake(0, height - 5 * height18, width, height18);
}

- (void)viewWilltransitionToSize
{
    button.frame = rectButton;
}

- (void)toggleBeeping:(GCButton *)b
{
    isBeeping = !isBeeping;
    if (isBeeping == YES) {
        [self performSelectorInBackground:@selector(performBeeping) withObject:nil];
        [button setTitle:_(@"keeptrackbeeper-Stop beeping") forState:UIControlStateNormal];
    } else {
        [button setTitle:_(@"keeptrackbeeper-Start beeping") forState:UIControlStateNormal];
    }
}

- (void)performBeeping
{
    while (isBeeping == YES) {
        [MyTools playSound:PLAYSOUND_BEEPER];
        [NSThread sleepForTimeInterval:5.0];
    }
}

@end
