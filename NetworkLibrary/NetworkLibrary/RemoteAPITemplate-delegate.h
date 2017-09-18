//
//  RemoteAPITemplate-delegate.h
//  NetworkLibrary
//
//  Created by Edwin Groothuis on 18/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "ToolsLibrary/InfoItem.h"

@class dbGroup;
@class dbAccount;
@class RemoteAPITemplate;

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPITemplate *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPITemplate *)api success:(NSString *)success;

@end

@protocol RemoteAPIDownloadDelegate

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier iiImport:(InfoItemID)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account;
- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks;
- (void)remoteAPI_failed:(NSInteger)identifier;

@end


