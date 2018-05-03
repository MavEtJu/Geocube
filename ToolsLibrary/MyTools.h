/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

+ (NSString *)DocumentRoot;
+ (NSString *)DataDistributionDirectory;
+ (NSString *)ApplicationSupportRoot;
+ (NSString *)FilesDir;
+ (NSString *)KMLDir;
+ (NSString *)MapCacheDir;
+ (NSString *)OldMapCacheDir;
+ (NSString *)ImagesDir;
+ (NSString *)OldImagesDir;
+ (NSString *)ImageFile:(NSString *)imgFile;
+ (NSString *)SettingsBundleDirectory;

+ (NSInteger)determineDirectorySize:(NSString *)path;

+ (struct timeval)timevalDifference:(struct timeval)t0 t1:(struct timeval)t1;

+ (NSInteger)secondsSinceEpochFromWindows:(NSString *)datetime;
+ (NSInteger)secondsSinceEpochFromISO8601:(NSString *)datetime;
+ (long long)millisecondsSinceEpoch;

+ (NSString *)dateTimeString_YYYY_MM_DDThh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DDThh_mm_ss;
+ (NSString *)dateTimeString_YYYY_MM_DD_hh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DD_hh_mm_ss;
+ (NSString *)dateTimeString_YYYYMMDD_hhmmss:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYYMMDD_hhmmss;
+ (NSString *)dateTimeString_YYYY_MM_DD:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYY_MM_DD;
+ (NSString *)dateTimeString_DD_MM_YYYY_dotspace:(NSInteger)seconds;
+ (NSString *)dateTimeString_DD_MM_YYYY_dotspace;
+ (NSString *)dateTimeString_YYYYMMDD:(NSInteger)seconds;
+ (NSString *)dateTimeString_YYYYMMDD;
+ (NSString *)dateTimeString_hh_mm_ss:(NSInteger)seconds;
+ (NSString *)dateTimeString_hh_mm_ss;
+ (NSString *)dateTimeString_dow:(NSInteger)seconds;
+ (NSString *)dateTimeString_dow;

+ (NSString *)stripHTML:(NSString *)s;
+ (NSString *)simpleHTML:(NSString *)plainText;
+ (NSInteger)numberOfLines:(NSString *)s;

+ (NSString *)niceCGPoint:(CGPoint)p;
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

+ (NSString *)strippedFloat:(NSString *)fmt f:(float)f;

+ (NSString *)urlEncode:(NSString *)in;
+ (NSString *)urlDecode:(NSString *)in;
+ (NSString *)urlParameterJoin:(NSDictionary *)in;
+ (NSString *)tickEscape:(NSString *)in;
+ (NSString *)JSONEscape:(NSString *)in;
+ (NSString *)HTMLEscape:(NSString *)in;
+ (NSString *)HTMLUnescape:(NSString *)in;
+ (NSString *)removeJSONWrapper:(NSString *)s jsonWrapper:(NSString *)jQueryCallback;

+ (NSString *)makeNewMyWaypoint;

+ (NSDictionary *)imageEXIFDataFile:(NSString *)file;
+ (NSDictionary *)imageEXIFDataURL:(NSURL *)url;

+ (BOOL)hasWifiNetwork;
+ (BOOL)hasMobileNetwork;
+ (BOOL)hasAnyNetwork;

+ (NSInteger)ThreadCount;

//+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr;

+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text;
+ (void)messageBox:(UIViewController *)vc header:(NSString *)header text:(NSString *)text error:(NSString *)error;

+ (UIColor *)randomColor;

+ (UIViewController *)topMostController;
+ (BOOL)iOSVersionAtLeast_10_0_0;

@end
