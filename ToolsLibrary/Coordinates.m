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

@interface Coordinates ()

@property (nonatomic)         CLLocationCoordinate2D coords;
@property (nonatomic, retain) OLCConvertor *olc;
@property (nonatomic, retain) UTM2LatLon *utm2latlon;
@property (nonatomic, retain) LatLon2UTM *latlon2UTM;
@property (nonatomic, retain) LatLon2MGRS *latlon2MGRS;
@property (nonatomic, retain) MGRS2LatLon *mgrs2latlon;

@end

@implementation Coordinates

#define COORDS_DEGREES_DECIMALMINUTES_REGEXP @"(\\d{1,3})[º° ] *(\\d{1,2}\\.\\d{1,3})['′]?"
#define COORDS_DECIMALDEGREES_SIGNED_REGEXP @"(-?\\d{1,3}\\.\\d+)"
#define COORDS_DECIMALDEGREES_CARDINAL_REGEXP @"(\\d{1,3}\\.\\d+)"
#define COORDS_DEGREES_MINUTES_SECONDS_REGEXP @"(\\d{1,3})[º° ] *(\\d{1,2})['′ ] *(\\d{1,2})[\"″]?"
#define COORDS_OPENLOCATIONCODE_REGEXP @"([023456789CFGHJMPQRVWX]+\\+[23456789CFGHJMPQRVWX]*)"
#define COORDS_UTM_REGEXP @"(\\d{2}[ACDEFGHJKLMNPQRSTUVWXZ] \\d+ \\d+)"
#define COORDS_MGRS_REGEXP @"(\\d{1,2}[^ABIOYZabioyz][A-Za-z]{2} +\\d+ +\\d+)"

/// Initialize a Coordinates object with a lat and a lon value
- (instancetype)initWithDegrees:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    self = [super init];
    self.coords = CLLocationCoordinate2DMake(latitude, longitude);
    return self;
}
/// Initialize a Coordinates object with a lat and a lon value from a set of coordinates
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coords           // { -34.02787, 151.07357 }
{
    self = [super init];
    self.coords = CLLocationCoordinate2DMake(coords.latitude, coords.longitude);
    return self;
}

/// init with a S 34 1.672, E 151 4.414 string
- (instancetype)initWitDegreesDecimalMinutesLatitude:(NSString *)latitude longitude:(NSString *)longitude // S 34 1.672, E 151 4.414
{
    self = [super init];
    self.coords = CLLocationCoordinate2DMake([Coordinates degreesDecimalMinutes2degrees:latitude], [Coordinates degreesDecimalMinutes2degrees:longitude]);
    return self;
}

// -34.02787 151.07357
- (instancetype)initWithDecimalDegreesSignedLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    self = [super init];
    self.coords = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    return self;
}

// S 34.02787 E 151.07357
- (instancetype)initWithDecimalDegreesCardinalLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    self = [super init];
    self.coords = [Coordinates parseCoordinatesWithString:[NSString stringWithFormat:@"%@ %@", latitude, longitude]  coordType:COORDINATES_DECIMALDEGREES_CARDINAL].coords;
    return self;
}

// S 34 27 57 E 151 7 57
- (instancetype)initWitDegreesMinutesSecondsLatitude:(NSString *)latitude longitude:(NSString *)longitude
{
    self = [super init];
    self.coords = [Coordinates parseCoordinatesWithString:[NSString stringWithFormat:@"%@ %@", latitude, longitude]  coordType:COORDINATES_DEGREES_MINUTES_SECONDS].coords;
    return self;
}

- (instancetype)initWithUTM:(NSString *)utm
{
    self = [super init];
    self.utm2latlon = [[UTM2LatLon alloc] init];
    CLLocationDegrees lat, lon;
    [self.utm2latlon convertUTM:utm ToLatitude:&lat Longitude:&lon];
    self.coords = CLLocationCoordinate2DMake(lat, lon);
    return self;
}
- (instancetype)initWithMGRS:(NSString *)mgrs
{
    self = [super init];
    self.mgrs2latlon = [[MGRS2LatLon alloc] init];
    CLLocationDegrees lat, lon;
    [self.mgrs2latlon convertMGRS:mgrs ToLatitude:&lat Longitude:&lon];
    self.coords = CLLocationCoordinate2DMake(lat, lon);
    return self;
}
- (instancetype)initWithOpenLocationCode:(NSString *)olc
{
    NSAssert(FALSE, @"");
    self = [super init];
    return self;
}

- (CLLocationCoordinate2D)coordinates
{
    return CLLocationCoordinate2DMake(self.coords.latitude, self.coords.longitude);
}

