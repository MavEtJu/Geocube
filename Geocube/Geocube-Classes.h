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

#ifndef Geocube_Geocube_Classes_h
#define Geocube_Geocube_Classes_h

@class AppDelegate;
@class AudioFeedback;
@class BrowserAccountsViewController;
@class BrowserBrowserViewController;
@class BrowserUserViewController;
@class CompassViewController;
@class Coordinates;
@class DNFListViewController;
@class DatabaseCache;
@class ExportGPX;
@class FilesViewController;
@class FilterCategoryTableViewCell;
@class FilterDateTableViewCell;
@class FilterDifficultyTableViewCell;
@class FilterDirectionTableViewCell;
@class FilterDistanceTableViewCell;
@class FilterFavouritesTableViewCell;
@class FilterFlagsTableViewCell;
@class FilterGroupsTableViewCell;
@class FilterObject;
@class FilterOthersTableViewCell;
@class FilterSizesTableViewCell;
@class FilterTableViewCell;
@class FilterTerrainTableViewCell;
@class FilterTextTableViewCell;
@class FilterTypesTableViewCell;
@class FiltersViewController;
@class FoundListViewController;
@class GCCloseButton;
@class GCCoordsHistorical;
@class GCDictionaryGCA;
@class GCDictionaryLiveAPI;
@class GCDictionaryOKAPI;
@class GCDictionaryObject;
@class GCLabel;
@class GCMutableURLRequest;
@class GCOAuthBlackbox;
@class GCPointAnnotation;
@class GCScrollView;
@class GCSmallLabel;
@class GCStringFilename;
@class GCStringGPX;
@class GCStringObject;
@class GCTableViewCell;
@class GCTableViewCellKeyValue;
@class GCTableViewCellRightImage;
@class GCTableViewCellSubtitleRightImage;
@class GCTableViewCellTwoTextfields;
@class GCTableViewCellWithSubtitle;
@class GCTableViewController;
@class GCTextblock;
@class GCURLRequest;
@class GCView;
@class GCViewController;
@class GlobalMenu;
@class GroupsViewController;
@class HelpAboutViewController;
@class HelpDatabaseViewController;
@class HelpHelpViewController;
@class HelpImagesViewController;
@class HighlightListViewController;
@class IOSFileTransfers;
@class IgnoredListViewController;
@class ImageLibrary;
@class ImagesDownloadManager;
@class ImportGCAJSON;
@class ImportGPX;
@class ImportGeocube;
@class ImportLiveAPIJSON;
@class ImportOKAPIJSON;
@class ImportViewController;
@class Importer;
@class InProgressListViewController;
@class KeepTrackCar;
@class KeepTrackHeightScroller;
@class KeepTrackTrack;
@class KeepTrackTracks;
@class KeyboardCoordinateView;
@class ListViewController;
@class LocalMenuItems;
@class LocationManager;
@class LogTableViewCell;
@class MapApple;
@class MapAppleCache;
@class MapGoogle;
@class MapOSM;
@class MapTemplate;
@class MapViewController;
@class MapWaypointInfoView;
@class MyConfig;
@class MyTools;
@class NotesFieldnotesViewController;
@class NotesImagesViewController;
@class NotesPersonalNotesViewController;
@class NoticeTableViewCell;
@class NoticesViewController;
@class NullViewController;
@class PersonalNoteTableViewCell;
@class ProtocolTemplate;
@class QueriesGCAViewController;
@class QueriesGroundspeakViewController;
@class QueriesTemplateViewController;
@class RemoteAPI;
@class RemoteAPI_GCA;
@class RemoteAPI_LiveAPI;
@class RemoteAPI_OKAPI;
@class SettingsAccountsViewController;
@class SettingsColourViewController;
@class SettingsColoursViewController;
@class SettingsMainColorPickerViewController;
@class SettingsMainViewController;
@class ThemeGeosphere;
@class ThemeManager;
@class ThemeNight;
@class ThemeNormal;
@class ThemeTemplate;
@class TrackablesInventoryViewController;
@class TrackablesListViewController;
@class TrackablesMineViewController;
@class UserProfileViewController;
@class WaypointAddViewController;
@class WaypointAttributesViewController;
@class WaypointDescriptionViewController;
@class WaypointGroupsViewController;
@class WaypointHeaderTableViewCell;
@class WaypointHintViewController;
@class WaypointImageViewController;
@class WaypointImagesViewController;
@class WaypointLogImagesViewController;
@class WaypointLogTrackablesViewController;
@class WaypointLogViewController;
@class WaypointLogsViewController;
@class WaypointManager;
@class WaypointPersonalNoteViewController;
@class WaypointRawViewController;
@class WaypointTableViewCell;
@class WaypointTrackablesViewController;
@class WaypointViewController;
@class WaypointWaypointsViewController;
@class WaypointsOfflineListViewController;
@class database;
@class dbAccount;
@class dbAttribute;
@class dbBookmark;
@class dbConfig;
@class dbContainer;
@class dbCountry;
@class dbExternalMap;
@class dbExternalMapURL;
@class dbFileImport;
@class dbFilter;
@class dbGroup;
@class dbImage;
@class dbLog;
@class dbLogString;
@class dbName;
@class dbNotice;
@class dbObject;
@class dbPersonalNote;
@class dbPin;
@class dbQueryImport;
@class dbState;
@class dbSymbol;
@class dbTrack;
@class dbTrackElement;
@class dbTrackable;
@class dbType;
@class dbWaypoint;

#endif
