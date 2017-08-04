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

#import <sys/time.h>
@interface MyTools ()

@end

@implementation MyTools

/// Returns the location where the app can read and write to files
+ (NSString *)DocumentRoot
{
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // create path to theDirectory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)ApplicationSupportRoot
{
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    // create path to theDirectory
    NSString *apsupDirectory = [paths objectAtIndex:0];
    return apsupDirectory;
}

/// Returns the location where the app has installed the various files
+ (NSString *)DataDistributionDirectory
{
    return [[NSBundle mainBundle] resourcePath];
}

/// Returns the location where the files distibuted by the app will be installed for the user
+ (NSString *)FilesDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/files", [self DocumentRoot]];
    return s;
}

/// Returns the location where the images downloaded will be
+ (NSString *)ImagesDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/images", [self ApplicationSupportRoot]];
    return s;
}
+ (NSString *)OldImagesDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/images", [self DocumentRoot]];
    return s;
}

/// Returns the location where the mapcache will be
+ (NSString *)MapCacheDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/MapCache", [self ApplicationSupportRoot]];
    return s;
}
+ (NSString *)OldMapCacheDir
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/MapCache", [self DocumentRoot]];
    return s;
}

/// Returns the location where a downloaded image will be
+ (NSString *)ImageFile:(NSString *)imgFile;
{
    NSString *s = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@",
                   [self ImagesDir],
                   [imgFile substringWithRange:NSMakeRange(0, 1)],
                   [imgFile substringWithRange:NSMakeRange(1, 1)],
                   imgFile
                   ];
    return s;
}

+ (NSInteger)determineDirectorySize:(NSString *)path
{
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:path];
    NSString *file;
    NSInteger size = 0;
    while ((file = [dirEnum nextObject])) {
        NSDictionary<NSFileAttributeKey,id> *d = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file] error:nil];
        size += [[d objectForKey:NSFileSize] integerValue];
    }
    return size;
}

///////////////////////////////////////////

/// Returns the difference between t1 and t0
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

/**
 * Return the number of seconds since Epoch from a Windows epoch string
 * The Windows string is in the format of "/Date(1413702000000-0700)/"
 *
 * @param datatime The windows epoch string
 * @return The Unix epoch string
 */
+ (NSInteger)secondsSinceEpochFromWindows:(NSString *)datetime
{
    // /Date(1413702000000-0700)/
    return (NSInteger)([[datetime substringFromIndex:6] longLongValue] / 1000);
}

/**
 * Return the NSDate object from an ISO8601 string
 *
 * @param string The ISO8601 string
 * @param format The format of the ISO8601 string
 * @return The NSData object
 */
+ (NSDate *)dateFromISO8601String:(NSString *)string format:(char *)format
{
    if (string == nil)
        return nil;

    struct tm tm;
    memset(&tm, 0, sizeof(struct tm));
    time_t t;

    strptime([string cStringUsingEncoding:NSUTF8StringEncoding], format, &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);

    return [NSDate dateWithTimeIntervalSince1970:t];
}

/// Returns the number of milliseconds for the current time
+ (long long)millisecondsSinceEpoch
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + (tv.tv_usec / 1000);
}

/**
 * Analyze the datetime string and return the epoch value for it.
 * The string can be YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ
 *
 * @param datetime The datetime string
 * @return Number of seconds since epoch for the given datetime string
 */
+ (NSInteger)secondsSinceEpochFromISO8601:(NSString *)datetime
{
    NSDate *date;
    if ([datetime length] == 10) {
        date = [MyTools dateFromISO8601String:datetime format:"%Y-%m-%d"];
    } else if ([datetime containsString:@"T"] == YES) {
        date = [MyTools dateFromISO8601String:datetime format:"%Y-%m-%dT%H:%M:%S%z"];
    } else {
        date = [MyTools dateFromISO8601String:datetime format:"%Y-%m-%d %H:%M:%S%z"];
    }
    return [date timeIntervalSince1970];
}

/**
 * Returns the datetime string for the specified epoch time
 *
 * @param seconds The number of seconds since epoch
 * @param format The requested format for the return string
 * @return The datetime string
 */
+ (NSString *)dateTimeStringFormat:(NSInteger)seconds format:(NSString *)format
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    dateFormatter.timeZone = tz;
    return [dateFormatter stringFromDate:date];
}

