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

@interface WaypointTableViewCell ()

@property (weak, nonatomic) IBOutlet GCLabel *labelDescription;
@property (weak, nonatomic) IBOutlet GCLabel *labelCode;
@property (weak, nonatomic) IBOutlet GCLabel *labelWhoWhen;
@property (weak, nonatomic) IBOutlet GCLabel *labelBearing;
@property (weak, nonatomic) IBOutlet GCLabel *labelDistance;
@property (weak, nonatomic) IBOutlet GCLabel *labelDirection;
@property (weak, nonatomic) IBOutlet GCLabel *labelLocation;
@property (weak, nonatomic) IBOutlet GCLabel *labelTerrain;
@property (weak, nonatomic) IBOutlet GCLabel *labelDifficulty;
@property (weak, nonatomic) IBOutlet GCLabel *labelFavourites;
@property (weak, nonatomic) IBOutlet GCLabel *labelSize;
@property (weak, nonatomic) IBOutlet GCImageView *ivFavourites;
@property (weak, nonatomic) IBOutlet GCImageView *ivContainer;
@property (weak, nonatomic) IBOutlet GCImageView *ivSize;

@end

@implementation WaypointTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
    self.ivFavourites.image = [imageLibrary get:ImageCacheView_favourites];
}

- (void)changeTheme
{
    [self.labelDescription changeTheme];
    [self.labelCode changeTheme];
    [self.labelWhoWhen changeTheme];
    [self.labelBearing changeTheme];
    [self.labelDistance changeTheme];
    [self.labelDirection changeTheme];
    [self.labelLocation changeTheme];
    [self.labelTerrain changeTheme];
    [self.labelDifficulty changeTheme];
    // the labelFavourites does not follow the theme rules.
    // [self.labelFavourites changeTheme];

    [super changeTheme];
}

- (void)setWaypoint:(dbWaypoint *)wp
{
    self.labelDescription.text = wp.wpt_urlname;
    self.ivContainer.image = [imageLibrary getType:wp];

    if (wp.account == nil)
        self.labelCode.text = wp.wpt_name;
    else
        self.labelCode.text = [NSString stringWithFormat:@"%@ on %@", wp.wpt_name, wp.account.site];

    if (wp.gs_owner == nil) {
        if ([wp hasGSData] == NO)
            self.labelWhoWhen.text = [NSString stringWithFormat:@"Placed on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
        else
            self.labelWhoWhen.text = [NSString stringWithFormat:@"Yours on %@", [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];
    } else
        self.labelWhoWhen.text = [NSString stringWithFormat:@"by %@ on %@", wp.gs_owner.name, [MyTools dateTimeString_YYYY_MM_DD:wp.wpt_date_placed_epoch]];

    if (wp.flag_highlight == YES)
        self.labelDescription.backgroundColor = currentTheme.labelHighlightBackgroundColor;
    else
        self.labelDescription.backgroundColor = [UIColor clearColor];

    if (wp.gs_rating_terrain == 0)
        self.labelTerrain.text = @"";
    else
        self.labelTerrain.text = [NSString stringWithFormat:@"T: %0.1f", wp.gs_rating_terrain];
    if (wp.gs_rating_difficulty == 0)
        self.labelDifficulty.text = @"";
    else
        self.labelDifficulty.text = [NSString stringWithFormat:@"D: %0.1f", wp.gs_rating_difficulty];

    [self setRatings:wp.gs_favourites size:wp.gs_container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude)];
    self.labelBearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    self.labelDirection.text = [Coordinates bearing2compass:bearing];
    self.labelDistance.text = [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude)]];
    self.labelLocation.text = [wp makeLocaleStateCountry];

    self.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        self.labelSize.hidden = NO;
        self.ivSize.hidden = YES;
    } else {
        self.labelSize.hidden = YES;
        self.ivSize.hidden = NO;
    }
}

- (void)setRatings:(NSInteger)favs size:(NSInteger)sz
{
    if (favs != 0) {
        self.labelFavourites.text = [NSString stringWithFormat:@"%ld", (long)favs];
        self.ivFavourites.hidden = NO;
    } else {
        self.labelFavourites.text = nil;
        self.ivFavourites.hidden = YES;
    }

    if (sz != 0) {
        self.ivSize.image = [imageLibrary get:sz];
        self.ivSize.hidden = NO;
    } else {
        self.ivSize.hidden = YES;
    }
}

@end
