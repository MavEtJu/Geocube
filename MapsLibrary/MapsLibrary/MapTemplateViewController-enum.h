//
//  MapTemplateViewController-enum.h
//  MapsLibrary
//
//  Created by Edwin Groothuis on 18/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//
typedef NS_ENUM(NSInteger, MVMenuItem) {
    MVCmenuBrandChange,
    MVCmenuMapType,
    MVCmenuLoadWaypoints,
    MVCmenuDirections,
    MVCmenuAutoZoom,
    MVCmenuRecenter,
    MVCmenuUseGNSS,
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
