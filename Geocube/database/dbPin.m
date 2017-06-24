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

@interface dbPin ()

@end

@implementation dbPin

TABLENAME(@"pins")

- (void)finish
{
    if (self.rgb == nil || [self.rgb isEqualToString:@""] == YES)
        self.rgb = self.rgb_default;
    self.colour = [ImageLibrary RGBtoColor:self.rgb];
    self.img = [ImageLibrary newPinHead:self.colour];

    [super finish];
}

- (NSId)dbCreate
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"insert into pins(id, description, rgb, rgb_default) values(?, ?, ?, ?)");

        SET_VAR_INT (1, self._id);
        SET_VAR_TEXT(2, self.desc);
        SET_VAR_TEXT(3, @"");
        SET_VAR_TEXT(4, self.rgb_default);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"update pins set description = ?, rgb_default = ? where id = ?");

        SET_VAR_TEXT(1, self.desc);
        SET_VAR_TEXT(2, self.rgb_default);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbPin *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbPin *> *ps = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, description, rgb, rgb_default from pins "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbPin *p = [[dbPin alloc] init];
            INT_FETCH (0, p._id);
            TEXT_FETCH(1, p.desc);
            TEXT_FETCH(2, p.rgb);
            TEXT_FETCH(3, p.rgb_default);
            [p finish];
            [ps addObject:p];
        }
        DB_FINISH;
    }
    return ps;
}

+ (NSArray<dbPin *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

- (void)dbUpdateRGB
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"update pins set rgb = ? where id = ?");

        SET_VAR_TEXT(1, self.rgb);
        SET_VAR_INT (2, self._id);
        DB_CHECK_OKAY;
        DB_FINISH;
    }

    self.colour = [ImageLibrary RGBtoColor:self.rgb];
    self.img = [ImageLibrary newPinHead:self.colour];
}

@end
