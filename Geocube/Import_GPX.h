//
//  Import_GPX.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_Import_GPX_h
#define Geocube_Import_GPX_h

@interface Import_GPX : NSObject <NSXMLParserDelegate> {
    NSArray *files;
    NSString *groupname;
    dbWaypointGroup *group;
    
    NSInteger index;
    NSInteger inItem;
    NSMutableString *currentText;
    NSString *currentElement;
    dbWaypoint *currentWP;
}

- (id)init:(NSString *)filename group:(NSString *)groupname;
- (void)parse;

@end

#endif