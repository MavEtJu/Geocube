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

@interface ProtocolOKAPI ()

@property (nonatomic, retain) RemoteAPITemplate *remoteAPI;
@property (nonatomic, retain) NSString *okapi_prefix;

@end

@implementation ProtocolOKAPI

- (instancetype)init:(RemoteAPITemplate *)remoteAPI
{
    self = [super init];

    self.remoteAPI = remoteAPI;
    self.okapi_prefix = @"okapi/services";

    return self;
}

- (NSString *)string_array:(NSArray<NSString *> *)fields
{
    return [MyTools urlEncode:[fields componentsJoinedByString:@"|"]];
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url parameters:(NSString *)parameters
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@", self.remoteAPI.account.url_site, self.okapi_prefix, url];
    if (parameters != nil)
        [urlString appendFormat:@"?%@", parameters];

    NSURL *urlURL = [NSURL URLWithString:urlString];
    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:urlURL];

    NSString *oauth = [self.remoteAPI.oabb oauth_header:urlRequest];
    [urlRequest addValue:oauth forHTTPHeaderField:@"Authorization"];
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

- (GCDictionaryOKAPI *)performURLRequest:(NSURLRequest *)urlRequest infoItem:(InfoItem *)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem infoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//  NSLog(@"error: %@", [error description]);
//  NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//  NSLog(@"retbody: %@", retbody);

    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [self.remoteAPI setNetworkError:[error description] error:REMOTEAPI_APIREFUSED];
        return nil;
    }
    if (response.statusCode != 400 && response.statusCode != 200) {
        NSLog(@"statusCode: %ld", (long)response.statusCode);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [self.remoteAPI setAPIError:[NSString stringWithFormat:_(@"remoteapiokapi-HTTP Response was %ld"), (long)response.statusCode] error:REMOTEAPI_APIFAILED];
        return nil;
    }

    GCDictionaryOKAPI *json = [[GCDictionaryOKAPI alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [self.remoteAPI setAPIError:[error description] error:REMOTEAPI_JSONINVALID];
        return nil;
    }

    return json;
}

// -----------------------------------------------------

- (GCDictionaryOKAPI *)services_users_byUsername:(NSString *)username infoItem:(InfoItem *)iid
{
    NSLog(@"services_users_byUsername");

    NSArray<NSString *> *fields = @[@"caches_found", @"caches_notfound", @"caches_hidden", @"rcmds_given", @"username", @"profile_url", @"uuid"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];
    [_dict setObject:self.remoteAPI.account.accountname.name forKey:@"username"];
    [_dict setObject:[self string_array:fields] forKey:@"fields"];
    NSString *params = [MyTools urlParameterJoin:_dict];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/users/user" parameters:params];

    GCDictionaryOKAPI *json = [self performURLRequest:urlRequest infoItem:iid];

    return json;
}

- (GCDictionaryOKAPI *)services_logs_submit:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite infoItem:(InfoItem *)iid
{
    NSLog(@"services_logs_submit");

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];
    [_dict setObject:[MyTools urlEncode:waypointName] forKey:@"cache_code"];
    [_dict setObject:[MyTools urlEncode:dateLogged] forKey:@"logtype"];
    [_dict setObject:@"plaintext" forKey:@"comment_format"];
    [_dict setObject:[MyTools urlEncode:note] forKey:@"comment"];
    [_dict setObject:[MyTools urlEncode:dateLogged] forKey:@"when"];
    [_dict setObject:(favourite == YES ? @"true" : @"false") forKey:@"recommend"];
    NSString *params = [MyTools urlParameterJoin:_dict];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/logs/submit" parameters:params];

    GCDictionaryOKAPI *json = [self performURLRequest:urlRequest infoItem:iid];

    return json;
}

- (GCDictionaryOKAPI *)services_caches_geocache:(NSString *)wpname infoItem:(InfoItem *)iid
{
    NSLog(@"services_caches_geocache: %@", wpname);
    return [self services_caches_geocaches:@[wpname] infoItem:iid];
}

- (GCDictionaryOKAPI *)services_caches_search_bbox:(GCBoundingBox *)bbox infoItem:(InfoItem *)iid
{
    NSLog(@"services_caches_search_bbox:%@", [bbox description]);

    NSString *str = [NSString stringWithFormat:@"%f|%f|%f|%f", bbox.bottomLat, bbox.leftLon, bbox.topLat, bbox.rightLon];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];
    [_dict setObject:[MyTools urlEncode:str] forKey:@"bbox"];
    NSString *params = [MyTools urlParameterJoin:_dict];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/caches/search/bbox" parameters:params];

    GCDictionaryOKAPI *json = [self performURLRequest:urlRequest infoItem:iid];

    return json;
}

- (GCDictionaryOKAPI *)services_caches_geocaches:(NSArray<NSString *> *)wpcodes infoItem:(InfoItem *)iid
{
    NSLog(@"services_caches_geocaches: (%lu) %@", (unsigned long)[wpcodes count], [wpcodes objectAtIndex:0]);

    NSArray<NSString *> *fields = @[@"code", @"name", @"names", @"location", @"type", @"status", @"url", @"owner", @"gc_code", @"is_found", @"is_not_found", @"founds", @"notfounds", @"willattends", @"size", @"size2", @"difficulty", @"terrain", @"trip_time", @"trip_distance", @"rating", @"rating_votes", @"recommendations", @"req_passwd", @"short_description", @"short_descriptions", @"description", @"descriptions", @"hint2", @"hints2", @"images", @"preview_image", @"attr_acodes", @"attrnames", @"attribution_note", @"latest_logs", @"my_notes", @"trackables_count", @"trackables", @"alt_wpts", @"country", @"state", @"protection_areas", @"last_found", @"last_modified", @"date_created", @"date_hidden", @"internal_id"];

    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:20];
    [_dict setObject:[self string_array:wpcodes] forKey:@"cache_codes"];
    [_dict setObject:[self string_array:fields] forKey:@"fields"];
    NSString *params = [MyTools urlParameterJoin:_dict];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/caches/geocaches" parameters:params];

    GCDictionaryOKAPI *json = [self performURLRequest:urlRequest infoItem:iid];

    return json;
}

@end
