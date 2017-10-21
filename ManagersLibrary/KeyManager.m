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

@interface KeyManager ()

@property (nonatomic, retain) NSDictionary *contentDict;

@end

@implementation KeyManager

- (instancetype)init
{
    self = [super init];

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EncryptionKeys" ofType:@"plist"];
    self.contentDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    self.gca_api = [self.contentDict objectForKey:@"gca-api"];
    self.googlemaps = [self.contentDict objectForKey:@"googlemaps"];

    return self;
}

- (NSString *)sharedSecret:(NSString *)key
{
    return [self.contentDict objectForKey:[NSString stringWithFormat:@"sharedsecret_%@", key]];
}

- (NSString *)decrypt:(NSString *)key data:(NSString *)encryptedString
{
    NSString *password = [keyManager sharedSecret:key];
    if (password == nil) {
        NSLog(@"No password for %@, skipping decrypt", key);
        return nil;
    }
    NSError *error = nil;
    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:encryptedString options:0];
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:password error:&error];
    NSAssert(error == nil, [error description]);
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

- (NSString *)encrypt:(NSString *)key data:(NSString *)plainText
{
    NSString *password = [keyManager sharedSecret:key];
    NSError *error = nil;
    NSData *plainData = [plainText dataUsingEncoding:NSASCIIStringEncoding];
    NSData *encryptedData = [RNEncryptor encryptData:plainData withSettings:kRNCryptorAES256Settings password:password error:&error];
    NSAssert(error == nil, [error description]);
    return [encryptedData base64EncodedStringWithOptions:0];
}

@end
