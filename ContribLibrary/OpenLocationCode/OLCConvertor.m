//
//  OpenLocationCode.m
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

#import <Foundation/Foundation.h>

#import "OLCConvertor.h"

@interface OLCConvertor ()

/// A separator used to break the code into two parts to aid memorability.
@property (nonatomic, retain) NSString *kSeparator;

/// String representation of kSeparator.
@property (nonatomic, retain) NSString *kSeparatorString;

/// The number of characters to place before the separator.
@property (nonatomic        ) NSInteger kSeparatorPosition;

/// The character used to pad codes.
@property (nonatomic, retain) NSString *kPaddingCharacter;

/// String representation of kPaddingCharacter.
@property (nonatomic, retain) NSString *kPaddingCharacterString;

/// The character set used to encode the values.
@property (nonatomic, retain) NSString *kCodeAlphabet;

/// CharacterSet representation of kCodeAlphabet.
@property (nonatomic, retain) NSCharacterSet *kCodeAlphabetCharset;

/// The base to use to convert numbers to/from.
@property (nonatomic        ) NSInteger kEncodingBase;

/// The maximum value for latitude in degrees.
@property (nonatomic        ) NSInteger kLatitudeMax;

/// The maximum value for longitude in degrees.
@property (nonatomic        ) NSInteger kLongitudeMax;

/// Maximum code length using lat/lng pair encoding. The area of such a
/// code is approximately 13x13 meters (at the equator), and should be suitable
/// for identifying buildings. This excludes prefix and separator characters.
@property (nonatomic        ) NSInteger kPairCodeLength;

/// The resolution values in degrees for each position in the lat/lng pair
/// encoding. These give the place value of each position, and therefore the
/// dimensions of the resulting area.  Each value is the previous, divided
/// by the base (kCodeAlphabet.length).
@property (nonatomic, retain) NSArray<NSNumber *> *kPairResolutions;

/// Number of columns in the grid refinement method.
@property (nonatomic        ) NSInteger kGridColumns;

/// Number of rows in the grid refinement method.
@property (nonatomic        ) NSInteger kGridRows;

/// Size of the initial grid in degrees.
@property (nonatomic        ) CLLocationDegrees kGridSizeDegrees;

/// Minimum length of a code that can be shortened.
@property (nonatomic        ) NSInteger kMinTrimmableCodeLen;

/// Space/padding characters. Unioned with kCodeAlphabet, forms the
/// complete valid charset for Open Location Codes.
@property (nonatomic, retain) NSCharacterSet *kLegalCharacters;

/// Default size of encoded Open Location Codes.
@property (nonatomic        ) NSInteger kDefaultFullCodeLength;

/// Default truncation amount for short codes.
@property (nonatomic        ) NSInteger kDefaultShortCodeTruncation;

/// Minimum amount to truncate a short code if it will be truncated.
/// Avoids creating short codes that are not really worth the shortening (i.e.
/// chars saved doesn't make up for need to resolve).
@property (nonatomic        ) NSInteger kMinShortCodeTruncation;

@end

@implementation OLCConvertor

