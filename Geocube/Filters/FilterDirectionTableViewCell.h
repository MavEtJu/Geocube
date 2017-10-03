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

@interface FilterDirectionTableViewCell : FilterTableViewCell

#define XIB_FILTERDIRECTIONTABLEVIEWCELL @"FilterDirectionTableViewCell"

typedef NS_ENUM(NSInteger, FilterDirection) {
    FILTER_DIRECTIONS_NORTH = 0,
    FILTER_DIRECTIONS_NORTHEAST,
    FILTER_DIRECTIONS_EAST,
    FILTER_DIRECTIONS_SOUTHEAST,
    FILTER_DIRECTIONS_SOUTH,
    FILTER_DIRECTIONS_SOUTHWEST,
    FILTER_DIRECTIONS_WEST,
    FILTER_DIRECTIONS_NORTHWEST,
};

@end
