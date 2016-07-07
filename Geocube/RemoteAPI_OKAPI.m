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

@interface RemoteAPI_OKAPI ()
{
    RemoteAPI *remoteAPI;
    NSString *okapi_prefix;
    id delegate;
}

@end

@implementation RemoteAPI_OKAPI

@synthesize delegate;

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;
    okapi_prefix = @"okapi/services";

    return self;
}

- (BOOL)commentSupportsFavouritePoint
{
    return NO;
}
- (BOOL)commentSupportsPhotos
{
    return NO;
}
- (BOOL)commentSupportsRating
{
    return NO;
}
- (BOOL)commentSupportsTrackables
{
    return NO;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return NO;
}

- (NSString *)string_array:(NSArray *)fields
{
    return [MyTools urlEncode:[fields componentsJoinedByString:@"|"]];
}

- (GCMutableURLRequest *)prepareURLRequest:(NSString *)url parameters:(NSString *)parameters
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@%@", remoteAPI.account.url_site, okapi_prefix, url];
    if (parameters != nil)
        [urlString appendFormat:@"?%@", parameters];

    NSURL *urlURL = [NSURL URLWithString:urlString];
    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:urlURL];

    NSString *oauth = [remoteAPI.oabb oauth_header:urlRequest];
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

- (GCDictionaryOKAPI *)services_users_byUsername:(NSString *)username
{
    NSLog(@"services_users_byUsername");

    NSArray *fields = @[@"caches_found", @"caches_notfound", @"caches_hidden", @"rcmds_given", @"username", @"profile_url" ,@"uuid"];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/users/user" parameters:[NSString stringWithFormat:@"username=%@&fields=%@", remoteAPI.account.accountname_string, [self string_array:fields]]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200) {
//        if (response.statusCode == 400) {
//            [delegate alertError:@"OKAPI - Unable to submit request: No such user" error:error];
//        } else {
//            [delegate alertError:@"OKAPI - The server was unable to deal with the request" error:error];
//        }
        return nil;
    }

    GCDictionaryOKAPI *json = [[GCDictionaryOKAPI alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    return json;
}

- (NSInteger)services_logs_submit:(NSString *)logtype waypointName:(NSString *)waypointName dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite
{
    NSLog(@"services_logs_submit");

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/logs/submit" parameters:[NSString stringWithFormat:@"cache_code=%@&logtype=%@&comment_format=%@&comment=%@&when=%@&recommend=%@", [MyTools urlEncode:waypointName], [MyTools urlEncode:logtype], @"plaintext", [MyTools urlEncode:note], [MyTools urlEncode:dateLogged], favourite == YES ? @"true" : @"false"]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200) {
//        [delegate alertError:@"OKAPI - Unable to submit request" error:error];
        return 0;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BOOL success = [[json valueForKey:@"success"] boolValue];
    if (success == NO) {
//        [delegate alertError:[NSString stringWithFormat:@"OKAPI - %@", [json valueForKey:@"message"]] error:nil];
        return 0;
    }

   return -1;
}

- (NSString *)services_caches_formatters_gpx:(NSString *)wpname
{
    NSLog(@"services_caches_formatters_gpx: %@", wpname);

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/caches/formatters/gpx" parameters:[NSString stringWithFormat:@"cache_codes=%@&ns_ground=true&latest_logs=true", [MyTools urlEncode:wpname]]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    return retbody;
}

- (NSDictionary *)services_caches_search_nearest:(CLLocationCoordinate2D)center offset:(NSInteger)offset
{
    NSLog(@"services_caches_search_nearest: %@ at %ld", [Coordinates NiceCoordinates:center], offset);

    float radius = myConfig.mapSearchMaximumDistanceOKAPI / 1000;

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/caches/search/nearest" parameters:[NSString stringWithFormat:@"center=%@&radius=%f&offset=%ld&limit=20", [MyTools urlEncode:[NSString stringWithFormat:@"%0.1f|%0.1f", center.latitude, center.longitude]], radius, (long)offset]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;
    return json;
}

- (NSDictionary *)services_caches_geocaches:(NSArray *)wpcodes
{
    NSLog(@"services_caches_geocaches: (%lu) %@", [wpcodes count], [wpcodes objectAtIndex:0]);

    NSArray *fields = @[@"code", @"name", @"names", @"location", @"type", @"status", @"url", @"owner", @"gc_code", @"is_found", @"is_not_found", @"founds", @"notfounds", @"willattends", @"size", @"size2", @"difficulty", @"terrain", @"trip_time", @"trip_distance", @"rating", @"rating_votes", @"recommendations", @"req_passwd", @"short_description", @"short_descriptions", @"description", @"descriptions", @"hint2", @"hints2", @"images", @"preview_image", @"attr_acodes", @"attrnames", @"attribution_note", @"latest_logs", @"my_notes", @"trackables_count", @"trackables", @"alt_wpts", @"country", @"state", @"protection_areas", @"last_found", @"last_modified", @"date_created", @"date_hidden", @"internal_id"];

    GCMutableURLRequest *urlRequest = [self prepareURLRequest:@"/caches/geocaches" parameters:[NSString stringWithFormat:@"cache_codes=%@&fields=%@", [self string_array:wpcodes], [self string_array:fields]]];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [MyTools sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    if (error != nil)
        return nil;
    return json;
}

@end
