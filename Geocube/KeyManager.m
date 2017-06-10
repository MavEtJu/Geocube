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

@end

@implementation KeyManager

- (instancetype)init
{
    self = [super init];

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EncryptionKeys" ofType:@"plist"];
    NSDictionary *contentDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    self.gca_api = [contentDict objectForKey:@"gca-api"];
    self.googlemaps = [contentDict objectForKey:@"googlemaps"];
    self.mapbox = [contentDict objectForKey:@"mapbox"];
    self.sharedsecret = [contentDict objectForKey:@"sharedsecret"];

    return self;
}

@end
