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

@interface DownloadManager ()
{
    UIViewController *bezelViewController;
    NSString *bezelText;

    dispatch_semaphore_t syncSem;
    NSURLSessionDataTask *syncSessionDataTask;
    NSURLSession *syncSession;
    NSError *syncError;
    NSMutableData *syncData;
    NSURLSessionConfiguration *syncSessionConfiguration;
    NSURLResponse *syncReponse;

    NSMutableArray *asyncRequests;
}

@end

@implementation DownloadManager

@synthesize downloadsImportsDelegate;

- (instancetype)init
{
    self = [super init];

    asyncRequests = [NSMutableArray arrayWithCapacity:10];

    return self;
}

- (void)resetForegroundDownload
{
    [downloadsImportsViewController resetForegroundDownload];
}

- (void)resetBackgroundDownload
{
    [downloadsImportsViewController resetBackgroundDownload];
}

- (void)addToQueue:(NSString *)url outputFile:(NSString *)output
{
    [downloadsImportsDelegate downloadManager_setQueueSize:42];
}

/////////////////////////////////////////////////////////////////////////

- (NSDictionary *)downloadAsynchronous:(NSURLRequest *)urlRequest semaphore:(dispatch_semaphore_t)sem
{
    NSMutableDictionary *req = [NSMutableDictionary dictionaryWithCapacity:10];
    [req setObject:urlRequest forKey:@"urlRequest"];
    [req setObject:sem forKey:@"semaphore"];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [req setObject:sessionConfiguration forKey:@"sessionConfiguration"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:syncSessionConfiguration delegate:self delegateQueue:nil];
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

- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error
{
    return [self sendSynchronousRequest:urlRequest returningResponse:response error:error];
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

- (NSData *)sendSynchronousRequest:(NSURLRequest *)urlRequest returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr
{
    __block NSData *result;

    result = nil;
    syncSem = dispatch_semaphore_create(0);

    if (bezelText == nil)
        bezelText = @"Downloading";

    if (bezelViewController == nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [DejalBezelActivityView activityViewForView:downloadsImportsViewController.view withLabel:bezelText];
        }];
    }

    [downloadsImportsDelegate downloadManager_setURL:urlRequest.URL.absoluteString];
    [downloadsImportsDelegate downloadManager_setNumberBytesDownload:0];
    [downloadsImportsDelegate downloadManager_setNumberBytesTotal:0];

    syncSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    syncSession = [NSURLSession sessionWithConfiguration:syncSessionConfiguration delegate:self delegateQueue:nil];

    syncData = [NSMutableData dataWithLength:0];

    syncError = nil;
    syncReponse = nil;

    syncSessionDataTask = [syncSession dataTaskWithRequest:urlRequest];
    [syncSessionDataTask resume];

    dispatch_semaphore_wait(syncSem, DISPATCH_TIME_FOREVER);
    *errorPtr = syncError;
    *responsePtr = syncReponse;

    if (bezelViewController == nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [DejalBezelActivityView removeViewAnimated:YES];
        }];
    }

    return syncData;
}

