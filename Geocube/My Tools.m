//
//  My Tools.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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

+ (NSString *)simpleHTML:(NSString *)plainText
{
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

@end
