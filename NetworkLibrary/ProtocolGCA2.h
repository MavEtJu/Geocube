/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

@interface ProtocolGCA2 : ProtocolTemplate

- (BOOL)authenticate:(dbAccount *)account;

- (GCDictionaryGCA2 *)api_services_users_by__username:(NSString *)username infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocache:(NSString *)wptname infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps logs:(NSInteger)numlogs infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_search_bbox:(GCBoundingBox *)bb infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_logs_submit:(dbWaypoint *)wp logtype:(NSString *)logtype comment:(NSString *)comment when:(NSString *)dateLogged rating:(NSInteger)rating recommended:(BOOL)recommended coordinates:(CLLocationCoordinate2D)coordinates infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_logs_images_add:(NSNumber *)logid data:(NSData *)imgdata caption:(NSString *)imageCaption description:(NSString *)imageDescription infoItem:(InfoItem *)iid;
- (GCDictionaryGCA2 *)api_services_caches_query_list:(InfoItem *)iid public:(BOOL)public;
- (GCDictionaryGCA2 *)api_services_caches_query_geocaches:(NSString *)queryId infoItem:(InfoItem *)iid;

@end
