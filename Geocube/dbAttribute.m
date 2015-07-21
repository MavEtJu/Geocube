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

@implementation dbAttribute

@synthesize icon, label, gc_id, _YesNo;

- (id)init:(NSId)__id gc_id:(NSId)_gc_id label:(NSString *)_label icon:(NSInteger)_icon
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
    dbAttribute *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, label, gc_id, icon from attributes");

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, label);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            INT_FETCH_AND_ASSIGN(req, 3, icon);
            s = [[dbAttribute alloc] init:_id gc_id:gc_id label:label icon:icon];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

//

+ (void)dbUnlinkAllFromCache:(NSId)cache_id
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from attribute2cache where cache_id = ?");

        SET_VAR_INT(req, 1, cache_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
}

- (void)dbLinkToCache:(NSId)cache_id YesNo:(BOOL)YesNO
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into attribute2cache(attribute_id, cache_id, yes ) values(?, ?, ?)");

        SET_VAR_INT(req, 1, _id);
        SET_VAR_INT(req, 2, cache_id);
        SET_VAR_BOOL(req, 3, YesNO);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByCache:(NSId)cache_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from attribute2cache where cache_id = ?");

        SET_VAR_INT(req, 1, cache_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByCache:(NSId)cache_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbAttribute *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, label, icon, gc_id from attributes where id in (select attribute_id from attribute2cache where cache_id = ?)");

        SET_VAR_INT(req, 1, cache_id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, label);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            s = [[dbAttribute alloc] init:_id gc_id:gc_id label:label icon:icon];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

@end
