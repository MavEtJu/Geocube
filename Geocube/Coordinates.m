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

@implementation Coordinates

- (id)init:(float)_lat lon:(float)_lon       // -34.02787 151.07357
{
    self = [super init];
    coords.latitude = _lat;
    coords.longitude= _lon;
    return self;
}
- (id)init:(CLLocationCoordinate2D)_coords           // { -34.02787, 151.07357 }
{
    self = [super init];
    coords.latitude = _coords.latitude;
    coords.longitude= _coords.longitude;
    return self;
}
- (NSString *)lat_decimalDegreesSigned     // -34.02787
{
    return [NSString stringWithFormat:@"%9.5f", coords.latitude];
}
- (NSString *)lon_decimalDegreesSigned     // 151.07357
{
    return [NSString stringWithFormat:@"%9.5f", coords.longitude];
}
- (NSString *)lat_decimalDegreesCardinal   // S 34.02787
{
    NSString *hemi = (coords.latitude < 0) ? @"S" : @"N";
    return [NSString stringWithFormat:@"%@ %9.5f", hemi, fabs(coords.latitude)];

}
- (NSString *)lon_decimalDegreesCardinal   // E 151.07357
{
    NSString *hemi = (coords.longitude < 0) ? @"W" : @"E";
    return [NSString stringWithFormat:@"%@ %9.5f", hemi, fabs(coords.longitude)];
}
- (NSString *)lat_degreesDecimalMinutes    // S 34° 1.672'
{
    NSString *hemi = (coords.latitude < 0) ? @"S" : @"N";
    float dummy;
    int degrees = (int)fabs(coords.latitude);
    float mins = modff(fabs(coords.latitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %06.3f'", hemi, degrees, mins * 60];
}
- (NSString *)lon_degreesDecimalMinutes    // E 151° 4.414
{
    NSString *hemi = (coords.longitude < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(coords.longitude);
    float mins = modff(fabs(coords.longitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %06.3f'", hemi, degrees, mins * 60];
}
- (NSString *)lat_degreesMinutesSeconds    // S 34° 01' 40"
{
    NSString *hemi = (coords.latitude < 0) ? @"S" : @"N";
    float dummy;
    int degrees = (int)fabs(coords.latitude);
    float mins = modff(fabs(coords.latitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %02d' %02d\"", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}
- (NSString *)lon_degreesMinutesSeconds    // E 151° 04' 25"
{
    NSString *hemi = (coords.longitude < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(coords.longitude);
    float mins = modff(fabs(coords.longitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %02d' %02d\"", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}

- (NSInteger)distance:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2distance:coords to:c];
}

- (NSInteger)bearing:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2bearing:coords to:c];
}


+ (float)toRadians:(float)f
{
    return f * M_PI / 180;
}

+ (float)toDegrees:(float)f
{
    return 180 * f / M_PI;
}

+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    float R = 6371000; // radius of Earth in metres
    float φ1 = [self toRadians:c1.latitude];
    float φ2 = [self toRadians:c2.latitude];
    float Δφ = [self toRadians:c2.latitude - c1.latitude];
    float Δλ = [self toRadians:c2.longitude - c1.longitude];

    float a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2);
    float c = 2 * atan2(sqrt(a), sqrt(1 - a));

    float d = R * c;
    return d;
}

+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html

    float φ1 = [self toRadians:c1.latitude];
    float φ2 = [self toRadians:c2.latitude];
    float Δλ = [self toRadians:c2.longitude - c1.longitude];

    float y = sin(Δλ) * cos(φ2);
    float x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ);
    NSInteger brng = [self toDegrees:atan2(y, x)];
    return (brng + 360) % 360;
}


+ (NSString *)bearing2compass:(NSInteger)bearing
{
    NSString *point;
    switch ((int)((bearing + 11.25) / 22.5)) {
        case  0: point = @"N";   break;
        case  1: point = @"NNE"; break;
        case  2: point = @"NE";  break;
        case  3: point = @"ENE"; break;
        case  4: point = @"E";   break;
        case  5: point = @"ESE"; break;
        case  6: point = @"SE";  break;
        case  7: point = @"SSE"; break;
        case  8: point = @"S";   break;
        case  9: point = @"SSW"; break;
        case 10: point = @"SW";  break;
        case 11: point = @"WSW"; break;
        case 12: point = @"W";   break;
        case 13: point = @"WNW"; break;
        case 14: point = @"NW";  break;
        case 15: point = @"NNW"; break;
        case 16: point = @"N";   break;
        default: point = @"???"; break;
    }
    return point;
}

+ (NSString *)NiceDistance:(NSInteger)i
{
    if (i < 1000)
        return [NSString stringWithFormat:@"%ld m", (long)i];
    if (i < 10000)
        return [NSString stringWithFormat:@"%0.1f km", i / 1000.0];
    return [NSString stringWithFormat:@"%ld km", (long)i / 1000];
}

+ (NSString *)NiceCoordinates:(CLLocationCoordinate2D)c
{
    Coordinates *co = [[Coordinates alloc] init:c];
    return [NSString stringWithFormat:@"%@ %@", [co lat_degreesDecimalMinutes], [co lon_degreesDecimalMinutes]];

}


@end
