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

#import "ImportTemplate.h"

#import "ToolsLibrary/InfoItem.h"

@class InfoViewer;

@interface ImportGeocube : ImportTemplate

#define KEY_REVISION_ATTRIBUTES     @"attributes_revision"
#define KEY_REVISION_BOOKMARKS      @"bookmarks_revision"
#define KEY_REVISION_CONFIG         @"config_revision"
#define KEY_REVISION_CONTAINERS     @"containers_revision"
#define KEY_REVISION_COUNTRIES      @"countries_revision"
#define KEY_REVISION_EXTERNALMAPS   @"externalmaps_revision"
#define KEY_REVISION_KEYS           @"keys_revision"
#define KEY_REVISION_LOGSTRINGS     @"logstrings_revision"
#define KEY_REVISION_NOTICES        @"notices_revision"
#define KEY_REVISION_PINS           @"pins_revision"
#define KEY_REVISION_SITES          @"sites_revision"
#define KEY_REVISION_STATES         @"states_revision"
#define KEY_REVISION_TYPES          @"types_revision"

#define KEY_VERSION_ATTRIBUTES      1
#define KEY_VERSION_BOOKMARKS       1
#define KEY_VERSION_CONFIG          1
#define KEY_VERSION_CONTAINERS      1
#define KEY_VERSION_COUNTRIES       1
#define KEY_VERSION_EXTERNALMAPS    1
#define KEY_VERSION_KEYS            1
#define KEY_VERSION_LOGSTRINGS      3
#define KEY_VERSION_NOTICES         1
#define KEY_VERSION_PINS            1
#define KEY_VERSION_SITES           1
#define KEY_VERSION_STATES          1
#define KEY_VERSION_TYPES           1

@property (nonatomic, retain) InfoItem *iii;

+ (BOOL)parse:(NSData *)data infoViewer:(InfoViewer *)iv iiImport:(InfoItemID)iii;
+ (BOOL)parse:(NSData *)data;
+ (NSString *)blockSeparator;
+ (NSString *)type_LogTemplatesAndMacros;

@end
