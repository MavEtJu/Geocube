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

@interface LiveAPI ()
{
    RemoteAPI *remoteAPI;
    NSString *liveAPIPrefix;

    NSMutableArray *GSLogTypesEvents;
    NSMutableArray *GSLogTypesOthers;
    NSMutableDictionary *GSLogTypes;

    id delegate;
}

@end

@implementation LiveAPI

@synthesize delegate;

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;
    liveAPIPrefix = @"https://api.groundspeak.com/LiveV6/geocaching.svc/";

    GSLogTypesEvents = nil;
    GSLogTypesOthers = nil;

    return self;
}

- (NSArray *)logtypes:(NSString *)waypointType
{

    if (GSLogTypesEvents == nil)
        [self GetGeocacheDataTypes];

    if ([waypointType isEqualToString:@"event"] == YES) {
        NSMutableArray *rs = [NSMutableArray arrayWithCapacity:20];
        [GSLogTypesEvents enumerateObjectsUsingBlock:^(NSNumber *num1, NSUInteger idx, BOOL *stop) {
            [[GSLogTypes allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                if ([[GSLogTypes objectForKey:key] integerValue] == [num1 integerValue]) {
                    [rs addObject:key];
                    *stop = YES;
                }
            }];
        }];
        return rs;
    }

    NSMutableArray *rs = [NSMutableArray arrayWithCapacity:20];
    [GSLogTypesOthers enumerateObjectsUsingBlock:^(NSNumber *num1, NSUInteger idx, BOOL *stop) {
        [[GSLogTypes allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            if ([[GSLogTypes objectForKey:key] integerValue] == [num1 integerValue]) {
                [rs addObject:key];
                *stop = YES;
            }
        }];
    }];
    return rs;
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

- (BOOL)checkStatus:(NSDictionary *)dict
{
    dict = [dict valueForKey:@"Status"];
    if (dict == nil)
        return NO;
    NSNumber *n = [dict valueForKey:@"StatusCode"];
    if (n == nil)
        return NO;
    if ([n isEqualToNumber:[NSNumber numberWithInteger:0]] == NO) {
        remoteAPI.account.oauth_token = @"";
        [remoteAPI.account dbUpdateOAuthToken];
        return NO;
    }

    return YES;
}

/**************************************************************************/

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
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];

    NSDictionary *_d = [NSMutableDictionary dictionaryWithCapacity:20];
    [_d setValue:@"1.2.3.4" forKey:@"ApplicationSoftwareVersion"];
    [_d setValue:@"2.3.4.5" forKey:@"DeviceOperatingSystem"];
    [_d setValue:@"42" forKey:@"DeviceUniqueId"];
    [_dict setValue:_d forKey:@"DeviceInfo"];

    _d = [NSMutableDictionary dictionaryWithCapacity:20];
    [_d setValue:@"true" forKey:@"FavoritePointsData"];
    [_d setValue:@"true" forKey:@"PublicProfileData"];
    [_dict setValue:_d forKey:@"ProfileOptions"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetCacheIdsFavoritedByUser
{
    NSLog(@"GetCacheIdsFavoritedByUser");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetCacheIdsFavoritedByUser" parameters:[NSString stringWithFormat:@"accessToken=%@", [MyTools urlEncode:remoteAPI.oabb.token]]];

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
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetGeocacheDataTypes
{
    NSLog(@"GetGeocacheDataTypes");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetGeocacheDataTypes" parameters:[NSString stringWithFormat:@"accessToken=%@&logTypes=true", [MyTools urlEncode:remoteAPI.oabb.token]]];

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
    if ([self checkStatus:json] == NO)
        return nil;

    /* Get the following:
     * For events: Write note, Will Attend, Attended, Announcement
     * For waypoints: Found it, Didn't find it, Write note, Needs Archived, Temporary Disable Listing, Enable Listing,
     *                Needs Maintenance, Owner Maintenance, Update Coordinates
     * For trackable: Write note, Dropped Off, Retrieved It from a Cache, Discovered It
     */

    GSLogTypesEvents = [NSMutableArray arrayWithCapacity:20];
    GSLogTypesOthers = [NSMutableArray arrayWithCapacity:20];
    GSLogTypes = [NSMutableDictionary dictionaryWithCapacity:20];

    [[json valueForKey:@"EventLogTypeIds"] enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
        [GSLogTypesEvents addObject:num];
    }];
    [[json valueForKey:@"GeocacheLogTypeIds"] enumerateObjectsUsingBlock:^(NSNumber *num, NSUInteger idx, BOOL *stop) {
        [GSLogTypesOthers addObject:num];
    }];

    NSArray *d = [json objectForKey:@"WptLogTypes"];
    if (d == nil)
        return nil;

    [d enumerateObjectsUsingBlock:^(NSDictionary *gslt, NSUInteger idx, BOOL *stop) {
        if ([[gslt objectForKey:@"AdminActionable"] boolValue] == YES && [[gslt objectForKey:@"OwnerActionable"] boolValue] == NO)
            return;
        [GSLogTypes setValue:[NSNumber numberWithInteger:[[gslt objectForKey:@"WptLogTypeId"] integerValue]] forKey:[gslt objectForKey:@"WptLogTypeName"]];
    }];

    return json;
}

- (NSInteger)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite
{
    NSLog(@"CreateFieldNoteAndPublish");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"CreateFieldNoteAndPublish" method:@"POST"];

    /*
     * {
     *      "AccessToken":"String content",
     *      "CacheCode":"String content",
     *      "WptLogTypeId":9223372036854775807,
     *      "UTCDateLogged":"\/Date(928174800000-0700)\/",
     *      "Note":"String content",
     *      "PromoteToLog":true,
     *      "ImageData":{
     *              "FileCaption":"String content",
     *              "FileDescription":"String content",
     *              "FileName":"String content",
     *              "base64ImageData":"String content"
     *      },
     *      "FavoriteThisCache":true,
     *      "EncryptLogText":true,
     *      "UpdatedLatitude":1.26743233E+15,
     *      "UpdatedLongitude":1.26743233E+15
     * }
     */
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:20];

    NSInteger gslogtype;
    NSTimeInterval date;

    if (GSLogTypesEvents == nil)
        [self GetGeocacheDataTypes];

    gslogtype = [[GSLogTypes objectForKey:logtype] integerValue];

    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"YYYY-MM-dd"];
    NSDate *todayDate = [dateF dateFromString:dateLogged];
    date = [todayDate timeIntervalSince1970];

    [dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [dict setValue:waypointName forKey:@"CacheCode"];
    [dict setValue:[NSNumber numberWithLong:gslogtype] forKey:@"WptLogTypeId"];
    [dict setValue:[NSNumber numberWithLong:1000 * date] forKey:@"UTCDateLogged"];
    [dict setValue:[MyTools JSONEscape:note] forKey:@"Note"];
    [dict setValue:((favourite == YES) ? @"true" : @"false") forKey:@"FavoriteThisCache"];
    [dict setValue:[NSNumber numberWithBool:NO] forKey:@"EncryptLogText"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;
    //NSString *_body = [NSString stringWithFormat:@"{\"AccessToken\":\"%@\",\"CacheCode\":\"%@\",\"WptLogTypeId\":%ld,\"UTCDateLogged\":\"/Date(%ld000)/\",\"Note\":\"%@\",\"PromoteToLog\":true,\"FavoriteThisCache\":%@,\"EncryptLogText\":false}", remoteAPI.oabb.token, waypointName, (long)gslogtype, (long)date, [MyTools JSONEscape:note], (favourite == YES) ? @"true" : @"false"];
    //urlRequest.HTTPBody = [_body dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return 0;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO)
        return 0;

    NSDictionary *log = [json objectForKey:@"Log"];
    NSNumber *log_id = [log objectForKey:@"ID"];
    return [log_id integerValue];
}

- (NSDictionary *)SearchForGeocaches_waypointname:(NSString *)wpname
{
    NSLog(@"SearchForGeocaches_waypointname");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"SearchForGeocaches" method:@"POST"];

    /*
     * {
     *  "AccessToken": "SUJK5WNyq865waiqrZrfjSfO0XU=",
     *  "CacheCode": {
     *      "CacheCodes": [
     *          "GC3NZDM"
     *      ]
     *      },
     *  "GeocacheLogCount": 20,
     *  "IsLite": false,
     *  "MaxPerPage": 20,
     *  "TrackableLogCount": 1
     * }
     */
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"GeocacheLogCount"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"MaxPerPage"];
    [_dict setValue:[NSNumber numberWithInteger:1] forKey:@"TrackableLogCount"];
    [_dict setValue:[NSNumber numberWithBool:FALSE] forKey:@"IsLite"];

    NSArray *cachecode = @[wpname];
    NSDictionary *cachecodes = [NSDictionary dictionaryWithObject:cachecode forKey:@"CacheCodes"];
    [_dict setValue:cachecodes forKey:@"CacheCode"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center
{
    NSLog(@"SearchForGeocaches_pointradius");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"SearchForGeocaches" method:@"POST"];

    /*
     * {
     *  "AccessToken": "SUJK5WNyq865waiqrZrfjSfO0XU=",
     *  "PointRadius":{
     *      DistanceInMeters":9223372036854775807,
     *      Point":{
     *          Latitude":1.26743233E+15,
     *          Longitude":1.26743233E+15
     *      },
     *  },
     *  "GeocacheLogCount": 20,
     *  "IsLite": false,
     *  "MaxPerPage": 20,
     *  "TrackableLogCount": 1
     * }
     */
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"GeocacheLogCount"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"MaxPerPage"];
    [_dict setValue:[NSNumber numberWithInteger:1] forKey:@"TrackableLogCount"];
    [_dict setValue:[NSNumber numberWithBool:FALSE] forKey:@"IsLite"];

    NSDictionary *dd = [NSMutableDictionary dictionaryWithCapacity:20];
    [dd setValue:[NSNumber numberWithFloat:5000] forKey:@"DistanceInMeters"];

    NSDictionary *p = [NSMutableDictionary dictionaryWithCapacity:20];
    [p setValue:[NSNumber numberWithFloat:center.latitude] forKey:@"Latitude"];
    [p setValue:[NSNumber numberWithFloat:center.longitude] forKey:@"Longitude"];
    [dd setValue:p forKey:@"Point"];
    [_dict setValue:dd forKey:@"PointRadius"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetMoreGeocaches:(NSInteger)offset
{
    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetMoreGeocaches" method:@"POST"];

    /*
     * {
     *  "AccessToken": "SUJK5WNyq865waiqrZrfjSfO0XU=",
     *  "GeocacheLogCount": 20,
     *  "IsLite": false,
     *  "MaxPerPage": 20,
     *  "TrackableLogCount": 1
     *  "StartIndex":2147483647,
     * }
     */
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"GeocacheLogCount"];
    [_dict setValue:[NSNumber numberWithInteger:20] forKey:@"MaxPerPage"];
    [_dict setValue:[NSNumber numberWithInteger:1] forKey:@"TrackableLogCount"];
    [_dict setValue:[NSNumber numberWithBool:FALSE] forKey:@"IsLite"];
    [_dict setValue:[NSNumber numberWithInteger:offset] forKey:@"StartIndex"];
    [_dict setValue:[NSNumber numberWithBool:FALSE] forKey:@"IsSummaryOnly"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200)
        return nil;

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetPocketQueryList
{
    NSLog(@"GetPocketQueryList");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetPocketQueryList" parameters:[NSString stringWithFormat:@"accessToken=%@", [MyTools urlEncode:remoteAPI.oabb.token]]];

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
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetPocketQueryZippedFile:(NSString *)guid
{
    NSLog(@"GetPocketQueryZippedFile");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetPocketQueryZippedFile" parameters:[NSString stringWithFormat:@"accessToken=%@&pocketQueryGuid=%@", [MyTools urlEncode:remoteAPI.oabb.token], guid]];
    [urlRequest setTimeoutInterval:1000];

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
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

- (NSDictionary *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems
{
    NSLog(@"GetFullPocketQueryData");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetFullPocketQueryData" parameters:[NSString stringWithFormat:@"accessToken=%@&pocketQueryGuid=%@&startItem=%ld&maxItems=%ld", [MyTools urlEncode:remoteAPI.oabb.token], guid, startItem, numItems]];
    [urlRequest setTimeoutInterval:1000];

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
    if ([self checkStatus:json] == NO)
        return nil;

    return json;
}

@end