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

@interface NoticeTableViewCell : GCTableViewCell

@property (nonatomic, retain) GCTextblock *noteLabel;
@property (nonatomic, retain) GCSmallLabel *senderLabel;
@property (nonatomic, retain) GCSmallLabel *dateLabel;
@property (nonatomic, retain) dbNotice *notice;
@property (nonatomic) BOOL seen;

#if !defined(__CLASS__NOTICESTABLEVIEWCELL__)
@property (nonatomic) UILabel *textLabel __attribute__((unavailable));
@property (nonatomic) UILabel *detailTextLabel __attribute__((unavailable));
#endif

- (void)setNote:(NSString *)noteString;
- (void)setURL:(NSString *)urlString;

@end
