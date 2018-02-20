/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) dbImage *img;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) UIScrollView *sv;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imgview;

@property (nonatomic        ) CGRect imgViewRect;
@property (nonatomic, retain) GCLabel *labelCount;
@property (nonatomic, retain) Coordinates *exifCoordinates;

@property (nonatomic        ) BOOL zoomedIn;

@property (nonatomic        ) NSInteger totalImages, thisImage;

@end

@implementation WaypointImageViewController

enum {
    menuUploadAirdrop,
    menuUploadICloud,
    menuDeletePhoto,
    menuAddNewWaypoint,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    self.img = nil;
    self.hasCloseButton = YES;
    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuUploadAirdrop label:_(@"waypointimageviewcontroller-Airdrop")];
    [self.lmi addItem:menuUploadICloud label:_(@"waypointimageviewcontroller-iCloud")];
    [self.lmi addItem:menuDeletePhoto label:_(@"waypointimageviewcontroller-Delete photo")];
    [self.lmi addItem:menuAddNewWaypoint label:_(@"waypointimageviewcontroller-Add waypoint")];
    self.image = nil;
    self.delegate = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.sv = [[UIScrollView alloc] initWithFrame:applicationFrame];
    self.sv.delegate = self;
    self.view = self.sv;

    [self loadImage];
    [self prepareCloseButton:self.sv];
}

- (void)loadImage
{
    [self.imgview removeFromSuperview];
    [self.labelCount removeFromSuperview];

    self.imgview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.imgview];

    self.labelCount = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.labelCount.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.labelCount];

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
    if (self.zoomedIn) {
        [UIView animateWithDuration:0.5 animations:^(void){
            [self zoominout:(!self.zoomedIn)];
        }];
        return;
    }

    CGSize imgSize = self.imgview.frame.size;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.imgview];
    [UIView animateWithDuration:0.5 animations:^(void){
        [self zoominout:(!self.zoomedIn) centerX:touchPoint.x / imgSize.width centerY:touchPoint.y / imgSize.height];
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

    if (self.labelCount == nil)
        return;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    CGRect frame = self.labelCount.frame;
    frame.origin.y = scrollView.contentOffset.y;
    frame.origin.x = scrollView.contentOffset.x + width - 100;
    self.labelCount.frame = frame;
    frame.origin.y = scrollView.contentOffset.y;
}

- (void)zoominout:(BOOL)zoomIn
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];

    applicationFrame.size.width--;
    applicationFrame.size.height--;

    // Nothing to zoom in if the picture is small enough already.
    if (self.image.size.width < applicationFrame.size.width &&
        self.image.size.height < applicationFrame.size.height) {

        // Center around the middle of the screen
        self.imgview.frame = CGRectMake((applicationFrame.size.width - self.image.size.width) / 2, (applicationFrame.size.height - self.image.size.height) / 2, self.image.size.width, self.image.size.height);

        self.sv.contentSize = self.imgview.frame.size;
        [self.view sizeToFit];
        self.zoomedIn = NO;
        return;
    }

    if (zoomIn == YES) {
        self.imgview.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
        self.sv.contentSize = self.image.size;
        [self.view sizeToFit];
        self.zoomedIn = YES;
        return;
    }

    // Adjust the picture according to the ration of the width and the height
    float rw = 1.0 * self.image.size.width / applicationFrame.size.width;
    float rh = 1.0 * self.image.size.height / applicationFrame.size.height;

    if (rw < 1.0 && rh >= 1.0) {
        self.imgview.frame = CGRectMake(0, 0, self.image.size.width / rh, self.image.size.height / rh);
    }
    if (rh < 1.0 && rw >= 1.0) {
        self.imgview.frame = CGRectMake(0, 0, self.image.size.width / rw, self.image.size.height / rw);
    }
    if (rh >= 1.0 && rw >= 1.0) {
        float rx = (rh > rw) ? rh : rw;
        self.imgview.frame = CGRectMake(0, 0, self.image.size.width / rx, self.image.size.height / rx);
    }

    self.sv.contentSize = self.imgview.frame.size;
    [self.view sizeToFit];
    self.zoomedIn = NO;
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

    xO = self.imgview.frame.size.width * centerX - applicationFrame.size.width / 2;
    yO = self.imgview.frame.size.height * centerY - applicationFrame.size.height / 2;
    if (applicationFrame.size.height > self.imgview.frame.size.height) {
        yO = 0;
    } else if (applicationFrame.size.width > self.imgview.frame.size.width) {
        xO = 0;
    }

    if (xO > self.imgview.frame.size.width - applicationFrame.size.width)
        xO = self.imgview.frame.size.width - applicationFrame.size.width;
    if (yO > self.imgview.frame.size.height - applicationFrame.size.height)
        yO = self.imgview.frame.size.height - applicationFrame.size.height;
    if (xO < 0)
        xO = 0;
    if (yO < 0)
        yO = 0;

    self.sv.contentOffset = CGPointMake(xO, yO);
}

