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
    CLLocationCoordinate2D coordsLast, coordsAverage;

    GCImageView *ivGpsMap;

    GCSmallLabel *labelCoordsMinX;
    GCSmallLabel *labelCoordsMinY;
    GCSmallLabel *labelCoordsMaxX;
    GCSmallLabel *labelCoordsMaxY;
    GCSmallLabel *labelCoordsAvg;
    GCSmallLabel *labelCoordsLast;
    GCSmallLabel *labelDistance;

    CGRect rectGpsMap;
    CGRect rectCoordsMinX;
    CGRect rectCoordsMinY;
    CGRect rectCoordsMaxX;
    CGRect rectCoordsMaxY;
    CGRect rectCoordsAvg;
    CGRect rectCoordsLast;
    CGRect rectDistance;

    float smallLabelLineHeight;
    BOOL stopTimer;
}

@end

@implementation ToolsGPSViewController

enum {
    menuRestart,
    menuCopyCoordsAvg,
    menuCopyCoordsLast,
    menuCreateWaypoint,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuRestart label:@"Restart"];
    [lmi addItem:menuCopyCoordsAvg label:@"Copy Average Coords"];
    [lmi addItem:menuCopyCoordsLast label:@"Copy Last Coords"];
    [lmi addItem:menuCreateWaypoint label:@"Create Waypoint"];

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = NO;
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    GCView *contentView = [[GCView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    [self.view sizeToFit];

    GCSmallLabel *l = [[GCSmallLabel alloc] initWithFrame:rectCoordsMinX];
    smallLabelLineHeight = l.font.lineHeight;

    coords = [NSMutableArray arrayWithCapacity:100];

    ivGpsMap = [[GCImageView alloc] initWithFrame:rectGpsMap];
    ivGpsMap.image = [self createGPSMap];
    [self.view addSubview:ivGpsMap];

    labelCoordsMinX = [[GCSmallLabel alloc] initWithFrame:rectCoordsMinX];
    labelCoordsMinX.text = @"MinX";
    labelCoordsMinX.transform = CGAffineTransformMakeRotation(-M_PI_2);
    labelCoordsMinX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCoordsMinX];

    labelCoordsMinY = [[GCSmallLabel alloc] initWithFrame:rectCoordsMinY];
    labelCoordsMinY.text = @"MinY";
    labelCoordsMinY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCoordsMinY];

    labelCoordsMaxX = [[GCSmallLabel alloc] initWithFrame:rectCoordsMaxX];
    labelCoordsMaxX.text = @"MaxX";
    labelCoordsMaxX.transform = CGAffineTransformMakeRotation(M_PI_2);
    labelCoordsMaxX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCoordsMaxX];

    labelCoordsMaxY = [[GCSmallLabel alloc] initWithFrame:rectCoordsMaxY];
    labelCoordsMaxY.text = @"MaxY";
    labelCoordsMaxY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCoordsMaxY];

    labelCoordsAvg = [[GCSmallLabel alloc] initWithFrame:rectCoordsAvg];
    labelCoordsAvg.text = @"avg";
    labelCoordsAvg.textAlignment = NSTextAlignmentCenter;
    labelCoordsAvg.textColor = [UIColor redColor];
    [self.view addSubview:labelCoordsAvg];

    labelCoordsLast = [[GCSmallLabel alloc] initWithFrame:rectCoordsLast];
    labelCoordsLast.text = @"last";
    labelCoordsLast.textAlignment = NSTextAlignmentCenter;
    labelCoordsLast.textColor = [UIColor greenColor];
    [self.view addSubview:labelCoordsLast];

    labelDistance = [[GCSmallLabel alloc] initWithFrame:rectDistance];
    labelDistance.text = @"last";
    labelDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelDistance];

    [self viewWilltransitionToSize];
    [self changeTheme];
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

    rectGpsMap = CGRectMake(smallLabelLineHeight, smallLabelLineHeight, width - 2 * smallLabelLineHeight, height - 5 * smallLabelLineHeight);

    rectCoordsMinX = CGRectMake( 0 * width16, width16, smallLabelLineHeight, 15 * height16);
    rectCoordsMaxX = CGRectMake(width - smallLabelLineHeight, width16, smallLabelLineHeight, 15 * height16);

    rectCoordsMaxY = CGRectMake(0,  0, width, smallLabelLineHeight);
    rectCoordsMinY = CGRectMake(0, height - 4 * smallLabelLineHeight, width, smallLabelLineHeight);

    rectCoordsLast = CGRectMake(0, height - 3 * smallLabelLineHeight, width, smallLabelLineHeight);
    rectCoordsAvg = CGRectMake( 0, height - 2 * smallLabelLineHeight, width, smallLabelLineHeight);
    rectDistance = CGRectMake(  0, height - 1 * smallLabelLineHeight, width, smallLabelLineHeight);
}

