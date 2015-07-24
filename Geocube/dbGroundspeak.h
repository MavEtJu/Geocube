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

#import "dbObject.h"

@interface dbGroundspeak : dbObject {
    NSId waypoint_id;

    float rating_difficulty, rating_terrain;
    NSInteger favourites;

    BOOL archived, available;

    NSString *country_str;
    NSId country_id;
    dbCountry *country;

    NSString *state_str;
    NSId state_id;
    dbState *state;

    BOOL short_desc_html, long_desc_html;
    NSString *short_desc, *long_desc;
    NSString *hint, *personal_note;

    NSString *placed_by;

    NSString *owner_gsid;
    NSString *owner_str;
    NSId owner_id;
    dbName *owner;

    NSId container_id;
    NSString *container_str;
    dbContainer *container;
}

@property (nonatomic) NSId waypoint_id;
@property (nonatomic) float rating_difficulty;
@property (nonatomic) float rating_terrain;
@property (nonatomic) NSInteger favourites;
@property (nonatomic) NSId country_id;
@property (nonatomic, retain) NSString *country_str;
@property (nonatomic, retain) dbCountry *country;
@property (nonatomic) NSId state_id;
@property (nonatomic, retain) NSString *state_str;
@property (nonatomic, retain) dbState *state;
@property (nonatomic) BOOL short_desc_html;
@property (nonatomic, retain) NSString *short_desc;
@property (nonatomic) BOOL long_desc_html;
@property (nonatomic, retain) NSString *long_desc;
@property (nonatomic, retain) NSString *hint;
@property (nonatomic, retain) NSString *personal_note;
@property (nonatomic) NSId container_id;
@property (nonatomic, retain) NSString *container_str;
@property (nonatomic, retain) dbContainer *container;
@property (nonatomic) BOOL archived;
@property (nonatomic) BOOL available;
@property (nonatomic, retain) NSString *placed_by;
@property (nonatomic, retain) NSString *owner_str;
@property (nonatomic, retain) NSString *owner_gsid;
@property (nonatomic) NSId owner_id;
@property (nonatomic, retain) dbName *owner;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) CLLocationCoordinate2D coordinates;

- (id)init:(NSId)_id;
- (NSInteger)hasFieldNotes;
- (NSInteger)hasLogs;
- (NSInteger)hasAttributes;
- (NSInteger)hasWaypoints;
- (NSInteger)hasInventory;
- (NSInteger)hasImages;

+ (void)dbCreate:(dbGroundspeak *)gs;
- (void)dbUpdate;
+ (NSArray *)dbAll;
+ (dbGroundspeak *)dbGet:(NSId)id;

@end
