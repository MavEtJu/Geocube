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

@protocol GlobalMenuDelegate

- (void)performLocalMenuAction:(NSInteger)idx;

@end

@interface GlobalMenu : NSObject <VKSideMenuDelegate, VKSideMenuDataSource>

@property (nonatomic, strong) VKSideMenu *menuLeft;
@property (nonatomic, strong) VKSideMenu *menuRight;

- (void)buttonMenuLeft:(id)sender;
- (void)buttonMenuRight:(id)sender;
- (void)defineLocalMenu:(LocalMenuItems *)lmi forVC:(id)vc;

@end

@interface LocalMenuItems : NSObject

- (instancetype)init:(NSInteger)max;
- (void)addItem:(NSInteger)idx label:(NSString *)label;
- (void)changeItem:(NSInteger)idx label:(NSString *)label;
- (NSMutableArray *)makeMenu;
- (void)enableItem:(NSInteger)idx;
- (void)disableItem:(NSInteger)idx;

@end