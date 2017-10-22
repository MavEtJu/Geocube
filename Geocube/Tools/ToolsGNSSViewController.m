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

@interface ToolsGNSSViewController ()

@property (nonatomic, retain) NSMutableArray<GCLocationCoordinate2D *> *coords;
@property (nonatomic        ) CLLocationCoordinate2D coordsLast, coordsAverage;

@property (nonatomic, retain) GCImageView *ivGNSSMap;

@property (nonatomic, retain) GCLabelSmallText *labelCoordsMinX;
@property (nonatomic, retain) GCLabelSmallText *labelCoordsMinY;
@property (nonatomic, retain) GCLabelSmallText *labelCoordsMaxX;
@property (nonatomic, retain) GCLabelSmallText *labelCoordsMaxY;
@property (nonatomic, retain) GCLabelSmallText *labelCoordsAvg;
@property (nonatomic, retain) GCLabelSmallText *labelCoordsLast;
@property (nonatomic, retain) GCLabelSmallText *labelDistance;

@property (nonatomic        ) CGRect rectGNSSMap;
@property (nonatomic        ) CGRect rectCoordsMinX;
@property (nonatomic        ) CGRect rectCoordsMinY;
@property (nonatomic        ) CGRect rectCoordsMaxX;
@property (nonatomic        ) CGRect rectCoordsMaxY;
@property (nonatomic        ) CGRect rectCoordsAvg;
@property (nonatomic        ) CGRect rectCoordsLast;
@property (nonatomic        ) CGRect rectDistance;

@property (nonatomic        ) float smallLabelLineHeight;
@property (nonatomic        ) BOOL stopTimer;


@end

@implementation ToolsGNSSViewController

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

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuRestart label:_(@"toolsgnssviewcontroller-Restart")];
    [self.lmi addItem:menuCopyCoordsAvg label:_(@"toolsgnssviewcontroller-Copy average coords")];
    [self.lmi addItem:menuCopyCoordsLast label:_(@"toolsgnssviewcontroller-Copy last coords")];
    [self.lmi addItem:menuCreateWaypoint label:_(@"toolsgnssviewcontroller-Create waypoint")];

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = NO;
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    GCView *contentView = [[GCView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    [self.view sizeToFit];

    GCLabelSmallText *l = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsMinX];
    self.smallLabelLineHeight = l.font.lineHeight;

    self.coords = [NSMutableArray arrayWithCapacity:100];

    self.ivGNSSMap = [[GCImageView alloc] initWithFrame:self.rectGNSSMap];
    self.ivGNSSMap.image = [self createGNSSMap];
    [self.view addSubview:self.ivGNSSMap];

    self.labelCoordsMinX = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsMinX];
    self.labelCoordsMinX.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.labelCoordsMinX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelCoordsMinX];

    self.labelCoordsMinY = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsMinY];
    self.labelCoordsMinY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelCoordsMinY];

    self.labelCoordsMaxX = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsMaxX];
    self.labelCoordsMaxX.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.labelCoordsMaxX.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelCoordsMaxX];

    self.labelCoordsMaxY = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsMaxY];
    self.labelCoordsMaxY.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelCoordsMaxY];

    self.labelCoordsAvg = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsAvg];
    self.labelCoordsAvg.textAlignment = NSTextAlignmentCenter;
    self.labelCoordsAvg.textColor = [UIColor redColor];
    [self.view addSubview:self.labelCoordsAvg];

    self.labelCoordsLast = [[GCLabelSmallText alloc] initWithFrame:self.rectCoordsLast];
    self.labelCoordsLast.textAlignment = NSTextAlignmentCenter;
    self.labelCoordsLast.textColor = [UIColor greenColor];
    [self.view addSubview:self.labelCoordsLast];

    self.labelDistance = [[GCLabelSmallText alloc] initWithFrame:self.rectDistance];
    self.labelDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelDistance];

    [self viewWilltransitionToSize];
    [self changeTheme];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LM startDelegationLocation:self isNavigating:YES];
    self.stopTimer = NO;
    BACKGROUND(updateEverySecond, nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.stopTimer = YES;
    [LM stopDelegationLocation:self];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger width16 = bounds.size.width / 16;
    NSInteger height16 = bounds.size.height / 18;
    NSInteger height = 16.8 * height16;

    self.rectGNSSMap = CGRectMake(self.smallLabelLineHeight, self.smallLabelLineHeight, width - 2 * self.smallLabelLineHeight, height - 5 * self.smallLabelLineHeight);

    self.rectCoordsMinX = CGRectMake( 0 * width16, width16, self.smallLabelLineHeight, 15 * height16);
    self.rectCoordsMaxX = CGRectMake(width - self.smallLabelLineHeight, width16, self.smallLabelLineHeight, 15 * height16);

    self.rectCoordsMaxY = CGRectMake(0,  0, width, self.smallLabelLineHeight);
    self.rectCoordsMinY = CGRectMake(0, height - 4 * self.smallLabelLineHeight, width, self.smallLabelLineHeight);

    self.rectCoordsLast = CGRectMake(0, height - 3 * self.smallLabelLineHeight, width, self.smallLabelLineHeight);
    self.rectCoordsAvg = CGRectMake( 0, height - 2 * self.smallLabelLineHeight, width, self.smallLabelLineHeight);
    self.rectDistance = CGRectMake(  0, height - 1 * self.smallLabelLineHeight, width, self.smallLabelLineHeight);
}

