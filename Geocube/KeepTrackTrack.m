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

/*
- (instancetype)init
{
    self = [super init];

    menuItems = nil;

    return self;
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
    labelName.text = selectedTrack.name;
    [self.view addSubview:labelName];

    labelDate = [[GCLabel alloc] initWithFrame:rectDate];
    labelDate.textAlignment = NSTextAlignmentCenter;
    if (selectedTrack.dateStart != 0) {
        if (selectedTrack.dateStop == 0)
            labelDate.text = [NSString stringWithFormat:@"%@ - now", [MyTools datetimePartDate:[MyTools dateString:selectedTrack.dateStart]]];
        else
            labelDate.text = [NSString stringWithFormat:@"%@ - %@", [MyTools datetimePartDate:[MyTools dateString:selectedTrack.dateStart]], [MyTools dateString:selectedTrack.dateStop]];
    }
    [self.view addSubview:labelDate];


    ivTrackImage = [[UIImageView alloc] initWithFrame:rectTrackImage];
    ivTrackImage.backgroundColor = [UIColor redColor];
    [self.view addSubview:ivTrackImage];

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
    ivTrackImage.frame = rectTrackImage;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    NSInteger height18 = bounds.size.height / 18;

    rectName = CGRectMake(0, 0, width, height18);
    rectDate = CGRectMake(0, height18, width, height18);
    rectTrackImage = CGRectMake(0, 2 * height18, width, height - 4 * height18);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (selectedTrack.dateStop == 0)
        labelDate.text = [NSString stringWithFormat:@"%@ - now", [MyTools datetimePartDate:[MyTools dateString:selectedTrack.dateStart]]];
    else
        labelDate.text = [NSString stringWithFormat:@"%@ - %@", [MyTools datetimePartDate:[MyTools dateString:selectedTrack.dateStart]], [MyTools dateString:selectedTrack.dateStop]];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self startNewTrack];
            return;;
        case 1:
            [self renameTrack];
            return;
        case 2:
            [self selectTrack];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)startNewTrack
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Start a new track"
                               message:@""
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *name = tf.text;

                             NSLog(@"Creating new track '%@'", name);

                             dbTrack *t = [[dbTrack alloc] init];
                             t.name = name;
                             t.dateStart = time(NULL);
                             t.dateStop = 0;
                             [t dbCreate];

                             [tracks addObject:t];
                             [myConfig currentTrackUpdate:t._id];
                             selectedTrack = t;
                             activeTrack = t;
                             activeTrack_id = t._id;

                             labelName.text = t.name;
                             labelDate.text = [MyTools dateString:t.dateStart];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of the new track";
        textField.text = [MyTools dateString:time(NULL)];
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)renameTrack
{

}

- (void)selectTrack
{
    __block NSInteger _idx = 0;
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:[tracks count]];
    [tracks enumerateObjectsUsingBlock:^(dbTrack *t, NSUInteger idx, BOOL * _Nonnull stop) {
        if (t._id == selectedTrack._id)
            _idx = idx;
        [as addObject:[NSString stringWithFormat:@"%@: %@", t.name, [MyTools dateString:t.dateStart]]];
    }];


    [ActionSheetStringPicker
     showPickerWithTitle:@"Select a track"
     rows:as
     initialSelection:_idx
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, dbTrack *selectedValue) {
         [tracks enumerateObjectsUsingBlock:^(dbTrack *t, NSUInteger idx, BOOL * _Nonnull stop) {
             if (selectedIndex == idx) {
                 selectedTrack = t;
                 *stop = YES;
             }
         }];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
     }
     origin:self.view
     ];

}
 */

@end
