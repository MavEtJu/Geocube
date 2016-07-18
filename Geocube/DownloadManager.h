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

- (void)downloadManager_queueSize:(NSInteger)size;

@end

@interface DownloadManager : NSObject <NSURLSessionDelegate>

@property (nonatomic, retain) id delegate;

- (void)addToQueue:(NSString *)url outputFile:(NSString *)output;
- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error;

@end
