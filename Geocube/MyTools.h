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

@interface MyTools : NSObject

typedef NS_ENUM(NSInteger, PlaySound) {
    PLAYSOUND_IMPORTCOMPLETE,
    PLAYSOUND_MAX
};

+ (NSString *)DocumentRoot;
+ (NSString *)DataDistributionDirectory;
+ (NSString *)FilesDir;
+ (NSString *)ImagesDir;
+ (NSString *)ImageFile:(NSString *)imgFile;

+ (struct timeval)timevalDifference:(struct timeval)t0 t1:(struct timeval)t1;

+ (NSInteger)secondsSinceEpochFromWindows:(NSString *)datetime;
+ (NSInteger)secondsSinceEpochFromISO8601:(NSString *)datetime;
+ (NSInteger)millisecondsSinceEpoch;

+ (NSString *)dateTimeString_YYYY_MM_DDThh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DDThh_mm_ss;
+ (NSString *)dateTimeString_YYYY_MM_DD_hh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DD_hh_mm_ss;
+ (NSString *)dateTimeString_YYYYMMDD_hhmmss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYYMMDD_hhmmss;
+ (NSString *)dateTimeString_YYYY_MM_DD:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DD;
+ (NSString *)dateTimeString_YYYYMMDD:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYYMMDD;
+ (NSString *)dateTimeString_hh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_hh_mm_ss;

+ (NSString *)stripHTML:(NSString *)s;
+ (NSString *)simpleHTML:(NSString *)plainText;
+ (NSInteger)numberOfLines:(NSString *)s;

+ (NSString *)niceCGRect:(CGRect)r;
+ (NSString *)niceCGSize:(CGSize)s;
+ (NSString *)niceNumber:(NSInteger)i;
+ (NSString *)niceFileSize:(NSInteger)i;
+ (NSString *)niceTimeDifference:(NSInteger)i;
+ (NSString *)niceDistance:(NSInteger)m;
+ (NSString *)niceDistance:(NSInteger)m isMetric:(BOOL)isMetric;
+ (NSString *)niceSpeed:(NSInteger)kmph;
+ (NSString *)niceSpeed:(NSInteger)kmph isMetric:(BOOL)isMetric;
+ (NSString *)nicePercentage:(NSInteger)value total:(NSInteger)total;

+ (NSString *)urlEncode:(NSString *)in;
+ (NSString *)urlDecode:(NSString *)in;
+ (NSString *)urlParameterJoin:(NSDictionary *)in;
+ (NSString *)tickEscape:(NSString *)in;
+ (NSString *)JSONEscape:(NSString *)in;
+ (NSString *)HTMLEscape:(NSString *)in;
+ (NSString *)HTMLUnescape:(NSString *)in;
+ (NSString *)removeJSONWrapper:(NSString *)s jsonWrapper:(NSString *)jQueryCallback;

+ (BOOL)checkCoordinate:(NSString *)text;
+ (NSString *)makeNewWaypoint:(NSString *)prefix;

+ (BOOL)hasWifiNetwork;
+ (BOOL)hasMobileNetwork;
+ (BOOL)hasAnyNetwork;

//+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr;

+ (void)playSound:(PlaySound)reason;
+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text;
+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text error:(NSString *)error;

+ (UIColor *)randomColor;

+ (UIViewController *)topMostController;

@end

typedef sqlite3_int64 NSId;

#define NEEDS_OVERLOADING_ASSERT \
    NSAssert(0, @"%s should be overloaded for %@", __FUNCTION__, [self class])
#define NEEDS_OVERLOADING(__name__) \
    - (void) __name__ { NEEDS_OVERLOADING_ASSERT; }
#define NEEDS_OVERLOADING_BOOL(__name__) \
    - (BOOL) __name__ { NEEDS_OVERLOADING_ASSERT; return NO; }
#define NEEDS_OVERLOADING_NSRANGE(__name__) \
    - (NSRange) __name__ { NEEDS_OVERLOADING_ASSERT; return NSMakeRange(0, 0); }
#define EMPTY_METHOD(__name__) \
    - (void) __name__ { }
#define EMPTY_METHOD_BOOL(__name__) \
    - (BOOL) __name__ { return NO; }

// JSON related safety functions
#define DICT_NSSTRING_KEY(__dict__, __a__, __key__) { \
    NSString *__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @""; \
    if ([__b__ isKindOfClass:[NSNumber class]] == YES) { \
        __a__ = [(NSNumber *)__b__ stringValue]; \
    } else \
        __a__ = __b__; \
    }
#define DICT_NSSTRING_PATH(__dict__, __a__, __path__) { \
    NSString *__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @""; \
    if ([__b__ isKindOfClass:[NSNumber class]] == YES) \
        __a__ = [(NSNumber *)__b__ stringValue]; \
    else \
        __a__ = __b__; \
    }

#define DICT_FLOAT_KEY(__dict__, __a__, __key__) { \
    NSString *__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  floatValue]; \
    }
#define DICT_FLOAT_PATH(__dict__, __a__, __path__) { \
    NSString *__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  floatValue]; \
    }

#define DICT_INTEGER_KEY(__dict__, __a__, __key__) { \
    NSString *__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  integerValue]; \
    }
#define DICT_INTEGER_PATH(__dict__, __a__, __path__) { \
    NSString *__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  integerValue]; \
    }

#define DICT_BOOL_KEY(__dict__, __a__, __key__) { \
    NSString *__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  boolValue]; \
    }
#define DICT_BOOL_PATH(__dict__, __a__, __path__) { \
    NSString *__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @"0"; \
    __a__ = [__b__  boolValue]; \
    }

#define DICT_ARRAY_KEY(__dict__, __a__, __key__) { \
    NSArray *__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @[]; \
    __a__ = __b__; \
    }
#define DICT_ARRAY_PATH(__dict__, __a__, __path__) { \
    NSArray *__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @[]; \
    __a__ = __b__; \
    }

// UIAlertController related macro
#define ALERT_VC_RVC(__vc__) __vc__.view.window.rootViewController

// Logging macro

#define GCLog(__fmt__, ...) \
    { \
        NSString *fmt = [NSString stringWithFormat:@"%%s: %@", __fmt__]; \
        NSLog(fmt, __func__, ## __VA_ARGS__); \
    }
