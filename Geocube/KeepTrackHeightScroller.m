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

#import "Geocube-prefix.pch"

@interface KeepTrackHeightScroller ()
{
    dbTrack *track;
    NSArray *tes;
    NSArray *timestamps;

    UIScrollView *sv;
    UIImage *image;
    UIImageView *imgview;
    UILabel *labelTimeStart, *labelTimeStop;

    BOOL zoomedIn;
    NSInteger centeredX;
    id delegate;
}

@end

@implementation KeepTrackHeightScroller

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
    lmi = nil;

    sv = nil;
    image = nil;
    hasCloseButton = YES;

    return self;
}

- (void)showTrack:(dbTrack *)_track
{
    track = _track;
    tes = [dbTrackElement dbAllByTrack:track._id];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;
    sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    sv.delegate = self;
    self.view = sv;

    [self loadImage];

    labelTimeStart = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 200, 20)];
    labelTimeStart.text = @"00:00:00";
    [sv addSubview:labelTimeStart];
    labelTimeStop = [[UILabel alloc] initWithFrame:CGRectMake(width - 200, 20, 200, 20)];
    labelTimeStop.text = @"00:00:00";
    labelTimeStop.textAlignment = NSTextAlignmentRight;
    [sv addSubview:labelTimeStop];
    [self updateLabelTime:0];
}

- (void)loadImage
{
    [imgview removeFromSuperview];

    imgview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imgview];

    [self zoominout:YES centerX:0];

    [self.view setUserInteractionEnabled:YES];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    [self createHeightMap];
    imgview.image = image;

    [self calculateRects];
    [self showCloseButton];
}

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (zoomedIn) {
        CGPoint touchPoint = [gestureRecognizer locationInView:imgview];
        CGSize imgSize = imgview.frame.size;
        [UIView animateWithDuration:0.5 animations:^(void){
            [self zoominout:(!zoomedIn) centerX:touchPoint.x / imgSize.width];
        }];
        return;
    }

    [UIView animateWithDuration:0.5 animations:^(void){
        [self zoominout:(!zoomedIn) centerX:0];
    }];
}

- (void)createHeightMap
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

    __block CGFloat ymin = +100000, ymax = -100000;
    __block CGFloat xmin = time(NULL) + 86400, xmax = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        ymin = MIN(ymin, te.height);
        ymax = MAX(ymax, te.height);
    }];
    xmin = 0;
    xmax = [tes count];
    ymin = MIN(0, ymin);

    if (ymax == ymin)
        return;
    if (ymax < ymin)
        return;

    NSInteger X = xmax;
    NSInteger Y = applicationFrame.size.height - 50;

    __block NSInteger steps = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te.restart)
            steps++;
    }];
    X += steps;

    NSLog(@"ymin,ymax=%0.2f,%0.2f xmin,xmax=%0.2f,%0.2f X,Y=%ld,%ld step=%ld", ymin, ymax, xmin, xmax, (long)X, (long)Y, (long)steps);

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
#define _X(x) \
    MARGIN + (X - 2 * MARGIN) * (x) / X
#define _Y(y) \
    Y * (y) / (ymax - ymin)
#define LINE(x, y) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, _X(x), Y + 0.5); \
    CGContextAddLineToPoint(context, _X(x), Y - _Y(y) + 0.5); \
    CGContextStrokePath(context);

    NSMutableArray *as = [NSMutableArray arrayWithCapacity:X];

    /* Draw lines */
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    __block NSInteger stepcounter = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te.restart) {
            stepcounter++;
            [as addObject:[NSNumber numberWithInteger:te.timestamp_epoch]];
        }
        [as addObject:[NSNumber numberWithInteger:te.timestamp_epoch]];
        LINE(idx + stepcounter, te.height);
    }];
    timestamps = as;

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *f = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], @"foo.png"];
    [UIImagePNGRepresentation(image) writeToFile:f atomically:YES];
    NSLog(@"%@", f);
}

- (void)zoominout:(BOOL)zoomIn centerX:(CGFloat)centerX
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

    if (zoomIn == YES) {
        imgview.frame = CGRectMake(0, 0, applicationFrame.size.width, applicationFrame.size.height - 50);
        sv.contentSize = imgview.frame.size;
        [self.view sizeToFit];
        zoomedIn = YES;
        [self updateLabelTime:0];
        return;
    }

    imgview.frame = CGRectMake(0, 0, image.size.width, applicationFrame.size.height - 50);
    sv.contentSize = imgview.frame.size;
    sv.contentOffset = CGPointMake(centerX * image.size.width, 0);
    [self.view sizeToFit];
    centeredX = centerX;
    zoomedIn = NO;
}

- (void)updateLabelTime:(NSInteger)idx
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    if (idx < 0)
        idx = 0;
    if (idx + width >= [timestamps count]) {
        idx = [timestamps count] - width - 1;
        if (idx < 0) {
            idx = 0;
            width = [timestamps count] - 1;
        }
    }

    labelTimeStart.text = [MyTools dateTimeString_hh_mm_ss:[[timestamps objectAtIndex:idx] integerValue]];
    labelTimeStop.text = [MyTools dateTimeString_hh_mm_ss:[[timestamps objectAtIndex:idx + width] integerValue]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];

    CGRect frame = labelTimeStart.frame;
    frame.origin.x = scrollView.contentOffset.x;
    labelTimeStart.frame = frame;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;
    frame = labelTimeStop.frame;
    frame.origin.x = scrollView.contentOffset.x + width - 200;
    labelTimeStop.frame = frame;

    [self.view bringSubviewToFront:labelTimeStart];
    [self.view bringSubviewToFront:labelTimeStop];
    [self updateLabelTime:scrollView.contentOffset.x];
}

- (void)calculateRects
{
    [self zoominout:zoomedIn centerX:centeredX];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self calculateRects];
                                 }
     ];
}

@end
