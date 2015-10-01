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

@interface dbType : dbObject {
    NSString *type_major;
    NSString *type_minor;
    NSString *type_full;
    NSInteger icon;
    NSInteger pin;
    NSString *pin_rgb;
    NSString *pin_rgb_default;

    /* Not read from the database */
    BOOL selected;
}

@property (nonatomic, retain) NSString *type_minor;
@property (nonatomic, retain) NSString *type_major;
@property (nonatomic, retain) NSString *type_full;
@property (nonatomic) NSInteger icon;
@property (nonatomic) NSInteger pin;
@property (nonatomic) BOOL selected;
@property (nonatomic, retain) NSString *pin_rgb;
@property (nonatomic, retain) NSString *pin_rgb_default;

- (void)dbUpdatePin;

@end