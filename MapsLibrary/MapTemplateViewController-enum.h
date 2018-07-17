/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

typedef NS_ENUM(NSInteger, MVMenuItem) {
    MVCmenuBrandChange,
    MVCmenuMapType,
    MVCmenuLoadWaypoints,
    MVCmenuOpenIn,
    MVCmenuDirections,
    MVCmenuAutoZoom,
    MVCmenuRecenter,
    MVCmenuRemoveTarget,
    MVCmenuShowBoundaries,
    MVCmenuExportVisible,
    MVCmenuRemoveHistory,
    MVCmenuMax,
};

typedef NS_ENUM(NSInteger, GCMapHowMany) {
    SHOW_ONEWAYPOINT = 1,
    SHOW_ALLWAYPOINTS,
    SHOW_LIVEMAPS,
};

typedef NS_ENUM(NSInteger, GCMapFollow) {
    SHOW_NEITHER = 0,
    SHOW_SEETARGET,
    SHOW_FOLLOWME,
    SHOW_FOLLOWMEZOOM,
    SHOW_SHOWBOTH,
};

typedef NS_ENUM(NSInteger, GCMapType) {
    MAPTYPE_NORMAL = 0,
    MAPTYPE_AERIAL,
    MAPTYPE_HYBRIDMAPAERIAL,
    MAPTYPE_TERRAIN,
};
