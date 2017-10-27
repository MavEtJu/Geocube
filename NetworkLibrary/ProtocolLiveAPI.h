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

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)CreateTrackableLog:(NSString *)wpt_name logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointnames:(NSArray<NSString *> *)wpnames infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)SearchForGeocaches_boundbox:(GCBoundingBox *)bb infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text infoItem:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoItem2 *)iid;
- (GCDictionaryLiveAPI *)GetTrackablesByPin:(NSString *)pin infoItem:(InfoItem2 *)iid;

@end