#define TIME(__method__, __format__) \
    + (NSString *)__method__ { \
        return [self __method__:time(NULL)]; \
    } \
    + (NSString *)__method__:(NSInteger)seconds { \
        return [self dateTimeStringFormat:seconds format:__format__]; \
    }

TIME(dateTimeString_YYYY_MM_DDThh_mm_ss, @"yyyy-MM-dd'T'HH:mm:ss")
TIME(dateTimeString_YYYY_MM_DD_hh_mm_ss, @"yyyy-MM-dd HH:mm:ss")
TIME(dateTimeString_YYYY_MM_DD, @"yyyy-MM-dd")
TIME(dateTimeString_YYYYMMDD, @"yyyyMMdd")
TIME(dateTimeString_YYYYMMDD_hhmmss, @"yyyyMMdd-HHmmss")
TIME(dateTimeString_hh_mm_ss, @"HH:mm:ss")
TIME(dateTimeString_dow, @"EEEE")

///////////////////////////////////////////

/// Convert a plain text string into a HTML string... Kind off
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

/// Remove all tags from an HTML string
+ (NSString *)stripHTML:(NSString *)l
{
    NSRange r;
    NSString *s = l;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

/// Count the number of lines in a string
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

/// Returns the number as a nicely formatted string with spaces every three digits
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

/// Returns the number as a nicely formatted string with bytes, Kb, Mb etc
+ (NSString *)niceFileSize:(NSInteger)i
{
    // No localisation needed
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

/// Returns the number as a nicely formatted string with meters, km, miles etc
+ (NSString *)niceDistance:(NSInteger)m
{
    return [MyTools niceDistance:m isMetric:configManager.distanceMetric];
}

/// Returns the number as a nicely formatted string with meters, km, miles etc
+ (NSString *)niceDistance:(NSInteger)m isMetric:(BOOL)isMetric
{
    if (isMetric == YES) {
        if (m < 1000)
            return [NSString stringWithFormat:@"%ld m", (long)m, NSLocalizedString(@"distance-m", nil)];
        if (m < 10000)
            return [NSString stringWithFormat:@"%0.2f km", m / 1000.0, NSLocalizedString(@"distance-km", nil)];
        return [NSString stringWithFormat:@"%ld km", (long)m / 1000, NSLocalizedString(@"distance-km", nil)];
    }

    /* Metric to imperial conversions
     * 1 mile is 1.6093 kilometers
     * 1 foot is 0.30480 meters
     *
     * From Darryl Wattenberg:
     * The norm is for miles down to 0.1 then switch to feet. The few apps that use yards get riidculed for it.
     */
    if (m <= 161)   // 1/10th of a mile
        return [NSString stringWithFormat:@"%ld %@", (long)(m / 0.30480), NSLocalizedString(@"distance-feet", nil)];
    if (m <= 16093)   // 10 miles
        return [NSString stringWithFormat:@"%0.2f %@", m / 1609.3, NSLocalizedString(@"distance-miles", nil)];
    return [NSString stringWithFormat:@"%ld %@", (long)(m / 1609.3), NSLocalizedString(@"distance-miles", nil)];
}

/// Returns the number as a nicely formatted string with km/h or mph
+ (NSString *)niceSpeed:(NSInteger)kmph
{
    return [MyTools niceSpeed:kmph isMetric:configManager.distanceMetric];
}

+ (NSString *)niceSpeed:(NSInteger)kmph isMetric:(BOOL)isMetric
{
    if (isMetric == YES) {
        return [NSString stringWithFormat:@"%ld %@", (long)kmph, NSLocalizedString(@"distance-km/h", nil)];
    } else {
        if (kmph / 1.6093 < 10)
            return [NSString stringWithFormat:@"%0.2f %@", (kmph / 1.6093), NSLocalizedString(@"distance-mls/h", nil)];
        else
            return [NSString stringWithFormat:@"%ld %@", (long)(kmph / 1.6093), NSLocalizedString(@"distance-mls/h", nil)];
    }
}

/// Returns the number as a nicely formatted string with seconds, hours, minutes etc ago
+ (NSString *)niceTimeDifference:(NSInteger)i
{
    long diff = time(NULL) - i;

    if (diff < 60) {
        return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-second-ago", nil) : NSLocalizedString(@"time-seconds-ago", nil)];
    }
    if (diff < 3600) {
        diff /= 60;
        return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-minute-ago", nil) : NSLocalizedString(@"time-minutes-ago", nil)];
    }
    if (diff < 24 * 3600) {
        diff /= 3600;
        return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-hour-ago", nil) : NSLocalizedString(@"time-hours-ago", nil)];
    }
    if (diff < 7 * 24 * 3600) {
        diff /= 24 * 3600;
        return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-day-ago", nil) : NSLocalizedString(@"time-days-ago", nil)];
    }
    if (diff < 365 * 24 * 3600) {
        diff /= 7 * 24 * 3600;
        return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-week-ago", nil) : NSLocalizedString(@"time-weeks-ago", nil)];
    }
    diff /= 365 * 24 * 3600;
    return [NSString stringWithFormat:@"%ld %@", diff, diff == 1 ? NSLocalizedString(@"time-year-ago", nil) : NSLocalizedString(@"time-years-ago", nil)];
}

/// Returns the number as a nicely formatted string for origin
+ (NSString *)niceCGPoint:(CGPoint)p;
{
    return [NSString stringWithFormat:@"(%0.0f, %0.0f)", p.x, p.y];
}

/// Returns the number as a nicely formatted string for origin and size
+ (NSString *)niceCGRect:(CGRect)r
{
    return [NSString stringWithFormat:@"(%0.0f, %0.0f), (%0.0f x %0.0f)", r.origin.x, r.origin.y, r.size.width, r.size.height];
}

/// Returns the number as a nicely formatted string for size
+ (NSString *)niceCGSize:(CGSize)s
{
    return [NSString stringWithFormat:@"(%0.0f x %0.0f)", s.width, s.height];
}

/// Returns the number as a nicely formatted string in percentage form
+ (NSString *)nicePercentage:(NSInteger)value total:(NSInteger)total;
{
    return [NSString stringWithFormat:@"%0.0f%%", 100.0 * value / total];
}

///////////////////////////////////////////

/// Return an percent encoded URL with %xx for non-alphanumeric characters
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

/// Return an string with percent encoding changed into normal characters
+ (NSString *)urlDecode:(NSString *)in
{
    return [in stringByRemovingPercentEncoding];
}

/// Join a dictionary for URL encoding
+ (NSString *)urlParameterJoin:(NSDictionary *)in
{
    NSMutableString *s = [NSMutableString stringWithString:@""];
    [in enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([s length] != 0)
            [s appendString:@"&"];
        [s appendFormat:@"%@=%@", key, value];
    }];
    return s;
}

/// Escape the " in a string with \"
+ (NSString *)tickEscape:(NSString *)in
{
    return [in stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

/// Escape the " and / in a string with \" and \/
+ (NSString *)JSONEscape:(NSString *)in
{
    NSMutableString *s = [NSMutableString stringWithString:in];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

/// Escape the &, < and > in a string with &amp, &lt; and &gt;
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

/// Remove a set of & escaped values with their normal character values
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

/// Remove the first and last character from a JSON string
+ (NSString *)removeJSONWrapper:(NSString *)s jsonWrapper:(NSString *)jQueryCallback
{
    NSString *t = [s substringFromIndex:[jQueryCallback length] + 1];
    t = [t substringToIndex:[t length] - 2];
    return t;
}

///////////////////////////////////////////

/// Check if a string matches a set of coordinates like ^[NESW] \d{1,3}º? ?\d{1,2}\.\d{1,3
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

/// Return a non-existing waypoint code based on the prefix supplied
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

/// Checks if the Wifi interface is connected to the Internet
+ (BOOL)hasWifiNetwork
{
    @synchronized (self) {
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
}

/// Checks if the Mobile interface is connected to the Internet
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

/// Check if there is any network conencted to the Internet
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

/// Play a sound file
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

/// Play one of the defined sounds
+ (void)playSound:(PlaySound)reason
{
    switch (reason) {
        case PLAYSOUND_IMPORTCOMPLETE:
            [MyTools playSoundFile:@"Import Complete" extension:@"wav"];
            break;
        case PLAYSOUND_MAX:
            break;
    }
}

///////////////////////////////////////////

/// Show up a message box with a header and a text
+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:header
                                message:text
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *close = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Close", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];

    [alert addAction:close];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ALERT_VC_RVC(vc) presentViewController:alert animated:YES completion:nil];
    }];
}

/// Show up a message box with a header, a text and an error string
+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text error:(NSString *)error
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:header
                                message:[NSString stringWithFormat:@"%@\n%@: %@", text, NSLocalizedString(@"Error", nil), error]
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *close = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"Close", nil)
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];

    [alert addAction:close];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [ALERT_VC_RVC(vc) presentViewController:alert animated:YES completion:nil];
    }];
}