/// Returns -34.02787
- (NSString *)lat_decimalDegreesSigned     // -34.02787
{
    return [NSString stringWithFormat:@"%9.5f", self.coords.latitude];
}
/// Returns 151.07357
- (NSString *)lon_decimalDegreesSigned     // 151.07357
{
    return [NSString stringWithFormat:@"%9.5f", self.coords.longitude];
}
/// Returns S 34.02787
- (NSString *)lat_decimalDegreesCardinal   // S 34.02787
{
    NSString *hemi = (self.coords.latitude < 0) ? _(@"compass-S") : _(@"compass-N") ;
    return [NSString stringWithFormat:@"%@ %9.5f", hemi, fabs(self.coords.latitude)];
}
/// Returns E 151.07357
- (NSString *)lon_decimalDegreesCardinal   // E 151.07357
{
    NSString *hemi = (self.coords.longitude < 0) ? _(@"compass-W") : _(@"compass-E") ;
    return [NSString stringWithFormat:@"%@ %9.5f", hemi, fabs(self.coords.longitude)];
}
/// Returns S 34° 1.672'
- (NSString *)lat_degreesDecimalMinutes    // S 34° 1.672'
{
    NSString *hemi = (self.coords.latitude < 0) ? _(@"compass-S") : _(@"compass-N") ;
    float dummy;
    int degrees = (int)fabs(self.coords.latitude);
    float mins = modff(fabs(self.coords.latitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %06.3f′", hemi, degrees, mins * 60];
}
/// Returns E 151° 4.414'
- (NSString *)lon_degreesDecimalMinutes    // E 151° 4.414'
{
    NSString *hemi = (self.coords.longitude < 0) ? _(@"compass-W") : _(@"compass-E") ;
    float dummy;
    int degrees = (int)fabs(self.coords.longitude);
    float mins = modff(fabs(self.coords.longitude), &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %06.3f′", hemi, degrees, mins * 60];
}
/// Returns S 34 1.672
- (NSString *)latEdit_degreesDecimalMinutes    // S 34 1.672
{
    NSString *hemi = (self.coords.latitude < 0) ? _(@"compass-S") : _(@"compass-N") ;
    float dummy;
    int degrees = (int)fabs(self.coords.latitude);
    float mins = modff(fabs(self.coords.latitude), &dummy);
    return [NSString stringWithFormat:@"%@ %d %0.3f", hemi, degrees, mins * 60];
}
/// Returns E 151 4.414
- (NSString *)lonEdit_degreesDecimalMinutes    // E 151 4.414
{
    NSString *hemi = (self.coords.longitude < 0) ? _(@"compass-W") : _(@"compass-E") ;
    float dummy;
    int degrees = (int)fabs(self.coords.longitude);
    float mins = modff(fabs(self.coords.longitude), &dummy);
    return [NSString stringWithFormat:@"%@ %d %0.3f", hemi, degrees, mins * 60];
}
/// Returns S 34° 01' 40"
- (NSString *)lat_degreesMinutesSeconds    // S 34° 01' 40"
{
    NSString *hemi = (self.coords.latitude < 0) ? _(@"compass-S") : _(@"compass-N") ;
    float dummy;
    int degrees = (int)fabs(self.coords.latitude);
    float mins = modff(fabs(self.coords.latitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %02d′ %02d″", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}
/// Returns E 151° 04' 25"
- (NSString *)lon_degreesMinutesSeconds    // E 151° 04' 25"
{
    NSString *hemi = (self.coords.longitude < 0) ? _(@"compass-W") : _(@"compass-E") ;
    float dummy;
    int degrees = (int)fabs(self.coords.longitude);
    float mins = modff(fabs(self.coords.longitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d° %02d′ %02d″", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}
/// Returns S 34 01 40
- (NSString *)latEdit_degreesMinutesSeconds    // S 34 01 40
{
    NSString *hemi = (self.coords.latitude < 0) ? _(@"compass-S") : _(@"compass-N") ;
    float dummy;
    int degrees = (int)fabs(self.coords.latitude);
    float mins = modff(fabs(self.coords.latitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d %02d %02d", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}
/// Returns E 151 04 25
- (NSString *)lonEdit_degreesMinutesSeconds    // E 151 04 25
{
    NSString *hemi = (self.coords.longitude < 0) ? _(@"compass-W") : _(@"compass-E") ;
    float dummy;
    int degrees = (int)fabs(self.coords.longitude);
    float mins = modff(fabs(self.coords.longitude), &dummy);
    float secs = modff(60 * mins, &dummy);
    return [NSString stringWithFormat:@"%@ %3d %02d %02d", hemi, degrees, (int)(mins * 60), (int)(secs * 60)];
}

- (NSString *)lat:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return [self lat_degreesMinutesSeconds];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [self lat_decimalDegreesSigned];
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [self lat_decimalDegreesCardinal];
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return [self lat_degreesDecimalMinutes];
        case COORDINATES_UTM:
        case COORDINATES_OPENLOCATIONCODE:
        case COORDINATES_MGRS:
        case COORDINATES_MAX:
            return @"???";
    }
    return @"???";
}
- (NSString *)lon:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return [self lon_degreesMinutesSeconds];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [self lon_decimalDegreesSigned];
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [self lon_decimalDegreesCardinal];
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return [self lon_degreesDecimalMinutes];
        case COORDINATES_UTM:
        case COORDINATES_OPENLOCATIONCODE:
        case COORDINATES_MGRS:
        case COORDINATES_MAX:
            return @"???";
    }
    return @"???";
}

- (NSString *)lat
{
    return [self lat:configManager.coordinatesType];
}
- (NSString *)lon
{
    return [self lon:configManager.coordinatesType];
}

/// Returns lat value
- (CLLocationDegrees)latitude
{
    return self.coords.latitude;
}
/// Returns lon value
- (CLLocationDegrees)longitude
{
    return self.coords.longitude;
}

// Returns OLCCode
- (NSString *)olcEncode
{
    if (self.olc == nil)
        self.olc = [[OLCConvertor alloc] init];
    return [self.olc encodeLatitude:self.coords.latitude longitude:self.coords.longitude];
}

// Returns UTM
- (NSString *)UTMEncode
{
    if (self.latlon2UTM == nil)
        self.latlon2UTM = [[LatLon2UTM alloc] init];
    return [self.latlon2UTM convertToUTMFromLatitude:self.coords.latitude Longitude:self.coords.longitude];
}

// Returns MGRS
- (NSString *)MGRSEncode
{
    if (self.latlon2MGRS == nil)
        self.latlon2MGRS = [[LatLon2MGRS alloc] init];
    return [self.latlon2MGRS convertToMGRSFromLatitude:self.coords.latitude Longitude:self.coords.longitude];
}

/// Returns calculated distance towards coordinates c
- (NSInteger)distance:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2distance:self.coords to:c];
}
- (NSInteger)distance:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    return [Coordinates coordinates2distance:self.coords to:CLLocationCoordinate2DMake(latitude, longitude)];
}

/// Returns bearing towards coordinates c
- (NSInteger)bearing:(CLLocationCoordinate2D)c
{
    return [Coordinates coordinates2bearing:self.coords to:c];
}
- (NSInteger)bearing:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    return [Coordinates coordinates2bearing:self.coords to:CLLocationCoordinate2DMake(latitude, longitude)];
}

/// Returns radians value of a degree value
+ (CLLocationDegrees)toRadians:(CLLocationDegrees)f
{
    return f * M_PI / 180;
}

/// Returns degree value of a radins value
+ (CLLocationDegrees)toDegrees:(CLLocationDegrees)f
{
    return 180 * f / M_PI;
}

/// Returns the coordinates of c plus o
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

/// Returns the coordinate of c minus o
+ (CLLocationCoordinate2D)coordinatesMinusOffset:(CLLocationCoordinate2D)c offset:(CLLocationCoordinate2D)o
{
    return [self coordinatesPlusOffset:c offset:CLLocationCoordinate2DMake(-o.latitude, -o.longitude)];
}

/// Returns the coordinates of c plus distanceMeters at bearing
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

/// Returns distance in meters between coordinates c1 and c2
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

+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude
{
    return [self coordinates2distance:c1 to:CLLocationCoordinate2DMake(c2Latitude, c2Longitude)];
}

+ (NSInteger)coordinates2distance:(CLLocationDegrees)c1Latitude fromLongitude:(CLLocationDegrees)c1Longitude toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude
{
    return [self coordinates2distance:CLLocationCoordinate2DMake(c1Latitude, c1Longitude) to:CLLocationCoordinate2DMake(c2Latitude, c2Longitude)];
}

/// Returns bearing between coordinates c1 and c2
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

+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude
{
    return [self coordinates2bearing:c1 to:CLLocationCoordinate2DMake(c2Latitude, c2Longitude)];
}

+ (NSInteger)coordinates2bearing:(CLLocationDegrees)c1Latitude fromLongitude:(CLLocationDegrees)c1Longitude to:(CLLocationCoordinate2D)c2
{
    return [self coordinates2bearing:CLLocationCoordinate2DMake(c1Latitude, c1Longitude) to:c2];
}

/// Returns compass direction for bearing
+ (NSString *)bearing2compass:(CLLocationDegrees)bearing
{
    NSString *point;
    switch ((int)((bearing + 11.25) / 22.5)) {
        case  0: point = _(@"compass-N");   break;
        case  1: point = _(@"compass-NNE"); break;
        case  2: point = _(@"compass-NE");  break;
        case  3: point = _(@"compass-ENE"); break;
        case  4: point = _(@"compass-E");   break;
        case  5: point = _(@"compass-ESE"); break;
        case  6: point = _(@"compass-SE");  break;
        case  7: point = _(@"compass-SSE"); break;
        case  8: point = _(@"compass-S");   break;
        case  9: point = _(@"compass-SSW"); break;
        case 10: point = _(@"compass-SW");  break;
        case 11: point = _(@"compass-WSW"); break;
        case 12: point = _(@"compass-W");   break;
        case 13: point = _(@"compass-WNW"); break;
        case 14: point = _(@"compass-NW");  break;
        case 15: point = _(@"compass-NNW"); break;
        case 16: point = _(@"compass-N");   break;
        default: point = @"???"; break;
    }
    return point;
}

/// Returns string with coordinates like N 1° 2.3' E 4° 5.6
- (NSString *)niceCoordinates
{
    return [self niceCoordinates:configManager.coordinatesType];
}

/// Returns string with coordinates like N 1° 2.3' E 4° 5.6
- (NSString *)niceCoordinates:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return [NSString stringWithFormat:@"%@ %@", [self lat_degreesDecimalMinutes], [self lon_degreesDecimalMinutes]];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [NSString stringWithFormat:@"%@ %@", [self lat_decimalDegreesSigned], [self lon_decimalDegreesSigned]];
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [NSString stringWithFormat:@"%@ %@", [self lat_decimalDegreesCardinal], [self lon_decimalDegreesCardinal]];
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return [NSString stringWithFormat:@"%@ %@", [self lat_degreesMinutesSeconds], [self lon_degreesMinutesSeconds]];
        case COORDINATES_OPENLOCATIONCODE:
            return [self olcEncode];
        case COORDINATES_UTM:
            return [self UTMEncode];
        case COORDINATES_MGRS:
            return [self MGRSEncode];
        case COORDINATES_MAX:
            return @"????";
    }

    return @"????";
}

/// Returns string with coordinates like N 1 2.3
- (NSString *)latEdit:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return [self latEdit_degreesDecimalMinutes];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [self lat_decimalDegreesSigned];
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [self lat_decimalDegreesCardinal];
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return [self latEdit_degreesMinutesSeconds];
        case COORDINATES_OPENLOCATIONCODE:
            return [self olcEncode];
        case COORDINATES_UTM:
            return [self UTMEncode];
        case COORDINATES_MGRS:
            return [self MGRSEncode];
        case COORDINATES_MAX:
            return @"????";
    }

    return @"????";
}

