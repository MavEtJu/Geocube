//
//  main.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "database.h"
#import "database-cache.h"
#import "dbObjects.h"
#import "GlobalMenu.h"
#import "ImageLibrary.h"

GlobalMenu *menuGlobal;

// Database handle
database *db = nil;
DatabaseCache *dbc = nil;

// Image Library
ImageLibrary *imageLibrary = nil;

//
AppDelegate *_AppDelegate;

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
