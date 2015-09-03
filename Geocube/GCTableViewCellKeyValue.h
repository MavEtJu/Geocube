//
//  GCTableViewCellKeyValue.h
//  Geocube
//
//  Created by Edwin Groothuis on 2/09/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface GCTableViewCellKeyValue : GCTableViewCell {
    UILabel *keyLabel;
    UILabel *valueLabel;
}

@property (nonatomic, retain) UILabel *keyLabel;
@property (nonatomic, retain) UILabel *valueLabel;



@end
