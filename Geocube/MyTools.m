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

@interface MyTools ()
{
    struct timeval clock;
    BOOL clockEnabled;
    NSString *clockTitle;
}

@end

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

///////////////////////////////////////////

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

+ (NSDate *)dateFromISO8601String17:(NSString *)string
{
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

+ (NSDate *)dateFromISO8601String10:(NSString *)string
{
    if (string == nil)
        return nil;

    struct tm tm;
    time_t t;

    memset(&tm, '\0', sizeof(tm));

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

+ (NSString *)dateTimeString:(NSInteger)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)timeString:(NSInteger)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)datetimePartDate:(NSString *)datetime
{
    return [datetime substringToIndex:10];
}

+ (NSString *)datetimePartTime:(NSString *)datetime
{
    return [datetime substringWithRange:NSMakeRange(11, 8)];
}

///////////////////////////////////////////

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

+ (NSString *)stripHTML:(NSString *)l
{
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

///////////////////////////////////////////

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

+ (NSString *)niceDistance:(NSInteger)m
{
    return [MyTools niceDistance:m isMetric:myConfig.distanceMetric];
}

+ (NSString *)niceDistance:(NSInteger)m isMetric:(BOOL)isMetric
{
    if (isMetric == YES) {
        if (m < 1000)
            return [NSString stringWithFormat:@"%ld m", (long)m];
        if (m < 10000)
            return [NSString stringWithFormat:@"%0.2f km", m / 1000.0];
        return [NSString stringWithFormat:@"%ld km", (long)m / 1000];
    }

    /* Metric to imperial conversions
     * 1 mile is 1.6093 kilometers
     * 1 foot is 0.30480 meters
     *
     * From Darryl Wattenberg:
     * The norm is for miles down to 0.1 then switch to feet. The few apps that use yards get ridiculed for it.
     */
    if (m <= 161)   // 1/10th of a mile
        return [NSString stringWithFormat:@"%ld feet", (long)(m / 0.30480)];
    if (m <= 16093)   // 10 miles
        return [NSString stringWithFormat:@"%0.2f miles", m / 1609.3];
    return [NSString stringWithFormat:@"%ld miles", (long)(m / 1609.3)];
}

+ (NSString *)niceSpeed:(NSInteger)kmph
{
    return [MyTools niceSpeed:kmph isMetric:myConfig.distanceMetric];
}

+ (NSString *)niceSpeed:(NSInteger)kmph isMetric:(BOOL)isMetric
{
    if (isMetric == YES) {
        return [NSString stringWithFormat:@"%ld km/h", (long)kmph];
    } else {
        if (kmph / 1.6093 < 10)
            return [NSString stringWithFormat:@"%0.2f mph", (kmph / 1.6093)];
        else
            return [NSString stringWithFormat:@"%ld mph", (long)(kmph / 1.6093)];
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

+ (NSString *)niceCGRect:(CGRect)r
{
    return [NSString stringWithFormat:@"(%0.0f, %0.0f), (%0.0f x %0.0f)", r.origin.x, r.origin.y, r.size.width, r.size.height];
}

+ (NSString *)niceCGSize:(CGSize)s
{
    return [NSString stringWithFormat:@"(%0.0f x %0.0f)", s.width, s.height];
}

+ (NSString *)nicePercentage:(float)value
{
    return [NSString stringWithFormat:@"%0.2f%%", value];
}


///////////////////////////////////////////

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

///////////////////////////////////////////

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
    return [NSString stringWithString:s];
}

+ (NSString *)HTMLEscape:(NSString *)in
{
    if (in == nil)
        return @"";
    NSMutableString *s = [NSMutableString stringWithString:in];
    [s replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

+ (NSString *)HTMLUnescape:(NSString *)in
{
    if (in == nil)
        return @"";
    NSMutableString *s = [NSMutableString stringWithString:in];
    [s replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&ndash;" withString:@"–" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&#039;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

///////////////////////////////////////////

+ (BOOL)checkCoordinate:(NSString *)text
{
    // As long as it matches any of these, it is fine:
    // ^[NESW] \d{1,3}º? ?\d{1,2}\.\d{1,3}

    NSError *e = nil;
    NSRegularExpression *r5 = [NSRegularExpression regularExpressionWithPattern:@"^[NESW] +\\d{1,3}°? ?\\d{1,2}\\.\\d{1,3}$" options:0 error:&e];

    NSRange range;
    range = [r5 rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (range.location == 0) return YES;

    return NO;
}

///////////////////////////////////////////

+ (NSString *)makeNewWaypoint:(NSString *)prefix
{
    NSString *name;
    NSInteger i = 1;

    do {
        name = [NSString stringWithFormat:@"%@%06ld", prefix, (long)i++];
    } while ([dbWaypoint dbGetByName:name] != 0);

    return name;
}

///////////////////////////////////////////

+ (BOOL)hasWifiNetwork
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];

    switch (status) {
        case NotReachable:
            return NO;
        case ReachableViaWiFi:
            return YES;
        case ReachableViaWWAN:
            return NO;
    }
    return NO;
}

+ (BOOL)hasMobileNetwork
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];

    switch (status) {
        case NotReachable:
            return NO;
        case ReachableViaWiFi:
            return NO;
        case ReachableViaWWAN:
            return YES;
    }
    return NO;
}

+ (BOOL)hasAnyNetwork
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    [reachability stopNotifier];

    switch (status) {
        case NotReachable:
            return NO;
        case ReachableViaWiFi:
            return YES;
        case ReachableViaWWAN:
            return YES;
    }
    return NO;
}

///////////////////////////////////////////

+ (void)playSoundFile:(NSString *)filename extension:(NSString *)extension
{
    /* Crappy way to do sound but will work for now */
    NSURL *tapSound = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
    CFURLRef        soundFileURLRef;
    SystemSoundID   soundFileObject;

    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef)tapSound;

    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject );
    AudioServicesPlaySystemSound(soundFileObject);
}

+ (void)playSound:(NSInteger)reason
{
    switch (reason) {
        case playSoundImportComplete:
            [MyTools playSoundFile:@"Import Complete" extension:@"wav"];
            break;
    }
}

///////////////////////////////////////////

+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:header
                               message:text
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *close = [UIAlertAction
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];

    [alert addAction:close];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ALERT_VC_RVC(vc) presentViewController:alert animated:YES completion:nil];
    }];
}

+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text error:(NSString *)error
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:header
                               message:[NSString stringWithFormat:@"%@\nError: %@", text, error]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *close = [UIAlertAction
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];

    [alert addAction:close];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ALERT_VC_RVC(vc) presentViewController:alert animated:YES completion:nil];
    }];
}

///////////////////////////////////////////

// Obtained from https://forums.developer.apple.com/thread/11519
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr
{
    dispatch_semaphore_t    sem;
    __block NSData *        result;

    result = nil;

    sem = dispatch_semaphore_create(0);

    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
                                         dispatch_semaphore_signal(sem);
                                     }] resume];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return result;
}

///////////////////////////////////////////

+ (UIViewController *)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

@end
