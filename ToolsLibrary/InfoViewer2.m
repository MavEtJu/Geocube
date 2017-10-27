//
//  InfoViewer2.m
//  Geocube
//
//  Created by Edwin Groothuis on 27/10/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@interface InfoViewer2 ()

@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *downloads;
@property (nonatomic, retain) GCLabelNormalText *headerDownloads;
@property (nonatomic, retain) NSMutableArray<InfoItem2 *> *imports;
@property (nonatomic, retain) GCLabelNormalText *headerImports;

@property (nonatomic        ) BOOL isVisible;

@end

@implementation InfoViewer2

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];

    self.headerDownloads = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerDownloads.text = @"Downloads";
    [self.headerDownloads sizeToFit];
    [self addSubview:self.headerDownloads];

    self.headerImports = [[GCLabelNormalText alloc] initWithFrame:CGRectZero];
    self.headerImports.text = @"Imports";
    [self.headerImports sizeToFit];
    [self addSubview:self.headerImports];

    self.isVisible = NO;
    self.needsRefresh = YES;

    self.downloads = [NSMutableArray arrayWithCapacity:5];
    self.imports = [NSMutableArray arrayWithCapacity:5];

    return self;
}

- (InfoItem2 *)addDownload
{
    InfoItem2 *ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW2 owner:self options:nil] firstObject];
    ii.parent = self;

    [self.downloads addObject:ii];
    self.needsRefresh = YES;

    MAINQUEUE(
              [self addSubview:ii];
              )
    return ii;
}

- (InfoItem2 *)addImport
{
    InfoItem2 *ii = [[[NSBundle mainBundle] loadNibNamed:XIB_INFOITEMVIEW2 owner:self options:nil] firstObject];
    ii.parent = self;

    [self.imports addObject:ii];
    self.needsRefresh = YES;

    MAINQUEUE(
        [self addSubview:ii];
    )
    return ii;
}

- (void)removeDownload:(InfoItem2 *)download
{
    __block NSInteger index = -1;
    [self.downloads enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull dl, NSUInteger idx, BOOL * _Nonnull stop) {
        if (dl == download) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index == -1)
        return;
    [self.downloads removeObjectAtIndex:index];

    [download removeFromSuperview];
}

- (void)removeImport:(InfoItem2 *)import
{
    __block NSInteger index = -1;
    [self.imports enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull ip, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ip == import) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index == -1)
        return;
    [self.imports removeObjectAtIndex:index];

    [import removeFromSuperview];
}

- (void)show
{
    self.isVisible = YES;
    self.needsRefresh = YES;

    MAINQUEUE(
        [self adjustRects];
    );
}

- (void)hide
{
    self.isVisible = NO;
    self.needsRefresh = NO;

    MAINQUEUE(
        [self adjustRects];
    );
}

- (void)adjustRects
{
    if (self.isVisible == NO) {
        self.frame = CGRectZero;
        return;
    }

    CGRect applicationFrame = self.superview.frame;
    NSInteger width = applicationFrame.size.width;

    __block NSInteger y = 0;

    if ([self.downloads count] != 0) {
        self.headerDownloads.frame = CGRectMake(0, y, 0, 0);
        [self.headerDownloads sizeToFit];
        y += self.headerDownloads.frame.size.height;
        y += 4;

        [self.downloads enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull download, NSUInteger idx, BOOL * _Nonnull stop) {
            [download sizeToFit];
            download.backgroundColor = [UIColor redColor];
            download.frame = CGRectMake(0, y, download.frame.size.width, download.frame.size.height);
            y += download.frame.size.height;
            y += 4;
        }];
    } else {
        self.headerDownloads.frame = CGRectMake(0, 0, 0, 0);
    }

    if ([self.imports count] != 0) {
        self.headerImports.frame = CGRectMake(0, y, 0, 0);
        [self.headerImports sizeToFit];
        y += self.headerImports.frame.size.height;
        y += 4;

        [self.imports enumerateObjectsUsingBlock:^(InfoItem2 * _Nonnull import, NSUInteger idx, BOOL * _Nonnull stop) {
            [import sizeToFit];
            import.backgroundColor = [UIColor redColor];
            import.frame = CGRectMake(0, y, import.frame.size.width, import.frame.size.height);
            y += import.frame.size.height;
            y += 4;
        }];
    } else {
        self.headerImports.frame = CGRectMake(0, 0, 0, 0);
    }

    self.frame = CGRectMake(0, applicationFrame.size.height - y, width, y);
}

@end
