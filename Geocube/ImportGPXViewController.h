//
//  ImportGPXViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface ImportGPXViewController : GCViewController {
    NSString *filename;
    dbCacheGroup *group;
    
    UILabel *newCachesLabel;
    UILabel *totalCachesLabel;
    UILabel *newLogsLabel;
    UILabel *totalLogsLabel;
    UILabel *progressLabel;
    
    NSInteger newCachesCount;
    NSInteger totalCachesCount;
    NSInteger newLogsCount;
    NSInteger totalLogsCount;
    
    NSUInteger percentageRead;
    
    Import_GPX *imp;
    BOOL importDone;
}

- (id)init:(NSString *)filename group:(dbCacheGroup *)group;

@end
