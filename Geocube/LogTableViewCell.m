//
//  LogTableViewCell.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation LogTableViewCell

@synthesize logtype, datetime, logger, log;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    
    /*
     +---+------+-----------------+
     | I | date | by Name         |  logtypeImage
     +---+------+-----------------|
     | Log                        |
     |                            |
     +----------------------------+
     */
#define BORDER 1
#define IMAGE_WIDTH 10
#define IMAGE_HEIGHT 10
#define DATE_WIDTH 100
    
    CGRect rectImage = CGRectMake(BORDER, BORDER, IMAGE_WIDTH, IMAGE_HEIGHT);
    CGRect rectDatetime = CGRectMake(BORDER + IMAGE_WIDTH, BORDER, DATE_WIDTH, IMAGE_HEIGHT);
    CGRect rectLogger = CGRectMake(BORDER + IMAGE_WIDTH + DATE_WIDTH, BORDER, width - 2 * BORDER - DATE_WIDTH - IMAGE_HEIGHT, IMAGE_HEIGHT);
    CGRect rectLog = CGRectMake(BORDER, BORDER + IMAGE_HEIGHT, width - 2 * BORDER, 30);
    
    // Image
    logtype = [[UIImageView alloc] initWithFrame:rectImage];
    logtype.image = [imageLibrary get:ImageCaches_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:logtype];
    
    // Date
    datetime = [[UILabel alloc] initWithFrame:rectDatetime];
    datetime.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:datetime];
    
    // Logger
    logger = [[UILabel alloc] initWithFrame:rectLogger];
    logger.font = [UIFont boldSystemFontOfSize:10.0];
    [self.contentView addSubview:logger];
    
    // Log
    log = [[UILabel alloc] initWithFrame:rectLog];
    log.font = [UIFont systemFontOfSize:12.0];
    log.numberOfLines = 0;
    //bearing.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:log];
    
    return self;
}

@end
