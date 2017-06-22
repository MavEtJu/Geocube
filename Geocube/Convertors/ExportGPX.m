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

@interface ExportGPX ()
{
    NSMutableArray<NSString *> *lines;
}

@end

@implementation ExportGPX

+ (void)export:(dbWaypoint *)wp
{
    ExportGPX *e = [[ExportGPX alloc] init];
    [e header];
    [e waypoint:wp];
    [e trailer];
    [e writeToFile:[NSString stringWithFormat:@"Export - %@.gpx", [MyTools dateTimeString_YYYYMMDD_hhmmss]]];
}

+ (void)exports:(NSArray<dbWaypoint *>*)wps
{
    ExportGPX *e = [[ExportGPX alloc] init];
    [e header];
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [e waypoint:wp];
    }];
    [e trailer];
    [e writeToFile:[NSString stringWithFormat:@"Export - %@.gpx", [MyTools dateTimeString_YYYYMMDD_hhmmss]]];
}

- (instancetype)init
{
    self = [super init];

    lines = [NSMutableArray arrayWithCapacity:1000];

    return self;
}

#define LINE_S(__tag__, __value__) \
    [lines addObject:[NSString stringWithFormat:@"<%@>%@</%@>", __tag__, [MyTools HTMLEscape:__value__], __tag__]]
#define LINE_I(__tag__, __value__) \
    [lines addObject:[NSString stringWithFormat:@"<%@>%ld</%@>", __tag__, __value__, __tag__]]
#define LINE_F(__tag__, __fmt__, __value__) \
    [lines addObject:[NSString stringWithFormat:@"<%@>%.*f</%@>", __tag__, __fmt__, __value__, __tag__]]

