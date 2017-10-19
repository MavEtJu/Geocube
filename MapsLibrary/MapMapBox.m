/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@import Mapbox;

@interface MapMapBox ()

@property (nonatomic, retain) MGLMapView *mapView;

@end

@implementation MapMapBox

EMPTY_METHOD(mapViewDidDisappear)
EMPTY_METHOD(mapViewWillDisappear)
EMPTY_METHOD(mapViewDidAppear)
EMPTY_METHOD(mapViewWillAppear)
EMPTY_METHOD(mapViewDidLoad)

- (BOOL)mapHasViewMap
{
    return YES;
}
- (BOOL)mapHasViewAerial
{
    return YES;
}
- (BOOL)mapHasViewHybridMapAerial
{
    return YES;
}
- (BOOL)mapHasViewTerrain
{
    return YES;
}

- (void)initMap
{
    self.mapView = [[MGLMapView alloc] initWithFrame:CGRectZero];
    self.mapvc.view = self.mapView;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
}

- (void)removeLineMeToWaypoint
{
}

- (void)removeHistory
{
}

- (void)showHistory
{
}

- (void)removeMarkers
{
}

- (void)placeMarkers
{
}

- (void)setMapType:(GCMapType)mapType
{

    NSURL *styleURL = nil;
    switch (mapType) {
        case MAPTYPE_NORMAL:
            styleURL = [MGLStyle streetsStyleURL];
            break;
        case MAPTYPE_TERRAIN:
            styleURL = [MGLStyle outdoorsStyleURL];
            break;
        case MAPTYPE_AERIAL:
            styleURL = [MGLStyle satelliteStyleURL];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            styleURL = [MGLStyle hybridStyleURL];
            break;
    }
    
    self.mapView.styleURL = styleURL;
}

- NEEDS_OVERLOADING_VOID(removeCamera)
- NEEDS_OVERLOADING_VOID(removeMap)
- NEEDS_OVERLOADING_VOID(moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel)
- NEEDS_OVERLOADING_VOID(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
- NEEDS_OVERLOADING_VOID(updateMyBearing:(CLLocationDirection)bearing)
- NEEDS_OVERLOADING_VOID(showBoundaries:(BOOL)yesno)
- NEEDS_OVERLOADING_VOID(addLineMeToWaypoint)
- NEEDS_OVERLOADING_VOID(addLineTapToMe:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(removeLineTapToMe)
- NEEDS_OVERLOADING_VOID(updateMyPosition:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(addHistory:(GCCoordsHistorical *)ch)
- NEEDS_OVERLOADING_VOID(showTrack:(dbTrack *)track)
- NEEDS_OVERLOADING_VOID(showTrack)
- NEEDS_OVERLOADING_CLLOCATIONCOORDINATE2D(currentCenter)
- NEEDS_OVERLOADING_DOUBLE(currentZoom)
- NEEDS_OVERLOADING_GCMAPTYPE(mapType)
- NEEDS_OVERLOADING_VOID(currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight)
- NEEDS_OVERLOADING_VOID(placeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(removeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(updateMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(loadKML:(NSString *)file)
- NEEDS_OVERLOADING_VOID(removeKMLs)

@end