/// Returns a random UIColor object (not black)
+ (UIColor *)randomColor
{
    NSArray<UIColor *> *colours = @[
                         [UIColor redColor],
                         [UIColor whiteColor],
                         [UIColor blueColor],
                         [UIColor brownColor],
                         [UIColor yellowColor],
                         [UIColor cyanColor],
                         [UIColor darkGrayColor],
                         [UIColor redColor],
                         [UIColor grayColor],
                         [UIColor greenColor],
                         [UIColor lightGrayColor],
                         [UIColor lightTextColor],
                         [UIColor magentaColor],
                         [UIColor orangeColor],
                         [UIColor purpleColor],
                         ];
    return colours[arc4random_uniform((uint32_t)[colours count])];
}

///////////////////////////////////////////

//// Obtained from https://forums.developer.apple.com/thread/11519
//+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr
//{
//    dispatch_semaphore_t    sem;
//    __block NSData *        result;
//
//    result = nil;
//
//    sem = dispatch_semaphore_create(0);
//
//    [[[NSURLSession sharedSession] dataTaskWithRequest:request
//                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                         if (errorPtr != NULL) {
//                                             *errorPtr = error;
//                                         }
//                                         if (responsePtr != NULL) {
//                                             *responsePtr = response;
//                                         }
//                                         if (error == nil) {
//                                             result = data;
//                                         }
//                                         dispatch_semaphore_signal(sem);
//                                     }] resume];
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//    return result;
//}

