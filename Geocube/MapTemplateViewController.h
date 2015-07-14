//
//  MapTemplateViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface MapTemplateViewController : GCViewController {
    NSArray *wps;
    NSInteger wpCount;
}

- (void)refreshCachesData:(NSString *)searchString;

@end
