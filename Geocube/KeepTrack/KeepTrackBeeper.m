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
    BOOL isBeeping;
    NSInteger interval;
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
    KeepTrackBeeperView *beepview = [[KeepTrackBeeperView alloc] initWithFrame:applicationFrame];
    beepview.delegate = self;
    self.view = beepview;
    [self.view sizeToFit];

    interval = configManager.keeptrackBeeperInterval;

    [self changeTheme];
}

- (void)buttonTestPressed
{
    [self testBeep];
}

- (void)buttonPlayPressed
{
    isBeeping = YES;
    BACKGROUND(performBeeping, nil);
}

- (void)buttonStopPressed
{
    isBeeping = NO;
}

- (void)sliderIntervalChanged:(float)value
{
    interval = value;
    [configManager keeptrackBeeperIntervalUpdate:interval];
}

- (void)performBeeping
{
    while (isBeeping == YES) {
        [audioManager playSound:PLAYSOUND_BEEPER];
        [NSThread sleepForTimeInterval:interval];
    }
}

- (void)testBeep
{
    [audioManager playSound:PLAYSOUND_BEEPER];
}

@end
