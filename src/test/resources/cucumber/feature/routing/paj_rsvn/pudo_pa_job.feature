@ArchiveDriverRoutes @CancelCreatedReservations @routing2 @pudo-pa-job
Feature: Zonal Routing API - Pudo PAJ

  @DeletePudoPickupJob @MediumPriority
  Scenario: POST /routes - Zonal Routing API - Create Driver Route & Assign Pudo PA Job Waypoint
    Given API Control - Operator create pudo pickup appointment job with data below:
      | request | { "from":{ "dpId":{pudo-paj-dp-id}}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupInstructions":"created by automation"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PUDO_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
#    will be enabled once RMD is catered for pudo paj
#    And DB Core - verify route_monitoring_data record:
#      | waypointId | {KEY_WAYPOINT_ID}                  |
#      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
#      | userId     | {pickup-user-id}                                |
#      | userName   | {pickup-user-name}                              |
#      | userEmail  | {pickup-user-email}                             |
#      | type       | 1                                               |
#      | pickupType | 2                                               |
#      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePudoPickupJob @MediumPriority @wip
  Scenario: PUT /routes - Zonal Routing Edit Route API - Add Unrouted Pudo PA Job Waypoints to Route
    Given API Control - Operator create pudo pickup appointment job with data below:
      | request | { "from":{ "dpId":{pudo-paj-dp-id}}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupInstructions":"created by automation"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PUDO_PA_JOBS[1].id}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
#    will be enabled once RMD is catered for pudo paj
#    And DB Core - verify route_monitoring_data record:
#      | waypointId | {KEY_WAYPOINT_ID}                  |
#      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
#      | userId     | {pickup-user-id}                                |
#      | userName   | {pickup-user-name}                              |
#      | userEmail  | {pickup-user-email}                             |
#      | type       | 1                                               |
#      | pickupType | 2                                               |
#      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @DeletePudoPickupJob @MediumPriority @wip
  Scenario: PUT /routes - Zonal Routing Edit Route API - Move Routed Pudo PA Job Waypoints to Another Route
    Given API Control - Operator create pudo pickup appointment job with data below:
      | request | { "from":{ "dpId":{pudo-paj-dp-id}}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupInstructions":"created by automation"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PUDO_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[2].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
#    will be enabled once RMD is catered for pudo paj
#    And DB Core - verify route_monitoring_data record:
#      | waypointId | {KEY_WAYPOINT_ID}                  |
#      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
#      | userId     | {pickup-user-id}                                |
#      | userName   | {pickup-user-name}                              |
#      | userEmail  | {pickup-user-email}                             |
#      | type       | 1                                               |
#      | pickupType | 2                                               |
#      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}                                                               |
#      | userId     | {pickup-user-id}                                                                                  |
#      | userName   | {pickup-user-name}                                                                                |
#      | userEmail  | {pickup-user-email}                                                                               |
#      | type       | 2                                                                                                 |
#      | pickupType | 2                                                                                                 |
#      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePudoPickupJob @CancelCreatedReservations @MediumPriority @wip
  Scenario: PUT /routes - Zonal Routing Edit Route API - Remove Pudo PA Job Waypoints From Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Control - Operator create pudo pickup appointment job with data below:
      | request | { "from":{ "dpId":{pudo-paj-dp-id}}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupInstructions":"created by automation"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PUDO_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID} |
      | seqNo   | null              |
      | routeId | null              |
      | status  | Pending           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | seqNo    | null              |
      | routeId  | null              |
      | status   | Pending           |
##    will be enabled once RMD is catered for pudo paj
#    And DB Core - verify route_monitoring_data is hard-deleted:
#      | {KEY_WAYPOINT_ID} |
#    will be enabled once pickup_events is catered for pudo paj
#    And DB Events - verify pickup_events record:
#      | pickupId   | {KEY_CONTROL_CREATED_PA_JOBS[1].id}             |
#      | userId     | {pickup-user-id}                                |
#      | userName   | {pickup-user-name}                              |
#      | userEmail  | {pickup-user-email}                             |
#      | type       | 3                                               |
#      | pickupType | 2                                               |
#      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
