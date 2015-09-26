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

@implementation CacheImageViewController

@synthesize delegate;

- (instancetype)init:(dbImage *)_img
{
    self = [super init];

    img = _img;
    hasCloseButton = YES;
    menuItems = nil;
    image = nil;
    delegate = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    self.view = sv;

    [self loadImage];
}

- (void)loadImage
{
    [imgview removeFromSuperview];

    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], img.datafile]];

    imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    imgview.image = image;
    [self.view addSubview:imgview];

    zoomedin = NO;
    [self zoominout];

    [self.view setUserInteractionEnabled:YES];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    UISwipeGestureRecognizer *swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeleft];

    UISwipeGestureRecognizer *swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swiperight];

    [self showCloseButton];
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.5 animations:^(void){
        [self zoominout];
    }];
}

- (void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (delegate != nil) {
        dbImage *imgnew = [delegate swipeToLeft];
        if (imgnew != nil) {
            img = imgnew;
            [self loadImage];
        }
    }
}

- (void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (delegate != nil) {
        dbImage *imgnew = [delegate swipeToRight];
        if (imgnew != nil) {
            img = imgnew;
            [self loadImage];
        }
    }
}

- (void)zoominout
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

    if (zoomedin == YES) {
        imgview.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        sv.contentSize = image.size;
        [self.view sizeToFit];
        zoomedin = NO;
        return;
    }

    // Nothing to zoom in if the picture is small enough already.
    if (image.size.width < applicationFrame.size.width &&
        image.size.height < applicationFrame.size.height) {

        // Center around the middle of the screen
        imgview.frame = CGRectMake((applicationFrame.size.width - image.size.width) / 2, (applicationFrame.size.height - image.size.height) / 2, image.size.width, image.size.height);

        sv.contentSize = imgview.frame.size;
        [self.view sizeToFit];
        zoomedin = NO;
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
    zoomedin = YES;
}

@end
