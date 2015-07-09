//
//  Coordinates.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geosphere-Prefix.pch"

@implementation Coordinates

+ (coordinate_type)myLocation
{
    coordinate_type c;
    c.lat = -33.866467;
    c.lon = 151.2076;
    return c;
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
    switch ((bearing * 16 / 360) % 16) {
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
