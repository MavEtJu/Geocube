//
//  GCTableViewCellPicker.h
//  Geocube
//
//  Created by Tim Learmont on 8/30/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#define XIB_GCTABLEVIEWCELLPICKER @"GCTableViewCellPicker"

@interface GCTableViewCellPicker : GCTableViewCell

@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end
