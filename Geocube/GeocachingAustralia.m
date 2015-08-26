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

@implementation GeocachingAustralia

- (id)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;

    return self;
}

- (NSDictionary *)cacher_statistic__finds:(NSString *)name
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/finds/", [MyTools urlencode:name]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (data == nil || response.statusCode != 200)
        return nil;

    // <div class='floater40'>Geocaching Australia Finds</div>
    // <div class='floater60'><b>49</b> </div>
    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    __block BOOL found = NO;
    __block NSDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];
    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL *stop) {
        if (found == YES) {
            // <div class='floater60'><b>49</b> </div>
            NSRange r = [l rangeOfString:@"<b>"];
            l = [l substringFromIndex:r.location + 3];
            r = [l rangeOfString:@"<"];
            l = [l substringToIndex:r.location];
            [ret setValue:l forKey:@"waypoints_found"];
            *stop = YES;
            return;
        }

        // <div class='floater40'>Geocaching Australia Finds</div>
        NSRange r = [l rangeOfString:@"Geocaching Australia Finds"];
        if (r.location == NSNotFound)
            return;
        found = YES;
    }];

    return ret;
}

@end
