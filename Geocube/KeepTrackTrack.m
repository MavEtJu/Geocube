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

@implementation KeepTrackTrack


- (instancetype)init
{
    self = [super init];

    menuItems = nil;
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
    ivTrackImage.image = [self createMap];
    [self.view addSubview:ivTrackImage];

    labelDistance.text = [NSString stringWithFormat:@"Total distance: %@", [MyTools NiceDistance:distance]];

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
    rectTrackImage = CGRectMake(0, 3 * height18, width, height - 5 * height18);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    labelDate.text = [NSString stringWithFormat:@"%@", [MyTools datetimePartDate:[MyTools dateString:track.dateStart]]];
}

- (UIImage *)createMap
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

#define X 360
#define Y 360
    UIGraphicsBeginImageContext(CGSizeMake(X, Y));
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Black background
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, X, Y));

#define MARGIN 10
#define _X(x)     MARGIN + (x - x0) * ((X - 2 * MARGIN) / (x3 - x0))
#define _Y(y) Y - MARGIN - (y - y0) * ((Y - 2 * MARGIN) / (y3 - y0))
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

#define LINE(x1, y1, x2, y2) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, _X(x1), _Y(y1) + 0.5); \
    CGContextAddLineToPoint(context, _X(x2) + 1, _Y(y2) + 0.5); \
    CGContextStrokePath(context);

   CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    __block dbTrackElement *te_prev = nil;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te_prev != nil) {
            LINE(te_prev.lon, te_prev.lat, te.lon, te.lat);
            distance += [Coordinates coordinates2distance:te_prev.coords to:te.coords];
        }
        te_prev = te;
    }];

    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData * binaryImageData = UIImagePNGRepresentation(img);
    [binaryImageData writeToFile:[[MyTools DocumentRoot] stringByAppendingPathComponent:@"myfile.png"] atomically:YES];

    return img;
}

@end
