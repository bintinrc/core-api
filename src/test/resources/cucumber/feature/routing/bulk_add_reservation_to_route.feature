@ForceSuccessOrder  @routing @bulk-route-rsvn @runnow
Feature: Bulk Add Reservation to Route

  @CancelCreatedReservations
  Scenario: PUT /2.0/reservations/route-bulk - Bulk Add Reservation to Route - Multiple Unrouted Reservations
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id-2}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator bulk add reservation to route using data below:
      | request | {"ids": [{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}, {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}],"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    Then API Core - Operator verifies response of bulk add reservation to route
      | successfulJobs | [{"id": {KEY_LIST_OF_CREATED_RESERVATIONS[1].id},"status": "PENDING"},{"id": {KEY_LIST_OF_CREATED_RESERVATIONS[2].id},"status": "PENDING"}] |
      | failedJobs     | []                                                                                                                                          |
#    reservation #1
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | not null                                         |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status  | Routed                                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
#    reservation #2
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | seqNo   | not null                                         |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status  | Routed                                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
    And DB Events - verify pickup_events record:
      | pickupId  | {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}        |
      | userId    | {pickup-user-id}                                |
      | userName  | {pickup-user-name}                              |
      | userEmail | {pickup-user-email}                             |
      | type      | 1                                               |
      | data      | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @CancelCreatedReservations @changeofroute
  Scenario: PUT /2.0/reservations/route-bulk - Bulk Add Reservation to Route - Multiple Routed Reservations Added to New Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id-2}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator bulk add reservation to route using data below:
      | request | {"ids": [{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}, {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}],"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":true} |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator bulk add reservation to route using data below:
      | request | {"ids": [{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}, {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}],"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"overwrite":true} |
    Then API Core - Operator verifies response of bulk add reservation to route
      | successfulJobs | [{"id": {KEY_LIST_OF_CREATED_RESERVATIONS[1].id},"status": "PENDING"},{"id": {KEY_LIST_OF_CREATED_RESERVATIONS[2].id},"status": "PENDING"}] |
      | failedJobs     | []                                                                                                                                          |
#    reservation #1
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | not null                                         |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status  | Routed                                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status   | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}                                                          |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 1                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |
#    reservation #2
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | seqNo   | not null                                         |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status  | Routed                                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status   | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}                                                          |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 1                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @CancelCreatedReservations
  Scenario: PUT /2.0/reservations/route-bulk - Bulk Add Reservation to Route - Partial Success Add Reservation
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id-2}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId}] } |
    And API Core - Operator force success waypoint via route manifest:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
    When API Core - Operator bulk add reservation to route using data below:
      | request | {"ids": [{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}, 160894, {KEY_LIST_OF_CREATED_RESERVATIONS[2].id}],"new_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"overwrite":false} |
    Then API Core - Operator verifies response of bulk add reservation to route
      | successfulJobs | [{"id": {KEY_LIST_OF_CREATED_RESERVATIONS[1].id},"status": "PENDING"}]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
      | failedJobs     | [{"id": 160894,"error": {"code": 103016,"nvErrorCode": "SERVER_ERROR_EXCEPTION","messages": ["Reservation not found"],"application": "core","description": "RESERVATION_NOT_FOUND","data": {"message": "Reservation not found"}}}, {"id": {KEY_LIST_OF_CREATED_RESERVATIONS[2].id},"error": {"code": 103088,"nvErrorCode": "SERVER_ERROR_EXCEPTION","messages": ["Reservation is in final state [status: SUCCESS]"],"application": "core","description": "INVALID_OPERATION","data": {"message": "Reservation is in final state [status: SUCCESS]"}}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | not null                                         |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status  | Routed                                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @CancelCreatedReservations
  Scenario: PUT /2.0/reservations/route-bulk - Bulk Add Reservation to Route - Route Id Doesn't Exist
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator bulk add reservation to route with partial success:
      | request    | {"ids": [{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}],"new_route_id":160894,"overwrite":false}                                                                                                                          |
      | failedJobs | {"code": 103080,"nvErrorCode": "SERVER_ERROR_EXCEPTION","messages": ["Unable to find route 160894"],"application": "core","description": "BAD_REQUEST_EXCEPTION","data": {"message": "Unable to find route 160894"}} |
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | null                                             |
      | routeId | null                                             |
      | status  | Pending                                          |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | null                                             |
      | routeId  | null                                             |
      | status   | Pending                                          |
