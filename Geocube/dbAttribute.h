//
//  dbAttribute.h
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbAttribute : dbObject {
    NSInteger _id;
    NSInteger icon;
    NSInteger gc_id;
    NSString *label;
    
    // Internal stuff
    BOOL _YesNo;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger icon;
@property (nonatomic) NSInteger gc_id;
@property (nonatomic, retain) NSString *label;
@property (nonatomic) BOOL _YesNo;

- (id)init:(NSInteger)_id gc_id:(NSInteger)gc_id label:(NSString *)label icon:(NSInteger)icon;

@end
