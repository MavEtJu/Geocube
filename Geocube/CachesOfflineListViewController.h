//
//  CachesOfflineListViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 6/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geosphere-Prefix.pch"

@interface CachesOfflineListViewController : GCTableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating> {
    NSArray *wps;
    NSInteger wpCount;
}

@property (strong, nonatomic) UISearchController *searchController;

@end
