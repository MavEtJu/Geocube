//
//  NSObject+OLCArea.m
//  OpenLocationCode
//
//  Created by Edwin Groothuis on 15/3/18.
//  Copyright © 2018 Edwin Groothuis. All rights reserved.
//

// Ported from open-location-code-swift.
// Original license:

//
//  Copyright 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//===----------------------------------------------------------------------===//
//
//  Convert between decimal degree coordinates and Open Location Codes. Shorten
//  and recover Open Location Codes for a given reference location.
//
//  Authored by William Denniss. Ported from openlocationcode.py.
//
//===----------------------------------------------------------------------===//

#import "OLCArea.h"

@interface OLCArea ()

@property (nonatomic) CLLocationDegrees kLatitudeMax;
@property (nonatomic) CLLocationDegrees kLongitudeMax;

@end

@implementation OLCArea

- (instancetype)initWithLatitudeLo:(CLLocationDegrees)latlo longitudeLo:(CLLocationDegrees)lonlo latitudeHi:(CLLocationDegrees)lathi longitudeHi:(CLLocationDegrees)lonhi codeLength:(NSInteger)codeLength
{
    self = [super init];

    /// The maximum value for latitude in degrees.
    self.kLatitudeMax = 90.0;

    /// The maximum value for longitude in degrees.
    self.kLongitudeMax = 180.0;

    self.latitudeLo = latlo;
    self.latitudeHi = lathi;
    self.longitudeLo = lonlo;
    self.longitudeHi = lonhi;
    self.codeLength = codeLength;

    self.latitudeCenter = (latlo + lathi) / 2;
    self.longitudeCenter = (lonlo + lonhi) / 2;

    self.latitudeCenter = MIN(latlo + (lathi - latlo) / 2, self.kLatitudeMax);
    self.longitudeCenter = MIN(lonlo + (lonhi - lonlo) / 2, self.kLongitudeMax);

    return self;
}

@end
