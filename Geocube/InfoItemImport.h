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

@interface InfoItemImport : InfoItem

- (void)setWaypointsTotal:(NSInteger)i;
- (void)setWaypointsNew:(NSInteger)i;
- (void)setLogsTotal:(NSInteger)i;
- (void)setLogsNew:(NSInteger)i;
- (void)setTrackablesNew:(NSInteger)i;
- (void)setTrackablesTotal:(NSInteger)i;

@end