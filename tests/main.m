//
//  main.m
//  tests
//
//  Created by Edwin Groothuis on 26/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface foo : NSObject
+ (NSString *)niceNumber:(NSInteger)i;
@end

@implementation foo

+ (NSString *)niceNumber:(NSInteger)i
{
    NSMutableString *sin = [NSMutableString stringWithFormat:@"%ld", (long)i];
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

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");

        NSInteger i_ = 1;
        for (NSInteger i = 0; i < 10; i++) {
            i_ *= 10;
            for (NSInteger j = -1; j < 2; j++) {
                NSInteger k = i_ + j;
                NSLog(@"%ld %@", k, [foo niceNumber:k]);
            }
        }
    }
    return 0;
}
