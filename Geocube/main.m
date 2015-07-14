//
//  main.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

GlobalMenu *menuGlobal;

// Database handle
database *db = nil;
DatabaseCache *dbc = nil;

// Image Library
ImageLibrary *imageLibrary = nil;

// Current dbCache to navigate to
dbCache *currentCache = nil;

//
AppDelegate *_AppDelegate;

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
