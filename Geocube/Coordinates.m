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

@interface Coordinates ()
{
    CLLocationCoordinate2D coords;
}

@end

@implementation Coordinates

- (instancetype)init:(CLLocationDegrees)_lat lon:(CLLocationDegrees)_lon       // -34.02787 151.07357
{
    self = [super init];
    coords.latitude = _lat;
    coords.longitude= _lon;
    return self;
}
- (instancetype)init:(CLLocationCoordinate2D)_coords           // { -34.02787, 151.07357 }
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
- (NSString *)lon_degreesDecimalMinutes    // E 151° 4.414'
{
    NSString *hemi = (coords.longitude < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(coords.longitude);
    float mins = modff(fabs(coords.longitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %06.3f'", hemi, degrees, mins * 60];
}
- (NSString *)lat_degreesDecimalMinutesSimple    // S 34 1.672
{
    NSString *hemi = (coords.latitude < 0) ? @"S" : @"N";
    float dummy;
    int degrees = (int)fabs(coords.latitude);
    float mins = modff(fabs(coords.latitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d %06.3f", hemi, degrees, mins * 60];
}
- (NSString *)lon_degreesDecimalMinutesSimple    // E 151 4.414
{
    NSString *hemi = (coords.longitude < 0) ? @"W" : @"E";
    float dummy;
    int degrees = (int)fabs(coords.longitude);
    float mins = modff(fabs(coords.longitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d %06.3f", hemi, degrees, mins * 60];
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
- (CLLocationDegrees)lat
{
    return coords.latitude;
}
- (CLLocationDegrees)lon
{
    return coords.longitude;
}

- (NSInteger)distance:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2distance:coords to:c];
}

- (NSInteger)bearing:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2bearing:coords to:c];
}


+ (CLLocationDegrees)toRadians:(CLLocationDegrees)f
{
    return f * M_PI / 180;
}

+ (CLLocationDegrees)toDegrees:(CLLocationDegrees)f
{
    return 180 * f / M_PI;
}

+ (CLLocationCoordinate2D)coordinatesPlusOffset:(CLLocationCoordinate2D)c offset:(CLLocationCoordinate2D)o
{
    // From http://www.movable-type.co.uk/scripts/latlong.html
    float R = 6371000; // radius of Earth in metres
    float d = sqrt(o.latitude * o.latitude + o.longitude * o.longitude);
    R *= 1000; // mm
    float δ = d / R;    // Ratio distance and ratio earth
    float θ = 0;        // Angle from the North clockwise.

    float longside = sqrt(o.longitude * o.longitude + o.latitude * o.latitude);
    if (fpclassify(longside) == FP_ZERO)
        return c;

    if (o.latitude >= 0 && o.longitude >= 0)
        θ = 0 * M_PI + asinf(o.longitude / longside);
    if (o.latitude <  0 && o.longitude >= 0)
        θ = 1 * M_PI - asinf(o.longitude / longside);
    if (o.latitude <  0 && o.longitude <  0)
        θ = 1 * M_PI + asinf(-o.longitude / longside);
    if (o.latitude >= 0 && o.longitude <  0)
        θ = 2 * M_PI - asinf(-o.longitude / longside);

    // NSLog(@"Angle: %f %0.f", θ, [self toDegrees:θ]);
    // NSLog(@"ratio: %0.f", δ);

    float φ1 = [self toRadians:c.latitude];
    float λ1 = [self toRadians:c.longitude];
    // NSLog(@"φ1:%f λ1:%f", φ1, λ1);
    float φ2 = asin(sin(φ1) * cos(δ) + cos(φ1) * sin(δ) * cos(θ));
    float λ2 = λ1 + atan2(sin(θ) * sin(δ) * cos(φ1), cos(δ) - sin(φ1) * sin(φ2));
    // NSLog(@"φ2:%f λ2:%f", φ2, λ2);

    float φ = [self toDegrees:φ2];
    float λ = [self toDegrees:λ2];

    // NSLog(@"φ:%f λ:%f", φ, λ);

    while (λ < -180)
        λ += 180;
    while (λ > 180)
        λ -= 180;

    return CLLocationCoordinate2DMake(φ, λ);
}

+ (CLLocationCoordinate2D)coordinatesMinusOffset:(CLLocationCoordinate2D)c offset:(CLLocationCoordinate2D)o
{
    return [self coordinatesPlusOffset:c offset:CLLocationCoordinate2DMake(-o.latitude, -o.longitude)];
}

// From http://stackoverflow.com/questions/7278094/moving-a-cllocation-by-x-meters
+ (CLLocationCoordinate2D)location:(CLLocationCoordinate2D)origin bearing:(float)bearing distance:(float)distanceMeters
{
    CLLocationCoordinate2D target;
    const double distRadians = distanceMeters / (6372797.6); // earth radius in meters

    float lat1 = origin.latitude * M_PI / 180;
    float lon1 = origin.longitude * M_PI / 180;

    float lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing));
    float lon2 = lon1 + atan2( sin(bearing) * sin(distRadians) * cos(lat1),
                              cos(distRadians) - sin(lat1) * sin(lat2) );

    target.latitude = lat2 * 180 / M_PI;
    target.longitude = lon2 * 180 / M_PI; // no need to normalize a heading in degrees to be within -179.999999° to 180.00000°

    return target;
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


+ (NSString *)bearing2compass:(CLLocationDegrees)bearing
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

+ (NSString *)NiceCoordinates:(CLLocationCoordinate2D)c
{
    Coordinates *co = [[Coordinates alloc] init:c];
    return [NSString stringWithFormat:@"%@ %@", [co lat_degreesDecimalMinutes], [co lon_degreesDecimalMinutes]];
}

+ (NSString *)NiceCoordinatesForEditing:(CLLocationCoordinate2D)c
{
    Coordinates *co = [[Coordinates alloc] init:c];
    return [NSString stringWithFormat:@"%@ %@", [co lat_degreesDecimalMinutesSimple], [co lon_degreesDecimalMinutesSimple]];
}

+ (NSString *)NiceLatitude:(CLLocationDegrees)l
{
    Coordinates *co = [[Coordinates alloc] init:CLLocationCoordinate2DMake(l, 0)];
    return [co lat_degreesDecimalMinutes];
}
+ (NSString *)NiceLongitude:(CLLocationDegrees)l
{
    Coordinates *co = [[Coordinates alloc] init:CLLocationCoordinate2DMake(0, l)];
    return [co lon_degreesDecimalMinutes];
}

+ (NSString *)NiceLatitudeForEditing:(CLLocationDegrees)l
{
    Coordinates *co = [[Coordinates alloc] init:CLLocationCoordinate2DMake(l, 0)];
    return [co lat_degreesDecimalMinutesSimple];
}
+ (NSString *)NiceLongitudeForEditing:(CLLocationDegrees)l
{
    Coordinates *co = [[Coordinates alloc] init:CLLocationCoordinate2DMake(0, l)];
    return [co lon_degreesDecimalMinutesSimple];
}

+ (CLLocationDegrees)degrees2rad:(CLLocationDegrees)d
{
    return d * M_PI / 180.0;
}

+ (CLLocationDegrees)rad2degrees:(CLLocationDegrees)r
{
    return 180.8 * r / M_PI;
}

+ (float)degreesDecimalMinutes2degrees:(NSString *)ddm
{
    NSScanner *scanner = [NSScanner scannerWithString:ddm];
    BOOL okay = YES;

    NSString *direction;
    okay &= [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"NESWnesw"] intoString:&direction];

    int degrees;
    okay &= [scanner scanInt:&degrees];

    // Skip over funny degrees things
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    [scanner scanUpToCharactersFromSet:digits intoString:nil];

    float mins;
    okay &= [scanner scanFloat:&mins];

    if (mins > 60 || mins < 0)
        okay = NO;
    if (degrees > 180 || degrees < 0)
        okay = NO;

    float ddegrees = degrees + mins / 60.0;

    if ([[direction uppercaseString] isEqualToString:@"W"] == YES)
        ddegrees = -ddegrees;
    if ([[direction uppercaseString] isEqualToString:@"S"] == YES)
        ddegrees = -ddegrees;

    if (okay)
        return ddegrees;
    return 0;
}

- (instancetype)initString:(NSString *)lat lon:(NSString *)lon    // S 34 1.672, E 151 4.414
{
    self = [super init];

    coords.latitude = [Coordinates degreesDecimalMinutes2degrees:lat];
    coords.longitude = [Coordinates degreesDecimalMinutes2degrees:lon];

    return self;
}

+ (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2
{
    CLLocationDegrees left, right, top, bottom;

    left = MIN(c1.latitude, c2.latitude);
    right = MAX(c1.latitude, c2.latitude);
    top = MAX(c1.longitude, c2.longitude);
    bottom = MIN(c1.longitude, c2.longitude);

    d1->latitude = left - (right - left) * 0.1;
    d2->latitude = right + (right - left) * 0.1;
    d1->longitude = top + (top - bottom) * 0.1;
    d2->longitude = bottom - (top - bottom) * 0.1;
}

+ (NSInteger)scanForWaypoints:(NSArray *)lines waypoint:(dbWaypoint *)waypoint view:(UIViewController *)vc
{
    NSError *e = nil;
    __block NSInteger found = 0;

    NSRegularExpression *rns = [NSRegularExpression regularExpressionWithPattern:@"([NSns] +\\d{1,3}[º°]? ?\\d{1,2}\\.\\d{1,3})" options:0 error:&e];
    NSRegularExpression *rew = [NSRegularExpression regularExpressionWithPattern:@"([EWew] +\\d{1,3}[º°]? ?\\d{1,2}\\.\\d{1,3})" options:0 error:&e];

    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *NS = nil;
        NSString *EW = nil;

        NSArray *matches = [rns matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match rangeAtIndex:1];
            NS = [line substringWithRange:range];
        }

        matches = [rew matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match rangeAtIndex:1];
            EW = [line substringWithRange:range];
        }

        if (NS != nil && EW != nil) {
            NSLog(@"%@ - %@", NS, EW);
            Coordinates *c = [[Coordinates alloc] initString:NS lon:EW];

            dbWaypoint *wp = [[dbWaypoint alloc] init:0];
            wp.wpt_lat = [c lat_decimalDegreesSigned];
            wp.wpt_lon = [c lon_decimalDegreesSigned];
            wp.wpt_lat_int = [c lat] * 1000000;
            wp.wpt_lon_int = [c lon] * 1000000;
            wp.wpt_name = [dbWaypoint makeName:[waypoint.wpt_name substringFromIndex:2]];
            wp.wpt_description = wp.wpt_name;
            wp.wpt_date_placed_epoch = time(NULL);
            wp.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:wp.wpt_date_placed_epoch];
            wp.wpt_url = nil;
            wp.wpt_urlname = wp.wpt_name;
            wp.wpt_symbol_id = 1;
            wp.wpt_type_id = [dbc Type_ManuallyEntered]._id;
            wp.related_id = waypoint._id;
            wp.account_id = waypoint.account_id;
            [wp finish];
            [dbWaypoint dbCreate:wp];

            [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
            [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];
            [dbc.Group_ManualWaypoints dbAddWaypoint:wp._id];

            [waypointManager needsRefreshAdd:wp];
            found++;
        }
    }];
    if (found == 0)
        [MyTools messageBox:vc header:@"Imported failed" text:@"No waypoints were found"];
    else if (found == 1)
        [MyTools messageBox:vc header:@"Imported successful" text:@"Succesfully added one waypoint"];
    else
        [MyTools messageBox:vc header:@"Imported successful" text:[NSString stringWithFormat:@"Succesfully added %ld waypoints", (long)found]];
    return found;
}

// From https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
+ (NSInteger)latitudeToTile:(CLLocationDegrees)lat zoom:(NSInteger)zoom
{
    return floor((1 - log(tan([Coordinates degrees2rad:lat]) + 1 / cos([Coordinates degrees2rad:lat])) / M_PI) /2 * pow(2, zoom));
}

+ (NSInteger)longitudeToTile:(CLLocationDegrees)lon zoom:(NSInteger)zoom
{
    return floor(((lon + 180) / 360) * pow(2, zoom));
}

@end