- (instancetype)init
{
    self = [super init];

    /// A separator used to break the code into two parts to aid memorability.
    self.kSeparator = @"+";

    /// String representation of kSeparator.
    self.kSeparatorString = self.kSeparator;

    /// The number of characters to place before the separator.
    self.kSeparatorPosition = 8;

    /// The character used to pad codes.
    self.kPaddingCharacter = @"0";

    /// String representation of kPaddingCharacter.
    self.kPaddingCharacterString = self.kPaddingCharacter;

    /// The character set used to encode the values.
    self.kCodeAlphabet = @"23456789CFGHJMPQRVWX";

    /// CharacterSet representation of kCodeAlphabet.
    self.kCodeAlphabetCharset = [NSCharacterSet characterSetWithCharactersInString:self.kCodeAlphabet];

    /// The base to use to convert numbers to/from.
    self.kEncodingBase = [self.kCodeAlphabet length];

    /// The maximum value for latitude in degrees.
    self.kLatitudeMax = 90.0;

    /// The maximum value for longitude in degrees.
    self.kLongitudeMax = 180.0;

    /// Maximum code length using lat/lng pair encoding. The area of such a
    /// code is approximately 13x13 meters (at the equator), and should be suitable
    /// for identifying buildings. This excludes prefix and separator characters.
    self.kPairCodeLength = 10;

    /// The resolution values in degrees for each position in the lat/lng pair
    /// encoding. These give the place value of each position, and therefore the
    /// dimensions of the resulting area.  Each value is the previous, divided
    /// by the base (kCodeAlphabet.length).
    self.kPairResolutions = @[@20.0, @1.0, @0.05, @0.0025, @0.000125];

    /// Number of columns in the grid refinement method.
    self.kGridColumns = 4;

    /// Number of rows in the grid refinement method.
    self.kGridRows = 5;

    /// Size of the initial grid in degrees.
    self.kGridSizeDegrees = 0.000125;

    /// Minimum length of a code that can be shortened.
    self.kMinTrimmableCodeLen = 6;

    /// Space/padding characters. Unioned with kCodeAlphabet, forms the
    /// complete valid charset for Open Location Codes.
    self.kLegalCharacters = [NSCharacterSet characterSetWithCharactersInString:@"23456789CFGHJMPQRVWX+0"];

    /// Default size of encoded Open Location Codes.
    self.kDefaultFullCodeLength = 11;

    /// Default truncation amount for short codes.
    self.kDefaultShortCodeTruncation = 4;

    /// Minimum amount to truncate a short code if it will be truncated.
    /// Avoids creating short codes that are not really worth the shortening (i.e.
    /// chars saved doesn't make up for need to resolve).
    self.kMinShortCodeTruncation = 4;

    return self;
}

- (BOOL)isValid:(NSString *)code
{
    // The separator is required.
    NSRange sep = [code rangeOfString:self.kSeparator];
    if (sep.location == NSNotFound)
        return NO;
    // Only one seperator is required.
    NSRange rsep = [code rangeOfString:self.kSeparator options:NSBackwardsSearch];
    if (rsep.location != sep.location)
        return NO;

    // Is it the only character?
    if ([code length] == 1)
        return NO;

    // Is it in an illegal position?
    if (sep.location > self.kSeparatorPosition || sep.location % 2 == 1)
        return NO;

    // We can have an even number of padding characters before the separator,
    // but then it must be the final character.
    NSRange pad = [code rangeOfString:self.kPaddingCharacterString];
    if (pad.location != NSNotFound) {
        // Not allowed to start with them!
        if (pad.location == 0)
            return NO;

        // There can only be one group and it must have even length.
        NSRange rpad = [code rangeOfString:self.kPaddingCharacterString options:NSBackwardsSearch];
        NSString *pads = [code substringWithRange:NSMakeRange(pad.location, rpad.location - pad.location + 1)];
        NSInteger padCharCount = [pads length] - [[pads stringByReplacingOccurrencesOfString:self.kPaddingCharacter withString:@""] length];
        if ([pads length] % 2 == 1 || padCharCount != [pads length])
            return NO;
        // Padded codes must end with a separator, make sure it does.
        if (pad.location + padCharCount + 1 != [code length])
            return NO;
    }
    // If there are characters after the separator, make sure there isn't just
    // one of them (not legal).
    if ([code length] - sep.location - 1 == 1)
        return NO;

    // Check the code contains only valid characters.
    NSCharacterSet *invalidChars = [self.kLegalCharacters invertedSet];
    NSRange ucrange = [[code uppercaseString] rangeOfCharacterFromSet:invalidChars];
    if (ucrange.location != NSNotFound)
        return NO;

    return YES;
}

/// Determines if a code is a valid short code.
/// A short Open Location Code is a sequence created by removing four or more
/// digits from an Open Location Code. It must include a separator
/// character.
///
/// - Parameter code: The Open Location Code to test.
/// - Returns: true if the code is a short Open Location Code.
- (BOOL)isShort:(NSString *)code
{
    // Check it's valid.
    if ([self isValid:code] == NO)
        return NO;

    // If there are less characters than expected before the SEPARATOR.
    NSRange sep = [code rangeOfString:self.kSeparatorString];
    if (sep.location != NSNotFound && sep.location < self.kSeparatorPosition)
        return YES;

    return NO;
}

