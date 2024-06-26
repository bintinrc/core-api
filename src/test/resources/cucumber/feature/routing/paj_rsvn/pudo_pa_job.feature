@ArchiveDriverRoutes @CancelCreatedReservations @routing2 @pudo-pa-job
Feature: Zonal Routing API - Pudo PAJ

  @DeletePudoPickupJob @MediumPriority
  Scenario: POST /routes - Zonal Routing API - Create Driver Route & Assign Pudo PA Job Waypoint
    Given API Control - Operator create pudo pickup appointment job with data below:
      | request | { "from":{ "dpId":{pudo-paj-dp-id}}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupInstructions":"created by automation"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PUDO_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
#      | userId     | {pickup-user-id}                                |
#      | userName   | {pickup-user-name}                              |
#      | userEmail  | {pickup-user-email}                             |
#      | type       | 1                                               |
#      | pickupType | 2                                               |
#      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |