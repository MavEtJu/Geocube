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

@interface KeepTrackTrack ()
{
    dbTrack *track;
    CGFloat distance;

    CGRect rectHeightImage;
    CGRect rectTrackImage;
    CGRect rectName;
    CGRect rectDate;
    CGRect rectDistance;

    GCLabel *labelName;
    GCLabel *labelDate;
    GCLabel *labelDistance;
    UIImageView *ivTrackImage;
    UIImageView *ivHeightImage;

    UITapGestureRecognizer *ivHeightTap;
}

@end

@implementation KeepTrackTrack

enum {
    menuExportTrack,
    menuDeleteTrack,

    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuExportTrack label:@"Export track"];
    [lmi addItem:menuDeleteTrack label:@"Delete track"];

    hasCloseButton = YES;

    return self;
}

- (void)showTrack:(dbTrack *)_track
{
    track = _track;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

    labelName = [[GCLabel alloc] initWithFrame:rectName];
    labelName.textAlignment = NSTextAlignmentCenter;
    labelName.text = track.name;
    [self.view addSubview:labelName];

    labelDate = [[GCLabel alloc] initWithFrame:rectDate];
    labelDate.textAlignment = NSTextAlignmentCenter;
    labelDate.text = [NSString stringWithFormat:@"%@", [MyTools datetimePartDate:[MyTools dateString:track.dateStart]]];
    [self.view addSubview:labelDate];

    labelDistance = [[GCLabel alloc] initWithFrame:rectDistance];
    labelDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelDistance];

    ivTrackImage = [[UIImageView alloc] initWithFrame:rectTrackImage];
    ivTrackImage.backgroundColor = [UIColor redColor];
    ivTrackImage.image = [self createTrackMap:rectTrackImage];
    [self.view addSubview:ivTrackImage];

    ivHeightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ivHeightTapMethod)];
    ivHeightImage = [[UIImageView alloc] initWithFrame:rectHeightImage];
    ivHeightImage.backgroundColor = [UIColor clearColor];
    [ivHeightImage setUserInteractionEnabled:YES];
    [ivHeightImage addGestureRecognizer:ivHeightTap];
    ivHeightImage.image = [self createHeightMap:rectHeightImage];
    [self.view addSubview:ivHeightImage];

    // Has to be done after the call to [self createMap]
    labelDistance.text = [NSString stringWithFormat:@"Total distance: %@", [MyTools niceDistance:distance]];

    [self viewWilltransitionToSize];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self calculateRects];
                                     [self viewWilltransitionToSize];
                                 }
     ];
}

- (void)viewWilltransitionToSize
{
    labelName.frame = rectName;
    labelDate.frame = rectDate;
    labelDistance.frame = rectDistance;
    ivTrackImage.frame = rectTrackImage;
    ivTrackImage.image = [self createTrackMap:rectTrackImage];
    ivHeightImage.frame = rectHeightImage;
    ivHeightImage.image = [self createHeightMap:rectHeightImage];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    NSInteger height18 = bounds.size.height / 18;

    rectName = CGRectMake(0, 0 * height18, width, height18);
    rectDate = CGRectMake(0, 1 * height18, width, height18);
    rectDistance = CGRectMake(0, 2 * height18, width, height18);
    rectTrackImage = CGRectMake(0, 3 * height18, width, height - 6 * height18);
    rectHeightImage = CGRectMake(0, height - 3 * height18, width, 1 * height18);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    labelDate.text = [NSString stringWithFormat:@"%@", [MyTools datetimePartDate:[MyTools dateString:track.dateStart]]];
}

- (void)ivHeightTapMethod
{
    KeepTrackHeightScroller *newController = [[KeepTrackHeightScroller alloc] init];
    [newController showTrack:track];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = @"";
    [self.navigationController pushViewController:newController animated:YES];
}

- (UIImage *)createHeightMap:(CGRect)rect
{
    UIImage *img = nil;

    NSArray *tes = [dbTrackElement dbAllByTrack:track._id];

    __block CGFloat ymin = +100000, ymax = -100000;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        ymin = MIN(ymin, te.height);
        ymax = MAX(ymax, te.height);
    }];
    ymin = MIN(0, ymin);

    if (ymax == ymin)
        return nil;
    if (ymax < ymin)
        return nil;

    NSInteger elements = [tes count];
    NSInteger X = rect.size.width;
    NSInteger Y = rect.size.height;

    UIGraphicsBeginImageContext(CGSizeMake(X, Y));
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Black background
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, X, Y));

    /*

    |
    |    ...
    |  |||||||,.
    |.||||||||||||
    +-------------------------
     */

