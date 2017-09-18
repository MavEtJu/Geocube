/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

#import <CoreLocation/CoreLocation.h>

#import "ProtocolTemplate.h"

#import "ToolsLibrary/InfoItem.h"

@class GCDictionaryGCA2;
@class InfoViewer;
@class dbAccount;
@class dbWaypoint;
@class GCBoundingBox;

@interface ProtocolGCA2 : ProtocolTemplate

- (BOOL)authenticate:(dbAccount *)account;

- (GCDictionaryGCA2 *)api_services_users_by__username:(NSString *)username infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps logs:(NSInteger)numlogs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_search_nearest:(CLLocationCoordinate2D)coords infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_search_bbox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_logs_submit:(dbWaypoint *)wp logtype:(NSString *)logtype comment:(NSString *)comment when:(NSString *)dateLogged rating:(NSInteger)rating recommended:(BOOL)recommended coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_logs_images_add:(NSNumber *)logid data:(NSData *)imgdata caption:(NSString *)imageCaption description:(NSString *)imageDescription infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_query_list:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGCA2 *)api_services_caches_query_geocaches:(NSString *)queryId infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
