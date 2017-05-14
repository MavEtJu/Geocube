/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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
{
    GCScrollView *contentView;
}

@property (nonatomic, retain) FileObject *allFO;
@property (nonatomic, retain) FileObject *shownFO;
@property (nonatomic, retain) NSMutableArray<FileObject *> *stackFO;
@property (nonatomic) NSInteger y;

@end

@implementation FileBrowserViewController

- (void)viewDidLoad
{
    hasCloseButton = NO;
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    contentView.delegate = self;
    self.view = contentView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    FileObject *rootFO = [[FileObject alloc] init];
    rootFO.filename = @"";
    rootFO.isDir = YES;
    rootFO.cwd = @"";
    [self performSelectorInBackground:@selector(loadContents:) withObject:rootFO];

    self.allFO = rootFO;
    self.shownFO = self.allFO;
    self.stackFO = [NSMutableArray arrayWithCapacity:10];

    [bezelManager showBezel:self];
    [bezelManager setText:@"Retrieving directory contents"];
}

- (void)loadContents:(FileObject *)rootFO
{
//  NSLog(@"loadContents: %@", rootFO.cwd);
    NSArray<NSString *> *fes = [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools DocumentRoot], rootFO.cwd] error:nil];
    NSMutableArray<FileObject *> *fos = [NSMutableArray arrayWithCapacity:20];

    [fes enumerateObjectsUsingBlock:^(NSString * _Nonnull fn, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObject *fo = [[FileObject alloc] init];

        NSString *fullFilename = [NSString stringWithFormat:@"%@/%@%@", [MyTools DocumentRoot], rootFO.cwd, fn];

        BOOL isDir = NO;
        NSDictionary<NSFileAttributeKey, id> *attrs = [fileManager attributesOfItemAtPath:fullFilename error:nil];
        if ([[attrs objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory] == YES)
            isDir = YES;

        fo.filename = fn;
        fo.isDir = isDir;
        if (isDir == YES) {
            fo.cwd = [NSString stringWithFormat:@"%@%@/", rootFO.cwd, fn];
            [self loadContents:fo];
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

    if ([rootFO.cwd isEqualToString:@""] == YES) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [bezelManager removeBezel];
            [self refreshContentsView];
        }];
    }

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

    for (UIView *v in contentView.subviews) {
        if ([v isKindOfClass:[GCLabel class]]) {
            [v removeFromSuperview];
        }
        if ([v isKindOfClass:[FileObjectView class]]) {
            [v removeFromSuperview];
        }
    }

    self.y = 0;

    GCLabel *l = [[GCLabel alloc] initWithFrame:CGRectMake(0, self.y, width, 20)];
    l.text = [self determineFullPath];
    self.y += l.frame.size.height;

    l.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUp:)];
    [l addGestureRecognizer:tapGesture];

    [contentView addSubview:l];

    [self.shownFO.contents enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObjectView *fov = [[FileObjectView alloc] initWithFrame:CGRectMake(0, self.y, width, 20)];
        fov.filename.text = fo.filename;
        fov.filesize.text = [MyTools niceFileSize:fo.filesize];
        fov.filetype.text = fo.isDir == YES ? @"(d)" : @"(f)";
        fov.fo = fo;
        self.y += fov.frame.size.height;

        fov.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFile:)];
        [fov addGestureRecognizer:tapGesture];
        UILongPressGestureRecognizer *tap2Gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fileMenu:)];
        [fov addGestureRecognizer:tap2Gesture];

        [contentView addSubview:fov];
    }];

    [contentView setContentSize:CGSizeMake(width, self.y)];
}

- (NSString *)determineFullPath
{
    NSMutableString *s = [NSMutableString string];
    [self.stackFO enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
        [s appendString:fo.filename];
        [s appendString:@"/"];
    }];
    [s appendString:self.shownFO.filename];
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
                               message:@"Choose you action"
                               preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action) {
                                 NSError *e = nil;
                                 [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@", [MyTools DocumentRoot], [self determineFullPath], fo.filename] error:&e];
                                 if (e != nil)
                                     [MyTools messageBox:self header:@"Deleting" text:[e description]];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    [view addAction:delete];
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];

}

@end
