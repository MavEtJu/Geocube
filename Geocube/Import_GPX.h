//
//  Import_GPX.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_Import_GPX_h
#define Geocube_Import_GPX_h

#import <Foundation/Foundation.h>
#import "dbObjects.h"

@interface Import_GPX : NSObject <NSXMLParserDelegate> {
    NSArray *files;
    NSString *groupname;
    dbObjectWaypointGroup *group;
    
    NSInteger index;
    NSInteger inItem;
    NSMutableString *currentText;
    NSString *currentElement;
    dbObjectWaypoint *currentWP;
}

- (id)init:(NSString *)filename group:(NSString *)groupname;
- (void)parse;

@end

#endif