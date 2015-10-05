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

// Returns the location where the files distibuted by the app will be installed for the user
+ (NSString *)ImagesDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/images/", [self DocumentRoot]];
    return s;
}

+ (struct timeval)timevalDifference:(struct timeval)t0 t1:(struct timeval)t1
{
    struct timeval ret;

    if (t0.tv_usec > t1.tv_usec) {
        ret.tv_usec = 1000000 + t1.tv_usec - t0.tv_usec;
        ret.tv_sec = t1.tv_sec - t0.tv_sec - 1;
    } else {
        ret.tv_usec = t1.tv_usec - t0.tv_usec;
        ret.tv_sec = t1.tv_sec - t0.tv_sec;
    }
    return ret;
}

+ (NSInteger)secondsSinceEpochWindows:(NSString *)datetime
{
    // /Date(1413702000000-0700)/
    return [[datetime substringFromIndex:6] integerValue] / 1000;
}

+ (NSDate *)dateFromISO8601String17:(NSString *)string {
    if (string == nil) {
        return nil;
    }

    struct tm tm;
    time_t t;

    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);

    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
}

+ (NSDate *)dateFromISO8601String10:(NSString *)string {
    if (string == nil) {
        return nil;
    }

    struct tm tm;
    time_t t;

    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%d", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);

    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
}

+ (NSInteger)secondsSinceEpoch:(NSString *)datetime
{
    NSDate *date;
    if ([datetime length] == 10) {
        date = [self dateFromISO8601String10:datetime];
    } else {
        date = [self dateFromISO8601String17:datetime];
    }
    return [date timeIntervalSince1970];
}

+ (NSString *)dateString:(NSInteger)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
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

+ (NSString *)stripHTML:(NSString *)l {
    NSRange r;
    NSString *s = l;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
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

+ (NSString *)niceTimeDifference:(NSInteger)i
{
    long diff = time(NULL) - i;

    if (diff < 60) {
        return [NSString stringWithFormat:@"%ld second%@ ago", diff, diff == 1 ? @"" : @"s"];
    }
    if (diff < 3600) {
        diff /= 60;
        return [NSString stringWithFormat:@"%ld minute%@ ago", diff, diff == 1 ? @"" : @"s"];
    }
    if (diff < 24 * 3600) {
        diff /= 3600;
        return [NSString stringWithFormat:@"%ld hour%@ ago", diff, diff == 1 ? @"" : @"s"];
    }
    if (diff < 7 * 24 * 3600) {
        diff /= 24 * 3600;
        return [NSString stringWithFormat:@"%ld day%@ ago", diff, diff == 1 ? @"" : @"s"];
    }
    if (diff < 365 * 24 * 3600) {
        diff /= 7 * 24 * 3600;
        return [NSString stringWithFormat:@"%ld week%@ ago", diff, diff == 1 ? @"" : @"s"];
    }
    diff /= 365 * 24 * 3600;
    return [NSString stringWithFormat:@"%ld year%@ ago", diff, diff == 1 ? @"" : @"s"];
}

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

+ (NSString *)urlEncode:(NSString *)in
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[in UTF8String];
    NSInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' ') {
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)urlDecode:(NSString *)in
{
    return [in stringByRemovingPercentEncoding];
}

+ (NSString *)tickEscape:(NSString *)in
{
    return [in stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

+ (NSString *)JSONEscape:(NSString *)in
{
    NSMutableString *s = [NSMutableString stringWithString:in];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

+ (NSString *)checkCoordinate:(NSString *)text
{
    // Don't check empty strings
    if ([text isEqualToString:@""] == YES)
        return text;

    // From now on things are working in three groups: Direction, first number, second number.

    // Make sure we have three groups:
    NSMutableArray *as = [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@" "]];
    while ([as count] > 3)
        [as removeObjectAtIndex:3];
    NSString *a0 = [as objectAtIndex:0];
    NSString *a1 = [as count] > 1 ? [as objectAtIndex:1] : nil;
    NSString *a2 = [as count] > 2 ? [as objectAtIndex:2] : nil;

    // The first object should only be one character long
    if ([a0 length] > 0) {
        if ([a0 length] > 2)
            a0 = [a0 substringToIndex:1];

        if ([a0 isEqualToString:@"3"] == YES)
            a0 = @"E";
        if ([a0 isEqualToString:@"6"] == YES)
            a0 = @"N";
        if ([a0 isEqualToString:@"7"] == YES)
            a0 = @"S";
        if ([a0 isEqualToString:@"9"] == YES)
            a0 = @"W";
        if ([a0 isEqualToString:@"N"] == NO &&
            [a0 isEqualToString:@"E"] == NO &&
            [a0 isEqualToString:@"S"] == NO &&
            [a0 isEqualToString:@"W"] == NO) {
            a0 = nil;
        }
    }

    if (a1 != nil && [a1 length] > 0) {
        // If there is a non-digit character, split the string there.
        NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSRange r = [a1 rangeOfCharacterFromSet:nonNumbers];
        if (r.location != NSNotFound) {
            a2 = [a1 substringFromIndex:r.location + 1];
            a1 = [a1 substringToIndex:r.location];
        }
    }

    if (a2 != nil && [a2 length] > 0) {
        // First character should be a digit.
        if ([[a2 substringToIndex:1] isEqualToString:@"."] == YES)
            a2 = @"";

        // Two periods? Throw away the rest.
        NSArray *ws = [a2 componentsSeparatedByString:@"."];
        if ([ws count] > 2)
            a2 = [NSString stringWithFormat:@"%@.%@", [ws objectAtIndex:0], [ws objectAtIndex:1]];
    }

    NSMutableString *a = [NSMutableString stringWithString:@""];
    if (a0 != nil) {
        [a appendString:a0];
        [a appendString:@" "];
    }

    if (a1 != nil)
        [a appendString:a1];

    if (a2 != nil) {
        [a appendString:@" "];
        [a appendString:a2];
    }

    return a;
}

- (void)toggleFlashLight:(BOOL)onoff
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    if (device.torchMode == AVCaptureTorchModeOff)
    {
        // Create an AV session
        AVCaptureSession *session = [[AVCaptureSession alloc] init];

        // Create device input and add to current session
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
        [session addInput:input];

        // Create video output and add to current session
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];

        // Start session configuration
        [session beginConfiguration];
        [device lockForConfiguration:nil];

        // Set torch to on
        [device setTorchMode:AVCaptureTorchModeOn];

        [device unlockForConfiguration];
        [session commitConfiguration];

        // Start the session
        [session startRunning];

        // Keep the session around
        AVSession = session;
    } else {
        [AVSession stopRunning];
        AVSession = nil;
    }
}

@end
