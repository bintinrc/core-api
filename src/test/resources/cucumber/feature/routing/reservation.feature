@ArchiveDriverRoutes @CancelCreatedReservations @routing @reservation
Feature: Assign and Remove Single Reservation To Route


  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | 100                                              |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status  | Routed                                           |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | type       | RESERVATION                                      |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | waypointStatus | Routed                                   |
      | driverId       | {driver-id}                              |
    And DB Events - verify pickup_events record:
      | pickupId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId      | {pickup-user-id}                                |
      | userName    | {pickup-user-name}                              |
      | userEmail   | {pickup-user-email}                             |
      | type        | 1                                               |
      | pickup_type | 1                                               |
      | data        | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |


  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Reservation Id Doesn't Exist
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator failed to add reservation to route using data below:
      | reservationId | 124                                |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | overwrite     | false                              |


  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Route Id Doesn't Exist
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When API Core - Operator failed to add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | 124                                      |
      | overwrite     | false                                    |
