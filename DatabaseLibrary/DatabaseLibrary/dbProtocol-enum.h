//
//  dbProtocol-enum.h
//  DatabaseLibrary
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

typedef NS_ENUM(NSInteger, ProtocolId) {
    PROTOCOL_NONE = 0,
    PROTOCOL_LIVEAPI = 1,
    PROTOCOL_OKAPI = 2,
    PROTOCOL_GCA = 3,
    PROTOCOL_GCA2 = 4,
    PROTOCOL_GGCW = 5,
};
