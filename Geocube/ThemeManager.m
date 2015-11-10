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

@interface ThemeManager ()
{
    NSArray *themeNames;
    NSInteger themeNr;
}

@end

// Current Theme
ThemeTemplate *currentTheme;
ThemeManager *themeManager;

@implementation ThemeManager

@synthesize themeNames;

- (instancetype)init
{
    self = [super init];

    themeNames = @[
                   @"Default day theme",
                   @"Default night theme",
                   @"Geosphere"
                  ];

    return self;
}

- (NSInteger)currentTheme
{
    return themeNr;
}

- (void)setTheme:(NSInteger)nr
{
    themeNr = nr;
    switch (nr) {
        case 0:
            currentTheme = [[ThemeNormal alloc] init];
            break;
        case 1:
            currentTheme = [[ThemeNight alloc] init];
            break;
        case 2:
            currentTheme = [[ThemeGeosphere alloc] init];
            break;
        default:
            currentTheme = [[ThemeNormal alloc] init];
            break;
    }

    [_AppDelegate.tabBars enumerateObjectsUsingBlock:^(BHTabsViewController *btc, NSUInteger tidx, BOOL *stop) {
        [btc.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nvc, NSUInteger nvidx, BOOL *stop) {
            [nvc.viewControllers enumerateObjectsUsingBlock:^(GCViewController *vc, NSUInteger vcidx, BOOL *stop) {
                NSLog(@"%ld %ld %ld", (unsigned long)tidx, (unsigned long)nvidx, (unsigned long)vcidx);
                [vc changeTheme];
            }];
        }];
    }];
}

- (void)changeTheme_:(UIView *)v
{
    //NSLog(@"%@", [v class]);
    if ([v isKindOfClass:[GCTableViewController class]] == YES) {
        GCTableViewController *v_ = (GCTableViewController *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCLabel class]] == YES) {
        GCLabel *v_ = (GCLabel *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCSmallLabel class]] == YES) {
        GCSmallLabel *v_ = (GCSmallLabel *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCScrollView class]] == YES) {
        GCScrollView *v_ = (GCScrollView *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCTextblock class]] == YES) {
        GCTextblock *v_ = (GCTextblock *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCTableViewCell class]] == YES) {
        GCTableViewCell *v_ = (GCTableViewCell *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCView class]] == YES) {
        GCView *v_ = (GCView *)v;
        [v_ changeTheme];
        return;
    }

    NSLog(@"%@ - not changedTheme: %@", [self class], [v class]);
}

- (void)changeThemeViewController:(UIViewController *)v
{
    [self changeTheme_:v.view];
}

- (void)changeThemeView:(UIView *)v
{
    [self changeTheme_:v];
}

- (void)changeThemeArray:(NSArray *)vs
{
    [vs enumerateObjectsUsingBlock:^(UIView *v, NSUInteger idx, BOOL *stop) {
        [self changeTheme_:v];
    }];
}

@end
