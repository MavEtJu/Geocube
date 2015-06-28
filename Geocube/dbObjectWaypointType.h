//
//  dbObjectWaypointType.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dbObjectWaypointType : NSObject {
    NSInteger _id;
    NSString *type;
    NSString *icon;
}

- (id)init:(NSInteger)_id type:(NSString *)type icon:(NSString *)icon;

@property NSInteger _id;
@property NSString *type;
@property NSString *icon;

@end
