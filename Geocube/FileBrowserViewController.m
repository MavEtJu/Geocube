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

@property (nonatomic, retain) NSString *cwd;
@property (nonatomic, retain) NSMutableArray<FileObject *> *contents;
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

    self.contents = [NSMutableArray arrayWithCapacity:100];

    self.cwd = @"";
    [self loadContents:self.cwd];
}

- (void)loadContents:(NSString *)cwd
{
    NSArray<NSString *> *fes = [fileManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", [MyTools DocumentRoot], cwd] error:nil];

    [fes enumerateObjectsUsingBlock:^(NSString * _Nonnull fn, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObject *fo = [[FileObject alloc] init];

        NSString *fullFilename = [NSString stringWithFormat:@"%@/%@", [MyTools DocumentRoot], fn];

        BOOL isDir = NO;
        [fileManager fileExistsAtPath:fullFilename isDirectory:&isDir];

        fo.filename = fn;
        fo.isDir = isDir;
        if (isDir)
            fo.filesize = [MyTools determineDirectorySize:fullFilename];
        else {
            NSDictionary<NSFileAttributeKey, id> *d = [fileManager attributesOfItemAtPath:fullFilename error:nil];
            fo.filesize = [[d objectForKey:NSFileSize] integerValue];
        }

        [self.contents addObject:fo];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    self.y = 0;
    [self.contents enumerateObjectsUsingBlock:^(FileObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
        FileObjectView *fov = [[FileObjectView alloc] initWithFrame:CGRectMake(0, self.y, width, 20)];
        fov.filename.text = fo.filename;
        fov.filesize.text = [MyTools niceFileSize:fo.filesize];
        fov.filetype.text = fo.isDir == YES ? @"(d)" : @"(f)";
        self.y += fov.frame.size.height;

        [contentView addSubview:fov];
    }];

    [contentView setContentSize:CGSizeMake(width, self.y)];
}

@end
