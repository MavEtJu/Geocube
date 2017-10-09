/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

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
