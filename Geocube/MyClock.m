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

@interface MyClock ()
{
    struct timeval clock;
    BOOL clockEnabled;
    NSString *clockTitle;
}

@end

@implementation MyClock

- (instancetype)initClock:(NSString *)_title
{
    self = [super init];

    clockTitle = _title;
    gettimeofday(&clock, NULL);
    [self clockShowAndReset];

    return self;
}

- (void)clockShowAndReset
{
    [self clockShowAndReset:nil];
}

- (void)clockShowAndReset:(NSString *)title
{
    struct timeval now1, now, diff;
    gettimeofday(&now1, NULL);
    now = now1;
    if (now.tv_usec < clock.tv_usec) {
        now.tv_sec--;
        now.tv_usec += 1000000;
    }
    diff.tv_usec = now.tv_usec - clock.tv_usec;
    diff.tv_sec = now.tv_sec - clock.tv_sec;

    clock = now1;
    if (clockEnabled == NO)
        return;

    NSMutableString *t = [NSMutableString stringWithString:clockTitle];
    if (title != nil) {
        [t appendString:@":"];
        [t appendString:title];
    }
    NSLog(@"CLOCK: %@ %ld.%06d", t, diff.tv_sec, diff.tv_usec);
}

- (void)clockEnable:(BOOL)yesno
{
    clockEnabled = yesno;
}

@end