/// Returns string with coordinates like E 1 2.3
- (NSString *)lonEdit:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return [self lonEdit_degreesDecimalMinutes];
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return [self lon_decimalDegreesSigned];
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return [self lon_decimalDegreesCardinal];
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return [self lonEdit_degreesMinutesSeconds];
        case COORDINATES_OPENLOCATIONCODE:
            return [self olcEncode];
        case COORDINATES_UTM:
            return [self UTMEncode];
        case COORDINATES_MGRS:
            return [self MGRSEncode];
        case COORDINATES_MAX:
            return @"????";
    }

    return @"????";
}

/// Returns string with coordinates like N 1° 2.3' E 4° 5.6
+ (NSString *)niceCoordinates:(CLLocationCoordinate2D)c
{
    return [self niceCoordinates:c coordType:configManager.coordinatesType];
}
+ (NSString *)niceCoordinates:(CLLocationCoordinate2D)c coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:c];
    return [co niceCoordinates:coordType];
}

+ (NSString *)niceCoordinates:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    return [self niceCoordinates:latitude longitude:longitude coordType:configManager.coordinatesType];
}
+ (NSString *)niceCoordinates:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithDegrees:latitude longitude:longitude];
    return [co niceCoordinates:coordType];
}

/// Returns string with coordinates like N 1 2.3 E 4 5.6
+ (NSString *)niceCoordinatesForEditing:(CLLocationCoordinate2D)c
{
    return [self niceCoordinatesForEditing:c coordType:configManager.coordinatesType];
}
+ (NSString *)niceCoordinatesForEditing:(CLLocationCoordinate2D)c coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:c];
    return [NSString stringWithFormat:@"%@ %@", [co latEdit:coordType], [co lonEdit:coordType]];
}

