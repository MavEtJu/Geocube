//
//  RemoteAPITemplate-enum.h
//  Geocube
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

typedef NS_ENUM(NSInteger, RemoteAPIResult) {
    REMOTEAPI_OK = 0,
    REMOTEAPI_APIREFUSED,               // Couldn't connect to the API
    REMOTEAPI_APIFAILED,                // Invalid values returned
    REMOTEAPI_APIDISABLED,              // No authentication details

    REMOTEAPI_JSONINVALID,              // JSON couldn't be parsed cleanly

    REMOTEAPI_NOTPROCESSED,             // Not supported in this protocol

    REMOTEAPI_USERSTATISTICS_LOADFAILED,    // Unable to load user statistics
    REMOTEAPI_CREATELOG_LOGFAILED,          // Unable to create the log
    REMOTEAPI_CREATELOG_IMAGEFAILED,        // Unable to upload the image
    REMOTEAPI_LOADWAYPOINT_LOADFAILED,      // Unable to load the waypoint
    REMOTEAPI_LOADWAYPOINTS_LOADFAILED,     // Unable to load the waypoints
    REMOTEAPI_LISTQUERIES_LOADFAILED,       // Unable to load the list of queries
    REMOTEAPI_PERSONALNOTE_UPDATEFAILED,    // Unable to update the personal note
    REMOTEAPI_RETRIEVEQUERY_LOADFAILED,     // Unable to load the query
    REMOTEAPI_TRACKABLES_FINDFAILED,        // Unable to find the trackable
    REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED,// Unable to load the trackables inventory
    REMOTEAPI_TRACKABLES_OWNEDLOADFAILED,   // Unable to load the trackables owned
};
