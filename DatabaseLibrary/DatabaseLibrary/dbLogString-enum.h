//
//  dbLogString-enum.h
//  DatabaseLibrary
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

typedef NS_ENUM(NSInteger, LogStringWPType) {
    LOGSTRING_WPTYPE_UNKNOWN = 0,
    LOGSTRING_WPTYPE_EVENT,
    LOGSTRING_WPTYPE_WAYPOINT,
    LOGSTRING_WPTYPE_TRACKABLEPERSON,
    LOGSTRING_WPTYPE_TRACKABLEWAYPOINT,
    LOGSTRING_WPTYPE_MOVEABLE,
    LOGSTRING_WPTYPE_WEBCAM,
    LOGSTRING_WPTYPE_LOCALLOG,
};

typedef NS_ENUM(NSInteger, LogStringFound) {
    LOGSTRING_FOUND_NO = 0,
    LOGSTRING_FOUND_YES,
    LOGSTRING_FOUND_NA,
};

typedef NS_ENUM(NSInteger, LogStringDefault) {
    LOGSTRING_DEFAULT_NOTE = 0,
    LOGSTRING_DEFAULT_FOUND,
    LOGSTRING_DEFAULT_VISIT,
    LOGSTRING_DEFAULT_DROPOFF,
    LOGSTRING_DEFAULT_PICKUP,
    LOGSTRING_DEFAULT_DISCOVER,
};