/// Returns string with latitude like N 1° 2.3'
+ (NSString *)niceLatitude:(CLLocationDegrees)l
{
    return [self niceLatitude:l coordType:configManager.coordinatesType];
}
+ (NSString *)niceLatitude:(CLLocationDegrees)l coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:CLLocationCoordinate2DMake(l, 0)];
    return [co lat:coordType];
}
/// Returns string with longitude like E 1° 2.3'
+ (NSString *)niceLongitude:(CLLocationDegrees)l
{
    return [self niceLongitude:l coordType:configManager.coordinatesType];
}
+ (NSString *)niceLongitude:(CLLocationDegrees)l coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:CLLocationCoordinate2DMake(0, l)];
    return [co lon:coordType];
}

/// Returns string with latitude like N 1 2.3
+ (NSString *)niceLatitudeForEditing:(CLLocationDegrees)l
{
    return [self niceLatitudeForEditing:l coordType:configManager.coordinatesType];
}
+ (NSString *)niceLatitudeForEditing:(CLLocationDegrees)l coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:CLLocationCoordinate2DMake(l, 0)];
    return [co latEdit:coordType];
}
/// Returns string with longitude like E 1 2.3
+ (NSString *)niceLongitudeForEditing:(CLLocationDegrees)l
{
    return [self niceLongitudeForEditing:l coordType:configManager.coordinatesType];
}
+ (NSString *)niceLongitudeForEditing:(CLLocationDegrees)l coordType:(CoordinatesType)coordType
{
    Coordinates *co = [[Coordinates alloc] initWithCoordinates:CLLocationCoordinate2DMake(0, l)];
    return [co lonEdit:coordType];
}

