//
//  LogTableViewCell.h
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface LogTableViewCell : UITableViewCell {
    UIImageView *logtype;
    UILabel *datetime;
    UILabel *logger;
    UILabel *log;
}

@property (nonatomic, retain) UIImageView *logtype;
@property (nonatomic, retain) UILabel *datetime;
@property (nonatomic, retain) UILabel *logger;
@property (nonatomic, retain) UILabel *log;

@end
