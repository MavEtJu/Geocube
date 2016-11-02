/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

@interface RemoteAPI_GCA2 : RemoteAPI_Template

- (BOOL)authenticate:(dbAccount *)account;

- (GCDictionaryGCA2 *)api_services_users_by__username:(NSString *)username downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocache:(NSString *)wptname downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray *)wps downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_caches_search_nearest:(CLLocationCoordinate2D)coords downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_logs_submit:(dbWaypoint *)wp logtype:(NSString *)logtype comment:(NSString *)comment when:(NSString *)dateLogged rating:(NSInteger)rating recommended:(BOOL)recommended downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_logs_images_add:(NSNumber *)logid data:(NSData *)imgdata caption:(NSString *)imageCaption description:(NSString *)imageDescription downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)api_services_caches_query_list:(InfoItemDowload *)iid;

// glue for now
- (GCDictionaryGCA2 *)my_query_list__json:(InfoItemDowload *)iid;
- (GCDictionaryGCA2 *)my_query_json:(NSString *)queryname downloadInfoItem:(InfoItemDowload *)iid;
- (GCStringGPX *)my_query_gpx:(NSString *)queryname downloadInfoItem:(InfoItemDowload *)iid;

@end
