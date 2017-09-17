//
//  dbTrackable-enum.h
//  DatabaseLibrary
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

typedef NS_ENUM(NSInteger, TrackableLog) {
    TRACKABLE_LOG_NONE = 0,
    TRACKABLE_LOG_VISIT,
    TRACKABLE_LOG_DROPOFF,
    TRACKABLE_LOG_PICKUP,
    TRACKABLE_LOG_DISCOVER,
    TRACKABLE_LOG_MAX
};
