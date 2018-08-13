/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface ThemeImageGCA ()

@property (nonatomic, retain) NSMutableDictionary<NSString *, UIImage *> *pinImages;
@property (nonatomic, retain) NSMutableDictionary<NSString *, UIImage *> *typeImages;
@property (nonatomic, retain) ThemeImageGeocube *geocube;

@end

@implementation ThemeImageGCA

- (instancetype)init
{
    self = [super init];

    /* Pin and type images */
    self.pinImages = [NSMutableDictionary dictionaryWithCapacity:25];
    self.typeImages = [NSMutableDictionary dictionaryWithCapacity:25];

    [self loadMapPins:@"gca-icons.json"];

    self.geocube = [[ThemeImageGeocube alloc] init];

    return self;
}

- (void)loadImages
{
    [self loadImages:@"gca-icons.json"];
}


- (BOOL)createPinImages:(NSString *)pinWanted imageName:(NSString *)imageName pinName:(NSString *)pinName
{
    if ([pinWanted isEqualToString:pinName] == NO)
        return NO;

    dbPin *pin = [dbPin getByDescription:pinWanted];
    UIImage *img;
    NSString *code;

    // Normal icon
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_gca", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    // Found icon
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_found", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    // DNF icon
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_dnf", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    // Disabled
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_disabled", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    // Archived
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_archived", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    // Owner
    img = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@_owned", [MyTools DataDistributionDirectory], imageName]];
    NSAssert(img != nil, @"img should be non-nil");
    code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    [self.pinImages setObject:img forKey:code];

    return YES;
}

- (void)loadMapPins:(NSString *)jsonfile
{
    NSData *jsondata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], jsonfile]];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsondata options:kNilOptions error:&error];

    NSArray<NSDictionary *> *pins = [dictionary objectForKey:@"pins"];
    [pins enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pin = [dict objectForKey:@"pin"];
        NSString *image = [dict objectForKey:@"image"];

#define PIN(__pinname__) \
    if ([self createPinImages:pin imageName:image pinName:__pinname__] == YES) \
        return;

        if (pin != nil && image != nil) {
            PIN(@"Benchmark")
            PIN(@"Event")
            PIN(@"Earth Cache")
            PIN(@"Letterbox Cache")
            PIN(@"Locationless Cache")
            PIN(@"Moveable Cache")
            PIN(@"Multi Cache")
            PIN(@"Mystery Cache")
            PIN(@"Other Cache")
            PIN(@"Traditional Cache")
            PIN(@"Virtual Cache")
            PIN(@"Waymark Cache")
            PIN(@"Webcam Cache")
            PIN(@"Wherigo Cache")

            NSAssert1(FALSE, @"Unknown pin: %@", pin);
        }
    }];
}

- (UIImage *)getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    UIImage *img = [imageManager get:type.icon];
    return img;
}

- (UIImage *)getTypeImage:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    UIImage *img = [imageManager get:type.icon];
    return img;
}

// ----------------------------------

- (UIImage *)getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    NSString *code = nil;
    UIImage *img = nil;
    if (archived == YES) {
        code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    } else if (disabled == YES) {
        code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    } else if (owner == YES) {
        code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    } else if (markedFound == YES || found == LOGSTATUS_FOUND) {
        code = [imageManager getCode:pin found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    } else if (markedDNF == YES || found == LOGSTATUS_NOTFOUND) {
        code = [imageManager getCode:pin found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    } else {
        code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        img = [self.pinImages valueForKey:code];

    }

    // Fallback to default
    if (img == nil)
        img = [self.geocube getPin:pin found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF];
    [self.pinImages setObject:img forKey:code];

    return img;
}

- (UIImage *)getPinImage:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    NSString *code = [imageManager getCode:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
    UIImage *imgmain = [self.pinImages objectForKey:code];

    return imgmain;
}

// ----------------------------------

- (CGPoint)centerOffsetAppleMaps
{
#warning to be fixed
    return CGPointMake(0, 0);
    return CGPointMake(7, -17);
}

- (CGPoint)groundAnchorGoogleMaps
{
#warning to be fixed
    return CGPointMake(0 / 35.0, 0 / 42.0);
    return CGPointMake(11.0 / 35.0, 38.0 / 42.0);
}
- (CGPoint)infoWindowAnchorGoogleMaps
{
#warning to be fixed
    return CGPointMake(0 / 35.0, 0 / 42.0);
    return CGPointMake(11.0 / 35.0, 3.0 / 42.0);
}

@end