/// Convert degrees to radians
+ (CLLocationDegrees)degrees2rad:(CLLocationDegrees)d
{
    return d * M_PI / 180.0;
}

/// Convert radians to degrees
+ (CLLocationDegrees)rad2degrees:(CLLocationDegrees)r
{
    return 180.8 * r / M_PI;
}

/// Convert S 34 1.672 to a float value
+ (float)degreesDecimalMinutes2degrees:(NSString *)ddm
{
    NSScanner *scanner = [NSScanner scannerWithString:ddm];
    BOOL okay = YES;

    NSString *direction;
    okay &= [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:_(@"compass-NESWnesw")] intoString:&direction];

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

    if ([[direction uppercaseString] isEqualToString:_(@"compass-W")] == YES)
        ddegrees = -ddegrees;
    if ([[direction uppercaseString] isEqualToString:_(@"compass-S")] == YES)
        ddegrees = -ddegrees;

    if (okay)
        return ddegrees;
    return 0;
}

/// Return a boundary which is 10% bigger than the entered
+ (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2 boundaryPercentage:(NSInteger)boundaryPercentage
{
    CLLocationDegrees left, right, top, bottom;

    left = MIN(c1.latitude, c2.latitude);
    right = MAX(c1.latitude, c2.latitude);
    top = MAX(c1.longitude, c2.longitude);
    bottom = MIN(c1.longitude, c2.longitude);

    d1->latitude =  left - (right - left) * boundaryPercentage / 100.0;
    d2->latitude =  right + (right - left) * boundaryPercentage / 100.0;
    d1->longitude = top + (top - bottom) * boundaryPercentage / 100.0;
    d2->longitude = bottom - (top - bottom) * boundaryPercentage / 100.0;

    if (d1->latitude  < -180) d1->latitude  = -180;
    if (d2->latitude  < -180) d2->latitude  = -180;
    if (d1->longitude >  180) d1->longitude =  180;
    if (d2->longitude >  180) d2->longitude =  180;
}

+ (Coordinates *)parseCoordinatesWithMatch:(NSTextCheckingResult *)match line:(NSString *)line coordType:(CoordinatesType)coordType
{
    if (match == nil)
        return nil;

    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES: {

            NSRange range = [match rangeAtIndex:1];
            NSString *NS = [line substringWithRange:range];
            range = [match rangeAtIndex:2];
            NSInteger NSdegrees = [[line substringWithRange:range] integerValue];
            range = [match rangeAtIndex:3];
            double NSminutes = [[line substringWithRange:range] doubleValue];
            double NSvalue = NSdegrees + NSminutes / 60.0;
            if ([[[NS uppercaseString] substringToIndex:1] isEqualToString:@"S"] == YES)
                NSvalue = -NSvalue;

            range = [match rangeAtIndex:4];
            NSString *EW = [line substringWithRange:range];
            range = [match rangeAtIndex:5];
            NSInteger EWdegrees = [[line substringWithRange:range] integerValue];
            range = [match rangeAtIndex:6];
            double EWminutes = [[line substringWithRange:range] doubleValue];
            double EWvalue = EWdegrees + EWminutes / 60.0;
            if ([[[EW uppercaseString] substringToIndex:1] isEqualToString:@"W"] == YES)
                EWvalue = -EWvalue;

            Coordinates *c = [[Coordinates alloc] initWithDegrees:NSvalue longitude:EWvalue];
            NSLog(@"Coordinates: '%f' '%f'", NSvalue, EWvalue);
            return c;
        }

        case COORDINATES_DECIMALDEGREES_SIGNED: {
            NSRange range = [match rangeAtIndex:1];
            double NSvalue = [[line substringWithRange:range] doubleValue] ;
            range = [match rangeAtIndex:2];
            double EWvalue = [[line substringWithRange:range] doubleValue] ;

            Coordinates *c = [[Coordinates alloc] initWithDegrees:NSvalue longitude:EWvalue];
            NSLog(@"Coordinates: '%f' '%f'", NSvalue, EWvalue);
            return c;
        }

        case COORDINATES_DECIMALDEGREES_CARDINAL: {
            NSRange range = [match rangeAtIndex:1];
            NSString *NS = [line substringWithRange:range];
            range = [match rangeAtIndex:2];
            double NSvalue = [[line substringWithRange:range] doubleValue];
            if ([[[NS uppercaseString] substringToIndex:1] isEqualToString:@"S"] == YES)
                NSvalue = -NSvalue;

            range = [match rangeAtIndex:3];
            NSString *EW = [line substringWithRange:range];
            range = [match rangeAtIndex:4];
            double EWvalue = [[line substringWithRange:range] doubleValue];
            if ([[[EW uppercaseString] substringToIndex:1] isEqualToString:@"W"] == YES)
                EWvalue = -EWvalue;

            Coordinates *c = [[Coordinates alloc] initWithDegrees:NSvalue longitude:EWvalue];
            NSLog(@"Coordinates: '%f' '%f'", NSvalue, EWvalue);
            return c;
        }

        case COORDINATES_DEGREES_MINUTES_SECONDS: {
            NSRange range = [match rangeAtIndex:1];
            NSString *NS = [line substringWithRange:range];
            range = [match rangeAtIndex:2];
            NSInteger NSdegrees = [[line substringWithRange:range] integerValue];
            range = [match rangeAtIndex:3];
            NSInteger NSminutes = [[line substringWithRange:range] doubleValue];
            range = [match rangeAtIndex:4];
            NSInteger NSseconds = [[line substringWithRange:range] doubleValue];
            double NSvalue = NSdegrees + NSminutes / 60.0 + NSseconds / 3600.0;
            if ([[[NS uppercaseString] substringToIndex:1] isEqualToString:@"S"] == YES)
                NSvalue = -NSvalue;

            range = [match rangeAtIndex:5];
            NSString *EW = [line substringWithRange:range];
            range = [match rangeAtIndex:6];
            NSInteger EWdegrees = [[line substringWithRange:range] integerValue];
            range = [match rangeAtIndex:7];
            NSInteger EWminutes = [[line substringWithRange:range] doubleValue];
            range = [match rangeAtIndex:4];
            NSInteger EWseconds = [[line substringWithRange:range] doubleValue];
            double EWvalue = EWdegrees + EWminutes / 60.0 + EWseconds / 3600.0;
            if ([[[EW uppercaseString] substringToIndex:1] isEqualToString:@"W"] == YES)
                EWvalue = -EWvalue;

            Coordinates *c = [[Coordinates alloc] initWithDegrees:NSvalue longitude:EWvalue];
            NSLog(@"Coordinates: '%f' '%f'", NSvalue, EWvalue);
            return c;
        }

        case COORDINATES_OPENLOCATIONCODE: {
            NSRange range = [match rangeAtIndex:1];
            NSString *s = [line substringWithRange:range];

            OLCConvertor *oc = [[OLCConvertor alloc] init];
            OLCArea *a = [oc decode:s];
            Coordinates *c = nil;
            c = [[Coordinates alloc] initWithDegrees:a.latitudeCenter longitude:a.longitudeCenter];
            NSLog(@"OpenLocationCode: '%@'", s);
            return c;
        }

        case COORDINATES_UTM: {
            NSRange range = [match rangeAtIndex:1];
            NSString *s = [line substringWithRange:range];

            UTM2LatLon *utm2ll = [[UTM2LatLon alloc] init];
            CLLocationDegrees lat, lon;
            [utm2ll convertUTM:s ToLatitude:&lat Longitude:&lon];
            Coordinates *c = [[Coordinates alloc] initWithDegrees:lat longitude:lon];
            NSLog(@"UTM: '%@'", s);
            return c;
        }

        case COORDINATES_MGRS: {
            NSRange range = [match rangeAtIndex:1];
            NSString *s = [line substringWithRange:range];

            MGRS2LatLon *mgrs2ll = [[MGRS2LatLon alloc] init];
            CLLocationDegrees lat, lon;
            [mgrs2ll convertMGRS:s ToLatitude:&lat Longitude:&lon];
            Coordinates *c = [[Coordinates alloc] initWithDegrees:lat longitude:lon];
            NSLog(@"MGRS: '%@'", s);
            return c;
        }

        case COORDINATES_MAX:
            NSAssert(FALSE, @"parseCoordinatesWithMatch");
    }

    return nil;
}

