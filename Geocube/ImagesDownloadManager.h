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

@protocol ImagesDownloadManagerDelegate

- (void)updateQueuedImagesData:(NSInteger)queuedImages downloadedImages:(NSInteger)downloadedImages;

@end

@interface ImagesDownloadManager : NSObject

+ (NSInteger)findImagesInDescription:(NSId)wp_id text:(NSString *)desc type:(NSInteger)type;
+ (void)addToQueue:(dbImage *)img;
+ (void)addToQueueImmediately:(dbImage *)img;
- (void)addDelegate:(id)_delegate;
- (void)removeDelegate:(id)_delegate;

@end