#define MARGIN 10
#define _XH(x) \
    MARGIN + (X - 2 * MARGIN) * (x) / elements
#define _YH(y) \
    Y * (y) / (ymax - ymin)
#define LINEHEIGHT(x, y) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, _XH(x), Y); \
    CGContextAddLineToPoint(context, _XH(x), Y - _YH(y) + 0.5); \
    CGContextStrokePath(context);

   CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    __block dbTrackElement *te_prev = nil;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te_prev != nil && te.restart == NO) {
            LINEHEIGHT(idx, te.height);
        }
        te_prev = te;
    }];

    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

- (UIImage *)createTrackMap:(CGRect)rect
{
    UIImage *img = nil;

    NSArray *tes = [dbTrackElement dbAllByTrack:track._id];

    __block CGFloat x0 = +180000000, x3 = -180000000, y0 = +180000000, y3 = -180000000;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        x0 = MIN(x0, te.lon_int);
        x3 = MAX(x3, te.lon_int);
        y0 = MIN(y0, te.lat_int);
        y3 = MAX(y3, te.lat_int);
    }];
    x0 /= 1000000.0;
    y0 /= 1000000.0;
    x3 /= 1000000.0;
    y3 /= 1000000.0;

    NSInteger X = rect.size.width;
    NSInteger Y = rect.size.height;

    UIGraphicsBeginImageContext(CGSizeMake(X, Y));
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Black background
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, X, Y));

#define MARGIN 10
#define _XTRACK(x)     MARGIN + (x - x0) * ((X - 2 * MARGIN) / (x3 - x0))
#define _YTRACK(y) Y - MARGIN - (y - y0) * ((Y - 2 * MARGIN) / (y3 - y0))
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

#define LINETRACK(x1, y1, x2, y2) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, _XTRACK(x1), _YTRACK(y1) + 0.5); \
    CGContextAddLineToPoint(context, _XTRACK(x2) + 1, _YTRACK(y2) + 0.5); \
    CGContextStrokePath(context);

   CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    __block dbTrackElement *te_prev = nil;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te_prev != nil && te.restart == NO) {
            LINETRACK(te_prev.lon, te_prev.lat, te.lon, te.lat);
            distance += [Coordinates coordinates2distance:te_prev.coords to:te.coords];
        }
        te_prev = te;
    }];

    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // NSData * binaryImageData = UIImagePNGRepresentation(img);
    // [binaryImageData writeToFile:[[MyTools DocumentRoot] stringByAppendingPathComponent:@"myfile.png"] atomically:YES];

    return img;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuDeleteTrack:
            [self trackDelete];
            return;
        case menuExportTrack:
            [self trackExport];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)trackDelete
{
    [dbTrackElement dbDeleteByTrack:track._id];
    [track dbDelete];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)trackExport
{
    NSArray *tes = [dbTrackElement dbAllByTrack:track._id];
    NSMutableString *o = [NSMutableString stringWithString:@""];
    [o appendString:@"<?xml version=\"1.0\"?>\n"];
    [o appendString:@"<gpx version=\"1.1\" creator=\"Geocube\">\n"];

    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        [o appendFormat:@"<wpt lat=\"%f\" lon=\"%f\">\n", te.lat, te.lon];
        [o appendFormat:@"<geoidheight>%ld</geoidheight>\n", (long)te.height];
        [o appendFormat:@"<time>%@</time>\n", [MyTools dateString:te.timestamp_epoch]];
        [o appendString:@"</wpt>\n"];
    }];

    [o appendString:@"</gpx>\n"];

    NSString *filename = [track.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *fullname = [NSString stringWithFormat:@"%@/export-%@", [MyTools FilesDir], filename];
    NSError *error = nil;
    [o writeToFile:fullname atomically:NO encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"Track written to %@, error %@", filename, error);

    [MyTools messageBox:self header:@"Export complete" text:[NSString stringWithFormat:@"Exported %@. You can find them in the Files menu.", filename]];
}

@end