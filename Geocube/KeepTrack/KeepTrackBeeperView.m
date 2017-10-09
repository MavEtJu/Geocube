/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface KeepTrackBeeperView ()
{
    BOOL isPlaying;
}

@property (nonatomic, weak) IBOutlet GCLabel *labelHelp;
@property (nonatomic, weak) IBOutlet GCLabel *labelVolume;
@property (nonatomic, weak) IBOutlet GCLabel *labelInterval;
@property (nonatomic, weak) IBOutlet UISlider *sliderInterval;
@property (nonatomic, weak) IBOutlet MPVolumeView *sliderVolume;
@property (nonatomic, weak) IBOutlet GCButton *buttonTest;
@property (nonatomic, weak) IBOutlet GCButton *buttonPlayStop;

@property (nonatomic, retain) KeepTrackBeeperView *firstView;

@end

@implementation KeepTrackBeeperView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    isPlaying = NO;

    self.firstView = [[[NSBundle mainBundle] loadNibNamed:@"KeepTrackBeeperView" owner:self options:nil] firstObject];
    self.firstView.frame = frame;
    [self addSubview:self.firstView];

    self.firstView.sliderInterval.value = configManager.keeptrackBeeperInterval;

    self.firstView.labelInterval.text = [NSString stringWithFormat:_(@"keeptrackbeeperview-Interval between beeps: %ld seconds"), lroundf(self.firstView.sliderInterval.value)];
    self.firstView.labelVolume.text = _(@"keeptrackbeeperview-Volume");
    self.firstView.labelHelp.text = _(@"keeptrackbeeperview-After starting the beeping, place your phone on a stable location so that it doesn't slide away. The sound will guide you back to the phone once you need it.");
    [self.firstView.buttonTest setTitle:_(@"keeptrackbeeperview-Test Sound") forState:UIControlStateNormal];
    [self.firstView.buttonPlayStop setTitle:_(@"keeptrackbeeperview-Start beeping") forState:UIControlStateNormal];

    [self.firstView.buttonTest addTarget:self action:@selector(pressTest:) forControlEvents:UIControlEventTouchDown];
    [self.firstView.buttonPlayStop addTarget:self action:@selector(pressPlayStop:) forControlEvents:UIControlEventTouchDown];

    [self.firstView.sliderInterval addTarget:self action:@selector(sliderInterval:) forControlEvents:UIControlEventValueChanged];

    [self changeTheme];

    return self;
}

- (void)pressTest:(GCButton *)button
{
    [self.delegate buttonTestPressed];
}

- (void)pressPlayStop:(GCButton *)button
{
    isPlaying = !isPlaying;
    if (isPlaying == YES) {
        [self.firstView.buttonPlayStop setTitle:_(@"keeptrackbeeperview-Stop beeping") forState:UIControlStateNormal];
        [self.delegate buttonPlayPressed];
    } else {
        [self.firstView.buttonPlayStop setTitle:_(@"keeptrackbeeperview-Start beeping") forState:UIControlStateNormal];
        [self.delegate buttonStopPressed];
    }
}

- (void)sliderInterval:(UISlider *)slider
{
    self.firstView.labelInterval.text = [NSString stringWithFormat:_(@"keeptrackbeeperview-Interval between beeps: %ld seconds"), lroundf(self.firstView.sliderInterval.value)];
    [self.delegate sliderIntervalChanged:slider.value];
}

- (void)changeTheme
{
    [super changeTheme];
    self.firstView.backgroundColor = [currentTheme viewControllerBackgroundColor];
    self.sliderInterval.backgroundColor = [currentTheme viewControllerBackgroundColor];
    [self.firstView.labelVolume changeTheme];
    [self.firstView.labelHelp changeTheme];
    [self.firstView.labelInterval changeTheme];
    [self.firstView.buttonPlayStop changeTheme];
    [self.firstView.buttonTest changeTheme];

    self.firstView.labelVolume.font = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
    self.firstView.labelHelp.font = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
    self.firstView.labelInterval.font = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
}

@end
