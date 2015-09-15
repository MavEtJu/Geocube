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

// Current Theme
ThemeTemplate *currentTheme;
ThemeManager *themeManager;

@implementation ThemeManager

@synthesize themeNames;

- (id)init
{
    self = [super init];

    themeNames = @[@"Default", @"Night", @"Geosphere"];

    return self;
}

- (void)setTheme:(NSInteger)nr
{
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
                NSLog(@"%ld %ld %ld", tidx, nvidx, vcidx);
                [vc changeTheme];
            }];
        }];
    }];
}

- (void)changeTheme_:(UIView *)v
{
    if ([v isKindOfClass:[GCTableViewController class]] == YES) {
        NSLog(@"%@", [v class]);
        GCTableViewController *v_ = (GCTableViewController *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCLabel class]] == YES) {
        NSLog(@"%@", [v class]);
        GCLabel *v_ = (GCLabel *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCSmallLabel class]] == YES) {
        NSLog(@"%@", [v class]);
        GCSmallLabel *v_ = (GCSmallLabel *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCScrollView class]] == YES) {
        NSLog(@"%@", [v class]);
        GCScrollView *v_ = (GCScrollView *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCTextblock class]] == YES) {
        NSLog(@"%@", [v class]);
        GCTextblock *v_ = (GCTextblock *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCTableViewCell class]] == YES) {
        NSLog(@"%@", [v class]);
        GCTableViewCell *v_ = (GCTableViewCell *)v;
        [v_ changeTheme];
        return;
    }

    if ([v isKindOfClass:[GCView class]] == YES) {
        NSLog(@"%@", [v class]);
        GCView *v_ = (GCView *)v;
        [v_ changeTheme];
        return;
    }

//    if ([v isKindOfClass:[UITableViewCellContentView class]] == YES) {
//    }

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
