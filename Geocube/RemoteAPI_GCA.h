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

@protocol RemoteAPI_GCADelegate

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie;

@end

@interface RemoteAPI_GCA : RemoteAPI_Template <NSURLConnectionDataDelegate>

@property (nonatomic) id<RemoteAPI_GCADelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (NSArray *)my_query:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)cacher_statistic__finds:(NSString *)name downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)cacher_statistic__hides:(NSString *)name downloadInfoItem:(InfoItemDownload *)iid;
- (GCStringGPX *)cache__gpx:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)cache__json:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)my_log_new:(NSString *)logtype waypointName:(NSString *)wpname dateLogged:(NSString *)dateLogged note:(NSString *)note rating:(NSInteger)rating downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)caches_gca:(CLLocationCoordinate2D)center downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)logs_cache:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)my_gallery_cache_add:(NSString *)wpname log_id:(NSInteger)log_id data:(NSData *)data caption:(NSString *)caption description:(NSString *)description downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)my_query_json:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid;
- (GCStringGPX *)my_query_gpx:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid;
- (NSInteger)my_query_count:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGCA *)my_query_list__json:(InfoItemDownload *)iid;

@end
