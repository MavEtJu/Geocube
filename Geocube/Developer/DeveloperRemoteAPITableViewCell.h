/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface DeveloperRemoteAPITableViewCell : GCTableViewCell

#define XIB_DEVELOPERREMOTEAPITABLEVIEWCELL @"DeveloperRemoteAPITableViewCell"

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelTest;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelStatus;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelLoadWaypoint;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelLoadWaypointsByCodes;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelLoadWaypointsByBoundingBox;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelUserStatistics;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelUpdatePersonalNote;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelListQueries;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelRetrieveQuery;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackablesMine;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackablesInventory;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackableFind;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackableDrop;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackableGrab;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelTrackableDiscover;

@end