- (void)header
{
    [lines addObject:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [lines addObject:@"<gpx xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.0\" creator=\"Geocube Exporter\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd\" xmlns=\"http://www.topografix.com/GPX/1/0\">"];
    [lines addObject:@"<name>Geocube Export</name>"];
    [lines addObject:@"<desc>Geocache file generated by Geocube</desc>"];
    [lines addObject:@"<author>Geocube</author>"];
    [lines addObject:@"<email>geocube@mavetju.org</email>"];
    LINE_S(@"time", [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss]);
    [lines addObject:@"<keywords>cache, geocache, geocube</keywords>"];
}

- (void)trailer
{
    [lines addObject:@"</gpx>"];
}

- (void)waypoint:(dbWaypoint *)wp
{
/*
    <wpt lat="-34.220417" lon="150.9979">
        <time>2001-06-17T07:00:00Z</time>
        <name>GCCA6</name>
        <desc>Dark Side of the Moon by Team Chaos, Traditional Cache (3/4)</desc>
        <url>http://www.geocaching.com/seek/cache_details.aspx?guid=7781922d-e4ba-4fa2-94ec-f4739c6275d2</url>
        <urlname>Dark Side of the Moon</urlname>
        <sym>Geocache Found</sym>
        <type>Geocache|Traditional Cache</type>
        <groundspeak:cache id="3238" available="True" archived="False" xmlns:groundspeak="http://www.groundspeak.com/cache/1/0/1">
            <groundspeak:name>Dark Side of the Moon</groundspeak:name>
            <groundspeak:placed_by>Team Chaos</groundspeak:placed_by>
            <groundspeak:owner id="12982">Team Chaos</groundspeak:owner>
            <groundspeak:type>Traditional Cache</groundspeak:type>
            <groundspeak:container>Regular</groundspeak:container>
            <groundspeak:attributes />
            <groundspeak:difficulty>3</groundspeak:difficulty>
            <groundspeak:terrain>4</groundspeak:terrain>
            <groundspeak:country>Australia</groundspeak:country>
            <groundspeak:state>New South Wales</groundspeak:state>
            <groundspeak:short_description html="True">2 ways to go - along or down...go down and you will get dirty! Take this a greater challenge... Maybe you'll need a permit?</groundspeak:short_description>
            <groundspeak:long_description html="True">Team Chaos will see you on the dark side of the moon... Aler t! Alert! There is extreme danger at the grid reference! Be careful! &lt;p&gt;If you decide to go down, you will need abseiling skills, caving gear(helmet, lights, gloves, etc) and a 90 metre rope. Take this seriously!&lt;/p&gt; Geocaching Australia Forum&lt;/a&gt;&lt;/p&gt;</groundspeak:long_description>
            <groundspeak:encoded_hints>You will not be driving it away.</groundspeak:encoded_hints>
            <groundspeak:logs>
                <groundspeak:log id="475820771">
                    <groundspeak:date>2015-02-08T20:00:00Z</groundspeak:date>
                    <groundspeak:type>Found it</groundspeak:type>
                    <groundspeak:finder id="8305738">Team MavEtJu</groundspeak:finder>
                    <groundspeak:text encoded="False">Today was the big day. Since security is in numbers, we had a team of nine people: Three kids, one oldie and then five medium age people. Thanks to Edward, Vic, Jez[sp], Chris, Casey, Gill, HanorahTLG and GeoDirk for tagging along!</groundspeak:text>
                </groundspeak:log>
            </groundspeak:logs>
            <groundspeak:travelbugs />
        </groundspeak:cache>
    </wpt>
*/
    NSMutableString *l = [NSMutableString string];

    [lines addObject:[NSString stringWithFormat:@"<wpt lat=\"%f\" lon=\"%f\">", wp.wpt_lat, wp.wpt_lon]];
    LINE_S(@"time", [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:wp.wpt_date_placed_epoch]);
    LINE_S(@"name", wp.wpt_name);
    LINE_S(@"desc", wp.wpt_description);
    if (wp.wpt_url == nil || [wp.wpt_url isEqualToString:@""] == YES)
        [lines addObject:@"<url />"];
    else
        LINE_S(@"url", wp.wpt_url);
    LINE_S(@"urlname", wp.wpt_urlname);
    LINE_S(@"sym", wp.wpt_symbol.symbol);
    LINE_S(@"type", wp.wpt_type.type_full);

    if (wp.gs_rating_difficulty != 0 && wp.gs_rating_terrain != 0) {
        [lines addObject:[NSString stringWithFormat:@"<groundspeak:cache id=\"%@\" archived=\"%@\" available=\"%@\" xmlns:groundspeak=\"http://www.groundspeak.com/cache/1/0/1\">", [NSNumber numberWithLongLong:wp._id], wp.gs_archived == YES ? @"true" : @"false", wp.gs_available == YES ? @"true" : @"false"]];
        LINE_S(@"groundspeak:name", wp.wpt_urlname);
        LINE_S(@"groundspeak:placed_by", wp.gs_placed_by);
        LINE_S(@"groundspeak:owner", wp.gs_owner.name);
        LINE_S(@"groundspeak:type", wp.wpt_type.type_minor);

        NSArray<dbAttribute *> *as = [dbAttribute dbAllByWaypoint:wp._id];
        if ([as count] == 0) {
            [lines addObject:@"<groundspeak:attributes />"];
        } else {
            [lines addObject:@"<groundspeak:attributes>"];
            [as enumerateObjectsUsingBlock:^(dbAttribute *a, NSUInteger idx, BOOL *stop) {
                NSString *l = [NSString stringWithFormat:@"<groundspeak:attribute id=\"%ld\" inc=\"%d\">%@</groundspeak:attribute>", (long)a.gc_id, a._YesNo == YES ? 1 : 0, a.label];
                [lines addObject:l];
            }];
            [lines addObject:@"</groundspeak:attributes>"];
        }

        LINE_F(@"groundspeak:difficulty", 1, wp.gs_rating_difficulty);
        LINE_F(@"groundspeak:terrain", 1, wp.gs_rating_terrain);
        LINE_S(@"groundspeak:country", wp.gs_country.name);
        LINE_S(@"groundspeak:state", wp.gs_state.name);

        [l appendString:@"<groundspeak:short_description html=\""];
        [l appendString:(wp.gs_short_desc_html == YES ? @"true" : @"false")];
        [l appendString:@"\">"];
        [l appendString:[MyTools HTMLEscape:wp.gs_short_desc]];
        [l appendString:@"</groundspeak:short_description>"];
        [lines addObject:l];

        [l appendString:@"<groundspeak:long_description html=\""];
        [l appendString:(wp.gs_long_desc_html == YES ? @"true" : @"false")];
        [l appendString:@"\">"];
        [l appendString:[MyTools HTMLEscape:wp.gs_long_desc]];
        [l appendString:@"</groundspeak:long_description>"];
        [lines addObject:l];

        LINE_S(@"groundspeak:encoded_hints", wp.gs_hint);

        NSArray<dbLog *> *logs = [dbLog dbAllByWaypoint:wp._id];
        if ([logs count] == 0) {
            [lines addObject:@"<groundspeak:logs />"];
        } else {
            [lines addObject:@"<groundspeak:logs>"];
            [logs enumerateObjectsUsingBlock:^(dbLog *log, NSUInteger idx, BOOL * _Nonnull stop) {
                [lines addObject:[NSString stringWithFormat:@"<groundspeak:log id=\"%ld\">", (long)log._id]];
                LINE_S(@"groundspeak:date", [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:log.datetime_epoch]);
                LINE_S(@"groundspeak:type", log.logstring.type);
                LINE_S(@"groundspeak:finder", log.logger.name);
                LINE_S(@"groundspeak:text", [MyTools HTMLEscape:log.log]);
                [lines addObject:@"</groundspeak:log>"];
            }];
            [lines addObject:@"</groundspeak:logs>"];
        }

        [lines addObject:@"<groundspeak:travelbugs />"];
        [lines addObject:@"</groundspeak:cache>"];
    }
    [lines addObject:@"</wpt>"];
}

- (void)writeToFile:(NSString *)filename
{
    NSString *fn = [NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename];
    NSLog(@"Exporting to %@", fn);

    NSMutableString *line = [NSMutableString string];
    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL * _Nonnull stop) {
        [line appendString:l];
        [line appendString:@"\n"];
    }];

    [line writeToFile:fn atomically:NO encoding:NSUTF8StringEncoding error:nil];

    line = nil;
    lines = nil;
}

@end
