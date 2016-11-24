/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface ToolsGPSViewController ()
{
    NSMutableArray *coords;

    UIImageView *gpsMap;

    GCLabel *coordsMin;
    GCLabel *coordsMax;
    GCLabel *coordsAvg;

    CGRect gpsMapRect;
    CGRect coordsMinRect;
    CGRect coordsMaxRect;
    CGRect coordsAvgRect;
}

@end

@implementation ToolsGPSViewController

enum {
    menuRestart,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuRestart label:@"Restart"];

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = NO;
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

    coords = [NSMutableArray arrayWithCapacity:100];

    gpsMap = [[UIImageView alloc] initWithFrame:gpsMapRect];
    gpsMap.image = [self createGPSMap];
    [self.view addSubview:gpsMap];

    coordsMin = [[GCLabel alloc] initWithFrame:coordsMinRect];
    coordsMin.text = @"Min";
    coordsMin.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:coordsMin];

    coordsMax = [[GCLabel alloc] initWithFrame:coordsMaxRect];
    coordsMax.text = @"Max";
    coordsMax.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:coordsMax];

    coordsAvg = [[GCLabel alloc] initWithFrame:coordsAvgRect];
    coordsAvg.text = @"avg";
    coordsAvg.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:coordsAvg];
}

- (void)viewDidAppear:(BOOL)animated
{
    [LM startDelegation:self isNavigating:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [LM stopDelegation:self];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height16 = bounds.size.height / 18;

    gpsMapRect = CGRectMake(0, height16, width, 14 * height16);
    coordsMinRect = CGRectMake(0, 0, width, height16);
    coordsMaxRect = CGRectMake(0, 15 * height16, width, height16);
    coordsAvgRect = CGRectMake(0, 8 * height16, width, height16);
}

- (UIImage *)createGPSMap
{
    UIImage *img = nil;

    __block CGFloat x0 = +180, x3 = -180, y0 = +180, y3 = -180;
    [coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D *c, NSUInteger idx, BOOL *stop) {
        x0 = MIN(x0, c.lon);
        x3 = MAX(x3, c.lon);
        y0 = MIN(y0, c.lat);
        y3 = MAX(y3, c.lat);
    }];

    coordsMin.text = [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(y0, x0)];
    coordsMax.text = [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(y3, x3)];

    x0 -= .0001;
    y0 -= .0001;
    x3 += .0001;
    y3 += .0001;

    NSInteger X = gpsMapRect.size.width;
    NSInteger Y = gpsMapRect.size.height;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(X, Y), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // White background
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(5, 5, X - 10, Y - 10));

#define MARGIN 10
#define _XTRACK(x) MARGIN + (x - x0) * ((X - 2 * MARGIN) / (x3 - x0))
#define _YTRACK(y) MARGIN - (y - y0) * ((Y - 2 * MARGIN) / (y3 - y0))
    /*
     * +----------------------------------+
     * |  .x0,y0                          |
     * |       .x,y                       |
     * |                                  |
     * |               .x3,y3             |
     * |                            .X,Y  |
     * |                                  |
     * +----------------------------------+
     *
     * scale: ratioX = X / (x3 - x0)
     *        x' = (x - x0) * ratioX
     */

    GCLocationCoordinate2D *avg = [[GCLocationCoordinate2D alloc] init];
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
    [coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D *c, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat xx = [self xtrack:c.lon x0:x0 X:X x3:x3];
        CGFloat yy = [self ytrack:c.lat y0:y0 Y:Y y3:y3];
        CGContextFillRect(context, CGRectMake(xx, yy, 5, 5));
        avg.lat += c.lat;
        avg.lon += c.lon;
    }];

    coordsAvg.text = [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(avg.lat / [coords count], avg.lon / [coords count])];
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    if ([coords count] != 0) {
        CGFloat xx = [self xtrack:(avg.lon / [coords count]) x0:x0 X:X x3:x3];
        CGFloat yy = [self ytrack:(avg.lat / [coords count]) y0:y0 Y:Y y3:y3];
        CGContextFillRect(context, CGRectMake(xx, yy, 5, 5));
    }

    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

- (CGFloat)xtrack:(CGFloat)x x0:(CGFloat)x0 X:(CGFloat)X x3:(CGFloat)x3
{
    return MARGIN + (x - x0) * ((X - 2 * MARGIN) / (x3 - x0));
}
- (CGFloat)ytrack:(CGFloat)y y0:(CGFloat)y0 Y:(CGFloat)Y y3:(CGFloat)y3
{
    return MARGIN + (y - y0) * ((Y - 2 * MARGIN) / (y3 - y0));
}

- (void)updateLocationManagerLocation
{
    GCLocationCoordinate2D *c = [[GCLocationCoordinate2D alloc] init];
    c.lat = LM.coords.latitude;
    c.lon = LM.coords.longitude;
    [coords addObject:c];
    
    gpsMap.image = [self createGPSMap];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuRestart:
            [coords removeAllObjects];
            [self updateLocationManagerLocation];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
