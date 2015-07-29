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

@implementation CacheFilter

@synthesize configPrefix;

+ (NSArray *)filter
{
    CacheFilter *filter = [[CacheFilter alloc] init];
    NSMutableArray *caches;

    /* Filter out by group:
     * The filter selects out the caches which belong to a certain group.
     * If a group is not defined then it will be considered not to be included.
     */

    [filter setConfigPrefix:@"groups"];
    caches = [NSMutableArray arrayWithCapacity:200];

    NSString *c = [filter configGet:@"enabled"];
    if (c != nil && [c boolValue] == YES) {
        NSMutableArray *groups = [NSMutableArray arrayWithCapacity:20];
        NSEnumerator *e = [[dbc Groups] objectEnumerator];
        dbGroup *group;
        while ((group = [e nextObject]) != nil) {
            c = [filter configGet:[NSString stringWithFormat:@"group_%ld", (long)group._id]];
            if (c == nil || [c boolValue] == 0)
                continue;
            [groups addObject:group];
        }
        [caches addObjectsFromArray:[dbWaypoint dbAllInGroups:groups]];
    } else {
        caches = [NSMutableArray arrayWithArray:[dbWaypoint dbAll]];
    }

    return caches;
}

- (NSString *)configGet:(NSString *)_name
{
    dbFilter *c = [dbFilter dbGetByKey:[NSString stringWithFormat:@"%@_%@", configPrefix, _name]];
    if (c == nil)
        return nil;
    return c.value;
}

- (void)configSet:(NSString *)_name value:(NSString *)_value
{
    [dbFilter dbUpdateOrInsert:[NSString stringWithFormat:@"%@_%@", configPrefix, _name] value:_value];
}

@end
