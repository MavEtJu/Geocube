/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSString *languageCode;
@property (nonatomic, retain) NSString *countryCode;

@end

@implementation LocalizationManager

- (instancetype)init
{
    self = [super init];

    self.txtable = [NSMutableDictionary dictionaryWithCapacity:200];

    NSString *sbdir = [MyTools SettingsBundleDirectory];

    // Find the first known localisation
    __block NSString *langdir = nil;
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(NSString * _Nonnull language, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
        self.languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        self.countryCode = [languageDic objectForKey:@"kCFLocaleCountryCodeKey"];
        langdir = [NSString stringWithFormat:@"%@/%@.lproj", sbdir, self.languageCode];
        if ([fileManager fileExistsAtPath:langdir] == YES)
            *stop = YES;
    }];
    if (self.languageCode == nil)
        self.languageCode = @"en";
    if (self.countryCode == nil)
        self.countryCode = @"GB";

    /* Load from {lang}.lproj, for example en.lprog */
    /* Load from {lang}_${cc}.lproj, for example en_US.lprog */

    /* Default translations for en */
    langdir = [NSString stringWithFormat:@"%@/%@.lproj", sbdir, self.languageCode];
    NSEnumerator *e = [fileManager enumeratorAtPath:langdir];
    NSString *s;
    while ((s = [e nextObject]) != nil) {
        if ([s rangeOfString:@"Localizable-.*.strings" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSInteger c = [self addToDictionary:langdir file:s];
            NSLog(@"Found %@/%@, %ld records", self.languageCode, s, (long)c);
        }
    }

    /* Default translations for en_US */
    langdir = [NSString stringWithFormat:@"%@/%@_%@.lproj", sbdir, self.languageCode, self.countryCode];
    e = [fileManager enumeratorAtPath:langdir];
    while ((s = [e nextObject]) != nil) {
        if ([s rangeOfString:@"Localizable-.*.strings" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSInteger c = [self addToDictionary:langdir file:s];
            NSLog(@"Found %@_%@/%@, %ld records", self.languageCode, self.countryCode, s, (long)c);
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
        line = [line stringByReplacingOccurrencesOfString:@"/\\*.*\\*/" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [line length])];
        if ([line isEqualToString:@""] == YES)
            return;
        if ([line rangeOfString:@"^\"[^\"]+\" = \"[^\"]+\";" options:NSRegularExpressionSearch].location != NSNotFound) {
            NSArray<NSString *> *cs = [line componentsSeparatedByString:@"\" = \""];
            NSString *key = [cs objectAtIndex:0];
            NSString *value = [cs objectAtIndex:1];

            [self.txtable setObject:[value substringToIndex:[value length] - 2] forKey:[key substringFromIndex:1]];
            c++;
        } else
            NSLog(@"%@", line);
    }];

    return c;
}

- (NSString *)localize:(NSString *)s
{
    NSString *t = [self.txtable objectForKey:s];
    if (t == nil)
        return s;
    return [t stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
}

+ (NSString *)localize:(NSString *)s
{
    return [localizationManager localize:s];
}

@end
