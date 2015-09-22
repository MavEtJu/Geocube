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

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;

@end

@interface RemoteAPI : NSObject <GCOAuthBlackboxDelegate, LiveAPIDelegate, OKAPIDelegate, GeocachingAustraliaDelegate> {
    GCOAuthBlackbox *oabb;

    LiveAPI *gs;
    OKAPI *okapi;
    GeocachingAustralia *gca;

    dbAccount *account;

    NSInteger stats_found, stats_notfound;
    id authenticationDelegate;

    NSString *clientMsg;
    NSError *clientError;
}

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic) NSInteger stats_found, stats_notfound;
@property (nonatomic) id authenticationDelegate;
@property (nonatomic, retain) NSString *clientMsg;
@property (nonatomic, retain) NSError *clientError;

- (instancetype)init:(dbAccount*)account;
- (BOOL)Authenticate;
- (BOOL)commentSupportsPhotos;
- (BOOL)commentSupportsTrackables;
- (NSArray *)logtypes:(NSString *)waypointType;

- (NSDictionary *)UserStatistics;
- (NSDictionary *)UserStatistics:(NSString *)username;
- (NSInteger)CreateLogNote:(NSString *)logtype waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite;
- (BOOL)updateWaypoint:(dbWaypoint *)waypoint;

@end
