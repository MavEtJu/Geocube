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

@interface KeepTrackTracks ()
{
    NSMutableArray<dbTrack *> *tracks;
}

@end

@implementation KeepTrackTracks

#define THISCELL @"KeepTracksTrackTableViewCell"

enum {
    menuAddATrack,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddATrack label:@"Start new track"];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_KEEPTRACKSTRACKTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tracks = [NSMutableArray arrayWithArray:[dbTrack dbAll]];
    if ([tracks count] == 0)
        [self newTrack:@"First track"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tracks = [NSMutableArray arrayWithArray:[dbTrack dbAll]];
    if ([tracks count] == 0)
        [self newTrack:@"New track"];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [tracks count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KeepTracksTrackTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbTrack *t = [tracks objectAtIndex:indexPath.row];

    cell.labelTrackName.text = t.name;
    cell.labelDateTimeStart.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:t.dateStart];

    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:t._id];
    __block CGFloat distance = 0;
    __block dbTrackElement *te_prev = nil;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement *te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te_prev != nil && te.restart == NO) {
            distance += [Coordinates coordinates2distance:te_prev.coords to:te.coords];
        }
        te_prev = te;
    }];
    cell.labelDistance.text = [NSString stringWithFormat:@"Distance: %@", [MyTools niceDistance:distance]];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbTrack *t = [tracks objectAtIndex:indexPath.row];

    [_AppDelegate switchController:RC_KEEPTRACK];
    [keepTrackTabController setSelectedIndex:VC_KEEPTRACK_MAP animated:YES];
    [keepTrackMapViewController showTrack:t];
    return;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbTrack *t = [tracks objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dbTrackElement dbDeleteByTrack:t._id];
        [t dbDelete];
        [tracks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuAddATrack:
            [self startNewTrack];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)startNewTrack
{
    UIAlertController *alert = [UIAlertController
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
                             [self newTrack:name];
                             [self.tableView reloadData];
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
        textField.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (dbTrack *)newTrack:(NSString *)name
{
    dbTrack *t = [[dbTrack alloc] init];
    t.name = name;
    t.dateStart = time(NULL);
    t.dateStop = 0;
    [t dbCreate];

    [tracks addObject:t];
    [configManager currentTrackUpdate:t._id];
    return t;
}

+ (void)trackAutoRotate
{
    NSString *newdate = [MyTools dateTimeString_YYYY_MM_DD];
    dbTrack *track = [dbTrack dbGet:configManager.currentTrack];
    NSString *olddate = [MyTools dateTimeString_YYYY_MM_DD:track.dateStart];

    if ([newdate isEqualToString:olddate] == NO) {
        dbTrack *t = [[dbTrack alloc] init];
        t.name = [NSString stringWithFormat:@"%@ (auto)", [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss]];
        t.dateStart = time(NULL);
        t.dateStop = 0;
        [t dbCreate];

        [configManager currentTrackUpdate:t._id];
    }
}

+ (void)trackAutoPurge
{
    NSArray<dbTrack *> *tracks = [dbTrack dbAll];
    time_t cutoff = time(NULL) - configManager.keeptrackPurgeAge * 86400;

    [tracks enumerateObjectsUsingBlock:^(dbTrack *track, NSUInteger idx, BOOL * _Nonnull stop) {
        if (track.dateStart < cutoff) {
            NSLog(@"trackAutoPurge: Purging %@", track.name);
            [dbTrackElement dbDeleteByTrack:track._id];
            [track dbDelete];
        }
    }];
}

@end
