//
//  GCTableViewCellTwoTextfields.h
//  Geocube
//
//  Created by Edwin Groothuis on 23/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface GCTableViewCellTwoTextfields : GCTableViewCell {
    UILabel *fieldLabel;
    UILabel *valueLabel;
}

@property (nonatomic, retain) UILabel *fieldLabel;
@property (nonatomic, retain) UILabel *valueLabel;

@end
