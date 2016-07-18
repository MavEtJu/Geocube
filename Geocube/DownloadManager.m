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
    dispatch_semaphore_t syncSem;

    NSURLSessionDataTask *syncSessionDataTask;
    NSURLSession *syncSession;
    NSError *syncError;
    NSMutableData *syncData;
    NSURLSessionConfiguration *syncSessionConfiguration;
    NSURLResponse *syncReponse;
}

@end

@implementation DownloadManager

@synthesize delegate;

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
    [delegate downloadManager_setQueueSize:42];
}

- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error
{
    return [self sendSynchronousRequest:urlRequest returningResponse:response error:error];
}

- (NSData *)sendSynchronousRequestX:(NSURLRequest *)urlRequest returningResponse:(NSURLResponse **)responsePtr error:(NSError **)errorPtr
{
    dispatch_semaphore_t sem;
    __block NSData *result;

    result = nil;
    sem = dispatch_semaphore_create(0);

    [delegate downloadManager_setURL:urlRequest.URL.absoluteString];
    [delegate downloadManager_setNumberBytesDownload:0];
    [delegate downloadManager_setNumberBytesTotal:0];

    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL)
                                             *errorPtr = error;
                                         if (responsePtr != NULL)
                                             *responsePtr = response;
                                         if (error == nil)
                                             result = data;
                                         [delegate downloadManager_setNumberBytesDownload:[data length]];
                                         [delegate downloadManager_setNumberBytesTotal:[data length]];
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

    [delegate downloadManager_setURL:urlRequest.URL.absoluteString];
    [delegate downloadManager_setNumberBytesDownload:0];
    [delegate downloadManager_setNumberBytesTotal:0];

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

    return syncData;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    syncError = error;
    [delegate downloadManager_setNumberBytesDownload:[syncData length]];
    [delegate downloadManager_setNumberBytesTotal:[syncData length]];

    dispatch_semaphore_signal(syncSem);
};

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [syncData appendData:data];
    [delegate downloadManager_setNumberBytesDownload:[syncData length]];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    syncReponse = response;
    if (response.expectedContentLength != 0)
        [delegate downloadManager_setNumberBytesTotal:response.expectedContentLength];
}

/////////////////////////////////////////////////////////////////////////

- (void)setDescription:(NSString *)description
{
    [delegate downloadManager_setDescription:description];
}

- (void)setURL:(NSString *)url
{
    [delegate downloadManager_setURL:url];
}

- (void)setNumberOfChunksTotal:(NSInteger)chunks
{
    [delegate downloadManager_setNumberOfChunksTotal:chunks];
}

- (void)setNumberOfChunksDownload:(NSInteger)chunks
{
    [delegate downloadManager_setNumberOfChunksDownload:chunks];
}

- (void)setNumberBytesTotal:(NSInteger)bytes
{
    [delegate downloadManager_setNumberBytesTotal:bytes];
}

- (void)setNumberBytesDownload:(NSInteger)bytes
{
    [delegate downloadManager_setNumberBytesDownload:bytes];
}

- (void)setBGDescription:(NSString *)description
{
    [delegate downloadManager_setBGDescription:description];
}

- (void)setBGURL:(NSString *)url
{
    [delegate downloadManager_setBGURL:url];
}

- (void)setBGNumberOfChunksTotal:(NSInteger)chunks
{
    [delegate downloadManager_setBGNumberOfChunksTotal:chunks];
}

- (void)setBGNumberOfChunksDownload:(NSInteger)chunks
{
    [delegate downloadManager_setBGNumberOfChunksDownload:chunks];
}

- (void)setBGNumberBytesTotal:(NSInteger)bytes
{
    [delegate downloadManager_setBGNumberBytesTotal:bytes];
}

- (void)setBGNumberBytesDownload:(NSInteger)bytes
{
    [delegate downloadManager_setBGNumberBytesDownload:bytes];
}

- (void)setQueueSize:(NSInteger)size
{
    [delegate downloadManager_setQueueSize:size];
}

@end
