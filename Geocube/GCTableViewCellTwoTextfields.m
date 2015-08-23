//
//  GCTableViewCellTwoTextfields.m
//  Geocube
//
//  Created by Edwin Groothuis on 23/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation GCTableViewCellTwoTextfields

@synthesize fieldLabel, valueLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:nil];
    UIFont *font = cell.textLabel.font;
    CGRect frame = cell.frame;
    frame.origin.x += 10;
    frame.size.width -= 2 * 10;

    // Name
    fieldLabel = [[UILabel alloc] initWithFrame:frame];
    fieldLabel.font = font;
    [self.contentView addSubview:fieldLabel];

    valueLabel = [[UILabel alloc] initWithFrame:frame];
    valueLabel.font = font;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:valueLabel];

    return self;
}

@end
