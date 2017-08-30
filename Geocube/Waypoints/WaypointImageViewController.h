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

@protocol WaypointImageViewControllerDelegate

- (void)WaypointImage_swipeToUp;
- (void)WaypointImage_swipeToDown;
- (void)WaypointImage_refreshTable;
- (void)WaypointImage_refreshWaypoint;

@end

@interface WaypointImageViewController : GCViewController

@property (nonatomic) id<WaypointImageViewControllerDelegate> delegate;

- (instancetype)init;
- (void)setImage:(dbImage *)img idx:(NSInteger)thisImage totalImages:(NSInteger)totalImages waypoint:(dbWaypoint *)wp;

@end
