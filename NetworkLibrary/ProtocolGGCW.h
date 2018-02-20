/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface ProtocolGGCW : ProtocolTemplate <NSURLConnectionDataDelegate>

@property (nonatomic) id<ProtocolGGCWDelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (GCDictionaryGGCW *)account_dashboard:(InfoItem *)iid;
- (GCDictionaryGGCW *)my_statistics:(InfoItem *)iid;

- (GCDictionaryGGCW *)pocket_default:(InfoItem *)iid;
- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid infoItem:(InfoItem *)iid;

- (NSDictionary *)geocache:(NSString *)wptname infoItem:(InfoItem *)iid;
- (GCStringGPX *)geocache_gpx:(NSString *)wptname infoItem:(InfoItem *)iid;
- (NSArray<NSString *> *)play_search:(CLLocationCoordinate2D)center infoItem:(InfoItem *)iid;

- (NSArray<NSDictionary *> *)my_inventory:(InfoItem *)iid;
- (NSDictionary *)track_details:(NSString *)guid id:(NSString *)_id infoItem:(InfoItem *)iid;
- (NSDictionary *)track_details:(NSString *)tracker infoItem:(InfoItem *)iid;
- (NSArray<NSDictionary *> *)track_search:(InfoItem *)iid;
- (NSDictionary *)track_log:(NSDictionary *)dict infoItem:(InfoItem *)iid;

- (GCDictionaryGGCW *)account_oauth_token:(InfoItem *)iid;
- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid infoItem:(InfoItem *)iid;

- (GCDictionaryGGCW *)play_serverparameters_params;
- (GCDictionaryGGCW *)account_oauth_token;
- (GCDictionaryGGCW *)api_proxy_web_v1_users_settings:(NSString *)referenceCode accessToken:(NSString *)accessToken;
- (GCDictionaryGGCW *)api_proxy_web_v1_geocache:(NSString *)wptname accessToken:(NSString *)accessToken;
- (GCDictionaryGGCW *)api_proxy_web_v1_Geocache_GeocacheLog:(NSString *)wptname dict:(NSDictionary *)dict accessToken:(NSString *)accessToken;

@end
