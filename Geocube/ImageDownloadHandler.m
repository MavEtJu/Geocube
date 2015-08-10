//
//  ImageDownloadHandler.m
//  Geocube
//
//  Created by Edwin Groothuis on 10/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation ImageDownloadHandler

+ (NSInteger)findImagesInDescription:(NSString *)desc
{
    NSInteger found = 0;
    NSString *next = desc;

    do {
        NSString *d = next;
        next = nil;

        // Search for '<img'
        NSRange r = [d rangeOfString:@"<img" options:NSCaseInsensitiveSearch];
        if (r.location == NSNotFound)
            continue;
        NSString *imgtag = [d substringFromIndex:r.location];
        // Search for '>'
        NSRange s = [imgtag rangeOfString:@">"];
        if (s.location == NSNotFound)
            continue;

        imgtag = [imgtag substringToIndex:s.location];
        //NSLog(@"%@", imgtag);

        // Save the string after the '>'
        next = [d substringFromIndex:s.location + r.location];

        // Search for the 'src=' or 'src = ' or 'src= ' or 'src ='
        r = [imgtag rangeOfString:@"src" options:NSCaseInsensitiveSearch];
        if (r.location == NSNotFound)
            continue;

        imgtag = [imgtag substringFromIndex:r.location + r.length];

        while ([[imgtag substringToIndex:1] compare:@" "] == NSOrderedSame) {
            imgtag = [imgtag substringFromIndex:1];
        }
        if ([[imgtag substringToIndex:1] compare:@"="] != NSOrderedSame) {
            NSLog(@"No =");
            continue;
        }
        imgtag = [imgtag substringFromIndex:1];
        while ([[imgtag substringToIndex:1] compare:@" "] == NSOrderedSame) {
            imgtag = [imgtag substringFromIndex:1];
        }
        //NSLog(@"%@", imgtag);

        // Search for the " or '
        NSString *quote = [imgtag substringToIndex:1];
        if ([quote compare:@"'"] != NSOrderedSame && [quote compare:@"\""] != NSOrderedSame)
            quote = @" ";
        imgtag = [imgtag substringFromIndex:1];
        r = [imgtag rangeOfString:quote];
        if (r.location == NSNotFound) {
            NSLog(@"No trailing %@", quote);
            continue;
        }

        imgtag = [imgtag substringToIndex:r.location];
        NSLog(@"Found image: %@", imgtag);

        NSString *datafile = [dbImage createDataFilename:imgtag];
        NSLog(@"Saving as %@", datafile);

        dbImage *img = [dbImage dbGetByURL:imgtag];
        if (img == nil) {
            img = [[dbImage alloc] init:imgtag datafile:datafile];
            [dbImage dbCreate:img];
        }

        found++;
    } while (next != nil);

    return found;
}

@end
