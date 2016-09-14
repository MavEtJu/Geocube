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

@interface RemoteAPI_LiveAPI : RemoteAPI_Template

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)CreateTrackableLog:(dbWaypoint *)waypoint logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text downloadInfoItem:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoItemDowload *)iid;
- (GCDictionaryLiveAPI *)GetTrackablesByTrackingNumber:(NSString *)code downloadInfoItem:(InfoItemDowload *)iid;

@end
