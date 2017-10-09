/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface RemoteAPIProcessingGroup ()
{
    NSMutableDictionary *expected;
    NSMutableDictionary *processed;
    NSMutableDictionary *downloaded;
}

@end

@implementation RemoteAPIProcessingGroup

- (instancetype)init
{
    self = [super init];

    @synchronized (self) {
        expected = [NSMutableDictionary dictionaryWithCapacity:10];
        processed = [NSMutableDictionary dictionaryWithCapacity:10];
        downloaded = [NSMutableDictionary dictionaryWithCapacity:10];
    }

    return self;
}

- (NSString *)description:(NSInteger)identifier
{
    return [NSString stringWithFormat:@"expected:%@ processed:%@ downloaded:%@",
            [expected objectForKey:[NSNumber numberWithInteger:identifier]],
            [processed objectForKey:[NSNumber numberWithInteger:identifier]],
            [downloaded objectForKey:[NSNumber numberWithInteger:identifier]]
            ];
}

- (void)clearAll
{
    @synchronized (self) {
        [expected removeAllObjects];
        [processed removeAllObjects];
        [downloaded removeAllObjects];
    }
}

- (void)addIdentifier:(NSInteger)identifier
{
    @synchronized (self) {
        [expected setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
        [processed setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
        [downloaded setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)removeIdentifier:(NSInteger)identifier
{
    @synchronized (self) {
        [expected removeObjectForKey:[NSNumber numberWithInteger:identifier]];
        [processed removeObjectForKey:[NSNumber numberWithInteger:identifier]];
        [downloaded removeObjectForKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (BOOL)hasIdentifier:(NSInteger)identifier
{
    @synchronized (self) {
        return [expected objectForKey:[NSNumber numberWithInteger:identifier]] != nil;
    }
}

- (BOOL)hasIdentifiers
{
    @synchronized (self) {
        return ([expected count] != 0);
    }
}

- (void)expectedChunks:(NSInteger)identifier chunks:(NSInteger)chunks
{
    @synchronized (self) {
        [expected setObject:[NSNumber numberWithInteger:chunks] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)increaseDownloadedChunks:(NSInteger)identifier
{
    @synchronized (self) {
        NSNumber *n = [downloaded objectForKey:[NSNumber numberWithInteger:identifier]];
        [downloaded setObject:[NSNumber numberWithInteger:1 + [n integerValue]] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)increaseProcessedChunks:(NSInteger)identifier
{
    @synchronized (self) {
        NSNumber *n = [processed objectForKey:[NSNumber numberWithInteger:identifier]];
        [processed setObject:[NSNumber numberWithInteger:1 + [n integerValue]] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (NSInteger)expectedChunks:(NSInteger)identifier;
{
    @synchronized (self) {
        return [[expected objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (NSInteger)downloadedChunks:(NSInteger)identifier;
{
    @synchronized (self) {
        return [[downloaded objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (NSInteger)processedChunks:(NSInteger)identifier;
{
    @synchronized (self) {
        return [[processed objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (BOOL)hasAllProcessed:(NSInteger)identifier
{
    @synchronized (self) {
        NSInteger e = [[expected objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
        NSInteger p = [[processed objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
        return e == p;
    }
}

@end
