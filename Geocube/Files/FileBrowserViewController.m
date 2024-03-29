/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@interface FileBrowserViewController ()

@property (nonatomic, retain) GCScrollView *contentView;

@property (nonatomic, retain) FileObject *rootFO;
@property (nonatomic, retain) FileObject *shownFO;
@property (nonatomic, retain) NSMutableArray<FileObject *> *stackFO;
@property (nonatomic, retain) NSOperationQueue *runqueue;

@end

@implementation FileBrowserViewController

- (void)viewDidLoad
{
    self.hasCloseButton = NO;
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    self.contentView.delegate = self;
    self.view = self.contentView;

    self.runqueue = [[NSOperationQueue alloc] init];
    [self.runqueue addObserver:self forKeyPath:@"operations" options:0 context:nil];

    [self changeThemeStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.rootFO = [[FileObject alloc] init];
    self.rootFO.filename = @"";
    self.rootFO.isDir = YES;
    self.rootFO.cwd = @"";
    [self loadContents:self.rootFO];

    self.shownFO = self.rootFO;
    self.stackFO = [NSMutableArray arrayWithCapacity:10];

    [bezelManager showBezel:self];
    [bezelManager setText:_(@"filebrowserviewcontroller-Retrieving directory contents")];
}

- (void)loadContents:(FileObject *)rootFO
{
    NSMutableArray<FileObject *> *fos = [NSMutableArray arrayWithCapacity:20];

    [self.runqueue addOperationWithBlock:^{
        FileObject *fo = [[FileObject alloc] init];
        fo.filename = @"Files";
        fo.isDir = YES;
        fo.cwd = @"";
        [self loadContentsOfDir:fo start:[MyTools FilesDir]];
        [fos addObject:fo];
    }];

    [self.runqueue addOperationWithBlock:^{
        FileObject *fo = [[FileObject alloc] init];
        fo.filename = @"Document Root";
        fo.isDir = YES;
        fo.cwd = @"";
        [self loadContentsOfDir:fo start:[MyTools DocumentRoot]];
        [fos addObject:fo];
    }];

    [self.runqueue addOperationWithBlock:^{
        FileObject *fo = [[FileObject alloc] init];
        fo.filename = @"KML";
        fo.isDir = YES;
        fo.cwd = @"";
        [self loadContentsOfDir:fo start:[MyTools KMLDir]];
        [fos addObject:fo];
    }];

    [self.runqueue addOperationWithBlock:^{
        FileObject *fo = [[FileObject alloc] init];
        fo.filename = @"Application Support";
        fo.isDir = YES;
        fo.cwd = @"";
        [self loadContentsOfDir:fo start:[MyTools ApplicationSupportRoot]];
        [fos addObject:fo];
    }];

    rootFO.contents = fos;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.runqueue && [keyPath isEqualToString:@"operations"]) {
        if (self.runqueue.operationCount == 0) {
            MAINQUEUE(
                [bezelManager removeBezel];
                [self refreshContentsView];
            )
        }
        return;
    }

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)loadContentsOfDir:(FileObject *)rootFO start:(NSString *)startdir
{
    NSArray<NSString *> *fes = [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", startdir, rootFO.cwd] error:nil];
    NSMutableArray<FileObject *> *fos = [NSMutableArray arrayWithCapacity:20];

    [fes enumerateObjectsUsingBlock:^(NSString * _Nonnull fn, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObject *fo = [[FileObject alloc] init];
        fo.filename = fn;

        fo.fullFilename = [NSString stringWithFormat:@"%@/%@%@", startdir, rootFO.cwd, fn];

        NSDictionary<NSFileAttributeKey, id> *attrs = [fileManager attributesOfItemAtPath:fo.fullFilename error:nil];
        if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            fo.isDir = YES;
        else if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink] == YES) {
            NSDictionary<NSFileAttributeKey, id> *as = [fileManager attributesOfItemAtPath:[fileManager destinationOfSymbolicLinkAtPath:fo.fullFilename error:nil] error:nil];
            if ([[as objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
                fo.isLinkToDir = YES;
            else if ([[as objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink] == YES)
                fo.isLinkToLink = YES;
            else
                fo.isLinkToFile = YES;
        }

        if (fo.isDir == YES) {
            fo.cwd = [NSString stringWithFormat:@"%@%@/", rootFO.cwd, fn];
            [self loadContentsOfDir:fo start:startdir];
            __block NSInteger totalSize = 0;
            [fo.contents enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
                totalSize += fo.filesize;
            }];
            fo.filesize = totalSize;
        } else {
            fo.filesize = [[attrs objectForKey:NSFileSize] integerValue];
        }

        [fos addObject:fo];
    }];

    rootFO.contents = fos;
}

- (void)calculateRects
{
    [super calculateRects];
    [self refreshContentsView];
}

- (void)refreshContentsView
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    for (UIView *v in self.contentView.subviews) {
        if ([v isKindOfClass:[GCLabel class]]) {
            [v removeFromSuperview];
        }
        if ([v isKindOfClass:[FileObjectView class]]) {
            [v removeFromSuperview];
        }
    }

    __block NSInteger y = 0;

    // Header with the directory
    GCLabelNormalText *l = [[GCLabelNormalText alloc] initWithFrame:CGRectMake(0, y, width, 0)];
    l.text = [self determineVisiblePath];
    [l sizeToFit];
    y += l.frame.size.height;

    l.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUp:)];
    [l addGestureRecognizer:tapGesture];

    [self.contentView addSubview:l];

    [self.shownFO.contents enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObjectView *fov = [[FileObjectView alloc] initWithFrame:CGRectMake(0, y, width, configManager.fontNormalTextSize)];
        fov.filename.text = fo.filename;
        fov.filesize.text = [MyTools niceFileSize:fo.filesize];
        fov.filetype.text = _(@"filebrowserviewcontroller-(f)");
        if (fo.isDir == YES)
            fov.filetype.text = _(@"filebrowserviewcontroller-(d)");
        if (fo.isLinkToLink == YES)
            fov.filetype.text = _(@"filebrowserviewcontroller-(ll)");
        if (fo.isLinkToDir == YES)
            fov.filetype.text = _(@"filebrowserviewcontroller-(ld)");
        if (fo.isLinkToFile == YES)
            fov.filetype.text = _(@"filebrowserviewcontroller-(lf)");
        fov.fo = fo;

        fov.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFile:)];
        [fov addGestureRecognizer:tapGesture];
        UILongPressGestureRecognizer *tap2Gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fileMenu:)];
        [fov addGestureRecognizer:tap2Gesture];

        [fov changeTheme];

        y += fov.frame.size.height;
        [self.contentView addSubview:fov];
    }];

    [self.contentView setContentSize:CGSizeMake(width, y)];
}

