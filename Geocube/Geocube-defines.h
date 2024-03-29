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

#import "MapsLibrary/MapTemplate-enum.h"

#define ASSERT_FINISHED \
    NSAssert(finished == YES, @"Not finished");
#define ASSERT_SELF_FIELD_EXISTS(__field__) \
    NSAssert(self.__field__ != nil, @"self.__field__")
#define ASSERT_FIELD_EXISTS(__field__) \
    NSAssert(__field__ != nil, @"__field__")

#define ASSERT_IMPORT(__expression__, __message__) \
    NSAssert(__expression__, __message__)

#define IS_IPAD \
    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_EMPTY(__s__) \
    (__s__ == nil || [__s__ length] == 0)
#define IS_NULL(__s__) \
    (__s__ == nil || [__s__ isKindOfClass:[NSNull class]] == YES)

#define NEEDS_OVERLOADING_ASSERT \
    NSAssert(0, @"%s should be overloaded for %@", __FUNCTION__, [self class])
#define NEEDS_OVERLOADING_VOID(__name__) \
    (void) __name__ { NEEDS_OVERLOADING_ASSERT; }

#define NEEDS_OVERLOADING_NIL(__type__, __name__) \
    (__type__) __name__ { NEEDS_OVERLOADING_ASSERT; return nil; }

#define NEEDS_OVERLOADING_NSSTRING(__name__) \
    NEEDS_OVERLOADING_NIL(NSString *, __name__)
#define NEEDS_OVERLOADING_NSARRAY_DBOBJECT(__name__) \
    NEEDS_OVERLOADING_NIL(NSArray<dbObject *> *, __name__)
#define NEEDS_OVERLOADING_DBOBJECT(__name__) \
    NEEDS_OVERLOADING_NIL(dbObject *, __name__)
#define NEEDS_OVERLOADING_NSARRAY_NSNUMBER(__name__) \
    NEEDS_OVERLOADING_NIL(NSArray<NSNumber *> *, __name__)
#define NEEDS_OVERLOADING_NSARRAY_NSSTRING(__name__) \
    NEEDS_OVERLOADING_NIL(NSArray<NSString *> *, __name__)
#define NEEDS_OVERLOADING_NSDICTIONARY(__name__) \
    NEEDS_OVERLOADING_NIL(NSDictionary *, __name__)
#define NEEDS_OVERLOADING_INSTANCETYPE(__name__) \
    NEEDS_OVERLOADING_NIL(instancetype, __name__)
#define NEEDS_OVERLOADING_UIIMAGE(__name__) \
    NEEDS_OVERLOADING_NIL(UIImage *, __name__)

#define NEEDS_OVERLOADING_BOOL(__name__) \
    (BOOL) __name__ { NEEDS_OVERLOADING_ASSERT; return NO; }
#define NEEDS_OVERLOADING_NSRANGE(__name__) \
    (NSRange) __name__ { NEEDS_OVERLOADING_ASSERT; return NSMakeRange(0, 0); }
#define NEEDS_OVERLOADING_CLLOCATIONCOORDINATE2D(__name__) \
    (CLLocationCoordinate2D) __name__ { NEEDS_OVERLOADING_ASSERT; return CLLocationCoordinate2DZero; }
#define NEEDS_OVERLOADING_NSINTEGER(__name__) \
    (NSInteger) __name__ { NEEDS_OVERLOADING_ASSERT; return 0; }
#define NEEDS_OVERLOADING_GCMAPTYPE(__name__) \
    (GCMapType) __name__ { NEEDS_OVERLOADING_ASSERT; return 0; }
#define NEEDS_OVERLOADING_DOUBLE(__name__) \
    (double) __name__ { NEEDS_OVERLOADING_ASSERT; return 0; }
#define NEEDS_OVERLOADING_NSID(__name__) \
    (NSId) __name__ { NEEDS_OVERLOADING_ASSERT; return 0; }
#define NEEDS_OVERLOADING_CGPOINT(__name__) \
    (CGPoint) __name__ { NEEDS_OVERLOADING_ASSERT; return CGPointZero; }

#define EMPTY_METHOD(__name__) \
    - (void) __name__ { }
#define EMPTY_METHOD_DOUBLE(__name__) \
    - (double) __name__ { return 0; }
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
    NSArray*__b__ = [__dict__ objectForKey:__key__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @[]; \
    __a__ = __b__; \
}
#define DICT_ARRAY_PATH(__dict__, __a__, __path__) { \
    NSArray*__b__ = [__dict__ valueForKeyPath:__path__]; \
    if ([__b__ isKindOfClass:[NSNull class]] == TRUE) \
        __b__ = @[]; \
    __a__ = __b__; \
}

// UIAlertController related macro
#define ALERT_VC_RVC(__vc__) \
    __vc__.view.window.rootViewController

// Logging macro

#define GCLog(__fmt__, ...) { \
    NSString *fmt = [NSString stringWithFormat:@"%%s: %@", __fmt__]; \
    NSLog(fmt, __func__, ## __VA_ARGS__); \
}

// Main Thread macro
#define MAINQUEUE(block) \
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{ \
        block; \
    }]; \

#define BACKGROUND(__selector__, __data__) \
    [self performSelectorInBackground:@selector(__selector__) withObject:__data__];
