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

@interface RemoteAPI_LiveAPI ()
{
    RemoteAPI *remoteAPI;
    NSString *liveAPIPrefix;
}

@end

@implementation RemoteAPI_LiveAPI

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;
    liveAPIPrefix = @"https://api.groundspeak.com/LiveV6/geocaching.svc/";

    return self;
}

- (BOOL)commentSupportsFavouritePoint
{
    return YES;
}
- (BOOL)commentSupportsPhotos
{
    return YES;
}
- (BOOL)commentSupportsRating
{
    return NO;
}
- (BOOL)commentSupportsTrackables
{
    return YES;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return YES;
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
    if (dict == nil) {
        [remoteAPI.account disableRemoteAccess:@"No values returned."];
        return NO;
    }
    return [self checkStatusCode:dict];
}

- (BOOL)checkStatusCode:(NSDictionary *)dict
{
    NSNumber *n = [dict valueForKey:@"StatusCode"];
    if (n == nil) {
        [remoteAPI.account disableRemoteAccess:@"No status code given."];
        return NO;
    }
    if ([n isEqualToNumber:[NSNumber numberWithInteger:0]] == NO) {
        [remoteAPI.account disableRemoteAccess:[NSString stringWithFormat:@"StatusCode %@: %@", [dict objectForKey:@"StatusCode"], [dict objectForKey:@"StatusMessage"]]];
        //remoteAPI.account.oauth_token = @"";
        //[remoteAPI.account dbUpdateOAuthToken];
        return NO;
    }

    return YES;
}

/**************************************************************************/

- (GCDictionaryLiveAPI *)GetYourUserProfile:(InfoItemDowload *)iid
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

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetCacheIdsFavoritedByUser:(InfoItemDowload *)iid
{
    NSLog(@"GetCacheIdsFavoritedByUser");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetCacheIdsFavoritedByUser" parameters:[NSString stringWithFormat:@"accessToken=%@", [MyTools urlEncode:remoteAPI.oabb.token]]];

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"reponse"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)CreateFieldNoteAndPublish:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription imageData:(NSData *)imageData imageFilename:(NSString *)imageFilename downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"CreateFieldNoteAndPublish:%@", waypointName);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"CreateFieldNoteAndPublish" method:@"POST"];
    [urlRequest setTimeoutInterval:configManager.downloadTimeoutSimple];

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
    NSTimeInterval date;

    NSMutableDictionary *imageDict = nil;
    if (imageData != nil) {
        imageDict = [NSMutableDictionary dictionaryWithCapacity:20];
        [imageDict setValue:imageCaption forKey:@"FileCaption"];
        [imageDict setValue:imageDescription forKey:@"FileDescription"];
        [imageDict setValue:imageFilename forKey:@"FileName"];

        NSData *b = [imageData base64EncodedDataWithOptions:0];
        NSString *bs = [[NSString alloc] initWithData:b encoding:NSASCIIStringEncoding];
        [imageDict setValue:bs forKey:@"base64ImageData"];

        [dict setValue:imageDict forKey:@"ImageData"];
    }

    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"YYYY-MM-dd"];
    NSDate *todayDate = [dateF dateFromString:dateLogged];
    date = [todayDate timeIntervalSince1970];

    [dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [dict setValue:waypointName forKey:@"CacheCode"];
    [dict setValue:[NSNumber numberWithLong:[logtype integerValue]] forKey:@"WptLogTypeId"];
    [dict setValue:[NSString stringWithFormat:@"/Date(%ld)/", (long)(1000 * date)] forKey:@"UTCDateLogged"];
    [dict setValue:[MyTools JSONEscape:note] forKey:@"Note"];
    [dict setValue:((favourite == YES) ? @"true" : @"false") forKey:@"FavoriteThisCache"];
    [dict setValue:[NSNumber numberWithBool:NO] forKey:@"EncryptLogText"];
    [dict setValue:@"true" forKey:@"PromoteToLog"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;
    //NSString *_body = [NSString stringWithFormat:@"{\"AccessToken\":\"%@\",\"CacheCode\":\"%@\",\"WptLogTypeId\":%ld,\"UTCDateLogged\":\"/Date(%ld000)/\",\"Note\":\"%@\",\"PromoteToLog\":true,\"FavoriteThisCache\":%@,\"EncryptLogText\":false}", remoteAPI.oabb.token, waypointName, (long)gslogtype, (long)date, [MyTools JSONEscape:note], (favourite == YES) ? @"true" : @"false"];
    //urlRequest.HTTPBody = [_body dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    GCDictionaryLiveAPI *retJson = [[GCDictionaryLiveAPI alloc] initWithDictionary:json];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return retJson;
    }

    return retJson;
}