// Determines if a code is a valid full Open Location Code.
// Not all possible combinations of Open Location Code characters decode to
// valid latitude and longitude values. This checks that a code is valid
// and also that the latitude and longitude values are legal. If the prefix
// character is present, it must be the first character. If the separator
// character is present, it must be after four characters.
///
/// - Parameter code: The Open Location Code to test.
/// - Returns: true if the code is a full Open Location Code.
- (BOOL)isFull:(NSString *)code
{
    if ([self isValid:code] == NO)
        return NO;

    // If it's short, it's not full
    if ([self isShort:code] == YES)
        return NO;

    // Work out what the first latitude character indicates for latitude.
    NSString *firstChar = [[code uppercaseString] substringToIndex:1];
    NSRange firstRange = [self.kCodeAlphabet rangeOfString:firstChar];
    CLLocationDegrees firstLatValue = firstRange.location * self.kEncodingBase;

    if (firstLatValue >= self.kLatitudeMax * 2)
        // The code would decode to a latitude of >= 90 degrees.
        return NO;

    if ([code length] > 1) {
        // Work out what the first longitude character indicates for longitude.
        NSString *firstChar = [[code uppercaseString] substringToIndex:1];
        NSRange firstRange = [self.kCodeAlphabet rangeOfString:firstChar];
        CLLocationDegrees firstLngValue = firstRange.location * self.kEncodingBase;

        if (firstLngValue >= self.kLongitudeMax * 2)
            // The code would decode to a longitude of >= 180 degrees.
            return NO;
    }
    return YES;
}

///  Clip a latitude into the range -90 to 90.
///
/// - Parameter latitude: A latitude in signed decimal degrees.
- (CLLocationDegrees)clipLatitude:(CLLocationDegrees)latitude
{
    return MIN(90.0, MAX(-90.0, latitude));
}

/// Compute the latitude precision value for a given code length. Lengths <=
/// 10 have the same precision for latitude and longitude, but lengths > 10
/// have different precisions due to the grid method having fewer columns than
/// rows.
- (NSInteger)computeLatitutePrecision:(NSInteger)codeLength
{
    if (codeLength <= 10)
        return pow(20, codeLength / -2 + 2);

    return pow(20.0, -3.0) / pow(self.kGridRows, codeLength - 10);
}

/// Normalize a longitude into the range -180 to 180, not including 180.
///
/// - Parameter longitude: A longitude in signed decimal degrees.
- (CLLocationDegrees)normalizeLongitude:(CLLocationDegrees)longitude
{
    while (longitude < -180)
        longitude += 360;
    while (longitude >= 180)
        longitude -= 360;

    return longitude;
}

/// Encode a location into a sequence of OLC lat/lng pairs.
/// This uses pairs of characters (longitude and latitude in that order) to
/// represent each step in a 20x20 grid. Each code, therefore, has 1/400th
/// the area of the previous code.
///
/// - Parameter latitude: A latitude in signed decimal degrees.
/// - Parameter longitude: A longitude in signed decimal degrees.
/// - Parameter codeLength: The number of significant digits in the output
///   code, not including any separator characters.
- (NSString *)encodePairsWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude codeLength:(NSInteger)codeLength
{
    NSMutableString *code = [NSMutableString stringWithString:@""];
    // Adjust latitude and longitude so they fall into positive ranges.
    CLLocationDegrees adjustedLatitude = latitude + self.kLatitudeMax;
    CLLocationDegrees adjustedLongitude = longitude + self.kLongitudeMax;
    // Count digits - can't use string length because it may include a separator
    // character.
    NSInteger digitCount = 0;
    while (digitCount < codeLength) {
        // Provides the value of digits in this place in decimal degrees.
        double placeValue = [[self.kPairResolutions objectAtIndex:digitCount / 2] doubleValue];
        // Do the latitude - gets the digit for this place and subtracts that for
        // the next digit.
        NSInteger digitValue = adjustedLatitude / placeValue;
        adjustedLatitude -= digitValue * placeValue;
        [code appendString:[self.kCodeAlphabet substringWithRange:NSMakeRange(digitValue, 1)]];
        digitCount += 1;
        // And do the longitude - gets the digit for this place and subtracts that
        // for the next digit.
        digitValue = adjustedLongitude / placeValue;
        adjustedLongitude -= digitValue * placeValue;
        [code appendString:[self.kCodeAlphabet substringWithRange:NSMakeRange(digitValue, 1)]];
        digitCount++;
        // Should we add a separator here?
        if (digitCount == self.kSeparatorPosition && digitCount < codeLength)
            [code appendString:self.kSeparator];
    }
    while ([code length] < self.kSeparatorPosition)
        [code appendString:@"0"];
    if ([code length] == self.kSeparatorPosition)
        [code appendString:self.kSeparator];

    return code;
}

