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

@class AppDelegate;
@class AudioFeedback;
@class AudioManager;
@class BezelManager;
@class BrowserAccountsViewController;
@class BrowserBrowserViewController;
@class BrowserUserViewController;
@class CompassViewController;
@class ConfigManager;
@class Coordinates;
@class DatabaseCache;
@class DeveloperDatabaseViewController;
@class DeveloperImagesViewController;
@class DeveloperRemoteAPITableViewCell;
@class DeveloperRemoteAPIViewController;
@class DownloadManager;
@class ExportGPX;
@class FileBrowserViewController;
@class FileKMLViewController;
@class FileObject;
@class FileObjectView;
@class FilesTableViewCell;
@class FilesViewController;
@class FilterAccountsTableViewCell;
@class FilterButton;
@class FilterCategoryTableViewCell;
@class FilterDatesTableViewCell;
@class FilterDifficultyTableViewCell;
@class FilterDirectionTableViewCell;
@class FilterDistanceTableViewCell;
@class FilterFavouritesTableViewCell;
@class FilterFlagsTableViewCell;
@class FilterGroupsTableViewCell;
@class FilterHeaderTableViewCell;
@class FilterObject;
@class FilterOthersTableViewCell;
@class FilterSizesTableViewCell;
@class FilterTableViewCell;
@class FilterTerrainTableViewCell;
@class FilterTextTableViewCell;
@class FilterTypesTableViewCell;
@class FiltersViewController;
@class GCArray;
@class GCBoundingBox;
@class GCButton;
@class GCCloseButton;
@class GCCoordsHistorical;
@class GCData;
@class GCDataZIPFile;
@class GCDictionary;
@class GCDictionaryGCA2;
@class GCDictionaryGGCW;
@class GCDictionaryLiveAPI;
@class GCDictionaryOKAPI;
@class GCGMSCircle;
@class GCImageView;
@class GCLabel;
@class GCLabelNormalText;
@class GCLabelSmallText;
@class GCLocationCoordinate2D;
@class GCMGLPointAnnotation;
@class GCMGLPointAnnotationKML;
@class GCMGLPolygonCircleFill;
@class GCMGLPolygonKML;
@class GCMGLPolylineCircleEdge;
@class GCMGLPolylineKML;
@class GCMGLPolylineLineToMe;
@class GCMGLPolylineTrack;
@class GCMKCircle;
@class GCMutableArray;
@class GCMutableURLRequest;
@class GCOAuthBlackbox;
@class GCScrollView;
@class GCString;
@class GCStringFilename;
@class GCStringGPX;
@class GCStringGPXGarmin;
@class GCSwitch;
@class GCTableViewCell;
@class GCTableViewCellKeyValue;
@class GCTableViewCellRightImage;
@class GCTableViewCellRightImageDisclosure;
@class GCTableViewCellSubtitleRightImage;
@class GCTableViewCellSubtitleRightImageDisclosure;
@class GCTableViewCellSwitch;
@class GCTableViewCellWithSubtitle;
@class GCTableViewController;
@class GCTableViewHeaderFooterView;
@class GCTextblock;
@class GCURLRequest;
@class GCView;
@class GCViewController;
@class GCWaypointAnnotation;
@class GroupsSystemViewController;
@class GroupsTemplateViewController;
@class GroupsUserViewController;
@class HelpAboutTableViewCell;
@class HelpAboutViewController;
@class HelpHelpViewController;
@class HelpIntroduction;
@class IOSFileTransfers;
@class ImageManager;
@class ImagesDownloadManager;
@class ImportGCA2JSON;
@class ImportGGCWJSON;
@class ImportGPX;
@class ImportGPXGarmin;
@class ImportGeocube;
@class ImportLiveAPIJSON;
@class ImportManager;
@class ImportOKAPIJSON;
@class ImportTemplate;
@class InfoItem;
@class InfoViewer;
@class KeepTrackBeeper;
@class KeepTrackBeeperView;
@class KeepTrackCar;
@class KeepTrackTracks;
@class KeepTracksTrackTableViewCell;
@class KeyManager;
@class KeyboardCoordinateView;
@class ListDNFViewController;
@class ListFoundViewController;
@class ListHighlightViewController;
@class ListIgnoredViewController;
@class ListInProgressViewController;
@class ListTemplateViewController;
@class LocalMenuItems;
@class LocalizationManager;
@class LocationManager;
@class LocationlessListViewController;
@class LocationlessPlannedViewController;
@class LocationlessTableViewCell;
@class LocationlessTemplateViewController;
@class LogTableViewCell;
@class MapAllWPViewController;
@class MapApple;
@class MapAppleCache;
@class MapAppleTemplate;
@class MapBrand;
@class MapESRIWorldTopo;
@class MapGoogle;
@class MapLogsViewController;
@class MapMapBox;
@class MapOSM;
@class MapOneWPViewController;
@class MapTemplate;
@class MapTemplateViewController;
@class MapTrackViewController;
@class MapWaypointInfoView;
@class MyClock;
@class MyTools;
@class NotesFieldnotesViewController;
@class NotesImagesViewController;
@class NotesPersonalNotesViewController;
@class NotesSavedViewController;
@class NoticeTableViewCell;
@class NoticesViewController;
@class OpenCageManager;
@class PersonalNoteTableViewCell;
@class ProtocolGCA2;
@class ProtocolGGCW;
@class ProtocolLiveAPI;
@class ProtocolOKAPI;
@class ProtocolTemplate;
@class QueriesGCAPublicViewController;
@class QueriesGCAViewController;
@class QueriesGGCWViewController;
@class QueriesLiveAPIViewController;
@class QueriesTableViewCell;
@class QueriesTemplateViewController;
@class RemoteAPIGCA2;
@class RemoteAPIGGCW;
@class RemoteAPILiveAPI;
@class RemoteAPIOKAPI;
@class RemoteAPIProcessingGroup;
@class RemoteAPITemplate;
@class SettingsAccountsViewController;
@class SettingsColourViewController;
@class SettingsColoursViewController;
@class SettingsLogTemplatesViewController;
@class SettingsMainColorPickerViewController;
@class SettingsMainViewController;
@class SideMenu;
@class StatisticsTableViewCell;
@class StatisticsViewController;
@class ThemeIOSNormalSize;
@class ThemeIOSSmallSize;
@class ThemeManager;
@class ThemeNightNormalSize;
@class ThemeNightSmallSize;
@class ThemeTemplate;
@class ToolsGNSSViewController;
@class ToolsRot13ViewController;
@class TrackableTableViewCell;
@class TrackablesInventoryViewController;
@class TrackablesListViewController;
@class TrackablesMineViewController;
@class TrackablesTemplateViewController;
@class WaypointAddViewController;
@class WaypointAttributesViewController;
@class WaypointDescriptionViewController;
@class WaypointGroupsViewController;
@class WaypointHeaderHeaderView;
@class WaypointHeaderTableViewCell;
@class WaypointHintViewController;
@class WaypointImageViewController;
@class WaypointImagesViewController;
@class WaypointLogEditViewController;
@class WaypointLogImagesViewController;
@class WaypointLogTrackablesViewController;
@class WaypointLogViewController;
@class WaypointLogsTableViewCell;
@class WaypointLogsViewController;
@class WaypointManager;
@class WaypointPersonalNoteViewController;
@class WaypointRawViewController;
@class WaypointSorter;
@class WaypointTableViewCell;
@class WaypointTrackablesViewController;
@class WaypointViewController;
@class WaypointWaypointsTableViewCell;
@class WaypointWaypointsViewController;
@class WaypointsListViewController;
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
@class dbKMLFile;
@class dbListData;
@class dbLocality;
@class dbLog;
@class dbLogData;
@class dbLogMacro;
@class dbLogString;
@class dbLogStringWaypoint;
@class dbLogTemplate;
@class dbName;
@class dbNotice;
@class dbObject;
@class dbPersonalNote;
@class dbPin;
@class dbProtocol;
@class dbQueryImport;
@class dbState;
@class dbSymbol;
@class dbTrack;
@class dbTrackElement;
@class dbTrackable;
@class dbType;
@class dbWaypoint;
