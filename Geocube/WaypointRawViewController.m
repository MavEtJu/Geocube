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
#import "objc/runtime.h"

@interface WaypointRawViewController ()
{
    UIScrollView *contentView;

    dbWaypoint *waypoint;
}

@end

@implementation WaypointRawViewController

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super init];

    waypoint = wp;
    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = YES;
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    contentView.delegate = self;
    self.view = contentView;

    GCLabel *l;
    NSInteger y = 20;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = 4 * bounds.size.width;

    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([waypoint class], &numberOfProperties);

        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
            // const char *attributesCString = property_getAttributes(property);
            // NSString *attributesString = [[NSString alloc] initWithUTF8String:attributesCString];
            id value = [waypoint valueForKey:name];
            // NSLog(@"Property %@ attributes: %@ value: %@", name, attributesString, value);

            l = [[GCLabel alloc] initWithFrame:CGRectMake(1, y, width, 20)];
            l.text = [NSString stringWithFormat:@"%@: %@", name, value];
            [contentView addSubview:l];
            y += 20;
        }
        free(propertyArray);
    }

    [contentView setContentSize:CGSizeMake(width, y)];

    [self prepareCloseButton:contentView];
}

@end
