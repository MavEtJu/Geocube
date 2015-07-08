//
//  dbObjectWaypointType.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbObjectWaypointType_h
#define Geocube_dbObjectWaypointType_h

#import <Foundation/Foundation.h>

@interface dbObjectWaypointType : NSObject {
    NSInteger _id;
    NSString *type;
    NSInteger icon;
}

- (id)init:(NSInteger)_id type:(NSString *)type icon:(NSInteger)icon;

@property NSInteger _id;
@property NSString *type;
@property NSInteger icon;

@end

#endif