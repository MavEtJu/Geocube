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

- (GCDictionaryGGCW *)my_default:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)pocket_default:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSDictionary *)geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCStringGPX *)geocache_gpx:(NSString *)wptname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)account_oauth_token:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)map:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)map_info:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)map_png:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)map_details:(NSString *)wpcode infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSArray<NSDictionary *> *)my_inventory:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSDictionary *)track_details:(NSString *)guid id:(NSString *)_id infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSDictionary *)track_details:(NSString *)tracker infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSArray<NSDictionary *> *)track_search:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGGCW *)seek_cache__details_SetUserCacheNote:(NSDictionary *)dict text:(NSString *)text infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSDictionary *)seek_log__form:(NSString *)gc_id infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSString *)seek_log__submit:(NSString *)gc_id dict:(NSDictionary *)dict logstring:(NSString *)logstring_type dateLogged:(NSString *)dateLogged note:(NSString *)note favpoint:(BOOL)favpoint trackables:(NSDictionary *)tbs infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;

@end
