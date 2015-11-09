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

#import "Geocube-Prefix.pch"

@interface dbAttribute ()
{
    NSInteger icon;
    NSId gc_id;
    NSString *label;

    // Internal stuff
    BOOL _YesNo;
}

@end

@implementation dbAttribute

@synthesize icon, label, gc_id, _YesNo;

- (instancetype)init:(NSId)__id gc_id:(NSId)_gc_id label:(NSString *)_label icon:(NSInteger)_icon
{
    self = [super init];

    icon = _icon;
    label = _label;
    gc_id = _gc_id;
    _id = __id;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, label, gc_id, icon from attributes");

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH( 2, a.gc_id);
            INT_FETCH( 3, a.icon);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSInteger)dbCount
{
    return [dbAttribute dbCount:@"attributes"];
}

//

+ (void)dbUnlinkAllFromWaypoint:(NSId)wp_id
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT( 1, wp_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(NSId)wp_id YesNo:(BOOL)YesNo
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values(?, ?, ?)");

        SET_VAR_INT( 1, _id);
        SET_VAR_INT( 2, wp_id);
        SET_VAR_BOOL(3, YesNo);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbAllLinkToWaypoint:(NSId)wp_id attributes:(NSArray *)attrs YesNo:(BOOL)YesNo
{
    if ([attrs count] == 0)
        return;

    __block NSMutableString *sql = [NSMutableString stringWithString:@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values "];
    [attrs enumerateObjectsUsingBlock:^(dbAttribute *attr, NSUInteger idx, BOOL *stop) {
        if (idx != 0)
            [sql appendString:@","];
        [sql appendFormat:@"(%ld, %ld, %d)", (long)attr._id, (long)wp_id, YesNo];
    }];
    @synchronized(db.dbaccess) {
        DB_PREPARE(sql);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT( 1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN( 0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, label, icon, gc_id from attributes where id in (select attribute_id from attribute2waypoints where waypoint_id = ?)");

        SET_VAR_INT( 1, wp_id);

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH( 2, a.icon);
            INT_FETCH( 3, a.gc_id);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

@end