- (void)viewWilltransitionToSize
{
    [self calculateRects];
    self.labelCoordsMinX.frame = self.rectCoordsMinX;
    self.labelCoordsMaxX.frame = self.rectCoordsMaxX;
    self.labelCoordsMinY.frame = self.rectCoordsMinY;
    self.labelCoordsMaxY.frame = self.rectCoordsMaxY;
    self.labelCoordsAvg.frame = self.rectCoordsAvg;
    self.labelCoordsLast.frame = self.rectCoordsLast;
    self.labelDistance.frame = self.rectDistance;

    self.ivGNSSMap.frame = self.rectGNSSMap;
}

- (UIImage *)createGNSSMap
{
    UIImage *img = nil;
    NSInteger X = self.rectGNSSMap.size.width;
    NSInteger Y = self.rectGNSSMap.size.height;

    if (X == 0 && Y == 0)
        return nil;

    __block CGFloat x0 = +180, x3 = -180, y0 = +180, y3 = -180;
    [self.coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        x0 = MIN(x0, c.lon);
        x3 = MAX(x3, c.lon);
        y0 = MIN(y0, c.lat);
        y3 = MAX(y3, c.lat);
    }];

    self.labelCoordsMinX.text = [Coordinates niceLongitude:x0];
    self.labelCoordsMaxX.text = [Coordinates niceLongitude:x3];
    self.labelCoordsMinY.text = [Coordinates niceLatitude:y0];
    self.labelCoordsMaxY.text = [Coordinates niceLatitude:y3];

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
    [self.coords enumerateObjectsUsingBlock:^(GCLocationCoordinate2D * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:(1.0 - 1.0 * (idx + 1) / [self.coords count]) alpha:1] CGColor]);
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
    GCLocationCoordinate2D *last = [self.coords lastObject];
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGFloat xx = [self xtrack:last.lon x0:x0 X:X x3:x3];
    CGFloat yy = [self ytrack:last.lat y0:y0 Y:Y y3:y3];
    CGContextStrokeRect(context, CGRectMake(xx - last.accuracy / 2.0, yy - last.accuracy / 2.0, last.accuracy, last.accuracy));

    // Average coordinates in red
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    if ([self.coords count] != 0) {
        CGFloat xx = [self xtrack:avg.lon x0:x0 X:X x3:x3];
        CGFloat yy = [self ytrack:avg.lat y0:y0 Y:Y y3:y3];
        CGContextFillRect(context, CGRectMake(xx - 2, yy - 2, 4, 4));
    }
    CGContextStrokePath(context);

    // Update text
    self.labelCoordsLast.text = [NSString stringWithFormat:@"%@: %@ ± %@", _(@"toolsgnssviewcontroller-Last"), [Coordinates niceCoordinates:last.lat longitude:last.lon], [MyTools niceDistance:last.accuracy]];
    self.labelCoordsAvg.text = [NSString stringWithFormat:@"%@: %@", _(@"toolsgnssviewcontroller-Average"), [Coordinates niceCoordinates:avg.lat longitude:avg.lon]];
    self.labelDistance.text = [NSString stringWithFormat:@"%@: %@", _(@"toolsgnssviewcontroller-Last distance to average"), [MyTools niceDistance:[Coordinates coordinates2distance:avg.lat fromLongitude:avg.lon toLatitude:last.lat toLongitude:last.lon]]];

    // Make an image
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Keep track
    self.coordsAverage = CLLocationCoordinate2DMake(avg.lat, avg.lon);
    self.coordsLast = CLLocationCoordinate2DMake(last.lat, last.lon);

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

    [self.coords addObject:c];
    while ([self.coords count] > 100)
        [self.coords removeObjectAtIndex:0];

    MAINQUEUE(
        self.ivGNSSMap.image = [self createGNSSMap];
    )
}

- (void)updateEverySecond
{
    while ([self.coords count] == 0) {
        [NSThread sleepForTimeInterval:1];
        if (self.stopTimer == YES)
            return;
    }
    while (1) {
        if (self.stopTimer == YES)
            return;
        [NSThread sleepForTimeInterval:1.0];

        GCLocationCoordinate2D *c = [self.coords lastObject];
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
    [MyTools messageBox:self header:_(@"toolsgnssviewcontroller-Copy successful") text:_(@"toolsgnssviewcontroller-The coordinates have been copied to the clipboard")];
}

- (void)createWaypoint:(CLLocationCoordinate2D)coord
{
    NSString *code = [MyTools makeNewWaypoint:@"MY"];
    NSString *name = [NSString stringWithFormat:@"Waypoint averaged on %@", [Coordinates niceCoordinates:coord]];

    dbWaypoint *wp = [[dbWaypoint alloc] init];
    Coordinates *c = [[Coordinates alloc] init:coord];

    wp.wpt_latitude= [c latitude];
    wp.wpt_longitude = [c longitude];
    wp.wpt_name = code;
    wp.wpt_description = name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_url = nil;
    wp.wpt_urlname = [NSString stringWithFormat:@"%@ - %@", code, name];
    wp.wpt_symbol = dbc.symbolVirtualStage;
    wp.wpt_type = dbc.typeManuallyEntered;
    [wp finish];
    [wp dbCreate];

    [waypointManager needsRefreshAdd:wp];

    [MyTools messageBox:self header:_(@"toolsgnssviewcontroller-Waypoint added") text:[NSString stringWithFormat:_(@"toolsgnssviewcontroller-Waypoint %@ is now created at %@"), code, [Coordinates niceCoordinates:coord]]];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuRestart:
            [self.coords removeAllObjects];
            [self updateLocationManagerLocation];
            return;

        case menuCopyCoordsLast:
            [self copyCoords:self.labelCoordsLast.text];
            return;

        case menuCopyCoordsAvg:
            [self copyCoords:self.labelCoordsAvg.text];
            return;

        case menuCreateWaypoint:
            [self createWaypoint:self.coordsAverage];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
