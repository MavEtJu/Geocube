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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;

    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], img.datafile]];

    UIImageView *i = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    i.image = image;
    [self.view addSubview:i];

    [self.view sizeToFit];
}

@end
