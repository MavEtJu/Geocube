/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface ImageManager : NSObject

- (instancetype)init;

- (UIImage *)get:(ImageNumber)imgnum;
- (NSString *)getCode:(dbWaypoint *)wp;
- (UIImage *)getPin:(dbWaypoint *)wp;
- (UIImage *)getType:(dbWaypoint *)wp;

- (UIImage *)getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF;
- (UIImage *)getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned;

- (void)reloadImages;
- (void)addToLibrary:(NSString *)name index:(NSInteger)index;

//- (UIImage *)getSquareWithNumber:(NSInteger)num;

- (NSString *)getName:(ImageNumber)imgnum;

+ (UIImage *)newPinHead:(UIColor *)color;

+ (void)RGBtoFloat:(NSString *)rgb r:(float *)r g:(float *)g b:(float *)b;
+ (UIColor *)RGBtoColor:(NSString *)rgb;
+ (NSString *)ColorToRGB:(UIColor *)c;
+ (UIImage *)circleWithColour:(UIColor *)c;

@end

extern ImageManager *imageManager;
