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

#ifndef Geocube_Import_GPX_h
#define Geocube_Import_GPX_h

@interface Import_GPX : NSObject <NSXMLParserDelegate> {
    NSInteger *newWaypointsCount;
    NSInteger *totalWaypointsCount;
    NSInteger *newLogsCount;
    NSInteger *totalLogsCount;
    NSInteger *newTravelbugsCount;
    NSInteger *totalTravelbugsCount;
    NSUInteger *percentageRead;
    NSUInteger totalLines;

    NSArray *files;
    dbGroup *group;

    NSMutableArray *attributes;
    NSMutableArray *logs;
    NSMutableArray *travelbugs;
    NSInteger index;
    NSInteger inItem, inLog, inTravelbug, inGroundspeak;
    NSMutableString *currentText;
    NSString *currentElement;
    NSString *gsOwnerNameId, *logFinderNameId;
    dbWaypoint *currentWP;
    dbGroundspeak *currentGS;
    dbLog *currentLog;
    dbTravelbug *currentTB;
}

- (id)init:(NSString *)filename group:(dbGroup *)group newWaypointsCount:(NSInteger *)nWC totalWaypointsCount:(NSInteger *)tWC newLogsCount:(NSInteger *)nLC totalLogsCount:(NSInteger *)tLC percentageRead:(NSUInteger *)pR newTravelbugsCount:(NSInteger *)nTC totalTravelbugsCount:(NSInteger *)tTC;
- (void)parse;

@end

#endif
