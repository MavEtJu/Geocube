/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@protocol IOSFileTransfersDelegate

- (void)refreshFilelist;

@end

@interface IOSFileTransfers : NSObject <UIDocumentMenuDelegate, UIDocumentPickerDelegate>

@property (nonatomic, retain) id<IOSFileTransfersDelegate> delegate;

- (void)cleanupITunes;
- (void)uploadAirdrop:(NSString *)path vc:(UIViewController *)vc;
- (void)uploadICloud:(NSString *)path vc:(UIViewController *)vc;
- (void)downloadICloud:(UIViewController *)vc;
- (void)importAirdropAttachment:(NSURL *)url;

@end
