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

    UIScrollView *sv;
    UIImage *image;
    UIImageView *imgview;

    BOOL zoomedIn;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    sv.delegate = self;
    self.view = sv;

    [self loadImage];
}

- (void)loadImage
{
    [imgview removeFromSuperview];

    imgview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imgview];

    [self zoominout:NO];

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

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer {

    if (zoomedIn) {
        [UIView animateWithDuration:0.5 animations:^(void){
            [self zoominout:(!zoomedIn)];
        }];
        return;
    }

    CGSize imgSize = imgview.frame.size;
    CGPoint touchPoint = [gestureRecognizer locationInView:imgview];
    [UIView animateWithDuration:0.5 animations:^(void){
        [self zoominout:(!zoomedIn) centerX:touchPoint.x / imgSize.width centerY:touchPoint.y / imgSize.height];
    }];
}

- (void)createHeightMap
{
    NSArray *tes = [dbTrackElement dbAllByTrack:track._id];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

    __block CGFloat ymin = +100000, ymax = -100000;
    __block CGFloat xmin = time(NULL) + 86400, xmax = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        ymin = MIN(ymin, te.height);
        ymax = MAX(ymax, te.height);
        xmin = MIN(xmin, te.timestamp_epoch);
        xmax = MAX(xmax, te.timestamp_epoch);
    }];
    ymin = MIN(0, ymin);

    if (ymax == ymin)
        return;
    if (ymax < ymin)
        return;

    NSInteger elements = [tes count];
    NSInteger X = 86400 / 10;
    NSInteger Y = applicationFrame.size.height - 50;

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

    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)zoominout:(BOOL)zoomIn
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

    // Nothing to zoom in if the picture is small enough already.
    if (image.size.width < applicationFrame.size.width &&
        image.size.height < applicationFrame.size.height) {

        // Center around the middle of the screen
        imgview.frame = CGRectMake((applicationFrame.size.width - image.size.width) / 2, (applicationFrame.size.height - image.size.height) / 2, image.size.width, image.size.height);

        sv.contentSize = imgview.frame.size;
        [self.view sizeToFit];
        zoomedIn = NO;
        return;
    }

    if (zoomIn == YES) {
        imgview.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        sv.contentSize = image.size;
        [self.view sizeToFit];
        zoomedIn = YES;
        return;
    }

    // Adjust the picture according to the ration of the width and the height
    float rw = 1.0 * image.size.width / applicationFrame.size.width;
    float rh = 1.0 * image.size.height / applicationFrame.size.height;

    if (rw < 1.0 && rh >= 1.0) {
        imgview.frame = CGRectMake(0, 0, image.size.width / rh, image.size.height / rh);
    }
    if (rh < 1.0 && rw >= 1.0) {
        imgview.frame = CGRectMake(0, 0, image.size.width / rw, image.size.height / rw);
    }
    if (rh >= 1.0 && rw >= 1.0) {
        float rx = (rh > rw) ? rh : rw;
        imgview.frame = CGRectMake(0, 0, image.size.width / rx, image.size.height / rx);
    }

    sv.contentSize = imgview.frame.size;
    [self.view sizeToFit];
    zoomedIn = NO;
}

- (void)zoominout:(BOOL)zoomIn centerX:(CGFloat)centerX centerY:(CGFloat)centerY
{
    [self zoominout:zoomIn];
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

    /*
     *  +-------------------+
     *  |                   |
     *  | O+---+            |
     *  |  |   |            |
     *  |  | C |            |
     *  |  |   |            |
     *  |  +---+            |
     *  |                   |
     *  |                   |
     *  +-------------------+
     *
     * xC = img.width * centerX
     * yC = img.height * centerY
     *
     * xO = xC - view.width / 2
     * yO = yC - view.height / 2
     *
     */

    CGFloat xO, yO;

    xO = imgview.frame.size.width * centerX - applicationFrame.size.width / 2;
    yO = imgview.frame.size.height * centerY - applicationFrame.size.height / 2;
    if (applicationFrame.size.height > imgview.frame.size.height) {
        yO = 0;
    } else if (applicationFrame.size.width > imgview.frame.size.width) {
        xO = 0;
    }

    if (xO > imgview.frame.size.width - applicationFrame.size.width)
        xO = imgview.frame.size.width - applicationFrame.size.width;
    if (yO > imgview.frame.size.height - applicationFrame.size.height)
        yO = imgview.frame.size.height - applicationFrame.size.height;
    if (xO < 0)
        xO = 0;
    if (yO < 0)
        yO = 0;

    sv.contentOffset = CGPointMake(xO, yO);
}

- (void)calculateRects
{
    [self zoominout:zoomedIn];
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