- (GCDictionaryLiveAPI *)SearchForGeocaches_waypointname:(NSString *)wpname downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"SearchForGeocaches_waypointname:%@", wpname);

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
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)SearchForGeocaches_pointradius:(CLLocationCoordinate2D)center downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"SearchForGeocaches_pointradius:%@", [Coordinates NiceCoordinates:center]);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"SearchForGeocaches" method:@"POST"];
    [urlRequest setTimeoutInterval:configManager.downloadTimeoutQuery];

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
    [dd setValue:[NSNumber numberWithFloat:configManager.mapSearchMaximumDistanceGS] forKey:@"DistanceInMeters"];

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
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetMoreGeocaches:(NSInteger)offset downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"GetMoreGeocaches:%ld", (long)offset);
    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetMoreGeocaches" method:@"POST"];
    [urlRequest setTimeoutInterval:configManager.downloadTimeoutQuery];

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
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetPocketQueryList:(InfoItemDowload *)iid
{
    NSLog(@"GetPocketQueryList");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetPocketQueryList" parameters:[NSString stringWithFormat:@"accessToken=%@", [MyTools urlEncode:remoteAPI.oabb.token]]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetPocketQueryZippedFile:(NSString *)guid downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"GetPocketQueryZippedFile:%@", guid);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetPocketQueryZippedFile" parameters:[NSString stringWithFormat:@"accessToken=%@&pocketQueryGuid=%@", [MyTools urlEncode:remoteAPI.oabb.token], guid]];
    [urlRequest setTimeoutInterval:configManager.downloadTimeoutQuery];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetFullPocketQueryData:(NSString *)guid startItem:(NSInteger)startItem numItems:(NSInteger)numItems downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"GetFullPocketQueryData:%@", guid);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetFullPocketQueryData" parameters:[NSString stringWithFormat:@"accessToken=%@&pocketQueryGuid=%@&startItem=%ld&maxItems=%ld", [MyTools urlEncode:remoteAPI.oabb.token], guid, (long)startItem, (long)numItems]];
    [urlRequest setTimeoutInterval:configManager.downloadTimeoutSimple];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)UpdateCacheNote:(NSString *)wpt_name text:(NSString *)text downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"UpdateCacheNote:%@", wpt_name);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"UpdateCacheNote" method:@"POST"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:wpt_name forKey:@"CacheCode"];
    [_dict setValue:text forKey:@"Note"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatusCode:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetUsersTrackables:(InfoItemDowload *)iid
{
    NSLog(@"GetUsersTrackables");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetUsersTrackables" method:@"POST"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:[NSNumber numberWithInteger:0] forKey:@"StartIndex"];
    [_dict setValue:[NSNumber numberWithInteger:30] forKey:@"MaxPerPage"];
    [_dict setValue:[NSNumber numberWithInteger:0] forKey:@"TrackableLogsCount"];
    [_dict setValue:[NSNumber numberWithBool:NO] forKey:@"CollectionOnly"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetOwnedTrackables:(InfoItemDowload *)iid
{
    NSLog(@"GetOwnedTrackables");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetOwnedTrackables" method:@"POST"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:[NSNumber numberWithInteger:0] forKey:@"StartIndex"];
    [_dict setValue:[NSNumber numberWithInteger:30] forKey:@"MaxPerPage"];
    [_dict setValue:[NSNumber numberWithInteger:0] forKey:@"TrackableLogsCount"];
    [_dict setValue:[NSNumber numberWithBool:NO] forKey:@"CollectionOnly"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)GetTrackablesByTrackingNumber:(NSString *)code downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"GetTrackablesByTrackingNumber:%@", code);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"GetTrackablesByTrackingNumber" parameters:[NSString stringWithFormat:@"accessToken=%@&trackingNumber=%@&trackableLogCount=0", [MyTools urlEncode:remoteAPI.oabb.token], code]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

- (GCDictionaryLiveAPI *)CreateTrackableLog:(dbWaypoint *)wp logtype:(NSString *)logtype trackable:(dbTrackable *)tb note:(NSString *)note dateLogged:(NSString *)dateLogged downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"CreateTrackableLog:%@", tb.ref);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"CreateTrackableLog" method:@"POST"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];

    /*
     "CacheCode":"String content",
     "TravelBugCode":"String content",
     "TrackingNumber":"String content",
     "UTCDateLogged":"\/Date(928174800000-0700)\/",
     "Note":"String content",
     "LogType":9223372036854775807,
     }*/

    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"YYYY-MM-dd"];
    NSDate *todayDate = [dateF dateFromString:dateLogged];
    time_t date = [todayDate timeIntervalSince1970];

    [_dict setValue:remoteAPI.oabb.token forKey:@"AccessToken"];
    [_dict setValue:wp.wpt_name forKey:@"CacheCode"];
    [_dict setValue:tb.code forKey:@"TrackingNumber"];
    [_dict setValue:tb.ref forKey:@"TravelBugCode"];
    [_dict setValue:[NSString stringWithFormat:@"/Date(%ld)/", (long)(1000 * date)] forKey:@"UTCDateLogged"];
    [_dict setValue:logtype forKey:@"LogType"];
    [_dict setValue:note forKey:@"Note"];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:_dict options:kNilOptions error:&error];
    urlRequest.HTTPBody = body;

    NSHTTPURLResponse *response = nil;
    error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error downloadInfoItem:iid];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (error != nil || response.statusCode != 200) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    GCDictionaryLiveAPI *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([self checkStatus:json] == NO) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        return nil;
    }

    return json;
}

@end
