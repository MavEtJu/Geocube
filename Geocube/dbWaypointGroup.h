//
//  dbWaypointGroup.h
//  Geocube
//
//  Created by Edwin Groothuis on 29/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbWaypointGroup_h
#define Geocube_dbWaypointGroup_h

@interface dbWaypointGroup : dbObject {
    NSInteger _id;
    NSString *name;
    BOOL usergroup;
}

- (id)init:(NSInteger)_id name:(NSString *)name usergroup:(BOOL)usergroup;

@property NSInteger _id;
@property NSString *name;
@property BOOL usergroup;

@end

#endif