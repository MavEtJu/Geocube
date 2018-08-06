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

void encryptionstuff(void);
KeyManager *keyManager;

int main(int argc, const char * argv[]) {
    encryptionstuff();

    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}

void encryptionstuff(void)
{
    keyManager = [[KeyManager alloc] init];

    NSString *key = @"2";
    NSArray<NSString *> *plains = @[
                                    @"Foo bar quux",
                                    // Your plain text goes here.
                                    ];

    [plains enumerateObjectsUsingBlock:^(NSString * _Nonnull plain, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", [keyManager decrypt:key data:[keyManager encrypt:key data:plain]]);
        NSLog(@"%@", [keyManager encrypt:key data:plain]);
    }];

    exit(0);
}