- (NSString *)determineFullPath
{
    NSMutableString *s = [NSMutableString string];
    [self.stackFO enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
        [s appendString:fo.filename];
        [s appendString:@"/"];
    }];
    if (self.shownFO.filename != nil)
        [s appendString:self.shownFO.filename];
    return s;
}

- (NSString *)determineVisiblePath
{
    NSMutableString *s = [NSMutableString stringWithString:[self determineFullPath]];
    if ([s length] == 0)
        [s appendString:@"/"];
    return s;
}

- (void)tapFile:(UITapGestureRecognizer *)tap
{
    FileObjectView *fov = (FileObjectView *)tap.view;
    FileObject *fo = fov.fo;

    if (fo.isDir == NO)
        return;

    [self.stackFO addObject:self.shownFO];
    self.shownFO = fo;
    [self refreshContentsView];
}

- (void)tapUp:(UITapGestureRecognizer *)tap
{
    if ([self.stackFO count] == 0)
        return;
    self.shownFO = [self.stackFO lastObject];
    [self.stackFO removeLastObject];
    [self refreshContentsView];
}

- (void)fileMenu:(UILongPressGestureRecognizer *)tap
{
    FileObjectView *fov = (FileObjectView *)tap.view;
    FileObject *fo = fov.fo;

    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:fo.filename
                               message:_(@"filebrowserviewcontroller-Choose your action")
                               preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:_(@"Delete")
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 NSError *e = nil;
                                 [fileManager removeItemAtPath:fo.fullFilename error:&e];
                                 if (e != nil)
                                     [MyTools messageBox:self header:_(@"Deleting") text:[e description]];

                                 self.shownFO = self.rootFO;
                                 [self.stackFO removeAllObjects];

                                 BACKGROUND(loadContents:,  self.rootFO);
                                 [bezelManager showBezel:self];
                                 [bezelManager setText:_(@"filebrowserviewcontroller-Retrieving directory contents")];

                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *tar = [UIAlertAction
                          actionWithTitle:_(@"Tar")
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              NSString *targz = [NSString stringWithFormat:@"%@.tgz", fo.fullFilename];
                              NSString *source = fo.fullFilename;
                              [[NVHTarGzip sharedInstance] tarFileAtPath:source toPath:targz completion:^(NSError* tarError) {
                                  if (tarError != nil)
                                      [MyTools messageBox:self header:_(@"Tar") text:[tarError description]];
                              }];

                              self.shownFO = self.rootFO;
                              [self.stackFO removeAllObjects];

                              BACKGROUND(loadContents:, self.rootFO);
                              [bezelManager showBezel:self];
                              [bezelManager setText:_(@"filebrowserviewcontroller-Retrieving directory contents")];

                              [view dismissViewControllerAnimated:YES completion:nil];
                          }];

    UIAlertAction *uploadAirdrop = [UIAlertAction
                                    actionWithTitle:_(@"filebrowserviewcontroller-Upload with Airdrop")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self uploadAirdrop:fo.fullFilename];
                                        [view dismissViewControllerAnimated:YES completion:nil];
                                    }];

    UIAlertAction *uploadICloud = [UIAlertAction
                                   actionWithTitle:_(@"filebrowserviewcontroller-Upload to iCloud")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self uploadICloud:fo.fullFilename];
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                   }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    [view addAction:delete];
    [view addAction:tar];
    [view addAction:uploadAirdrop];
    [view addAction:uploadICloud];
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
}

- (void)uploadAirdrop:(NSString *)filename
{
    [IOSFTM uploadAirdrop:filename vc:self];
}

- (void)uploadICloud:(NSString *)filename
{
    [IOSFTM uploadICloud:filename vc:self];
}

@end
