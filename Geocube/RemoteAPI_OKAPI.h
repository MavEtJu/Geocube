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

@interface RemoteAPI_OKAPI : RemoteAPI_Template

- (GCDictionaryOKAPI *)services_users_byUsername:(NSString *)username downloadInfoItem:(InfoDownloadItem *)idi;
- (NSInteger)services_logs_submit:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite downloadInfoItem:(InfoDownloadItem *)idi;
- (NSString *)services_caches_formatters_gpx:(NSString *)wpname downloadInfoItem:(InfoDownloadItem *)idi;
- (NSDictionary *)services_caches_search_nearest:(CLLocationCoordinate2D)center offset:(NSInteger)offset downloadInfoItem:(InfoDownloadItem *)idi;
- (NSDictionary *)services_caches_geocaches:(NSArray *)wpcode downloadInfoItem:(InfoDownloadItem *)idi;

@end
