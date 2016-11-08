/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "RemoteAPI_Template.h"

@protocol RemoteAPI_GGCWDelegate

- (void)GCAuthSuccessful:(NSHTTPCookie *)cookie;

@end

@interface RemoteAPI_GGCW : RemoteAPI_Template <NSURLConnectionDataDelegate>

@property (nonatomic) id<RemoteAPI_GGCWDelegate> delegate;
@property (nonatomic, retain, readonly) NSString *callback;

- (void)storeCookie:(NSHTTPCookie *)cookie;

- (GCDictionaryGGCW *)my_default:(NSString *)username downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGGCW *)pocket_default:(InfoItemDownload *)iid;
- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid downloadInfoItem:(InfoItemDownload *)iid;
- (GCStringGPX *)geocache:(NSString *)wptname downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGGCW *)account_oauth_token:(InfoItemDownload *)iid;
- (GCDictionaryGGCW *)map:(InfoItemDownload *)iid;
- (GCDictionaryGGCW *)map_info:(NSInteger)x y:(NSInteger)y z:(NSInteger)z downloadInfoItem:(InfoItemDownload *)iid;
- (GCDictionaryGGCW *)map_details:(NSString *)wpcode downloadInfoItem:(InfoItemDownload *)iid;
- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid downloadInfoItem:(InfoItemDownload *)iid;

@end
