//
//  MKCircle+GCCircle.h
//  Geocube
//
//  Created by Edwin Groothuis on 10/10/2016.
//  Copyright © 2016 Edwin Groothuis. All rights reserved.
//

@interface GCCircle : MKCircle
{
    dbWaypoint *waypoint;
}

@property (nonatomic, retain) dbWaypoint *waypoint;

@end
