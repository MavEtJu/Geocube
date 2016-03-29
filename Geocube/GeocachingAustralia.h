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

@protocol GeocachingAustraliaDelegate

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie;
- (void)alertError:(NSString *)msg error:(NSError *)error;

@end

@interface GeocachingAustralia : ProtocolTemplate <NSURLConnectionDataDelegate>

@property (nonatomic) id delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (NSArray *)my_query;
- (NSDictionaryGCA *)cacher_statistic__finds:(NSString *)name;
- (NSDictionaryGCA *)cacher_statistic__hides:(NSString *)name;
- (NSStringGPX *)cache__gpx:(NSString *)wpname;
- (NSDictionaryGCA *)cache__json:(NSString *)wpname;
- (NSInteger)my_log_new:(NSString *)logtype waypointName:(NSString *)wpname dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite;
- (NSDictionaryGCA *)caches_gca:(CLLocationCoordinate2D)center;
- (NSDictionaryGCA *)logs_cache:(NSString *)wpname;
- (NSInteger)my_gallery_cache_add:(NSString *)wpname data:(NSData *)data caption:(NSString *)caption description:(NSString *)description;
- (NSDictionaryGCA *)my_query_json:(NSString *)queryname;
- (NSStringGPX *)my_query_gpx:(NSString *)queryname;
- (NSInteger)my_query_count:(NSString *)queryname;
- (NSDictionaryGCA *)my_query_list__json;

@end
