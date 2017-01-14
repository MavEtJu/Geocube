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

@protocol ProtocolGCADelegate

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie;

@end

@interface ProtocolGCA : ProtocolTemplate <NSURLConnectionDataDelegate>

@property (nonatomic) id<ProtocolGCADelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (NSArray *)my_query:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)cacher_statistic__finds:(NSString *)name infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)cacher_statistic__hides:(NSString *)name infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCStringGPX *)cache__gpx:(NSString *)wpname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)cache__json:(NSString *)wpname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)my_log_new:(NSString *)logtype waypointName:(NSString *)wpname dateLogged:(NSString *)dateLogged note:(NSString *)note rating:(NSInteger)rating infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)caches_gca:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)logs_cache:(NSString *)wpname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)my_gallery_cache_add:(NSString *)wpname log_id:(NSInteger)log_id data:(NSData *)data caption:(NSString *)caption description:(NSString *)description infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)my_query_json:(NSString *)queryname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCStringGPX *)my_query_gpx:(NSString *)queryname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (NSInteger)my_query_count:(NSString *)queryname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryGCA *)my_query_list__json:(InfoViewer *)iv ivi:(InfoItemID)ivi;

@end
