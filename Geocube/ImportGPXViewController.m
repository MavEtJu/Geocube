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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation ImportGPXViewController

- (id)init:(NSString *)_filename group:(dbCacheGroup *)_group
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

    newCachesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:newCachesLabel];
    y += 40;

    totalCachesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:totalCachesLabel];
    y += 40;

    newLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:newLogsLabel];
    y += 40;

    totalLogsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, 40)];
    [self.view addSubview:totalLogsLabel];
    y += 40;

    imp = [[Import_GPX alloc] init:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] group:group newCachesCount:&newCachesCount totalCachesCount:&totalCachesCount newLogsCount:&newLogsCount totalLogsCount:&totalLogsCount percentageRead:&percentageRead];

    importDone = NO;
    [self performSelectorInBackground:@selector(run) withObject:nil];
    [self performSelectorInBackground:@selector(refresh) withObject:nil];
}

- (void)run
{
    [imp parse];
    percentageRead = 100;
    [NSThread sleepForTimeInterval:0.02];
    importDone = YES;
}

- (void)refresh
{
    while (importDone == NO) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            progressLabel.text = [NSString stringWithFormat:@"Done %ld%%", percentageRead];
            newCachesLabel.text = [NSString stringWithFormat:@"New caches imported: %ld", newCachesCount];
            totalCachesLabel.text = [NSString stringWithFormat:@"Total caches read: %ld", totalCachesCount];
            newLogsLabel.text = [NSString stringWithFormat:@"New logs imported: %ld", newLogsCount];
            totalLogsLabel.text = [NSString stringWithFormat:@"Total logs read: %ld", totalLogsCount];
        }];
        [NSThread sleepForTimeInterval:0.01];
    }
}

@end
