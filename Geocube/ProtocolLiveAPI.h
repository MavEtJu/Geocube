/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)CreateTrackableLog:(dbWaypoint *)waypoint logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (GCDictionaryLiveAPI *)GetTrackablesByTrackingNumber:(NSString *)code infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;

@end