/// Check if a string matches a set of coordinates like ^[NESW] \d{1,3}º? ?\d{1,2}\.\d{1,3
+ (BOOL)checkCoordinate:(NSString *)text
{
    return [self checkCoordinate:text coordType:configManager.coordinatesType];
}
+ (BOOL)checkCoordinate:(NSString *)text coordType:(CoordinatesType)coordType
{
    // As long as it matches any of these, it is fine:
    // ^[NESW] \d{1,3}º? ?\d{1,2}\.\d{1,3}

    NSError *e = nil;
    NSRegularExpression *r5;
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^[NESWnesw%@] *%@ +[NESWnesw%@] *%@$", _(@"compass-NESW"), COORDS_DEGREES_DECIMALMINUTES_REGEXP, _(@"compass-NESW"), COORDS_DEGREES_DECIMALMINUTES_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DECIMALDEGREES_SIGNED:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^ *%@ +%@$", COORDS_DECIMALDEGREES_SIGNED_REGEXP, COORDS_DECIMALDEGREES_SIGNED_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^[NESWnesw%@] *%@ +[NESWnesw%@] *%@$", _(@"compass-NESW"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP, _(@"compass-NESW"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^[NESWnesw%@] *%@ +[NESWnesw%@] *%@$", _(@"compass-NESW"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP, _(@"compass-NESW"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_OPENLOCATIONCODE:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@$", COORDS_OPENLOCATIONCODE_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_UTM:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@$", COORDS_UTM_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_MGRS:
            r5 = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^%@$", COORDS_MGRS_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_MAX:
            r5 = nil;
            break;
    }

    NSRange range;
    range = [r5 rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    if (range.location == 0)    // Location 0, not "NSNotFound"
        return YES;

    return NO;
}

/// Search for something which looks like a coordinate string
+ (NSInteger)scanForWaypoints:(NSArray<NSString *> *)lines waypoint:(dbWaypoint *)waypoint view:(UIViewController *)vc
{
    NSInteger total = 0;
    for (NSInteger i = 0; i < COORDINATES_MAX; i++) {
        total += [self scanForWaypoints:lines waypoint:waypoint view:vc coordType:i];
    }
    if (total == 0)
        [MyTools messageBox:vc header:_(@"coordinates-Import failed") text:_(@"coordinates-No waypoints were found")];
    else if (total == 1)
        [MyTools messageBox:vc header:_(@"coordinates-Import successful") text:_(@"coordinates-Succesfully added one waypoint")];
    else
        [MyTools messageBox:vc header:_(@"coordinates-Import successful") text:[NSString stringWithFormat:_(@"coordinates-Succesfully added %ld waypoints"), (long)total]];
    return total;
}

+ (NSInteger)scanForWaypoints:(NSArray<NSString *> *)lines waypoint:(dbWaypoint *)waypoint view:(UIViewController *)vc coordType:(CoordinatesType)coordType
{
    NSError *e = nil;
    __block NSInteger found = 0;

    NSRegularExpression *r = nil;
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DEGREES_DECIMALMINUTES_REGEXP, _(@"compass-EWew"), COORDS_DEGREES_DECIMALMINUTES_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DECIMALDEGREES_SIGNED:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@ +%@", COORDS_DECIMALDEGREES_SIGNED_REGEXP, COORDS_DECIMALDEGREES_SIGNED_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP, _(@"compass-EWew"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP, _(@"compass-EWew"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_OPENLOCATIONCODE:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_OPENLOCATIONCODE_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_UTM:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_UTM_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_MGRS:
            r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_MGRS_REGEXP] options:0 error:&e];
            break;
        case COORDINATES_MAX:
            break;
    }

    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
        NSTextCheckingResult *match = [matches firstObject];
        Coordinates *c = [self parseCoordinatesWithMatch:match line:line coordType:coordType];

        if (c != nil) {
            dbWaypoint *wp = [[dbWaypoint alloc] init];
            wp.wpt_latitude = c.latitude;
            wp.wpt_longitude = c.longitude;
            wp.wpt_name = [dbWaypoint makeName:[waypoint.wpt_name substringFromIndex:2]];
            wp.wpt_description = wp.wpt_name;
            wp.wpt_date_placed_epoch = time(NULL);
            wp.wpt_url = nil;
            wp.wpt_urlname = wp.wpt_name;
            wp.wpt_symbol = dbc.symbolVirtualStage;
            wp.wpt_type = [dbc typeManuallyEntered];
            wp.account = waypoint.account;
            [wp finish];
            [wp dbCreate];

            [dbc.groupAllWaypointsManuallyAdded addWaypointToGroup:wp];
            [dbc.groupAllWaypoints addWaypointToGroup:wp];
            [dbc.groupManualWaypoints addWaypointToGroup:wp];

            [waypointManager needsRefreshAdd:wp];
            found++;
        };
    }];
    return found;
}

