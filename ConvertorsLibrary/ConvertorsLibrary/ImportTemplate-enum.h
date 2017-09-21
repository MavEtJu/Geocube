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

// Needs to be defined here instead of in ImportManager.
typedef NS_ENUM(NSInteger, ImportOptions) {
    IMPORTOPTION_NONE = 0,
    IMPORTOPTION_LOGSONLY = 1,
    IMPORTOPTION_NOPOST = 2,
    IMPORTOPTION_NOPRE = 4,
    IMPORTOPTION_NOPARSE = 8,
};