/// Encode a location using the grid refinement method into an OLC string.
/// The grid refinement method divides the area into a grid of 4x5, and uses a
/// single character to refine the area. This allows default accuracy OLC
/// codes to be refined with just a single character.
///
/// - Parameter latitude: A latitude in signed decimal degrees.
/// - Parameter longitude: A longitude in signed decimal degrees.
/// - Parameter codeLength: The number of characters required.
/// - Returns: Open Location Code representing the given grid.
- (NSString *)encodeGridWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude codeLength:(NSInteger)codeLength
{
    NSMutableString *code = [NSMutableString stringWithString:@""];
    CLLocationDegrees latPlaceValue = self.kGridSizeDegrees;
    CLLocationDegrees lngPlaceValue = self.kGridSizeDegrees;
    // Adjust latitude and longitude so they fall into positive ranges and
    // get the offset for the required places.
    CLLocationDegrees adjustedLatitude = fmod(latitude + self.kLatitudeMax, latPlaceValue);
    CLLocationDegrees adjustedLongitude = fmod(longitude + self.kLongitudeMax, lngPlaceValue);

    for (NSInteger i = 0; i < codeLength; i++) {
        // Work out the row and column.
        NSInteger row = adjustedLatitude / (latPlaceValue / self.kGridRows);
        NSInteger col = adjustedLongitude / (lngPlaceValue / self.kGridColumns);
        latPlaceValue /= self.kGridRows;
        lngPlaceValue /= self.kGridColumns;
        adjustedLatitude -= row * latPlaceValue;
        adjustedLongitude -= col * lngPlaceValue;
        [code appendString:[self.kCodeAlphabet substringWithRange:NSMakeRange(row * self.kGridColumns + col, 1)]];
    }
    return code;
}

/// Encode a location into an Open Location Code.
/// Produces a code of the specified length, or the default length if no
/// length is provided.
/// The length determines the accuracy of the code. The default length is
/// 10 characters, returning a code of approximately 13.5x13.5 meters. Longer
/// codes represent smaller areas, but lengths > 14 are sub-centimetre and so
/// 11 or 12 are probably the limit of useful codes.
///
/// - Parameter latitude: A latitude in signed decimal degrees. Will be
///   clipped to the range -90 to 90.
/// - Parameter longitude: A longitude in signed decimal degrees. Will be
///   normalised to the range -180 to 180.
/// - Parameter codeLength: The number of significant digits in the output
///   code, not including any separator characters. Possible values are;
///   `2`, `4`, `6`, `8`, `10`, `11`, `12`, `13` and above. Lower values
///   indicate a larger area, higher values a more precise area.
///   You can also shorten a code after encoding for codes used with a
///   reference point (e.g. your current location, a city, etc).
///
/// - Returns: Open Location Code for the given coordinate.
- (NSString *)encodeLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    return [self encodeLatitude:latitude longitude:longitude codeLength:self.kDefaultFullCodeLength];
}

- (NSString *)encodeLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude codeLength:(NSInteger)codeLength
{
    if (codeLength < 2 || (codeLength < self.kPairCodeLength && codeLength % 2 == 1))
        // 'Invalid Open Location Code length - '
        return nil;

    // Ensure that latitude and longitude are valid.
    latitude = [self clipLatitude:latitude];
    longitude = [self normalizeLongitude:longitude];

    // Latitude 90 needs to be adjusted to be just less, so the returned code
    // can also be decoded.
    if (latitude == 90)
        latitude -= [self computeLatitutePrecision:codeLength];

    NSMutableString *code = [NSMutableString stringWithString:[self encodePairsWithLatitude:latitude longitude:longitude codeLength:MIN(codeLength, self.kPairCodeLength)]];
    // If the requested length indicates we want grid refined codes.
    if (codeLength > self.kPairCodeLength)
        [code appendString:[self encodeGridWithLatitude:latitude longitude:longitude codeLength:codeLength - self.kPairCodeLength]];

    return code;
}

