/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

@interface MyClock ()

@property (nonatomic        ) struct timeval clock;
@property (nonatomic        ) struct timeval clockStarted;
@property (nonatomic        ) BOOL clockEnabled;
@property (nonatomic, retain) NSString *clockTitle;

@end

@implementation MyClock

/**
 * Initalizes the clock with a certain prefix
 *
 * @param title Prefix to be used in logs
 * @return an MyClock object
 */
- (instancetype)initClock:(NSString *)title
{
    self = [super init];

    self.clockTitle = title;
    struct timeval clock;
    gettimeofday(&clock, NULL);
    self.clock = self.clockStarted = clock;
    [self clockShowAndReset];

    return self;
}

/// Displays the clock and resets to zero
- (void)clockShowAndReset
{
    [self clockShowAndReset:nil];
}

/**
 * Displays the clock and resets to zero
 *
 * @param suffix Extra text to be displayed before the time
 */
- (void)clockShowAndReset:(NSString *)suffix
{
    struct timeval now1, now, diff;
    gettimeofday(&now1, NULL);
    now = now1;
    if (now.tv_usec < self.clock.tv_usec) {
        now.tv_sec--;
        now.tv_usec += 1000000;
    }
    diff.tv_usec = now.tv_usec - self.clock.tv_usec;
    diff.tv_sec = now.tv_sec - self.clock.tv_sec;

    self.clock = now1;
    if (self.clockEnabled == NO)
        return;

    NSMutableString *t = [NSMutableString stringWithString:self.clockTitle];
    if (suffix != nil) {
        [t appendString:@":"];
        [t appendString:suffix];
    }
    NSLog(@"CLOCK: %@ %ld.%06d", t, diff.tv_sec, diff.tv_usec);
}

- (void)showTotal:(NSString *)suffix
{
    struct timeval now1, now, diff;
    gettimeofday(&now1, NULL);
    now = now1;
    if (now.tv_usec < self.clockStarted.tv_usec) {
        now.tv_sec--;
        now.tv_usec += 1000000;
    }
    diff.tv_usec = now.tv_usec - self.clockStarted.tv_usec;
    diff.tv_sec = now.tv_sec - self.clockStarted.tv_sec;

    NSMutableString *t = [NSMutableString stringWithString:self.clockTitle];
    if (suffix != nil) {
        [t appendString:@":"];
        [t appendString:suffix];
    }
    NSLog(@"CLOCK: %@ %ld.%06d", t, diff.tv_sec, diff.tv_usec);
}

/// Determine to show the clock or not when clockShowAndReset has been called
- (void)clockEnable:(BOOL)yesno
{
    self.clockEnabled = yesno;
}

@end
