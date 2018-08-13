/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface ThemeImageTemplate ()

@end

@implementation ThemeImageTemplate

- (instancetype)init
{
    self = [super init];

    [self loadImages];

    return self;
}

- NEEDS_OVERLOADING_VOID(loadImages)
- NEEDS_OVERLOADING_UIIMAGE(getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF)
- NEEDS_OVERLOADING_UIIMAGE(getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned)

- NEEDS_OVERLOADING_CGPOINT(centerOffsetAppleMaps:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_CGPOINT(groundAnchorGoogleMaps:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_CGPOINT(infoWindowAnchorGoogleMaps:(dbWaypoint *)wp)

- (void)loadImages:(NSString *)jsonfile
{
    NSData *jsondata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], jsonfile]];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsondata options:kNilOptions error:&error];

    NSArray<NSDictionary *> *logs = [dictionary objectForKey:@"logs"];
    [logs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *log = [dict objectForKey:@"log"];
        NSString *image = [dict objectForKey:@"image"];

#define LOG(__id__, __string__) \
    if ([__string__ isEqualToString:log] == YES) { \
        [imageManager addToLibrary:image index:ImageLog_ ## __id__]; \
        return; \
    }

        if (log != nil && image != nil) {
            LOG(Announcement, @"Announcement")
            LOG(Archived, @"Archived")
            LOG(Attended, @"Attended")
            LOG(Coordinates, @"Coordinates")
            LOG(DidNotFind, @"DidNotFind")
            LOG(Disabled, @"Disabled")
            LOG(Empty, @"Empty")
            LOG(Enabled, @"Enabled")
            LOG(Found, @"Found")
            LOG(Moved, @"Moved")
            LOG(NeedsArchiving, @"NeedsArchiving")
            LOG(NeedsMaintenance, @"NeedsMaintenance")
            LOG(Note, @"Note")
            LOG(OwnerMaintenance, @"OwnerMaintenance")
            LOG(Published, @"Published")
            LOG(ReviewerNote, @"ReviewerNote")
            LOG(Unarchived, @"Unarchived")
            LOG(Unknown, @"Unknown")
            LOG(WebcamPhoto, @"WebcamPhoto")
            LOG(WillAttend, @"WillAttend")

            NSAssert1(FALSE, @"Unknown log: %@", log);
        }
    }];

    NSArray<NSDictionary *> *types = [dictionary objectForKey:@"types"];
    [types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *type = [dict objectForKey:@"type"];
        NSString *image = [dict objectForKey:@"image"];

#define TYPE(__id__, __string__) \
    if ([__string__ isEqualToString:type] == YES) { \
        [imageManager addToLibrary:image index:ImageTypes_ ## __id__]; \
        return; \
    }

        if (type != nil && image != nil) {
            TYPE(AugmentedReality, @"AugmentedReality")
            TYPE(Beacon, @"Beacon")
            TYPE(Benchmark, @"Benchmark")
            TYPE(BurkeWills, @"BurkeWills")
            TYPE(CITO, @"CITO")
            TYPE(EarthCache, @"EarthCache")
            TYPE(Ephemeral, @"Ephemeral")
            TYPE(Event, @"Event")
            TYPE(Gadget, @"Gadget")
            TYPE(Geocacher, @"Geocacher")
            TYPE(Giga, @"Giga")
            TYPE(GroundspeakHQ, @"GroundspeakHQ")
            TYPE(History, @"History")
            TYPE(Letterbox, @"Letterbox")
            TYPE(Maze, @"Maze")
            TYPE(Mega, @"Mega")
            TYPE(Moveable, @"Moveable")
            TYPE(MultiCache, @"MultiCache")
            TYPE(Mystery, @"Mystery")
            TYPE(Night, @"Night")
            TYPE(Other, @"Other")
            TYPE(Podcast, @"Podcast")
            TYPE(Reverse, @"Reverse")
            TYPE(TraditionalCache, @"TraditionalCache")
            TYPE(Trigpoint, @"Trigpoint")
            TYPE(UnknownCache, @"UnknownCache")
            TYPE(VirtualCache, @"VirtualCache")
            TYPE(Waymark, @"Waymark")
            TYPE(WebcamCache, @"WebcamCache")
            TYPE(WhereigoCache, @"WhereigoCache")

            NSAssert1(FALSE, @"Unknown type: %@", type);
        }
    }];
}

- (UIImage *)getType:(dbWaypoint *)wp
{
    return [self getType:wp.wpt_type found:wp.logStatus disabled:(wp.gs_available == NO) archived:(wp.gs_archived == YES) highlight:wp.flag_highlight owner:[dbc accountIsOwner:wp] markedFound:wp.flag_markedfound inProgress:wp.flag_inprogress markedDNF:wp.flag_dnf planned:wp.flag_planned];
}

- (UIImage *)getPin:(dbWaypoint *)wp
{
    __block BOOL owner = NO;
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a._id == wp.account._id && a.accountname._id == wp.gs_owner._id) {
            *stop = YES;
            owner = YES;
        }
    }];

    return [self getPin:wp.wpt_type.pin found:wp.logStatus disabled:(wp.gs_available == NO) archived:(wp.gs_archived == YES) highlight:wp.flag_highlight owner:owner markedFound:wp.flag_markedfound inProgress:wp.flag_inprogress markedDNF:wp.flag_dnf];
}

- (UIImage *)addImageToImage:(UIImage *)img1 withImage2:(UIImage *)img2 andRect:(CGRect)cropRect
{
    CGSize size = img1.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    CGPoint pointImg1 = CGPointMake(0, 0);
    [img1 drawAtPoint:pointImg1];

    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint:pointImg2];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
