@class dbWaypoint;

@protocol ImportDelegate

- (void)Import_WaypointProcessed:(dbWaypoint *)wp;

@end
