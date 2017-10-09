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
    NSString *waypointName;
    NSString *placedBy;
    NSString *country;
    NSString *state;
    NSString *locality;
    NSString *description;
    NSString *logs;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;

@property (nonatomic, weak) IBOutlet FilterButton *buttonWaypointName;
@property (nonatomic, weak) IBOutlet FilterButton *buttonPlacedBy;
@property (nonatomic, weak) IBOutlet FilterButton *buttonCountry;
@property (nonatomic, weak) IBOutlet FilterButton *buttonState;
@property (nonatomic, weak) IBOutlet FilterButton *buttonLocality;
@property (nonatomic, weak) IBOutlet FilterButton *buttonDescription;
@property (nonatomic, weak) IBOutlet FilterButton *buttonLogs;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelWaypointName;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelPlacedBy;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelCountry;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelState;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelLocality;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelDescription;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelLogs;

@end

@implementation FilterTextTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.labelWaypointName.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Waypoint name")];
    self.labelPlacedBy.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Placed by")];
    self.labelLocality.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Locality")];
    self.labelState.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-State")];
    self.labelCountry.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Country")];
    self.labelDescription.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Description")];
    self.labelLogs.text = [NSString stringWithFormat:@"%@: ", _(@"filtertexttableviewcell-Logs")];

    [self.buttonWaypointName addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonPlacedBy addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonLocality addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonState addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonCountry addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDescription addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
    [self.buttonLogs addTarget:self action:@selector(finishText:) forControlEvents:UIControlEventTouchDown];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelHeader changeTheme];
    [self.labelWaypointName changeTheme];
    [self.labelPlacedBy changeTheme];
    [self.labelLocality changeTheme];
    [self.labelState changeTheme];
    [self.labelCountry changeTheme];
    [self.labelDescription changeTheme];
    [self.labelLogs changeTheme];
}

- (void)viewRefresh
{
    [self.buttonWaypointName setTitle:waypointName forState:UIControlStateNormal];
    [self.buttonPlacedBy setTitle:placedBy forState:UIControlStateNormal];
    [self.buttonLocality setTitle:locality forState:UIControlStateNormal];
    [self.buttonState setTitle:state forState:UIControlStateNormal];
    [self.buttonCountry setTitle:country forState:UIControlStateNormal];
    [self.buttonDescription setTitle:description forState:UIControlStateNormal];
    [self.buttonLogs setTitle:logs forState:UIControlStateNormal];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), fo.name];

    waypointName = [self configGet:@"waypointname"];
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
    [self configSet:@"placedby" value:placedBy];
    [self configSet:@"locale" value:locality];
    [self configSet:@"state" value:state];
    [self configSet:@"country" value:country];
    [self configSet:@"description" value:description];
    [self configSet:@"logs" value:logs];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"text";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"waypointname", @"placedby", @"locale", @"state", @"country", @"description", @"logs", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"waypointname": @"",
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

- (void)finishText:(FilterButton *)b
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

                             if (b == self.buttonWaypointName) waypointName = newstring;
                             if (b == self.buttonPlacedBy) placedBy = newstring;
                             if (b == self.buttonLocality) locality = newstring;
                             if (b == self.buttonState) state = newstring;
                             if (b == self.buttonCountry) country = newstring;
                             if (b == self.buttonDescription) description = newstring;
                             if (b == self.buttonLogs) logs = newstring;
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
