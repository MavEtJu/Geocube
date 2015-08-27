//
//  RemoteAPI.h
//  Geocube
//
//  Created by Edwin Groothuis on 26/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;

@end

@interface RemoteAPI : NSObject <GCOAuthBlackboxDelegate> {
    GCOAuthBlackbox *oabb;

    LiveAPI *gs;
    OKAPI *okapi;
    GeocachingAustralia *gca;

    dbAccount *account;

    NSInteger stats_found, stats_notfound;
    id authenticationDelegate;
}

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic) NSInteger stats_found, stats_notfound;
@property (nonatomic) id authenticationDelegate;

- (id)init:(dbAccount*)account;
- (BOOL)Authenticate;
- (NSDictionary *)UserStatistics;
- (NSDictionary *)UserStatistics:(NSString *)username;

@end