/// Decode an OLC code made up of lat/lng pairs.
/// This decodes an OLC code made up of alternating latitude and longitude
/// characters, encoded using base 20.
///
/// - Parameter code: A valid OLC code, presumed to be full, but with the
///   separator removed.
- (OLCArea *)decodePairs:(NSString *)code
{
    // Get the latitude and longitude values. These will need correcting from
    // positive ranges.
    NSArray<NSNumber *> *latitude = [self decodePairsSequence:code offset:0];
    NSArray<NSNumber *> *longitude = [self decodePairsSequence:code offset:1];
    // Correct the values and set them into the CodeArea object.
    return [[OLCArea alloc] initWithLatitudeLo:([[latitude objectAtIndex:0] doubleValue] - self.kLatitudeMax) longitudeLo:([[longitude objectAtIndex:0] doubleValue] - self.kLongitudeMax) latitudeHi:([[latitude objectAtIndex:1] doubleValue] - self.kLatitudeMax) longitudeHi:([[longitude objectAtIndex:1] doubleValue] - self.kLongitudeMax) codeLength:[code length]];
}

/// Decode either a latitude or longitude sequence.
/// This decodes the latitude or longitude sequence of a lat/lng pair
//  encoding. Starting at the character at position offset, every second
/// character is decoded and the value returned.
///
/// - Parameter code: A valid OLC code, presumed to be full, with the
///   separator removed.
/// - Parameter offset: The character to start from.
/// - Returns: A pair of the low and high values. The low value comes from
///   decoding the
///   characters. The high value is the low value plus the resolution of the
///   last position. Both values are offset into positive ranges and will need
///   to be corrected before use.
- (NSArray<NSNumber *> *)decodePairsSequence:(NSString *)code offset:(NSInteger)offset
{
    NSInteger i = 0;
    CLLocationDegrees value = 0.0;
    while (i * 2 + offset < [code length]) {
        NSRange pos = [self.kCodeAlphabet rangeOfString:[code substringWithRange:NSMakeRange(i * 2 + offset, 1)]];
        double value3 = pos.location * [[self.kPairResolutions objectAtIndex:i] doubleValue];
        value += value3;
        i++;
    }
    return @[[NSNumber numberWithDouble:value], [NSNumber numberWithDouble:value + [[self.kPairResolutions objectAtIndex:i - 1] doubleValue]]];
}

/// Decode the grid refinement portion of an OLC code.
/// This decodes an OLC code using the grid refinement method.
///
/// - Parameter code: A valid OLC code sequence that is only the grid
///   refinement portion. This is the portion of a code starting at position
///   11.
- (OLCArea *)decodeGrid:(NSString *)code
{
    CLLocationDegrees latitudeLo = 0.0;
    CLLocationDegrees longitudeLo = 0.0;
    CLLocationDegrees latPlaceValue = self.kGridSizeDegrees;
    CLLocationDegrees lngPlaceValue = self.kGridSizeDegrees;
    NSInteger i = 0;
    while (i < [code length]) {
        NSRange codeIndex = [self.kCodeAlphabet rangeOfString:[code substringWithRange:NSMakeRange(i, 1)]];
        NSInteger row = codeIndex.location / self.kGridColumns;
        NSInteger col = codeIndex.location % self.kGridColumns;
        latPlaceValue /= self.kGridRows;
        lngPlaceValue /= self.kGridColumns;
        latitudeLo += row * latPlaceValue;
        longitudeLo += col * lngPlaceValue;
        i++;
    }
    return [[OLCArea alloc] initWithLatitudeLo:latitudeLo longitudeLo:longitudeLo latitudeHi:(latitudeLo + latPlaceValue) longitudeHi:(longitudeLo + lngPlaceValue) codeLength:[code length]];
}