- (void)viewWilltransitionToSize
{
    [self calculateRects];
    labelCoordsMinX.frame = rectCoordsMinX;
    labelCoordsMaxX.frame = rectCoordsMaxX;
    labelCoordsMinY.frame = rectCoordsMinY;
    labelCoordsMaxY.frame = rectCoordsMaxY;
    labelCoordsAvg.frame = rectCoordsAvg;
    labelCoordsLast.frame = rectCoordsLast;
    labelDistance.frame = rectDistance;

    ivGpsMap.frame = rectGpsMap;
}

- (UIImage *)createGPSMap
{
    UIImage *img = nil;
    NSInteger X = rectGpsMap.size.width;
    NSInteger Y = rectGpsMap.size.height;

    if (X == 0 && Y == 0)
        return nil;

    __block CGFloat x0 = +180, x3 = -180, y0 = +180, y3 = -180;
    [coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D *c, NSUInteger idx, BOOL *stop) {
        x0 = MIN(x0, c.lon);
        x3 = MAX(x3, c.lon);
        y0 = MIN(y0, c.lat);
        y3 = MAX(y3, c.lat);
    }];

    labelCoordsMinX.text = [Coordinates NiceLongitude:x0];
    labelCoordsMaxX.text = [Coordinates NiceLongitude:x3];
    labelCoordsMinY.text = [Coordinates NiceLatitude:y0];
    labelCoordsMaxY.text = [Coordinates NiceLatitude:y3];

    x0 -= .0001;
    y0 -= .0001;
    x3 += .0001;
    y3 += .0001;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(X, Y), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // White background
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetFillColorWithColor(context, [currentTheme.imageBackgroundColor CGColor]);
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
    labelCoordsLast.text = [NSString stringWithFormat:@"Last: %@ ± %@", [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(last.lat, last.lon)], [MyTools niceDistance:last.accuracy]];
    labelCoordsAvg.text = [NSString stringWithFormat:@"Average: %@", [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(avg.lat, avg.lon)]];
    labelDistance.text = [NSString stringWithFormat:@"Last distance to average: %@", [MyTools niceDistance:[Coordinates coordinates2distance:CLLocationCoordinate2DMake(avg.lat, avg.lon) to:CLLocationCoordinate2DMake(last.lat, last.lon)]]];

    // Make an image
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Keep track
    coordsAverage = CLLocationCoordinate2DMake(avg.lat, avg.lon);
    coordsLast = CLLocationCoordinate2DMake(last.lat, last.lon);

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
        ivGpsMap.image = [self createGPSMap];
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

- (void)createWaypoint:(CLLocationCoordinate2D)coord
{
    NSString *code = [MyTools makeNewWaypoint:@"MY"];
    NSString *name = [NSString stringWithFormat:@"Waypoint averaged on %@", [Coordinates NiceCoordinates:coord]];

    dbWaypoint *wp = [[dbWaypoint alloc] init:0];
    Coordinates *c = [[Coordinates alloc] init:coord];

    wp.wpt_lat = [c lat_decimalDegreesSigned];
    wp.wpt_lon = [c lon_decimalDegreesSigned];
    wp.wpt_lat_int = [c lat] * 1000000;
    wp.wpt_lon_int = [c lon] * 1000000;
    wp.wpt_name = code;
    wp.wpt_description = name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:wp.wpt_date_placed_epoch];
    wp.wpt_url = nil;
    wp.wpt_urlname = [NSString stringWithFormat:@"%@ - %@", code, name];
    wp.wpt_symbol_id = 1;
    wp.wpt_type_id = [dbc Type_ManuallyEntered]._id;
    wp.related_id = 0;  // This is a new parent
    [wp finish];
    [dbWaypoint dbCreate:wp];

    [waypointManager needsRefreshAdd:wp];

    [MyTools messageBox:self header:@"Waypoint added" text:[NSString stringWithFormat:@"Waypoint %@ is now created at %@", code, [Coordinates NiceCoordinates:coord]]];
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
            [self copyCoords:labelCoordsLast.text];
            return;

        case menuCopyCoordsAvg:
            [self copyCoords:labelCoordsAvg.text];
            return;

        case menuCreateWaypoint:
            [self createWaypoint:coordsAverage];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
