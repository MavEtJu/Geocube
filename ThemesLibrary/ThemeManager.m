/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic) GCThemeStyleType themeStyleNr;
@property (nonatomic) GCThemeImageType themeImageNr;

@end

// Current themes
ThemeStyleTemplate *currentStyleTheme;
ThemeImageTemplate *currentImageTheme;

ThemeManager *themeManager;

@implementation ThemeManager

- (instancetype)init
{
    self = [super init];

    self.themeStyleNames = @[
                             _(@"thememanager-Default iOS theme, small icons"),
                             _(@"thememanager-Geocube night theme, small icons"),
                             _(@"thememanager-Default iOS theme, normal icons"),
                             _(@"thememanager-Geocube night theme, normal icons"),
                             ];

    self.themeImageNames = @[
                             _(@"thememanager-Default Geocube icons"),
                             _(@"thememanager-Geocaching Australia icons"),
                             ];

    return self;
}

- (GCThemeImageType)currentThemeImage
{
    return self.themeImageNr;
}

- (void)setThemeImage:(GCThemeImageType)nr
{
    self.themeImageNr = nr;
    switch (nr) {
        case THEME_IMAGE_GEOCUBE:
            currentImageTheme = [[ThemeImageGeocube alloc] init];
            break;
        case THEME_IMAGE_GCA:
            currentImageTheme = [[ThemeImageGCA alloc] init];
            break;
        default:
            currentImageTheme = [[ThemeImageGeocube alloc] init];
            break;
    }
}

- (GCThemeStyleType)currentThemeStyle
{
    return self.themeStyleNr;
}

- (void)setThemeStyle:(GCThemeStyleType)nr
{
    self.themeStyleNr = nr;
    switch (nr) {
        case THEME_STYLE_IOS_SMALLSIZE:
            currentStyleTheme = [[ThemeStyleIOSSmallSize alloc] init];
            break;
        case THEME_STYLE_NIGHT_SMALLSIZE:
            currentStyleTheme = [[ThemeStyleNightSmallSize alloc] init];
            break;
        case THEME_STYLE_IOS_NORMALSIZE:
            currentStyleTheme = [[ThemeStyleIOSNormalSize alloc] init];
            break;
        case THEME_STYLE_NIGHT_NORMALSIZE:
            currentStyleTheme = [[ThemeStyleNightNormalSize alloc] init];
            break;
        default:
            currentStyleTheme = [[ThemeStyleIOSNormalSize alloc] init];
            break;
    }

    [_AppDelegate.tabBars enumerateObjectsUsingBlock:^(MHTabBarController * _Nonnull tb, NSUInteger tidx, BOOL * _Nonnull stop) {
        [tb changeThemeStyle];
        [tb.viewControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull nvc, NSUInteger nvidx, BOOL * _Nonnull stop) {
            [nvc.viewControllers enumerateObjectsUsingBlock:^(GCViewController * _Nonnull vc, NSUInteger vcidx, BOOL * _Nonnull stop) {
                NSLog(@"%ld %ld %ld", (unsigned long)tidx, (unsigned long)nvidx, (unsigned long)vcidx);
                [vc changeThemeStyle];
            }];
        }];
    }];
}

- (void)changeThemeStyle_:(UIView *)v
{
    //NSLog(@"%@", [v class]);
    if ([v respondsToSelector:@selector(changeThemeStyle)] == YES) {
        [v performSelector:@selector(changeThemeStyle)];
        return;
    }

    if ([[[v class] description] isEqualToString:@"UIButtonLabel"] == YES)
        return;
    if ([[[v class] description] isEqualToString:@"UISwitchModernVisualElement"] == YES)
        return;
    if ([[[v class] description] isEqualToString:@"UITableViewCellContentView"] == YES)
        return;

    if ([[[v class] description] hasPrefix:@"_"] == NO)
        NSLog(@"%@ - not changedTheme: %@", [self class], [v class]);
}

- (void)changeThemeStyleViewController:(UIViewController *)v
{
    [self changeThemeStyle_:v.view];
}

- (void)changeThemeStyleView:(UIView *)v
{
    [self changeThemeStyle_:v];
}

- (void)changeThemeStyleArray:(NSArray<UIView *> *)vs
{
    [vs enumerateObjectsUsingBlock:^(UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        [self changeThemeStyle_:v];
    }];
}

@end
