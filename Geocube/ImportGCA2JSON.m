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

@interface ImportGCA2JSON ()

@end

@implementation ImportGCA2JSON

- (void)parseDictionary:(GCDictionaryGCA2 *)dict infoItemImport:(InfoItemImport *)iii
{
    infoItemImport = iii;
    if ([dict objectForKey:@"waypoints"] != nil) {
        [self parseBefore_waypoints];
        [self parseData_waypoints:[dict objectForKey:@"waypoints"]];
        [self parseAfter_waypoints];
    }
    if ([dict objectForKey:@"geocaches"] != nil) {
//        [self parseBefore_caches];
//        [self parseData_caches:dict];
//        [self parseAfter_caches];
    }
    if ([dict objectForKey:@"logs1"] != nil) {
//        [self parseBefore_logs];
//        [self parseData_logs:[dict objectForKey:@"logs1"]];
//        [self parseAfter_logs];
    }
    if ([dict objectForKey:@"logs"] != nil) {
//        [self parseBefore_logs];
//        [self parseData_logs:dict];
//        [self parseAfter_logs];
    }
}

@end
