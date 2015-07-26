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

@implementation ImportGPXViewController

- (id)init:(NSString *)_filename group:(dbGroup *)_group
{
    self = [super init];

    filename = _filename;
    group = _group;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    NSInteger width = applicationFrame.size.width;
    NSInteger y = 0;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [label setText:[NSString stringWithFormat:@"Import of %@", filename ]];
    [self.view addSubview:label];
    y += 40;

    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:progressLabel];
    y += 40;

    newWaypointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:newWaypointsLabel];
    y += 40;

    totalWaypointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:totalWaypointsLabel];
    y += 40;

    newTravelbugsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:newTravelbugsLabel];
    y += 40;

    totalTravelbugsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:totalTravelbugsLabel];
    y += 40;

    newLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:newLogsLabel];
    y += 40;

    totalLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:totalLogsLabel];
    y += 40;

    imp = [[Import_GPX alloc] init:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] group:group];
    imp.delegate = self;

    [self performSelectorInBackground:@selector(run) withObject:nil];
}

- (void)run
{
    [imp parse];
    progressLabel.text = @"Done 100%";
}

- (void)updateData:(NSInteger)percentageRead newWaypointsCount:(NSInteger)newWaypointsCount totalWaypointsCount:(NSInteger)totalWaypointsCount newLogsCount:(NSInteger)newLogsCount totalLogsCount:(NSInteger)totalLogsCount newTravelbugsCount:(NSInteger)newTravelbugsCount totalTravelbugsCount:(NSInteger)totalTravelbugsCount
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        progressLabel.text = [NSString stringWithFormat:@"Done %lu%%", (long)percentageRead];
        newWaypointsLabel.text = [NSString stringWithFormat:@"New caches imported: %ld", (long)newWaypointsCount];
        totalWaypointsLabel.text = [NSString stringWithFormat:@"Total caches read: %ld", (long)totalWaypointsCount];
        newLogsLabel.text = [NSString stringWithFormat:@"New logs imported: %ld", (long)newLogsCount];
        totalLogsLabel.text = [NSString stringWithFormat:@"Total logs read: %ld", (long)totalLogsCount];
        newTravelbugsLabel.text = [NSString stringWithFormat:@"New travelbugs imported: %ld", (long)newTravelbugsCount];
        totalTravelbugsLabel.text = [NSString stringWithFormat:@"Total travelbugs read: %ld", (long)totalTravelbugsCount];
    }];
}

@end