- (void)calculateRects
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    self.labelCount.frame = CGRectMake(width - 100, 0, 100, 15);
    [self zoominout:self.zoomedIn];
}

- (void)setImage:(dbImage *)img idx:(NSInteger)thisImage totalImages:(NSInteger)totalImages waypoint:(dbWaypoint *)wp
{
    self.img = img;
    self.waypoint = wp;
    self.thisImage = thisImage;
    self.totalImages = totalImages;
    [self viewWillTransitionToSize];

    [self.lmi disableItem:menuAddNewWaypoint];
    NSDictionary *exif = [MyTools imageEXIFDataFile:[MyTools ImageFile:self.img.datafile]];
    NSDictionary *exifgps = [exif objectForKey:@"{GPS}"];
    NSString *lats = [exifgps objectForKey:@"Latitude"];
    NSString *latref = [exifgps objectForKey:@"LatitudeRef"];
    NSString *lons = [exifgps objectForKey:@"Longitude"];
    NSString *lonref = [exifgps objectForKey:@"LongitudeRef"];

    if (lats != nil) {
        CLLocationDegrees lat = [lats floatValue];
        if ([latref isEqualToString:@"S"] == YES)
            lat = -lat;
        CLLocationDegrees lon = [lons floatValue];
        if ([lonref isEqualToString:@"W"] == YES)
            lon = -lon;
        self.exifCoordinates = [[Coordinates alloc] init:lat longitude:lon];
        [self.lmi enableItem:menuAddNewWaypoint];
    }
}

- (void)viewWillTransitionToSize
{
    self.labelCount.text = [NSString stringWithFormat:@"%ld / %ld", (long)self.thisImage, (long)self.totalImages];

    self.image = [UIImage imageWithContentsOfFile:[MyTools ImageFile:self.img.datafile]];
    self.imgview.image = self.image;
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
            [fileManager removeItemAtPath:[MyTools ImageFile:self.img.datafile] error:nil];
            [self.delegate WaypointImage_refreshTable];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        case menuAddNewWaypoint:
            [self addNewWaypoint];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)uploadAirdrop
{
    NSString *filename = [MyTools ImageFile: self.img.datafile];
    [IOSFTM uploadAirdrop:filename vc:self];
}

- (void)uploadICloud
{
    NSString *filename = [MyTools ImageFile:self.img.datafile];
    [IOSFTM uploadICloud:filename vc:self];
}

- (void)addNewWaypoint
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    wp.wpt_latitude = self.exifCoordinates.latitude;
    wp.wpt_longitude = self.exifCoordinates.longitude;
    wp.wpt_name = [dbWaypoint makeName:[self.waypoint.wpt_name substringFromIndex:2]];
    wp.wpt_description = wp.wpt_name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_url = nil;
    wp.wpt_urlname = wp.wpt_name;
    wp.wpt_symbol = dbc.symbolVirtualStage;
    wp.wpt_type = dbc.typeManuallyEntered;
    wp.account = self.waypoint.account;
    [wp finish];
    [wp dbCreate];

    [dbc.groupAllWaypointsManuallyAdded addWaypointToGroup:wp];
    [dbc.groupAllWaypoints addWaypointToGroup:wp];
    [dbc.groupManualWaypoints addWaypointToGroup:wp];

    [waypointManager needsRefreshAdd:wp];

    [MyTools messageBox:self header:_(@"waypointimageviewcontroller-Waypoint added") text:_(@"waypointimageviewcontroller-The new waypoint has been added to the map")];

    [self.delegate WaypointImage_refreshWaypoint];
}

@end
