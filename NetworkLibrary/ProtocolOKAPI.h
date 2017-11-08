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

@interface ProtocolOKAPI : ProtocolTemplate

- (GCDictionaryOKAPI *)services_users_byUsername:(NSString *)username infoItem:(InfoItem *)iid;
- (GCDictionaryOKAPI *)services_logs_submit:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite infoItem:(InfoItem *)iid;
- (GCDictionaryOKAPI *)services_caches_geocache:(NSString *)wpname infoItem:(InfoItem *)iid;
- (GCDictionaryOKAPI *)services_caches_geocaches:(NSArray<NSString *> *)wpcode infoItem:(InfoItem *)iid;
- (GCDictionaryOKAPI *)services_caches_search_bbox:(GCBoundingBox *)bbox infoItem:(InfoItem *)iid;

@end
