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

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)CreateTrackableLog:(dbWaypoint *)waypoint logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text downloadInfoItem:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoDownloadItem *)idi;
- (GCDictionaryLiveAPI *)GetTrackablesByTrackingNumber:(NSString *)code downloadInfoItem:(InfoDownloadItem *)idi;

@end
