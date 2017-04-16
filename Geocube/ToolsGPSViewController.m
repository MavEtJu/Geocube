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

@interface ToolsGPSViewController ()
{
    NSMutableArray<GCLocationCoordinate2D *> *coords;

    UIImageView *gpsMap;

    GCSmallLabel *coordsMinX;
    GCSmallLabel *coordsMinY;
    GCSmallLabel *coordsMaxX;
    GCSmallLabel *coordsMaxY;
    GCSmallLabel *coordsAvg;
    GCSmallLabel *coordsLast;
    GCSmallLabel *distance;

    CGRect gpsMapRect;
    CGRect coordsMinXRect;
    CGRect coordsMinYRect;
    CGRect coordsMaxXRect;
    CGRect coordsMaxYRect;
    CGRect coordsAvgRect;
    CGRect coordsLastRect;
    CGRect distanceRect;

    float smallLabelLineHeight;
    BOOL stopTimer;
}

@end

@implementation ToolsGPSViewController

enum {
    menuRestart,
    menuCopyCoordsAvg,
    menuCopyCoordsLast,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuRestart label:@"Restart"];
    [lmi addItem:menuCopyCoordsAvg label:@"Copy Average Coords"];
    [lmi addItem:menuCopyCoordsLast label:@"Copy Last Coords"];

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

    GCSmallLabel *l = [[GCSmallLabel alloc] initWithFrame:coordsMinXRect];
    smallLabelLineHeight = l.font.lineHeight;

    coords = [NSMutableArray arrayWithCapacity:100];

    gpsMap = [[UIImageView alloc] initWithFrame:gpsMapRect];
    gpsMap.image = [self createGPSMap];
    [self.view addSubview:gpsMap];

    coordsMinX = [[GCSmallLabel alloc] initWithFrame:coordsMinXRect];
    coordsMinX.text = @"MinX";
    coordsMinX.transform = CGAffineTransformMakeRotation(-M_PI_2);
    coordsMinX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:coordsMinX];

    coordsMinY = [[GCSmallLabel alloc] initWithFrame:coordsMinYRect];
    coordsMinY.text = @"MinY";
    coordsMinY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:coordsMinY];

    coordsMaxX = [[GCSmallLabel alloc] initWithFrame:coordsMaxXRect];
    coordsMaxX.text = @"MaxX";
    coordsMaxX.transform = CGAffineTransformMakeRotation(M_PI_2);
    coordsMaxX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:coordsMaxX];

    coordsMaxY = [[GCSmallLabel alloc] initWithFrame:coordsMaxYRect];
    coordsMaxY.text = @"MaxY";
    coordsMaxY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:coordsMaxY];

    coordsAvg = [[GCSmallLabel alloc] initWithFrame:coordsAvgRect];
    coordsAvg.text = @"avg";
    coordsAvg.textAlignment = NSTextAlignmentCenter;
    coordsAvg.textColor = [UIColor redColor];
    [self.view addSubview:coordsAvg];

    coordsLast = [[GCSmallLabel alloc] initWithFrame:coordsLastRect];
    coordsLast.text = @"last";
    coordsLast.textAlignment = NSTextAlignmentCenter;
    coordsLast.textColor = [UIColor greenColor];
    [self.view addSubview:coordsLast];

    distance = [[GCSmallLabel alloc] initWithFrame:distanceRect];
    distance.text = @"last";
    distance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:distance];

    [self viewWilltransitionToSize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LM startDelegation:self isNavigating:YES];
    stopTimer = NO;
    [self performSelectorInBackground:@selector(updateEverySecond) withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    stopTimer = YES;
    [LM stopDelegation:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [LM stopDelegation:self];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger width16 = bounds.size.width / 16;
    NSInteger height16 = bounds.size.height / 18;
    NSInteger height = 16.8 * height16;

    gpsMapRect = CGRectMake(smallLabelLineHeight, smallLabelLineHeight, width - 2 * smallLabelLineHeight, height - 5 * smallLabelLineHeight);

    coordsMinXRect = CGRectMake( 0 * width16, width16, smallLabelLineHeight, 15 * height16);
    coordsMaxXRect = CGRectMake(width - smallLabelLineHeight, width16, smallLabelLineHeight, 15 * height16);

    coordsMaxYRect = CGRectMake(0,  0, width, smallLabelLineHeight);
    coordsMinYRect = CGRectMake(0, height - 4 * smallLabelLineHeight, width, smallLabelLineHeight);

    coordsLastRect = CGRectMake(0, height - 3 * smallLabelLineHeight, width, smallLabelLineHeight);
    coordsAvgRect = CGRectMake( 0, height - 2 * smallLabelLineHeight, width, smallLabelLineHeight);
    distanceRect = CGRectMake(  0, height - 1 * smallLabelLineHeight, width, smallLabelLineHeight);
}

- (void)viewWilltransitionToSize
{
    [self calculateRects];
    coordsMinX.frame = coordsMinXRect;
    coordsMaxX.frame = coordsMaxXRect;
    coordsMinY.frame = coordsMinYRect;
    coordsMaxY.frame = coordsMaxYRect;
    coordsAvg.frame = coordsAvgRect;
    coordsLast.frame = coordsLastRect;
    distance.frame = distanceRect;

    gpsMap.frame = gpsMapRect;
}

- (UIImage *)createGPSMap
{
    UIImage *img = nil;
    NSInteger X = gpsMapRect.size.width;
    NSInteger Y = gpsMapRect.size.height;

    if (X == 0 && Y == 0)
        return nil;

    __block CGFloat x0 = +180, x3 = -180, y0 = +180, y3 = -180;
    [coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D *c, NSUInteger idx, BOOL *stop) {
        x0 = MIN(x0, c.lon);
        x3 = MAX(x3, c.lon);
        y0 = MIN(y0, c.lat);
        y3 = MAX(y3, c.lat);
    }];

    coordsMinX.text = [Coordinates NiceLongitude:x0];
    coordsMaxX.text = [Coordinates NiceLongitude:x3];
    coordsMinY.text = [Coordinates NiceLatitude:y0];
    coordsMaxY.text = [Coordinates NiceLatitude:y3];

    x0 -= .0001;
    y0 -= .0001;
    x3 += .0001;
    y3 += .0001;

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

    // Al coordinates. The older the coordinates, the lighters they will be.
    GCLocationCoordinate2D *avg = [[GCLocationCoordinate2D alloc] init];
    CGContextSetLineWidth(context, 1);
    __block NSInteger countavg = 0;
    [coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D *c, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:(1.0 - 1.0 * (idx + 1) / [coords count]) alpha:1] CGColor]);
        CGFloat xx = [self xtrack:c.lon x0:x0 X:X x3:x3];
        CGFloat yy = [self ytrack:c.lat y0:y0 Y:Y y3:y3];
        CGContextStrokeRect(context, CGRectMake(xx - c.accuracy / 2.0, yy - c.accuracy / 2.0, c.accuracy, c.accuracy));

        // All accuracies over 30 m get one count, everything below gets (30-accuracy) counts.
        // Also the newer measurements get a higher weight.
        avg.lat += idx * (1 + (c.accuracy > 30 ? 0 : 30 - c.accuracy)) * c.lat;
        avg.lon += idx * (1 + (c.accuracy > 30 ? 0 : 30 - c.accuracy)) * c.lon;
        countavg += idx * (1 + (c.accuracy > 30 ? 0 : 30 - c.accuracy));
    }];
    avg.lat /= countavg;
    avg.lon /= countavg;

    // Last coordinates in green
    GCLocationCoordinate2D *last = [coords lastObject];
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGFloat xx = [self xtrack:last.lon x0:x0 X:X x3:x3];
    CGFloat yy = [self ytrack:last.lat y0:y0 Y:Y y3:y3];
    CGContextStrokeRect(context, CGRectMake(xx - last.accuracy / 2.0, yy - last.accuracy / 2.0, last.accuracy, last.accuracy));

    // Average coordinates in red
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    if ([coords count] != 0) {
        CGFloat xx = [self xtrack:avg.lon x0:x0 X:X x3:x3];
        CGFloat yy = [self ytrack:avg.lat y0:y0 Y:Y y3:y3];
        CGContextFillRect(context, CGRectMake(xx - 2, yy - 2, 4, 4));
    }
    CGContextStrokePath(context);

    // Update text
    coordsLast.text = [NSString stringWithFormat:@"Last: %@ ± %@", [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(last.lat, last.lon)], [MyTools niceDistance:last.accuracy]];
    coordsAvg.text = [NSString stringWithFormat:@"Average: %@", [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(avg.lat, avg.lon)]];
    distance.text = [NSString stringWithFormat:@"Last distance to average: %@", [MyTools niceDistance:[Coordinates coordinates2distance:CLLocationCoordinate2DMake(avg.lat, avg.lon) to:CLLocationCoordinate2DMake(last.lat, last.lon)]]];

    // Make an image
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
    c.accuracy = LM.accuracy;

    if (c.lat == 0 && c.lon == 0)
        return;

    struct timeval tv;
    gettimeofday(&tv, NULL);
    c.tv = tv;

    [coords addObject:c];
    while ([coords count] > 100)
        [coords removeObjectAtIndex:0];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        gpsMap.image = [self createGPSMap];
    }];
}

- (void)updateEverySecond
{
    while ([coords count] == 0) {
        [NSThread sleepForTimeInterval:1];
        if (stopTimer == YES)
            return;
    }
    while (1) {
        if (stopTimer == YES)
            return;
        [NSThread sleepForTimeInterval:1.0];

        GCLocationCoordinate2D *c = [coords lastObject];
        long lastc = c.tv.tv_sec;
        long now = time(NULL);

        // Only make a new data point if the poll was more than one second away.
        if (now - lastc < 1)
            continue;

        [self updateLocationManagerLocation];
    }
}

- (void)copyCoords:(NSString *)c
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = c;
    [MyTools messageBox:self header:@"Copy successful" text:@"The coordinates have been copied to the clipboard."];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuRestart:
            [coords removeAllObjects];
            [self updateLocationManagerLocation];
            return;

        case menuCopyCoordsLast:
            [self copyCoords:coordsLast.text];
            return;

        case menuCopyCoordsAvg:
            [self copyCoords:coordsAvg.text];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
