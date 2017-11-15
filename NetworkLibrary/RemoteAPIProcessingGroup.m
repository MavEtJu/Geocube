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

@property (nonatomic, retain) NSMutableDictionary *expected;
@property (nonatomic, retain) NSMutableDictionary *processed;
@property (nonatomic, retain) NSMutableDictionary *downloaded;

@end

@implementation RemoteAPIProcessingGroup

- (instancetype)init
{
    self = [super init];

    @synchronized(self) {
        self.expected = [NSMutableDictionary dictionaryWithCapacity:10];
        self.processed = [NSMutableDictionary dictionaryWithCapacity:10];
        self.downloaded = [NSMutableDictionary dictionaryWithCapacity:10];
    }

    return self;
}

- (NSString *)description:(NSInteger)identifier
{
    return [NSString stringWithFormat:@"expected:%@ processed:%@ downloaded:%@",
            [self.expected objectForKey:[NSNumber numberWithInteger:identifier]],
            [self.processed objectForKey:[NSNumber numberWithInteger:identifier]],
            [self.downloaded objectForKey:[NSNumber numberWithInteger:identifier]]
            ];
}

- (void)clearAll
{
    @synchronized(self) {
        [self.expected removeAllObjects];
        [self.processed removeAllObjects];
        [self.downloaded removeAllObjects];
    }
}

- (void)addIdentifier:(NSInteger)identifier
{
    @synchronized(self) {
        [self.expected setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
        [self.processed setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
        [self.downloaded setObject:[NSNumber numberWithInteger:0] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)removeIdentifier:(NSInteger)identifier
{
    @synchronized(self) {
        [self.expected removeObjectForKey:[NSNumber numberWithInteger:identifier]];
        [self.processed removeObjectForKey:[NSNumber numberWithInteger:identifier]];
        [self.downloaded removeObjectForKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (BOOL)hasIdentifier:(NSInteger)identifier
{
    @synchronized(self) {
        return [self.expected objectForKey:[NSNumber numberWithInteger:identifier]] != nil;
    }
}

- (BOOL)hasIdentifiers
{
    @synchronized(self) {
        return ([self.expected count] != 0);
    }
}

- (void)expectedChunks:(NSInteger)identifier chunks:(NSInteger)chunks
{
    @synchronized(self) {
        [self.expected setObject:[NSNumber numberWithInteger:chunks] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)increaseDownloadedChunks:(NSInteger)identifier
{
    @synchronized(self) {
        NSNumber *n = [self.downloaded objectForKey:[NSNumber numberWithInteger:identifier]];
        [self.downloaded setObject:[NSNumber numberWithInteger:1 + [n integerValue]] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (void)increaseProcessedChunks:(NSInteger)identifier
{
    @synchronized(self) {
        NSNumber *n = [self.processed objectForKey:[NSNumber numberWithInteger:identifier]];
        [self.processed setObject:[NSNumber numberWithInteger:1 + [n integerValue]] forKey:[NSNumber numberWithInteger:identifier]];
    }
}

- (NSInteger)expectedChunks:(NSInteger)identifier;
{
    @synchronized(self) {
        return [[self.expected objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (NSInteger)downloadedChunks:(NSInteger)identifier;
{
    @synchronized(self) {
        return [[self.downloaded objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (NSInteger)processedChunks:(NSInteger)identifier;
{
    @synchronized(self) {
        return [[self.processed objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
    }
}

- (BOOL)hasAllProcessed:(NSInteger)identifier
{
    @synchronized(self) {
        NSInteger e = [[self.expected objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
        NSInteger p = [[self.processed objectForKey:[NSNumber numberWithInteger:identifier]] integerValue];
        return e == p;
    }
}

@end
