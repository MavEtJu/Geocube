//
//  dbWaypointGroup.h
//  Geocube
//
//  Created by Edwin Groothuis on 29/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbWaypointGroup_h
#define Geocube_dbWaypointGroup_h

@interface dbCacheGroup: dbObject {
    NSInteger _id;
    NSString *name;
    BOOL usergroup;
}

- (id)init:(NSInteger)_id name:(NSString *)name usergroup:(BOOL)usergroup;

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL usergroup;

@end

#endif