/// Decodes an Open Location Code into the location coordinates.
/// Returns a OpenLocationCodeArea object that includes the coordinates of the
/// bounding box - the lower left, center and upper right.
///
/// - Parameter code: The Open Location Code to decode.
/// - Returns: A CodeArea object that provides the latitude and longitude of
///   two of the corners of the area, the center, and the length of the
///   original code.
- (OLCArea *)decode:(NSString *)code
{
    if ([self isFull:code] == NO)
        return nil;

    // Strip out separator character (we've already established the code is
    // valid so the maximum is one), padding characters and convert to upper
    // case.
    code = [code uppercaseString];
    code = [[code componentsSeparatedByCharactersInSet:[self.kCodeAlphabetCharset invertedSet]] componentsJoinedByString:@""];

    // Decode the lat/lng pair component.
    OLCArea *codeArea = [self decodePairs:[code substringToIndex:MIN(self.kPairCodeLength, [code length])]];
    if ([code length] <= self.kPairCodeLength)
        return codeArea;

    // If there is a grid refinement component, decode that.
    OLCArea *gridArea = [self decodeGrid:[code substringFromIndex:self.kPairCodeLength]];
    OLCArea *area = [[OLCArea alloc] initWithLatitudeLo:(codeArea.latitudeLo + gridArea.latitudeLo) longitudeLo:(codeArea.longitudeLo + gridArea.longitudeLo) latitudeHi:(codeArea.latitudeLo + gridArea.latitudeHi) longitudeHi:(codeArea.longitudeLo + gridArea.longitudeHi) codeLength:(codeArea.codeLength + gridArea.codeLength)];
    return area;
}

/// Recover the nearest matching code to a specified location.
/// Given a short Open Location Code of between four and seven characters,
/// this recovers the nearest matching full code to the specified location.
/// The number of characters that will be prepended to the short code, depends
/// on the length of the short code and whether it starts with the separator.
/// If it starts with the separator, four characters will be prepended. If it
/// does not, the characters that will be prepended to the short code, where S
/// is the supplied short code and R are the computed characters, are as
/// follows:
/// ```
/// SSSS  -> RRRR.RRSSSS
/// SSSSS   -> RRRR.RRSSSSS
/// SSSSSS  -> RRRR.SSSSSS
/// SSSSSSS -> RRRR.SSSSSSS
/// ```
///
/// Note that short codes with an odd number of characters will have their
/// last character decoded using the grid refinement algorithm.
///
/// - Parameter shortcode: A valid short OLC character sequence.
/// - Parameter referenceLatitude: The latitude (in signed decimal degrees) to
///   use to find the nearest matching full code.
/// - Parameter referenceLongitude: The longitude (in signed decimal degrees)
///   to use to find the nearest matching full code.
/// - Returns: The nearest full Open Location Code to the reference location
///   that matches the short code. If the passed code was not a valid short
///   code, but was a valid full code, it is returned unchanged.
- (NSString *)recoverNearestWithShortcode:(NSString *)shortcode referenceLatitude:(CLLocationDegrees)referenceLatitude referenceLongitude:(CLLocationDegrees)referenceLongitude
{
    // Passed short code is actually a full code.
    if ([self isFull:shortcode] == YES)
        return shortcode;

    // Passed short code is not valid.
    if ([self isShort:shortcode] == NO)
        return nil;

    // Ensure that latitude and longitude are valid.
    referenceLatitude = [self clipLatitude:referenceLatitude];
    referenceLongitude = [self normalizeLongitude:referenceLongitude];
    // Clean up the passed code.
    shortcode = [shortcode uppercaseString];
    // Compute the number of digits we need to recover.
    NSInteger paddingLength = self.kSeparatorPosition - [shortcode rangeOfString:self.kSeparatorString].location;
    // The resolution (height and width) of the padded area in degrees.
    double resolution = pow(20, 2 - (paddingLength / 2));
    // Distance from the center to an edge (in degrees).
    double halfResolution = resolution / 2.0;
    // Encodes the reference location, uses it to fill in the gaps of the
    // given short code, creating a full code, then decodes it.
    NSString *encodedReferencePoint = [self encodeLatitude:referenceLatitude longitude:referenceLongitude];

    NSString *expandedCode = [NSString stringWithFormat:@"%@%@", [encodedReferencePoint substringToIndex:paddingLength], shortcode];
    OLCArea *codeArea = [self decode:expandedCode];

    CLLocationDegrees latitudeCenter = codeArea.latitudeCenter;
    CLLocationDegrees longitudeCenter = codeArea.longitudeCenter;

    // How many degrees latitude is the code from the reference? If it is more
    // than half the resolution, we need to move it north or south but keep it
    // within -90 to 90 degrees.
    if (referenceLatitude + halfResolution < latitudeCenter &&
        latitudeCenter - resolution >= -self.kLatitudeMax) {
        // If the proposed code is more than half a cell north of the reference
        // location, it's too far, and the best match will be one cell south.
        latitudeCenter -= resolution;
    } else if (referenceLatitude - halfResolution > latitudeCenter &&
               latitudeCenter + resolution <= self.kLatitudeMax) {
        // If the proposed code is more than half a cell south of the reference
        // location, it's too far, and the best match will be one cell north.
        latitudeCenter += resolution;
    }
    // Adjust longitude if necessary.
    if (referenceLongitude + halfResolution < longitudeCenter) {
        longitudeCenter -= resolution;
    } else if (referenceLongitude - halfResolution > longitudeCenter) {
        longitudeCenter += resolution;
    }

    return [self encodeLatitude:latitudeCenter longitude:longitudeCenter codeLength:codeArea.codeLength];
}

