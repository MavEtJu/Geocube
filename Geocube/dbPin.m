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

@interface dbPin ()

@end

@implementation dbPin

@synthesize _id, rgb, rgb_default, description, colour, img;

- (void)finish
{
    if (rgb == nil || [rgb isEqualToString:@""] == YES)
        rgb = rgb_default;
    colour = [ImageLibrary RGBtoColor:rgb];
    img = [ImageLibrary newPinHead:colour];

    [super finish];
}

- (void)dbUpdateRGB
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update pins set rgb = ? where id = ?");

        SET_VAR_TEXT(1, self.rgb);
        SET_VAR_INT (2, self._id);
        DB_CHECK_OKAY;
        DB_FINISH;
    }

    colour = [ImageLibrary RGBtoColor:self.rgb];
    img = [ImageLibrary newPinHead:colour];
}

+ (NSArray *)dbAll
{
    NSMutableArray *ps = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, description, rgb, rgb_default from pins");

        DB_WHILE_STEP {
            dbPin *p = [[dbPin alloc] init];
            INT_FETCH (0, p._id);
            TEXT_FETCH(1, p.description);
            TEXT_FETCH(2, p.rgb);
            TEXT_FETCH(3, p.rgb_default);
            [p finish];
            [ps addObject:p];
        }
        DB_FINISH;
    }
    return ps;
}

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into pins(id, description, rgb, rgb_default) values(?, ?, ?, ?)");

        SET_VAR_INT (1, _id);
        SET_VAR_TEXT(2, description);
        SET_VAR_TEXT(3, @"");
        SET_VAR_TEXT(4, rgb_default);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }

    _id = __id;
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update pins set description = ?, rgb_default = ? where id = ?");

        SET_VAR_TEXT(1, description);
        SET_VAR_TEXT(2, rgb_default);
        SET_VAR_INT (3, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbPin dbCount:@"pins"];
}

@end
