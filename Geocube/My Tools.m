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

#import <sys/time.h>
#import "Geocube-Prefix.pch"

@implementation MyTools

// Returns the location where the app can read and write to files
+ (NSString *)DocumentRoot
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // create path to theDirectory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

// Returns the location where the app has installed the various files
+ (NSString *)DataDistributionDirectory
{
    return [[NSBundle mainBundle] resourcePath];
}

// Returns the location where the files distibuted by the app will be installed for the user
+ (NSString *)FilesDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/files", [self DocumentRoot]];
    return s;
}

+ (NSInteger)secondsSinceEpoch:(NSString *)datetime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:[datetime substringWithRange:NSMakeRange(0, 19)]];
    return [date timeIntervalSince1970];
}

+ (NSString *)datetimePartDate:(NSString *)datetime {
    return [datetime substringToIndex:10];
}

+ (NSString *)datetimePartTime:(NSString *)datetime
{
    return [datetime substringWithRange:NSMakeRange(11, 8)];
}

+ (NSString *)simpleHTML:(NSString *)plainText
{
    if (plainText == nil)
        return @"";
    NSMutableString *s = [NSMutableString stringWithString:plainText];
    [s replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"<br>" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

+ (NSInteger)numberOfLines:(NSString *)s
{
    NSInteger lineNum = 0;
    NSInteger length = [s length];
    NSRange range = NSMakeRange(0, length);
    while (range.location < length) {
        range = [s lineRangeForRange:NSMakeRange(range.location, 0)];
        range.location = NSMaxRange(range);
        lineNum += 1;
    }
    return lineNum;
}

+ (NSString *)niceNumber:(NSInteger)i
{
    NSMutableString *sin = [NSMutableString stringWithFormat:@"%ld", (long)i];
    if (i < 1000)
        return sin;

    NSMutableString *sout = [NSMutableString stringWithString:@""];
    NSInteger l = [sin length];
    while (l > 0) {
        if ([sout length] != 0)
            [sout insertString:@" " atIndex:0];
        [sout insertString:[sin substringWithRange:NSMakeRange(l > 3 ? l - 3 : 0, l > 3 ? 3 : l)] atIndex:0];
        l -= 3;
    }
    return sout;
}

+ (NSString *)niceFileSize:(NSInteger)i
{
    if (i < 1024)
        return [NSString stringWithFormat:@"%ld bytes", (long)i];

    if (i < 10 * 1024 )
        return [NSString stringWithFormat:@"%0.1f Kb", i / 1024.0];

    if (i < 1024 * 1024 )
        return [NSString stringWithFormat:@"%ld Kb", (long)(i / 1024)];

    if (i < 10 * 1024 * 1024 )
        return [NSString stringWithFormat:@"%0.1f Mb", i / (1024.0 * 1024.0)];

    return [NSString stringWithFormat:@"%ld Mb", (long)(i / (1024 * 1024))];
}

+ (NSString *)NiceDistance:(NSInteger)i
{
    if (myConfig.distanceMetric == YES) {
        if (i < 1000)
            return [NSString stringWithFormat:@"%ld m", (long)i];
        if (i < 10000)
            return [NSString stringWithFormat:@"%0.2f km", i / 1000.0];
        return [NSString stringWithFormat:@"%ld km", (long)i / 1000];
    } else {
        /* Metric to imperial conversions
         * 1 mile is 1.6093 kilometers
         * 1 foot is 0.30480 meters
         */
        if (i <= 161)   // 1/10th of a mile
            return [NSString stringWithFormat:@"%ld feet", (long)(i / 0.30480)];
        if (i <= 16093)   // 10 miles
            return [NSString stringWithFormat:@"%0.2f miles", i / 1609.3];
        return [NSString stringWithFormat:@"%ld miles", (long)(i / 1609.3)];
    }

}

- (id)initClock:(NSString *)_title
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
    struct timeval now, diff;
    gettimeofday(&now, NULL);
    if (now.tv_usec < clock.tv_usec) {
        now.tv_sec--;
        now.tv_usec += 1000000;
    }
    diff.tv_usec = now.tv_usec - clock.tv_usec;
    diff.tv_sec = now.tv_sec - clock.tv_sec;

    clock = now;
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
