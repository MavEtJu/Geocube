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

@interface LocalizationManager ()

@property(nonatomic, retain) NSMutableDictionary *txtable;

@end

@implementation LocalizationManager

- (instancetype)init
{
    self = [super init];

    self.txtable = [NSMutableDictionary dictionaryWithCapacity:200];

    NSString *sbdir = [MyTools SettingsBundleDirectory];

    // Find the first known localisation
    __block NSString *lang = nil;
    __block NSString *langdir = nil;
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(NSString * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        langdir = [NSString stringWithFormat:@"%@/%@.lproj", sbdir, languageCode];
        if ([fileManager fileExistsAtPath:langdir] == YES) {
            lang = languageCode;
            *stop = YES;
        }
    }];
    if (lang == nil)
        lang = @"en";

    /* Default translations */
    NSEnumerator *e = [fileManager enumeratorAtPath:langdir];
    NSString *s;
    while ((s = [e nextObject]) != nil) {
        if ([s rangeOfString:@"Localizable-.*.strings" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSInteger c = [self addToDictionary:langdir file:s];
            NSLog(@"Found %@, %ld records", s, (long)c);
        }
    }

    /* User supplied translations */
    e = [fileManager enumeratorAtPath:[MyTools FilesDir]];
    while ((s = [e nextObject]) != nil) {
        if ([s isEqualToString:@"Personalize.strings"] == YES) {
            NSInteger c = [self addToDictionary:[MyTools FilesDir] file:s];
            NSLog(@"Found %@, %ld records", s, (long)c);
        }
    }

    return self;
}

- (NSInteger)addToDictionary:(NSString *)langdir file:(NSString *)file
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", langdir, file] usedEncoding:nil error:&error];
    if (error != nil)
        NSLog(@"%@", error);
    NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
    __block NSInteger c = 0;
    [lines enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([line rangeOfString:@"\"[^\"]+\" = \"[^\"]+\";" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSArray<NSString *> *cs = [line componentsSeparatedByString:@"\" = \""];
            NSString *key = [cs objectAtIndex:0];
            NSString *value = [cs objectAtIndex:1];

            [self.txtable setObject:[value substringToIndex:[value length] - 2] forKey:[key substringFromIndex:1]];
            c++;
        }
    }];

    return c;
}

- (NSString *)localize:(NSString *)s
{
    NSString *t = [self.txtable objectForKey:s];
    if (t != nil)
        return t;
    return s;
}

+ (NSString *)localize:(NSString *)s
{
    return [localizationManager localize:s];
}

@end
