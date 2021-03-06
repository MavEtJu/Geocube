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

@interface KeepTrackTracks ()

@property (nonatomic, retain) NSMutableArray<dbTrack *> *tracks;

@end

@implementation KeepTrackTracks

enum {
    menuAddATrack,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuAddATrack label:_(@"keeptracktracks-Start new track")];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_KEEPTRACKSTRACKTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_KEEPTRACKSTRACKTABLEVIEWCELL];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tracks = [NSMutableArray arrayWithArray:[dbTrack dbAll]];
    if ([self.tracks count] == 0)
        [self newTrack:_(@"keeptracktracks-First track")];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tracks = [NSMutableArray arrayWithArray:[dbTrack dbAll]];
    if ([self.tracks count] == 0)
        [self newTrack:_(@"keeptracktracks-New track")];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (configManager.keeptrackEnable == NO)
        [MyTools messageBox:self header:_(@"keeptracktracks-Keep Track is not enabled") text:_(@"keeptracktracks-You can enable it in the settings menu")];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KeepTracksTrackTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_KEEPTRACKSTRACKTABLEVIEWCELL forIndexPath:indexPath];

    dbTrack *t = [self.tracks objectAtIndex:indexPath.row];

    cell.labelTrackName.text = t.name;
    cell.labelDateTimeStart.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:t.dateStart];

    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:t];
    __block CGFloat distance = 0;
    __block dbTrackElement *te_prev = nil;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull te, NSUInteger idx, BOOL * _Nonnull stop) {
        if (te_prev != nil && te.restart == NO) {
            distance += [Coordinates coordinates2distance:te_prev.lat fromLongitude:te_prev.lon toLatitude:te.lat toLongitude:te.lon];
        }
        te_prev = te;
    }];
    cell.labelDistance.text = [NSString stringWithFormat:@"%@: %@", _(@"keeptracktracks-Distance"), [MyTools niceDistance:distance]];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbTrack *t = [self.tracks objectAtIndex:indexPath.row];

    [_AppDelegate switchController:RC_KEEPTRACK];
    [keepTrackTabController setSelectedIndex:VC_KEEPTRACK_MAP animated:YES];
    [keepTrackMapViewController showTrack:t];
    return;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbTrack *t = [self.tracks objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dbTrackElement dbDeleteByTrack:t];
        [t dbDelete];
        [self.tracks removeObjectAtIndex:indexPath.row];
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
                                alertControllerWithTitle:_(@"keeptracktracks-Start a new track")
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
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
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"keeptracktracks-Name of the new track");
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

    [self.tracks addObject:t];
    [configManager currentTrackUpdate:t];
    return t;
}

+ (void)trackAutoRotate
{
    NSString *newdate = [MyTools dateTimeString_YYYY_MM_DD];
    dbTrack *track = configManager.currentTrack;
    NSString *olddate = [MyTools dateTimeString_YYYY_MM_DD:track.dateStart];

    if ([newdate isEqualToString:olddate] == NO) {
        dbTrack *t = [[dbTrack alloc] init];
        t.name = [NSString stringWithFormat:@"%@ (%@)", [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss], _(@"keeptracktracks-auto")];
        t.dateStart = time(NULL);
        t.dateStop = 0;
        [t dbCreate];

        [configManager currentTrackUpdate:t];
    }
}

+ (void)trackAutoPurge
{
    NSArray<dbTrack *> *tracks = [dbTrack dbAll];
    time_t cutoff = time(NULL) - configManager.keeptrackPurgeAge * 86400;

    [tracks enumerateObjectsUsingBlock:^(dbTrack * _Nonnull track, NSUInteger idx, BOOL * _Nonnull stop) {
        if (track.dateStart < cutoff) {
            NSLog(@"trackAutoPurge: Purging %@", track.name);
            [dbTrackElement dbDeleteByTrack:track];
            [track dbDelete];
        }
    }];
}

@end
