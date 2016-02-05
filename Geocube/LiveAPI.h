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

- (NSDictionary *)GetYourUserProfile;
- (NSDictionary *)GetCacheIdsFavoritedByUser;
- (NSDictionary *)GetGeocacheDataTypes;
- (NSInteger)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite;
- (NSDictionary *)SearchForGeocaches_waypointname:(NSString *)wpname;
- (NSDictionary *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center;
- (NSDictionary *)GetMoreGeocaches:(NSInteger)offset;
- (NSDictionary *)GetPocketQueryList;
- (NSDictionary *)GetPocketQueryZippedFile:(NSString *)guid;
- (NSDictionary *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems;

@end
