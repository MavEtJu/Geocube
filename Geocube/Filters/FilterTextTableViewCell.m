/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface FilterTextTableViewCell ()
{
    UIButton *bWaypointName;
    UIButton *bOwner;
    UIButton *bPlacedBy;
    UIButton *bCountry;
    UIButton *bState;
    UIButton *bLocality;
    UIButton *bDescription;
    UIButton *bLogs;

    NSString *waypointName;
    NSString *owner;
    NSString *placedBy;
    NSString *country;
    NSString *state;
    NSString *locality;
    NSString *description;
    NSString *logs;
}

@end

@implementation FilterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;
    GCLabel *l;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = cellHeight = y;
        return self;
    }

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Waypoint name")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bWaypointName = [UIButton buttonWithType:UIButtonTypeSystem];
    bWaypointName.frame = rect;
    bWaypointName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bWaypointName setTitle:waypointName forState:UIControlStateNormal];
    [bWaypointName addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bWaypointName];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Owner")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bOwner = [UIButton buttonWithType:UIButtonTypeSystem];
    bOwner.frame = rect;
    bOwner.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bOwner setTitle:owner forState:UIControlStateNormal];
    [bOwner addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bOwner];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Locality")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bLocality = [UIButton buttonWithType:UIButtonTypeSystem];
    bLocality.frame = rect;
    bLocality.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bLocality setTitle:locality forState:UIControlStateNormal];
    [bLocality addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bLocality];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-State")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bState = [UIButton buttonWithType:UIButtonTypeSystem];
    bState.frame = rect;
    bState.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bState setTitle:state forState:UIControlStateNormal];
    [bState addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bState];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Country")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bCountry = [UIButton buttonWithType:UIButtonTypeSystem];
    bCountry.frame = rect;
    bCountry.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bCountry setTitle:country forState:UIControlStateNormal];
    [bCountry addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bCountry];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Description")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bDescription = [UIButton buttonWithType:UIButtonTypeSystem];
    bDescription.frame = rect;
    bDescription.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bDescription setTitle:description forState:UIControlStateNormal];
    [bDescription addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bDescription];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabelSmallText alloc] initWithFrame:rect];
    l.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Logs")];
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    bLogs = [UIButton buttonWithType:UIButtonTypeSystem];
    bLogs.frame = rect;
    bLogs.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bLogs setTitle:logs forState:UIControlStateNormal];
    [bLogs addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:bLogs];
    y += 20;

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    waypointName = [self configGet:@"waypointname"];
    owner = [self configGet:@"owner"];
    placedBy = [self configGet:@"placedby"];
    locality = [self configGet:@"locale"];
    state = [self configGet:@"state"];
    country = [self configGet:@"country"];
    description = [self configGet:@"description"];
    logs = [self configGet:@"logs"];
}

- (void)configUpdate
{
    [self configSet:@"waypointname" value:waypointName];
    [self configSet:@"owner" value:owner];
    [self configSet:@"placedby" value:placedBy];
    [self configSet:@"locale" value:locality];
    [self configSet:@"state" value:state];
    [self configSet:@"country" value:country];
    [self configSet:@"description" value:description];
    [self configSet:@"logs" value:logs];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

+ (NSString *)configPrefix
{
    return @"text";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"waypointname", @"owner", @"placedby", @"locale", @"state", @"country", @"description", @"logs", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"waypointname": @"",
             @"owner": @"",
             @"placedby": @"",
             @"locale": @"",
             @"state": @"",
             @"country": @"",
             @"description": @"",
             @"logs": @"",
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)finishText:(UIButton *)b
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"filterflagstableviewcell-Change field")
                                message:_(@"filterflagstableviewcell-New field")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *newstring = tf.text;

                             [b setTitle:newstring forState:UIControlStateNormal];
                             if (b == bWaypointName) waypointName = newstring;
                             if (b == bOwner) owner = newstring;
                             if (b == bPlacedBy) placedBy = newstring;
                             if (b == bLocality) locality = newstring;
                             if (b == bState) state = newstring;
                             if (b == bCountry) country = newstring;
                             if (b == bDescription) description = newstring;
                             if (b == bLogs) logs = newstring;
                             [self configUpdate];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"filterflagstableviewcell-Change field2");
    }];

    UIViewController *activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [ALERT_VC_RVC(activeVC) presentViewController:alert animated:YES completion:nil];
}

@end