+ (Coordinates *)parseCoordinatesWithString:(NSString *)line coordType:(CoordinatesType)coordType
{
    NSError *e = nil;

    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DEGREES_DECIMALMINUTES_REGEXP, _(@"compass-EWew"), COORDS_DEGREES_DECIMALMINUTES_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_DECIMALDEGREES_SIGNED: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@ +%@", COORDS_DECIMALDEGREES_SIGNED_REGEXP, COORDS_DECIMALDEGREES_SIGNED_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_DECIMALDEGREES_CARDINAL: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP, _(@"compass-EWew"), COORDS_DECIMALDEGREES_CARDINAL_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_DEGREES_MINUTES_SECONDS: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([NSns%@]) *%@ +([EWew%@]) *%@", _(@"compass-NSns"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP, _(@"compass-EWew"), COORDS_DEGREES_MINUTES_SECONDS_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_OPENLOCATIONCODE: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_OPENLOCATIONCODE_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_UTM: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_UTM_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_MGRS: {
            NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@", COORDS_MGRS_REGEXP] options:0 error:&e];
            NSArray<NSTextCheckingResult *> *matches = [r matchesInString:line options:0 range:NSMakeRange(0, [line length])];
            NSTextCheckingResult *match = [matches firstObject];

            return [self parseCoordinatesWithMatch:match line:line coordType:coordType];
        }

        case COORDINATES_MAX:
            break;
    }

    return nil;

}

