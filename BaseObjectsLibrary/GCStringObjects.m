/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface GCString ()

@property (nonatomic, retain) NSMutableString *sfn;

@end

@implementation GCString

- (instancetype)initWithString:(NSString *)s
{
    self = [super init];
    self.sfn = [NSMutableString stringWithString:s];
    return self;
}

- (instancetype)initWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    self = [super init];
    self.sfn = [[NSMutableString alloc] initWithData:data encoding:encoding];
    return self;
}

- (NSData *)dataUsingEncoding:(NSStringEncoding)encoding
{
    return [self.sfn dataUsingEncoding:encoding];
}

- (NSUInteger)length
{
    return [self.sfn length];
}

- (NSString *)description
{
    return [self.sfn description];
}

- (NSString *)_string
{
    return self.sfn;
}

@end

@interface GCStringGPX ()

@end

@implementation GCStringGPX

@end

@interface GCStringGPXGarmin ()

@end

@implementation GCStringGPXGarmin

@end

@interface GCStringFilename ()

@end

@implementation GCStringFilename

@end
