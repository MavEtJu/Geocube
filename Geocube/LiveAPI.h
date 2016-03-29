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

@protocol LiveAPIDelegate

- (void)alertError:(NSString *)msg error:(NSError *)error;

@end

@interface LiveAPI : ProtocolTemplate

@property (nonatomic) id delegate;

- (NSDictionaryLiveAPI *)GetYourUserProfile;
- (NSDictionaryLiveAPI *)GetCacheIdsFavoritedByUser;
- (NSDictionaryLiveAPI *)GetGeocacheDataTypes;
- (NSInteger)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename;
- (NSDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname;
- (NSDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center;
- (NSDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset;
- (NSDictionaryLiveAPI *)GetPocketQueryList;
- (NSDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid;
- (NSDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems;
- (NSDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text;

@end