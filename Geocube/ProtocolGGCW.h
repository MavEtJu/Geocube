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

@protocol ProtocolGGCWDelegate

- (void)GGCWAuthSuccessful:(NSHTTPCookie *)cookie;

@end

@interface ProtocolGGCW : ProtocolTemplate <NSURLConnectionDataDelegate>

@property (nonatomic) id<ProtocolGGCWDelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (GCDictionaryGGCW *)account_dashboard:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)pocket_default:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCStringGPX *)geocache_gpx:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)account_oauth_token:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)map:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)map_info:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)map_png:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)map_details:(NSString *)wpcode infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSArray<NSDictionary *> *)my_inventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)track_details:(NSString *)guid id:(NSString *)_id infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)track_details:(NSString *)tracker infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSArray<NSDictionary *> *)track_search:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryGGCW *)seek_cache__details_SetUserCacheNote:(NSDictionary *)dict text:(NSString *)text infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSDictionary *)seek_log__form:(NSString *)gc_id infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (NSString *)seek_log__submit:(NSString *)gc_id dict:(NSDictionary *)dict logstring:(NSString *)logstring_type dateLogged:(NSString *)dateLogged note:(NSString *)note favpoint:(BOOL)favpoint trackables:(NSDictionary *)tbs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (GCDictionaryGGCW *)my_statistics:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