///////////////////////////////////////////

/// Return the top UIViewController for this view
+ (UIViewController *)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    return topController;
}

/// Send a Tweet through the iOS Twitter interface
+ (void)sendTweet:(UIViewController *)vc text:(NSString *)text
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:text];
        [vc presentViewController:tweetSheet animated:YES completion:nil];
    } else {

        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Sorry", nil)
                                    message:NSLocalizedString(@"tweet-fail", nil)
                                    preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *close = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"Close", nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                }];

        [alert addAction:close];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [ALERT_VC_RVC(vc) presentViewController:alert animated:YES completion:nil];
        }];
    }
}

/*
NSLocalizedString(@"distance-metre", nil);
NSLocalizedString(@"distance-metres", nil);
NSLocalizedString(@"distance-kms", nil);
NSLocalizedString(@"distance-kilometer", nil);
NSLocalizedString(@"distance-kilometers", nil);
NSLocalizedString(@"distance-m/s", nil);
NSLocalizedString(@"distance-metre/second", nil);
NSLocalizedString(@"distance-metres/second", nil);
NSLocalizedString(@"distance-kms/h", nil);
NSLocalizedString(@"distance-kilometer/hour", nil);
NSLocalizedString(@"distance-kilometers/hour", nil);
NSLocalizedString(@"distance-ft", nil);
NSLocalizedString(@"distance-ml", nil);
NSLocalizedString(@"distance-mls", nil);
NSLocalizedString(@"distance-mile", nil);
NSLocalizedString(@"distance-ft/s", nil);
NSLocalizedString(@"distance-feet/second", nil);
NSLocalizedString(@"distance-miles/hour", nil);
NSLocalizedString(@"time-day", nil);
NSLocalizedString(@"time-days", nil);
NSLocalizedString(@"time-hour", nil);
NSLocalizedString(@"time-hours", nil);
NSLocalizedString(@"time-minute", nil);
NSLocalizedString(@"time-minutes", nil);
NSLocalizedString(@"time-second", nil);
NSLocalizedString(@"time-seconds", nil);
NSLocalizedString(@"time-week", nil);
NSLocalizedString(@"time-weeks", nil);
NSLocalizedString(@"time-year", nil);
NSLocalizedString(@"time-years", nil);
*/

@end