/////////////////////////////////////////////////////////////////////////

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"URLSession:(NSURLSession *) task:(NSURLSessionTask *) didCompleteWithError:(NSError *)");
    if (session == syncSession && task == syncSessionDataTask) {
        syncError = error;
        [downloadsImportsDelegate downloadManager_setNumberBytesDownload:[syncData length]];
        [downloadsImportsDelegate downloadManager_setNumberBytesTotal:[syncData length]];

        dispatch_semaphore_signal(syncSem);
        return;
    }

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && task == [req objectForKey:@"task"]) {
                [req setObject:[NSNumber numberWithBool:YES] forKey:@"completed"];
                if (error != nil)
                    [req setObject:error forKey:@"error"];
                [asyncRequests removeObjectAtIndex:idx];
                dispatch_semaphore_signal([req objectForKey:@"semaphore"]);
                *stop = YES;
                NSLog(@"Finished download thread %ld", (long)idx);
                return;
            }
        }];
    }

};

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"URLSession:(NSURLSession *) dataTask:(NSURLSessionTask *) diReceiveData:(NSData *)");
    if (session == syncSession && dataTask == syncSessionDataTask) {
        [syncData appendData:data];
        [downloadsImportsDelegate downloadManager_setNumberBytesDownload:[syncData length]];
        return;
    }

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && dataTask == [req objectForKey:@"task"]) {
                NSMutableData *d = [req objectForKey:@"data"];
                [d appendData:data];
                *stop = YES;
                return;
            }
        }];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"URLSession:(NSURLSession *) dataTask:(NSURLSessionTask *) didReceiveResponse:(NSURLResponse *)");
    if (session == syncSession && dataTask == syncSessionDataTask) {
        completionHandler(NSURLSessionResponseAllow);
        syncReponse = response;
        if (response.expectedContentLength >= 0)
            [downloadsImportsDelegate downloadManager_setNumberBytesTotal:response.expectedContentLength];
        return;
    }

    @synchronized (asyncRequests) {
        [asyncRequests enumerateObjectsUsingBlock:^(NSMutableDictionary *req, NSUInteger idx, BOOL * _Nonnull stop) {
            if (session == [req objectForKey:@"session"] && dataTask == [req objectForKey:@"task"]) {
                NSLog(@"Starting download thread %ld", (long)idx);
                completionHandler(NSURLSessionResponseAllow);
                [req setObject:response forKey:@"response"];
                syncReponse = response;
                *stop = YES;
                return;
            }
        }];
    }
}

/////////////////////////////////////////////////////////////////////////

- (void)setBezelViewController:(UIViewController *)vc
{
    bezelViewController = vc;
    bezelText = @"Downloading";

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (bezelViewController == nil)
            [DejalBezelActivityView removeViewAnimated:YES];
        else
            [DejalBezelActivityView activityViewForView:bezelViewController.view withLabel:bezelText];
    }];
}

- (void)setBezelViewText:(NSString *)text
{
    bezelText = text;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView currentActivityView].activityLabel.text = text;
        [DejalBezelActivityView currentActivityView].labelWidth = 0;
    }];
}

/////////////////////////////////////////////////////////////////////////

- (void)setDescription:(NSString *)description
{
    [downloadsImportsDelegate downloadManager_setDescription:description];
}

- (void)setURL:(NSString *)url
{
    [downloadsImportsDelegate downloadManager_setURL:url];
}

- (void)setNumberOfChunksTotal:(NSInteger)chunks
{
    [downloadsImportsDelegate downloadManager_setNumberOfChunksTotal:chunks];
}

- (void)setNumberOfChunksDownload:(NSInteger)chunks
{
    [downloadsImportsDelegate downloadManager_setNumberOfChunksDownload:chunks];
}

- (void)setNumberBytesTotal:(NSInteger)bytes
{
    [downloadsImportsDelegate downloadManager_setNumberBytesTotal:bytes];
}

- (void)setNumberBytesDownload:(NSInteger)bytes
{
    [downloadsImportsDelegate downloadManager_setNumberBytesDownload:bytes];
}

- (void)setBGDescription:(NSString *)description
{
    [downloadsImportsDelegate downloadManager_setBGDescription:description];
}

- (void)setBGURL:(NSString *)url
{
    [downloadsImportsDelegate downloadManager_setBGURL:url];
}

- (void)setBGNumberOfChunksTotal:(NSInteger)chunks
{
    [downloadsImportsDelegate downloadManager_setBGNumberOfChunksTotal:chunks];
}

- (void)setBGNumberOfChunksDownload:(NSInteger)chunks
{
    [downloadsImportsDelegate downloadManager_setBGNumberOfChunksDownload:chunks];
}

- (void)setBGNumberBytesTotal:(NSInteger)bytes
{
    [downloadsImportsDelegate downloadManager_setBGNumberBytesTotal:bytes];
}

- (void)setBGNumberBytesDownload:(NSInteger)bytes
{
    [downloadsImportsDelegate downloadManager_setBGNumberBytesDownload:bytes];
}

- (void)setQueueSize:(NSInteger)size
{
    [downloadsImportsDelegate downloadManager_setQueueSize:size];
}

@end
