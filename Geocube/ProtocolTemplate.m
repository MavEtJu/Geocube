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

@interface ProtocolTemplate ()

@end

@implementation ProtocolTemplate

NEEDS_OVERLOADING_BOOL(commentSupportsFavouritePoint)
NEEDS_OVERLOADING_BOOL(commentSupportsPhotos)
NEEDS_OVERLOADING_BOOL(commentSupportsRating)
NEEDS_OVERLOADING_BOOL(commentSupportsTrackables)
NEEDS_OVERLOADING_BOOL(waypointSupportsPersonalNotes)
- (instancetype)init:(RemoteAPI *)remoteAPI { NEEDS_OVERLOADING_ASSERT; return nil; }
- (NSArray *)logtypes:(NSString *)waypointType { NEEDS_OVERLOADING_ASSERT; return nil; }

@end

@implementation NSStringFilename
- (instancetype)initWithString:(NSString *)s
{
    self = [super init];
    sfn = [NSMutableString stringWithString:s];
    return self;
}
- (NSString *)description
{
    return sfn;
}
@end

@implementation NSStringGPX
- (instancetype)initWithString:(NSString *)s
{
    self = [super init];
    sg = [NSMutableString stringWithString:s];
    return self;
}
- (NSString *)description
{
    return sg;
}
@end

@implementation NSDictionaryGCA
@end

@implementation NSDictionaryLiveAPI
@end

@implementation NSDictionaryOC
@end