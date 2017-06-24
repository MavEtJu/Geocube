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

@interface WaypointHeaderTableViewCell ()

@property (nonatomic, retain) IBOutlet UIImageView *ivContainer;
@property (nonatomic, retain) IBOutlet UIImageView *ivSize;
@property (nonatomic, retain) IBOutlet UIImageView *ivFavourites;
@property (nonatomic, retain) IBOutlet GCLabel *labelLatLon;
@property (nonatomic, retain) IBOutlet GCLabel *labelBearDis;
@property (nonatomic, retain) IBOutlet GCLabel *labelLocation;
@property (nonatomic, retain) IBOutlet GCLabel *labelRatingD;
@property (nonatomic, retain) IBOutlet GCLabel *labelRatingT;
@property (nonatomic, retain) IBOutlet GCLabel *labelFavourites;
@property (nonatomic, retain) IBOutlet GCLabel *labelSize;

@end

@implementation WaypointHeaderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
    self.ivFavourites.image = [imageLibrary get:ImageCacheView_favourites];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelLatLon changeTheme];
    [self.labelBearDis changeTheme];
    [self.labelLocation changeTheme];
    [self.labelRatingD changeTheme];
    [self.labelRatingT changeTheme];
    // the labelFavourites does not follow the theme rules.
    // [self.labelFavourites changeTheme];
    [self.labelSize changeTheme];
}

- (void)setWaypoint:(dbWaypoint *)wp
{
    Coordinates *c = [[Coordinates alloc] init:wp.wpt_latitude longitude:wp.wpt_longitude];
    self.labelLatLon.text = [NSString stringWithFormat:@"%@ %@", [c lat_degreesDecimalMinutes], [c lon_degreesDecimalMinutes]];
    if (wp.gs_rating_terrain == 0)
        self.labelRatingT.text = @"";
    else
        self.labelRatingT.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    if (wp.gs_rating_difficulty == 0)
        self.labelRatingD.text = @"";
    else
        self.labelRatingD.text = [NSString stringWithFormat:@"D: %0.1f", wp.gs_rating_difficulty];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude)];
    self.labelBearDis.text = [NSString stringWithFormat:@"%ldº (%@) at %@",
                              (long)[Coordinates coordinates2bearing:LM.coords to:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude)],
                              [Coordinates bearing2compass:bearing],
                              [MyTools niceDistance:[Coordinates coordinates2distance:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) to:LM.coords]]];
    self.labelLocation.text = [wp makeLocaleStateCountry];

    self.ivContainer.image = [imageLibrary getType:wp];

    if (wp.gs_favourites == 0) {
        self.ivFavourites.hidden = YES;
        self.labelFavourites.hidden = YES;
    } else {
        self.ivFavourites.hidden = NO;
        self.labelFavourites.hidden = NO;
        self.labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)wp.gs_favourites];
    }

    self.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        self.labelSize.hidden = NO;
        self.ivSize.hidden = YES;
    } else {
        self.labelSize.hidden = YES;
        self.ivSize.hidden = NO;
    }
    if (wp.gs_container.icon != 0) {
        self.ivSize.image = [imageLibrary get:wp.gs_container.icon];
        self.ivSize.hidden = NO;
    } else {
        self.ivSize.hidden = YES;
    }
}

@end
