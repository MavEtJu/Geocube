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

@interface GroupsUserViewController ()

@end

@implementation GroupsUserViewController

enum {
    menuEmptyGroups = 0,
    menuAddAGroup,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.showUsers = YES;
    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuEmptyGroups label:_(@"groupsuserviewcontroller-emptygroups")];
    [lmi addItem:menuAddAGroup label:_(@"groupsuserviewcontroller-addagroup")];

    return self;
}

- (void)refreshGroupData
{
    self.cgs = [dbGroup dbAllByUserGroup:YES];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Add a group
    if (self.showUsers == YES) {
        switch (index) {
            case menuEmptyGroups:
                [self emptyGroups];
                return;
            case menuAddAGroup:
                [self newGroup];
                return;
        }
    } else {
        if (index == 0) {
            [self emptyGroups];
            return;
        }
    }

    [super performLocalMenuAction:index];
}

@end
