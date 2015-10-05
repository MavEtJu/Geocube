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

#ifndef Geocube_My_Tools_h
#define Geocube_My_Tools_h

@interface MyTools : NSObject {
    struct timeval clock;
    BOOL clockEnabled;
    NSString *clockTitle;
}

+ (NSString *)DocumentRoot;
+ (NSString *)DataDistributionDirectory;
+ (NSString *)FilesDir;
+ (NSString *)ImagesDir;

+ (struct timeval)timevalDifference:(struct timeval)t0 t1:(struct timeval)t1;

+ (NSInteger)secondsSinceEpochWindows:(NSString *)datetime;
+ (NSInteger)secondsSinceEpoch:(NSString *)datetime;
+ (NSString *)dateString:(NSInteger)seconds;
+ (NSString *)datetimePartDate:(NSString *)datetime;
+ (NSString *)datetimePartTime:(NSString *)datetime;

+ (NSString *)stripHTML:(NSString *)s;
+ (NSString *)simpleHTML:(NSString *)plainText;
+ (NSInteger)numberOfLines:(NSString *)s;

+ (NSString *)niceNumber:(NSInteger)i;
+ (NSString *)niceFileSize:(NSInteger)i;
+ (NSString *)niceTimeDifference:(NSInteger)i;
+ (NSString *)NiceDistance:(NSInteger)i;

- (instancetype)initClock:(NSString *)title;
- (void)clockShowAndReset;
- (void)clockShowAndReset:(NSString *)title;
- (void)clockEnable:(BOOL)yesno;

+ (NSString *)urlEncode:(NSString *)in;
+ (NSString *)urlDecode:(NSString *)in;
+ (NSString *)tickEscape:(NSString *)in;
+ (NSString *)JSONEscape:(NSString *)in;

+ (NSString *)checkCoordinate:(NSString *)text;

- (void)toggleFlashLight:(BOOL)onoff;

@end

typedef sqlite3_int64 NSId;


#define NEEDS_OVERLOADING_ASSERT \
    NSAssert(0, @"%s should be overloaded for %@", __FUNCTION__, [self class])
#define NEEDS_OVERLOADING(__name__) \
    - (void) __name__ { NEEDS_OVERLOADING_ASSERT; }

#endif
