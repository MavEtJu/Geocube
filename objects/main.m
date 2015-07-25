//
//  main.m
//  objects
//
//  Created by Edwin Groothuis on 25/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Objc/runtime.h>

@interface testObject : NSObject {
    NSNumber *i;
    NSString *s;
}

@property (nonatomic, retain) NSString *s;
@property (nonatomic) NSNumber *i;

@end

@implementation testObject

@synthesize  i, s;

@end

#define SuppressPerformSelectorLeakWarning(Stuff) \
    do { \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        Stuff; \
        _Pragma("clang diagnostic pop") \
    } while (0)


int main(int argc, const char * argv[]) {
    testObject *t = [[testObject alloc] init];
    t.i = @24;
    t.s = @"foo";
    NSLog(@"b. %@ %@", t.i, t.s);

    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([t class], &propertyCount);
    NSLog(@"%d properties", propertyCount);

    // http://iphonedevsdk.com/forum/iphone-sdk-development/71859-iterate-through-an-objects-properties-is-it-possible.html

    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        NSLog(@"0. %@", propertyName);

        char firstLetter = [propertyName characterAtIndex:0];
        propertyName = [propertyName substringFromIndex:1];

        if (firstLetter > 96 && firstLetter < 123) {
            firstLetter -= 32;
        }

        NSString *selectorName = [NSString stringWithFormat:@"set%c%@:", firstLetter, propertyName];

        NSLog(@"1. %@ %@", t.i, t.s);
        if (i == 0) {
            SuppressPerformSelectorLeakWarning(
                [t performSelector:NSSelectorFromString(selectorName) withObject:@"Bar"];
            );
        }
        if (i == 1) {
            NSNumber *n = @12;
            SuppressPerformSelectorLeakWarning(
                [t performSelector:NSSelectorFromString(selectorName) withObject:n];
            );
        }
        NSLog(@"2. %@ %@", t.i, t.s);
    }

    NSLog(@"a. %@ %@", t.i, t.s);

    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
