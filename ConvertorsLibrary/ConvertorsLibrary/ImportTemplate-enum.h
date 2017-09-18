//
//  ImportTemplate-enum.h
//  Geocube
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

// Needs to be defined here instead of in ImportManager.
typedef NS_ENUM(NSInteger, ImportOptions) {
    IMPORTOPTION_NONE = 0,
    IMPORTOPTION_LOGSONLY = 1,
    IMPORTOPTION_NOPOST = 2,
    IMPORTOPTION_NOPRE = 4,
    IMPORTOPTION_NOPARSE = 8,
};