/// Convert a latitude and zoom level to a value for the tilename
/// From https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
+ (NSInteger)latitudeToTile:(CLLocationDegrees)lat zoom:(NSInteger)zoom
{
    return floor((1 - log(tan([Coordinates degrees2rad:lat]) + 1 / cos([Coordinates degrees2rad:lat])) / M_PI) /2 * pow(2, zoom));
}

/// Convert a longitude and zoom level to a value for the tilename
/// From https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
+ (NSInteger)longitudeToTile:(CLLocationDegrees)lon zoom:(NSInteger)zoom
{
    return floor(((lon + 180) / 360) * pow(2, zoom));
}

+ (NSString *)coordinateExample:(CoordinatesType)coordType
{
    switch (coordType) {
        case COORDINATES_DEGREES_DECIMALMINUTES:
            return @"S 12° 34.567";
        case COORDINATES_DECIMALDEGREES_SIGNED:
            return @"-12.345678";
        case COORDINATES_DECIMALDEGREES_CARDINAL:
            return @"S 12.345678";
        case COORDINATES_DEGREES_MINUTES_SECONDS:
            return @"S 12° 34′ 56″";
        case COORDINATES_OPENLOCATIONCODE:
            return @"2345678+9CF";
        case COORDINATES_UTM:
            return @"51H 326625E 6222609N";
        case COORDINATES_MGRS:
            return @"51H 326625E 6222609N";
        case COORDINATES_MAX:
            return @"????";
    }
    return @"????";
}

+ (NSArray<NSString *> *)coordinateTypes
{
    NSArray<NSString *> *cts = @[
        [NSString stringWithFormat:_(@"coordinates-Degrees with decimal minutes (%@)"), [self coordinateExample:COORDINATES_DEGREES_DECIMALMINUTES]],
        [NSString stringWithFormat:_(@"coordinates-Decimal degrees signed (%@)"), [self coordinateExample:COORDINATES_DECIMALDEGREES_SIGNED]],
        [NSString stringWithFormat:_(@"coordinates-Decimal degrees cardinal (%@)"), [self coordinateExample:COORDINATES_DECIMALDEGREES_CARDINAL]],
        [NSString stringWithFormat:_(@"coordinates-Degrees Minutes Seconds (%@)"), [self coordinateExample:COORDINATES_DEGREES_MINUTES_SECONDS]],
        [NSString stringWithFormat:_(@"coordinates-Open Location Code (%@)"), [self coordinateExample:COORDINATES_OPENLOCATIONCODE]],
        [NSString stringWithFormat:_(@"coordinates-UTM (%@)"), [self coordinateExample:COORDINATES_UTM]],
        [NSString stringWithFormat:_(@"coordinates-MGRS (%@)"), [self coordinateExample:COORDINATES_MGRS]],
    ];

    NSAssert([cts count] == COORDINATES_MAX, @"Number of coordinateTypes is not the size of the array");

    return cts;
}

@end
