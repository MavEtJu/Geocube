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

@interface ProtocolGGCW : ProtocolTemplate <NSURLConnectionDataDelegate>

@property (nonatomic) id<ProtocolGGCWDelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (GCDictionaryGGCW *)account_dashboard:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)my_statistics:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (GCDictionaryGGCW *)pocket_default:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (NSDictionary *)geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCStringGPX *)geocache_gpx:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSArray<NSString *> *)play_search:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (NSArray<NSDictionary *> *)my_inventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)track_details:(NSString *)guid id:(NSString *)_id infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)track_details:(NSString *)tracker infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSArray<NSDictionary *> *)track_search:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)track_log:(NSDictionary *)dict infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (GCDictionaryGGCW *)account_oauth_token:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (GCDictionaryGGCW *)play_serverparameters_params;
- (GCDictionaryGGCW *)account_oauth_token;
- (GCDictionaryGGCW *)api_proxy_web_v1_users_settings:(NSString *)referenceCode accessToken:(NSString *)accessToken;
- (GCDictionaryGGCW *)api_proxy_web_v1_geocache:(NSString *)wptname accessToken:(NSString *)accessToken;
- (GCDictionaryGGCW *)api_proxy_web_v1_Geocache_GeocacheLog:(NSString *)wptname dict:(NSDictionary *)dict accessToken:(NSString *)accessToken;

@end