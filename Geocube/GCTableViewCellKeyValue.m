//
//  GCTableViewCellKeyValue.m
//  Geocube
//
//  Created by Edwin Groothuis on 2/09/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation GCTableViewCellKeyValue

@synthesize keyLabel, valueLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:nil];
    CGRect frame = cell.frame;
    UIFont *font = cell.textLabel.font;

    frame.origin.x += 10;
    frame.size.width -= 2 * 10;

    CGRect rectKey = CGRectMake(frame.origin.x + 10, frame.origin.y, 10 * 10 - 5, frame.size.height);
    CGRect rectValue = CGRectMake(frame.origin.x + 100, frame.origin.y, frame.size.width - 10 * 10, frame.size.height);

    // Name
    keyLabel = [[UILabel alloc] initWithFrame:rectKey];
    keyLabel.font = font;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:keyLabel];

    valueLabel = [[UILabel alloc] initWithFrame:rectValue];
    valueLabel.font = font;
    [self.contentView addSubview:valueLabel];

    return self;
}

@end
