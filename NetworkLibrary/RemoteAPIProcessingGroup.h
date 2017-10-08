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

@interface RemoteAPIProcessingGroup : NSObject

- (void)clearAll;
- (NSString *)description:(NSInteger)identifier;
- (void)addIdentifier:(NSInteger)identifier;
- (void)removeIdentifier:(NSInteger)identifier;
- (BOOL)hasIdentifier:(NSInteger)identifier;
- (BOOL)hasIdentifiers;

- (void)expectedChunks:(NSInteger)identifier chunks:(NSInteger)chunks;
- (void)increaseDownloadedChunks:(NSInteger)identifier;
- (void)increaseProcessedChunks:(NSInteger)identifier;
- (NSInteger)expectedChunks:(NSInteger)identifier;
- (NSInteger)downloadedChunks:(NSInteger)identifier;
- (NSInteger)processedChunks:(NSInteger)identifier;
- (BOOL)hasAllProcessed:(NSInteger)identifier;

@end
