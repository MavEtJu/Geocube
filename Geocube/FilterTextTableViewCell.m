/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation FilterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;
    UILabel *l;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = height = y;
        return self;
    }

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Cache name:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvCacheName = [[UITextField alloc] initWithFrame:rect];
    tvCacheName.frame = rect;
    tvCacheName.backgroundColor = [UIColor lightGrayColor];
    tvCacheName.delegate = self;
    tvCacheName.text = cacheName;
    [tvCacheName addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvCacheName];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Owner:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvOwner = [[UITextField alloc] initWithFrame:rect];
    tvOwner.frame = rect;
    tvOwner.backgroundColor = [UIColor lightGrayColor];
    tvOwner.delegate = self;
    tvOwner.text = owner;
    [tvOwner addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvOwner];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"State:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvState = [[UITextField alloc] initWithFrame:rect];
    tvState.frame = rect;
    tvState.backgroundColor = [UIColor lightGrayColor];
    tvState.delegate = self;
    tvState.text = state;
    [tvState addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvState];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Country:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvCountry = [[UITextField alloc] initWithFrame:rect];
    tvCountry.frame = rect;
    tvCountry.backgroundColor = [UIColor lightGrayColor];
    tvCountry.delegate = self;
    tvCountry.text = country;
    [tvCountry addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvCountry];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Description:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvDescription = [[UITextField alloc] initWithFrame:rect];
    tvDescription.frame = rect;
    tvDescription.backgroundColor = [UIColor lightGrayColor];
    tvDescription.delegate = self;
    tvDescription.text = description;
    [tvDescription addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvDescription];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Logs:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    tvLogs = [[UITextField alloc] initWithFrame:rect];
    tvLogs.frame = rect;
    tvLogs.backgroundColor = [UIColor lightGrayColor];
    tvLogs.delegate = self;
    tvLogs.text = logs;
    [tvLogs addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventEditingDidEnd];
    [self.contentView addSubview:tvLogs];
    y += 20;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    configPrefix = @"text";

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    cacheName = [self configGet:@"cachename"];
    owner = [self configGet:@"owner"];
    placedBy = [self configGet:@"placedby"];
    state = [self configGet:@"state"];
    country = [self configGet:@"country"];
    description = [self configGet:@"description"];
    logs = [self configGet:@"logs"];
}

- (void)configUpdate
{
    [self configSet:@"cachename" value:tvCacheName.text];
    [self configSet:@"owner" value:tvOwner.text];
    [self configSet:@"placedby" value:tvPlacedBy.text];
    [self configSet:@"state" value:tvState.text];
    [self configSet:@"country" value:tvCountry.text];
    [self configSet:@"description" value:tvDescription.text];
    [self configSet:@"logs" value:tvLogs.text];
}

#pragma mark -- callback functions

- (void)finishText:(UITextField *)textField
{
    [self configUpdate];
}


@end
