//
//  dbWaypointType.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbWaypointType_h
#define Geocube_dbWaypointType_h

@interface dbWaypointType : dbObject {
    NSInteger _id;
    NSString *type;
    NSInteger icon;
}

- (id)init:(NSInteger)_id type:(NSString *)type icon:(NSInteger)icon;

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *type;
@property (nonatomic) NSInteger icon;

@end

#endif