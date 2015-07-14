//
//  Coordinates.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation Coordinates

- (id)init:(float)_lat lon:(float)_lon       // -34.02787 151.07357
{
    self = [super init];
    lat = _lat;
    lon = _lon;
    return self;
}
- (id)init:(coordinate_type)coor           // { -34.02787, 151.07357 }
{
    self = [super init];
    lat = coor.lat;
    lon = coor.lon;
    return self;
}
- (NSString *)lat_decimalDegreesSigned     // -34.02787
{
    return [NSString stringWithFormat:@"%0.5f", lat];
}
- (NSString *)lon_decimalDegreesSigned     // 151.07357
{
    return [NSString stringWithFormat:@"%0.5f", lon];
}
- (NSString *)lat_decimalDegreesCardinal   // S 34.02787
{
    NSString *hemi = (lat < 0) ? @"S" : @"N";
    return [NSString stringWithFormat:@"%@ %0.5f", hemi, fabs(lat)];
    
}
- (NSString *)lon_decimalDegreesCardinal   // E 151.07357
{
    NSString *hemi = (lon < 0) ? @"W" : @"E";
    return [NSString stringWithFormat:@"%@ %0.5f", hemi, fabs(lon)];
}
- (NSString *)lat_degreesDecimalMinutes    // S 34° 1.672'
{
    NSString *hemi = (lat < 0) ? @"S" : @"N";
    float dummy;
    int degrees = (int)fabs(lat);
    float mins = modff(fabs(lat), &dummy);
    return [NSString stringWithFormat:@"%@ %d° %.3f'", hemi, degrees, mins * 60];
}
- (NSString *)lon_degreesDecimalMinutes    // E 151° 4.414
{
    NSString *hemi = (lon < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(lon);
    float mins = modff(fabs(lon), &dummy);
    return [NSString stringWithFormat:@"%@ %d° %.3f'", hemi, degrees, mins * 60];
}
- (NSString *)lat_degreesMinutesSeconds    // S 34° 01' 40"
{
    NSString *hemi = (lat < 0) ? @"S" : @"N";
    float dummy;
    int degrees = (int)fabs(lat);
    float mins = modff(fabs(lat), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %d° %02d' %02d\"", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}
- (NSString *)lon_degreesMinutesSeconds    // E 151° 04' 25"
{
    NSString *hemi = (lon < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(lon);
    float mins = modff(fabs(lon), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %d° %02d' %02d\"", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}

+ (coordinate_type)myLocation
{
    coordinate_type c;
    /* Sydney */
    c.lat = -33.866467;
    c.lon = 151.2076;
    /* Random location */
    c.lat = -33.866467;
    c.lon = 150.2076;
    return c;
}

+ (float)myLocation_Lat
{
    return [self myLocation].lat;
}

+ (float)myLocation_Lon
{
    return [self myLocation].lon;
}

+ (float)toRadians:(float)f
{
    return f * M_PI / 180;
}

+ (float)toDegrees:(float)f
{
    return 180 * f / M_PI;
}

+ (NSInteger)coordinates2distance:(coordinate_type)c1 to:(coordinate_type)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    float R = 6371000; // radius of Earth in metres
    float φ1 = [self toRadians:c1.lat];
    float φ2 = [self toRadians:c2.lat];
    float Δφ = [self toRadians:c2.lat - c1.lat];
    float Δλ = [self toRadians:c2.lon - c1.lon];
    
    float a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2);
    float c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    float d = R * c;
    return d;
}

+ (NSInteger)coordinates2bearing:(coordinate_type)c1 to:(coordinate_type)c2
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    
    float φ1 = [self toRadians:c1.lat];
    float φ2 = [self toRadians:c2.lat];
    float Δλ = [self toRadians:c2.lon - c1.lon];
    
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
        return [NSString stringWithFormat:@"%ld m", i];
    if (i < 10000)
        return [NSString stringWithFormat:@"%0.1f km", i / 1000.0];
    return [NSString stringWithFormat:@"%ld km", i / 1000];
}

@end

coordinate_type MKCoordinates(float lat, float lon)
{
    coordinate_type c;
    c.lat = lat;
    c.lon = lon;
    return c;
}