/// Remove characters from the start of an OLC code.
/// This uses a reference location to determine how many initial characters
/// can be removed from the OLC code. The number of characters that can be
/// removed depends on the distance between the code center and the reference
/// location.
/// The minimum number of characters that will be removed is four. If more
/// than four characters can be removed, the additional characters will be
/// replaced with the padding character. At most eight characters will be
/// removed. The reference location must be within 50% of the maximum range.
/// This ensures that the shortened code will be able to be recovered using
/// slightly different locations.
///
/// - Parameter code: A full, valid code to shorten.
/// - Parameter latitude: A latitude, in signed decimal degrees, to use as the
///   reference point.
/// - Parameter longitude: A longitude, in signed decimal degrees, to use as
///   the reference point.
/// - Parameter maximumTruncation: The maximum number of characters to remove.
/// - Returns: Either the original code, if the reference location was not
///   close enough, or the original.
- (NSString *)shortenCode:(NSString *)code latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    return [self shortenCode:code latitude:latitude longitude:longitude maximumTruncation:self.kDefaultShortCodeTruncation];
}

- (NSString *)shortenCode:(NSString *)code latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude maximumTruncation:(NSInteger)maximumTruncation
{
    if ([self isFull:code] == NO)
        // Passed code is not valid and full
        return nil;

    if ([code rangeOfString:self.kPaddingCharacterString].location != NSNotFound)
        // Cannot shorten padded codes
        return nil;

    code = [code uppercaseString];
    OLCArea *codeArea = [self decode:code];
    if (codeArea.codeLength < self.kMinTrimmableCodeLen)
        // Code length must be at least kMinTrimmableCodeLen
        return nil;

    // Ensure that latitude and longitude are valid.
    latitude = [self clipLatitude:latitude];
    longitude = [self normalizeLongitude:longitude];
    // How close are the latitude and longitude to the code center.
    CLLocationDegrees coderange = MAX(fabs(codeArea.latitudeCenter - latitude),
                                      fabs(codeArea.longitudeCenter - longitude));

    for (NSInteger i = [self.kPairResolutions count] - self.kMinShortCodeTruncation/2; i >= 0; i--) {
        // Check if we're close enough to shorten. The range must be less than 1/2
        // the resolution to shorten at all, and we want to allow some safety, so
        // use 0.3 instead of 0.5 as a multiplier.
        if (coderange < [[self.kPairResolutions objectAtIndex:i] doubleValue] * 0.3) {
            NSInteger shortenby = MIN(maximumTruncation, (i+1)*2);
            // Trim it.
            NSString *shortcode = [code substringFromIndex:shortenby];
            return shortcode;
        }
    }
    return code;
}

@end
