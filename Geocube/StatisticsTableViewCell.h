//
//  StatisticsTableViewCell.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#define XIB_STATISTICSTABLEVIEWCELL @"StatisticsTableViewCell"

@interface StatisticsTableViewCell : GCTableViewCell

@property (weak, nonatomic) IBOutlet GCLabel *site;
@property (weak, nonatomic) IBOutlet GCLabel *status;
@property (weak, nonatomic) IBOutlet GCLabel *wpsFound;
@property (weak, nonatomic) IBOutlet GCLabel *wpsHidden;
@property (weak, nonatomic) IBOutlet GCLabel *wpsDNF;
@property (weak, nonatomic) IBOutlet GCLabel *recommendationsGiven;
@property (weak, nonatomic) IBOutlet GCLabel *recommendationsReceived;

@end
