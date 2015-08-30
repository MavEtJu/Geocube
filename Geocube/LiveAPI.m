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

#import "Geocube-Prefix.pch"

@implementation LiveAPI

- (id)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;
    liveAPIPrefix = @"https://api.groundspeak.com/LiveV6/geocaching.svc/";

    return self;
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url parameters:(NSString *)parameters
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", liveAPIPrefix, url];
    if (parameters != nil) {
        [urlString appendFormat:@"?format=json&%@", parameters];
    } else {
        [urlString appendString:@"?format=json"];
    }

    NSURL *urlURL = [NSURL URLWithString:urlString];
    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:urlURL];

    [urlRequest setValue:@"none" forHTTPHeaderField:@"Accept-Encoding"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    return urlRequest;
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url
{
    return [self prepareURLRequest:url parameters:nil];
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url method:(NSString *)method
{
    GCMutableURLRequest *req = [self prepareURLRequest:url parameters:nil];
    [req setHTTPMethod:method];
    return req;
}

- (NSDictionary *)GetYourUserProfile
{
    NSLog(@"GetYourUserProfile");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetYourUserProfile" method:@"POST"];

    /*
     * {
     *    "AccessToken": "D7dYifnoQrG6QrbpHlTFOuW/BI0=",
     *    "DeviceInfo": {
     *        "ApplicationSoftwareVersion": "4.98.2",
     *        "DeviceOperatingSystem": "10.10.5",
     *        "DeviceUniqueId": "8141B980-CF1B-491B-9247-18AB78A3A8B1"
     *    },
     *    "ProfileOptions": {
     *        "FavoritePointsData": "true",
     *        "PublicProfileData": "true"
     *    }
     * }
     */
    NSString *_body = [NSString stringWithFormat:@"{\"AccessToken\":\"%@\",\"ProfileOptions\":{\"PublicProfileData\":\"true\",\"EmailData\":\"true\"},\"DeviceInfo\":{ \"ApplicationSoftwareVersion\":\"1.2.3.4\",\"DeviceOperatingSystem\":\"2.3.4.5\",\"DeviceUniqueId\":\"42\"}}", remoteAPI.oabb.token];
    urlRequest.HTTPBody = [_body dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return json;
}

- (NSDictionary *)GetCacheIdsFavoritedByUser
{
    NSLog(@"GetCacheIdsFavoritedByUser");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetCacheIdsFavoritedByUser" parameters:[NSString stringWithFormat:@"accessToken=%@", [MyTools urlencode:remoteAPI.oabb.token]]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return json;
}

@end
