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

#import <CoreLocation/CoreLocation.h>

#import "ProtocolTemplate.h"

#import "ToolsLibrary/InfoItem.h"

@class GCDictionaryOKAPI;
@class InfoViewer;
@class GCBoundingBox;

@interface ProtocolOKAPI : ProtocolTemplate

- (GCDictionaryOKAPI *)services_users_byUsername:(NSString *)username infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryOKAPI *)services_logs_submit:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryOKAPI *)services_caches_geocache:(NSString *)wpname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryOKAPI *)services_caches_geocaches:(NSArray<NSString *> *)wpcode infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryOKAPI *)services_caches_search_nearest:(CLLocationCoordinate2D)center offset:(NSInteger)offset infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryOKAPI *)services_caches_search_bbox:(GCBoundingBox *)bbox infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
