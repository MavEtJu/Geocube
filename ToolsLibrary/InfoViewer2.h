//
//  InfoViewer2.h
//  Geocube
//
//  Created by Edwin Groothuis on 27/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@interface InfoViewer2 : GCView

@property (nonatomic        ) BOOL needsRefresh;

- (InfoItem2 *)addDownload;
- (InfoItem2 *)addImport;
- (InfoItem2 *)addImage;

- (void)removeDownload:(InfoItem2 *)download;
- (void)removeImport:(InfoItem2 *)import;
- (void)removeImage:(InfoItem2 *)image;

- (void)show;
- (void)hide;
- (BOOL)hasItems;

@end
