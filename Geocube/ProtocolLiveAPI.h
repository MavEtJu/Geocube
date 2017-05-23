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

@interface ProtocolLiveAPI : ProtocolTemplate

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)CreateTrackableLog:(dbWaypoint *)waypoint logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointnames:(NSArray<NSString *> *)wpnames infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_boundbox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (GCDictionaryLiveAPI *)GetTrackablesByTrackingNumber:(NSString *)code infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
