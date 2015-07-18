//
//  dbWaypointType.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbWaypointType_h
#define Geocube_dbWaypointType_h

@interface dbCacheType : dbObject {
    NSInteger _id;
    NSString *type;
    NSInteger icon;
    NSInteger pin;
}

- (id)init:(NSInteger)_id type:(NSString *)type icon:(NSInteger)icon pin:(NSInteger)pin;

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *type;
@property (nonatomic) NSInteger icon;
@property (nonatomic) NSInteger pin;

@end

#endif