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

@protocol DownloadManagerDelegate

- (void)downloadManager_setDescription:(NSString *)description;
- (void)downloadManager_setURL:(NSString *)url;
- (void)downloadManager_setNumberOfChunksTotal:(NSInteger)chunks;
- (void)downloadManager_setNumberOfChunksDownload:(NSInteger)chunks;
- (void)downloadManager_setNumberBytesTotal:(NSInteger)bytes;
- (void)downloadManager_setNumberBytesDownload:(NSInteger)bytes;

- (void)downloadManager_setBGDescription:(NSString *)description;
- (void)downloadManager_setBGURL:(NSString *)url;
- (void)downloadManager_setBGNumberOfChunksTotal:(NSInteger)chunks;
- (void)downloadManager_setBGNumberOfChunksDownload:(NSInteger)chunks;
- (void)downloadManager_setBGNumberBytesTotal:(NSInteger)bytes;
- (void)downloadManager_setBGNumberBytesDownload:(NSInteger)bytes;

@end

@interface DownloadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, retain) id<DownloadManagerDelegate> downloadsImportsDelegate;

/*
 * Download an image now.
 */
- (NSData *)downloadImage:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error;

/*
 * Download the contents of an URL now.
 */
- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error downloadInfoItem:(InfoItem *)iti;

/*
 * Add  the contents of an URL to the download queue.
 */
- (NSDictionary *)downloadAsynchronous:(NSURLRequest *)urlRequest semaphore:(dispatch_semaphore_t)sem downloadInfoItem:(InfoItem *)idi;

/*
 * Reset the values of the foreground download view or the background download view back to their initial values.
 */
- (void)resetForegroundDownload;
- (void)resetBackgroundDownload;

/*
 * Set various fields
 */
- (void)setDescription:(NSString *)description;
- (void)setURL:(NSString *)url;
- (void)setNumberOfChunksTotal:(NSInteger)chunks;
- (void)setNumberOfChunksDownload:(NSInteger)chunks;
- (void)setNumberBytesTotal:(NSInteger)bytes;
- (void)setNumberBytesDownload:(NSInteger)bytes;
- (void)setBGDescription:(NSString *)description;
- (void)setBGURL:(NSString *)url;
- (void)setBGNumberOfChunksTotal:(NSInteger)chunks;
- (void)setBGNumberOfChunksDownload:(NSInteger)chunks;
- (void)setBGNumberBytesTotal:(NSInteger)bytes;
- (void)setBGNumberBytesDownload:(NSInteger)bytes;

@end
