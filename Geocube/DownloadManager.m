/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface DownloadManager ()
{
    NSMutableArray *asyncRequests;
}

@end

@implementation DownloadManager

- (instancetype)init
{
    self = [super init];

    asyncRequests = [NSMutableArray arrayWithCapacity:10];

    return self;
}

/////////////////////////////////////////////////////////////////////////

- (NSDictionary *)downloadAsynchronous:(NSURLRequest *)urlRequest semaphore:(dispatch_semaphore_t)sem downloadInfoItem:(InfoItem *)iti
{
    NSMutableDictionary *req = [NSMutableDictionary dictionaryWithCapacity:10];
    [req setObject:urlRequest forKey:@"urlRequest"];
    [req setObject:sem forKey:@"semaphore"];
    [req setObject:(iti == nil ? [NSNull null] : iti) forKey:@"downloadInfoItem"];
    if (iti != nil)
        [iti setURL:urlRequest.URL.absoluteString];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [req setObject:sessionConfiguration forKey:@"sessionConfiguration"];
    sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    [req setObject:session forKey:@"session"];

    NSData *data = [NSMutableData dataWithLength:0];
    [req setObject:data forKey:@"data"];

    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:urlRequest];
    [req setObject:sessionDataTask forKey:@"task"];

    [req setObject:[NSNumber numberWithBool:NO] forKey:@"completed"];

    [sessionDataTask resume];

    @synchronized (asyncRequests) {
        [asyncRequests addObject:req];
    }

    return req;
}

- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error downloadInfoItem:(InfoItem *)iti
{
    return [self sendSynchronousRequest:urlRequest returningResponse:response error:error downloadInfoItem:iti];
}

- (NSData *)downloadImage:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error
{
    return [self imageSynchronousRequest:urlRequest returningResponse:response error:error];
}

- (NSData *)imageSynchronousRequest:(NSURLRequest *)urlRequest returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr
{
    dispatch_semaphore_t sem;
    __block NSData *result;

    result = nil;
    sem = dispatch_semaphore_create(0);

    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL)
                                             *errorPtr = error;
                                         if (responsePtr != NULL)
                                             *responsePtr = response;
                                         if (error == nil)
                                             result = data;
                                         dispatch_semaphore_signal(sem);
                                     }] resume];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return result;
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)urlRequest returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr downloadInfoItem:(InfoItem *)iti
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iti];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    *responsePtr = [retDict objectForKey:@"response"];
    if (errorPtr != nil)
        *errorPtr = [retDict objectForKey:@"error"];

    return data;
}

/////////////////////////////////////////////////////////////////////////

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"URLSession:(NSURLSession *) task:(NSURLSessionTask *) didCompleteWithError:(NSError *)");

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && task == [req objectForKey:@"task"]) {
                [req setObject:[NSNumber numberWithBool:YES] forKey:@"completed"];
                if (error != nil)
                    [req setObject:error forKey:@"error"];
                [asyncRequests removeObjectAtIndex:idx];
                dispatch_semaphore_signal([req objectForKey:@"semaphore"]);

                InfoItemDownload *iid = [req objectForKey:@"downloadInfoItem"];
                if (iid != nil && [iid isKindOfClass:[NSNull class]] == NO) {
                    NSMutableData *d = [req objectForKey:@"data"];
                    [iid setBytesCount:[d length]];
                    [iid setBytesTotal:[d length]];
                }

                *stop = YES;
                NSLog(@"Finished download thread %ld", (long)idx);
                return;
            }
        }];
    }

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
//  NSLog(@"URLSession:(NSURLSession *) dataTask:(NSURLSessionTask *) didReceiveData:(NSData *)");

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && dataTask == [req objectForKey:@"task"]) {
                NSMutableData *d = [req objectForKey:@"data"];
                [d appendData:data];

                InfoItemDownload *iid = [req objectForKey:@"downloadInfoItem"];
                if (iid != nil && [iid isKindOfClass:[NSNull class]] == NO)
                    [iid setBytesCount:[d length]];

                *stop = YES;
                return;
            }
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"URLSession:(NSURLSession *) dataTask:(NSURLSessionTask *) didReceiveResponse:(NSURLResponse *)");

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && dataTask == [req objectForKey:@"task"]) {
                NSLog(@"Starting download thread %ld", (long)idx);
                completionHandler(NSURLSessionResponseAllow);
                [req setObject:response forKey:@"response"];

                InfoItemDownload *iid = [req objectForKey:@"downloadInfoItem"];
                if (iid != nil && [iid isKindOfClass:[NSNull class]] == NO)
                    [iid setBytesTotal:(NSInteger)response.expectedContentLength];

                *stop = YES;
                return;
            }
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSLog(@"URLSession:(NSURLSession *) task:(NSURLSessionTask *) willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler");
    if (redirectResponse != nil)
        completionHandler(nil);
}

@end
