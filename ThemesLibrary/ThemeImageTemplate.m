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

@end
