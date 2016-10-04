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

@class AppDelegate;
@class AudioFeedback;
@class BezelManager;
@class BrowserAccountsViewController;
@class BrowserBrowserViewController;
@class BrowserUserViewController;
@class CompassViewController;
@class ConfigManager;
@class Coordinates;
@class DatabaseCache;
@class DownloadManager;
@class DownloadsImportsViewController;
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
@class GCButton;
@class GCCloseButton;
@class GCCoordsHistorical;
@class GCDictionaryGCA;
@class GCDictionaryLiveAPI;
@class GCDictionaryOKAPI;
@class GCDictionaryObject;
@class GCImageView;
@class GCLabel;
@class GCMutableURLRequest;
@class GCOAuthBlackbox;
@class GCPointAnnotation;
@class GCScrollView;
@class GCSmallLabel;
@class GCStringFilename;
@class GCStringGPX;
@class GCStringObject;
@class GCSwitch;
@class GCTableViewCell;
@class GCTableViewCellFieldValue;
@class GCTableViewCellKeyValue;
@class GCTableViewCellRightImage;
@class GCTableViewCellSubtitleRightImage;
@class GCTableViewCellWithSubtitle;
@class GCTableViewController;
@class GCTextblock;
@class GCURLRequest;
@class GCView;
@class GCViewController;
@class GroupsViewController;
@class HelpAboutViewController;
@class HelpDatabaseViewController;
@class HelpHelpViewController;
@class HelpImagesViewController;
@class IOSFileTransfers;
@class ImageLibrary;
@class ImagesDownloadManager;
@class ImportGCAJSON;
@class ImportGPX;
@class ImportGeocube;
@class ImportLiveAPIJSON;
@class ImportManager;
@class ImportOKAPIJSON;
@class ImportTemplate;
@class InfoItem;
@class InfoItemDowload;
@class InfoItemImage;
@class InfoItemImport;
@class InfoViewer;
@class KeepTrackCar;
@class KeepTrackHeightScroller;
@class KeepTrackTrack;
@class KeepTrackTracks;
@class KeepTrackTracksCell;
@class KeyboardCoordinateView;
@class ListDNFViewController;
@class ListFoundViewController;
@class ListHighlightViewController;
@class ListIgnoredViewController;
@class ListInProgressViewController;
@class ListTemplateViewController;
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
@class MyClock;
@class MyTools;
@class NotesFieldnotesViewController;
@class NotesImagesViewController;
@class NotesPersonalNotesViewController;
@class NoticeTableViewCell;
@class NoticesViewController;
@class PersonalNoteTableViewCell;
@class QueriesGCAViewController;
@class QueriesGroundspeakViewController;
@class QueriesTemplateViewController;
@class RemoteAPI;
@class RemoteAPI_GCA;
@class RemoteAPI_LiveAPI;
@class RemoteAPI_OKAPI;
@class RemoteAPI_Template;
@class SettingsAccountsViewController;
@class SettingsColourViewController;
@class SettingsColoursViewController;
@class SettingsMainColorPickerViewController;
@class SettingsMainViewController;
@class SideMenu;
@class StatisticsViewController;
@class ThemeIOS;
@class ThemeManager;
@class ThemeNight;
@class ThemeTemplate;
@class TrackablesInventoryViewController;
@class TrackablesListViewController;
@class TrackablesMineViewController;
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
@class dbLocale;
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
