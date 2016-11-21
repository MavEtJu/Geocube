/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface ThemeManager ()
{
    GCThemeType themeNr;
}

@end

// Current Theme
ThemeTemplate *currentTheme;
ThemeManager *themeManager;

@implementation ThemeManager

- (instancetype)init
{
    self = [super init];

    self.themeNames = @[
                        @"Default iOS theme",
                        @"Geocube night theme",
                        ];

    return self;
}

- (GCThemeType)currentTheme
{
    return themeNr;
}

- (void)setTheme:(GCThemeType)nr
{
    themeNr = nr;
    switch (nr) {
        case THEME_IOS:
            currentTheme = [[ThemeIOS alloc] init];
            break;
        case THEME_NIGHT:
            currentTheme = [[ThemeNight alloc] init];
            break;
        default:
            currentTheme = [[ThemeIOS alloc] init];
            break;
    }

    [_AppDelegate.tabBars enumerateObjectsUsingBlock:^(MHTabBarController *tb, NSUInteger tidx, BOOL *stop) {
        [tb.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nvc, NSUInteger nvidx, BOOL *stop) {
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

    if ([v isKindOfClass:[GCSwitch class]] == YES) {
        GCSwitch *v_ = (GCSwitch *)v;
        [v_ changeTheme];
        return;
    }

    if ([[[v class] description] hasPrefix:@"_"] == NO)
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
