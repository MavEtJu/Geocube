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

#import <Foundation/Foundation.h>

#import "ToolsLibrary/InfoItem.h"

@class InfoViewer;

@interface DownloadManager : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

/*
 * Download an image now.
 */
- (NSData *)downloadImage:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error;

/*
 * Download the contents of an URL now.
 */
- (NSData *)downloadSynchronous:(NSURLRequest *)urlRequest returningResponse:(NSHTTPURLResponse **)response error:(NSError **)error infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

/*
 * Add  the contents of an URL to the download queue.
 */
- (NSDictionary *)downloadAsynchronous:(NSURLRequest *)urlRequest semaphore:(dispatch_semaphore_t)sem infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end

extern DownloadManager *downloadManager;
