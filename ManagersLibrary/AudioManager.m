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

@interface AudioManager ()
{
    AVAudioPlayer *audioPlayer;
}

@end

@implementation AudioManager

- (instancetype)init
{
    self = [super init];

    audioPlayer = nil;

    return self;
}

/// Play a sound file
- (void)playSoundFile:(NSString *)filename extension:(NSString *)extension
{
    /* Crappy way to do sound but will work for now */
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    audioPlayer.delegate = self;
    [audioPlayer play];
}

/// Play one of the defined sounds
- (void)playSound:(PlaySound)reason
{
    switch (reason) {
        case PLAYSOUND_IMPORTCOMPLETE:
            [self playSoundFile:@"Import Complete" extension:@"wav"];
            break;
        case PLAYSOUND_BEEPER:
            [self playSoundFile:@"Beeper" extension:@"wav"];
            break;
        case PLAYSOUND_MAX:
            break;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // Let others know that they can resume sound
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
