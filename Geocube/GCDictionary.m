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

@interface GCDictionary ()

@end

@implementation GCDictionary
{
    NSDictionary *d;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary
{
    self = [super self];
    d = [NSDictionary dictionaryWithDictionary:otherDictionary];
    return self;
}

- (id)objectForKey:(NSString *)aKey
{
    return [d objectForKey:aKey];
}

- (id)valueForKey:(NSString *)aKey
{
    return [d valueForKey:aKey];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block
{
    [d enumerateKeysAndObjectsUsingBlock:block];
}

- (NSUInteger)count
{
    return [d count];
}

- (NSString *)description
{
    return [d description];
}

- (NSDictionary *)_dict
{
    return d;
}

@end

@interface GCDictionaryGCA2 ()

@end

@implementation GCDictionaryGCA2

@end

@interface GCDictionaryLiveAPI ()

@end

@implementation GCDictionaryLiveAPI

@end

@interface GCDictionaryOKAPI ()

@end

@implementation GCDictionaryOKAPI

@end

@interface GCDictionaryGGCW ()

@end

@implementation GCDictionaryGGCW

@end
