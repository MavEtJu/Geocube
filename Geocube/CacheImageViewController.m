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

- (id)init:(dbImage *)_img
{
    self = [super init];

    img = _img;
    hasCloseButton = YES;
    zoomedin = NO;
    image = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    self.view = sv;

    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], img.datafile]];

    imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    imgview.image = image;
    [self.view addSubview:imgview];

    [self zoominout];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [imgview addGestureRecognizer:singleTap];
    [imgview setUserInteractionEnabled:YES];
}

- (void)imageTaped:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.5 animations:^(void){
        [self zoominout];
    }];
}

- (void)zoominout
{
    if (zoomedin == YES) {
        imgview.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        sv.contentSize = image.size;
        [self.view sizeToFit];
        zoomedin = NO;
        return;
    }

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];

    // Nothing to zoom in if the picture is small enough already.
    if (image.size.width < applicationFrame.size.width &&
        image.size.height < applicationFrame.size.height)
        return;

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
