//
//  ImportGPXViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
