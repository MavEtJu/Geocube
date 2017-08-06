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

@interface WaypointImageViewController ()
{
    dbImage *img;
    UIScrollView *sv;
    UIImage *image;
    UIImageView *imgview;

    CGRect imgViewRect;
    GCLabel *labelCount;

    BOOL zoomedIn;

    NSInteger totalImages, thisImage;
}

@end

@implementation WaypointImageViewController

enum {
    menuUploadAirdrop,
    menuUploadICloud,
    menuDeletePhoto,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    img = nil;
    hasCloseButton = YES;
    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUploadAirdrop label:_(@"waypointimageviewcontroller-airdrop")];
    [lmi addItem:menuUploadICloud label:_(@"waypointimageviewcontroller-icloud")];
    [lmi addItem:menuDeletePhoto label:_(@"waypointimageviewcontroller-deletephoto")];
    image = nil;
    self.delegate = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    sv.delegate = self;
    self.view = sv;

    [self loadImage];
    [self prepareCloseButton:sv];
}

- (void)loadImage
{
    [imgview removeFromSuperview];
    [labelCount removeFromSuperview];

    imgview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imgview];

    labelCount = [[GCLabel alloc] initWithFrame:CGRectZero];
    labelCount.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:labelCount];

    [self zoominout:NO];

    [self.view setUserInteractionEnabled:YES];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    UISwipeGestureRecognizer *swipeup = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeup.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeup];

    UISwipeGestureRecognizer *swipedown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipedown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipedown];

    [self calculateRects];
    [self viewWillTransitionToSize];
    [self showCloseButton];
}

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer
{
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

- (void)swipeUp:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (self.delegate != nil) {
        [self.delegate WaypointImage_swipeToUp];
        [self loadImage];
    }
}

- (void)swipeDown:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (self.delegate != nil) {
        [self.delegate WaypointImage_swipeToDown];
        [self loadImage];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];

    if (labelCount == nil)
        return;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    CGRect frame = labelCount.frame;
    frame.origin.y = scrollView.contentOffset.y;
    frame.origin.x = scrollView.contentOffset.x + width - 100;
    labelCount.frame = frame;
    frame.origin.y = scrollView.contentOffset.y;
}

- (void)zoominout:(BOOL)zoomIn
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

    applicationFrame.size.width--;
    applicationFrame.size.height--;

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
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

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
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    labelCount.frame = CGRectMake(width - 100, 0, 100, 15);
    [self zoominout:zoomedIn];
}

- (void)setImage:(dbImage *)_img idx:(NSInteger)_thisImage totalImages:(NSInteger)_totalImages
{
    img = _img;
    thisImage = _thisImage;
    totalImages = _totalImages;
    [self viewWillTransitionToSize];
}

- (void)viewWillTransitionToSize
{
    labelCount.text = [NSString stringWithFormat:@"%ld / %ld", (long)thisImage, (long)totalImages];

    image = [UIImage imageWithContentsOfFile:[MyTools ImageFile:img.datafile]];
    imgview.image = image;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuUploadAirdrop:
            [self uploadAirdrop];
            return;
        case menuUploadICloud:
            [self uploadICloud];
            return;
        case menuDeletePhoto:
            [fileManager removeItemAtPath:[MyTools ImageFile:img.datafile] error:nil];
            [self.delegate WaypointImage_refreshTable];
            [self.navigationController popViewControllerAnimated:YES];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)uploadAirdrop
{
    NSString *filename = [MyTools ImageFile: img.datafile];
    [IOSFTM uploadAirdrop:filename vc:self];
}

- (void)uploadICloud
{
    NSString *filename = [MyTools ImageFile:img.datafile];
    [IOSFTM uploadICloud:filename vc:self];
}

@end
