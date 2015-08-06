//
//  main.m
//  objects
//
//  Created by Edwin Groothuis on 25/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>


int main(int argc, const char * argv[]) {
    NSString *a = @"E 12 30.000";
    NSScanner *scanner = [NSScanner scannerWithString:a];
    BOOL okay = YES;

    NSString *direction;
    NSLog(@"%d/%d - scanning string - '%@'", okay, scanner.atEnd, [scanner.string substringFromIndex:scanner.scanLocation]);
    okay &= [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"NESW"] intoString:&direction];

    int degrees;
    NSLog(@"%d/%d - scanning int: '%@'", okay, scanner.atEnd, [scanner.string substringFromIndex:scanner.scanLocation]);
    okay &= [scanner scanInt:&degrees];

    float mins;
    NSLog(@"%d/%d - scanning float: '%@'", okay, scanner.atEnd, [scanner.string substringFromIndex:scanner.scanLocation]);
    okay &= [scanner scanFloat:&mins];

    NSLog(@"%d/%d - result: '%@'", okay, scanner.atEnd, [scanner.string substringFromIndex:scanner.scanLocation]);

    NSLog(@"Okay? %d", okay);
    NSLog(@"input: %@", a);
    NSLog(@"direction: %@", direction);
    NSLog(@"degrees: %d", degrees);
    NSLog(@"mins: %f", mins);

    float ddegrees = degrees + mins / 60.0;

    if ([[direction uppercaseString] compare:@"W"] == NSOrderedSame)
        ddegrees = -ddegrees;
    if ([[direction uppercaseString] compare:@"S"] == NSOrderedSame)
        ddegrees = -ddegrees;

    NSLog(@"%f", ddegrees);

    return 0;
}
