@ForceSuccessOrders @CancelCreatedReservations @routing1 @route-delete
Feature: Delete Route

  @route-delete @routing-refactor @happy-path @HighPriority
  Scenario Outline: Operator Delete Driver Route Successfully - Single Pending Transaction - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "<route_type>" route
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_CREATED_ROUTE.id} |
      | deletedAt | not null               |
    And Operator search for "<transaction_type>" transaction with status "PENDING"
    And DB Core - verify transactions record:
      | id      | {KEY_TRANSACTION_DETAILS.id} |
      | routeId | null                         |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_TRANSACTION_DETAILS.waypointId} |
      | routeId  | null                                 |
      | seqNo    | null                                 |
      | status   | Pending                              |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_TRANSACTION_DETAILS.waypointId} |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | ZONAL_ROUTING_REMOVE   |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor @happy-path @HighPriority
  Scenario: Operator Delete Driver Route Successfully - Single Pending Reservation
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | deletedAt | not null                           |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId  | null                                             |
      | seqNo    | null                                             |
      | status   | Pending                                          |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | waypointStatus | Pending                                  |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes

  @route-delete @routing-refactor @HighPriority
  Scenario Outline: Operator Delete Driver Route Successfully - Merged Pending Waypoint - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator search for all created orders
    And Operator add order by tracking id to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order by tracking id to driver "<route_type>" route
    And Operator search for all created orders
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | deletedAt | not null                           |
    And Operator search for multiple "<transaction_type>" transactions with status "PENDING"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[1]} |
      | routeId | null                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | routeId  | null                          |
      | seqNo    | null                          |
      | status   | Pending                       |
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[2]} |
      | routeId | null                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[2]} |
      | routeId  | null                          |
      | seqNo    | null                          |
      | status   | Pending                       |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_LIST_OF_WAYPOINT_IDS[2]} |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ZONAL_ROUTING_REMOVE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeEventSource | ZONAL_ROUTING_REMOVE              |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor @MediumPriority
  Scenario: Operator Delete Driver Route Successfully - Single Empty Route
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | deletedAt | not null                           |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes

  @route-delete @MediumPriority @wip
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Reservation - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    And API Core - Operator force success waypoint via route manifest:
      | routeId    | {KEY_CREATED_ROUTE_ID}                           |
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
    Then Operator delete driver route with status code 500
    And Operator verify delete route response with proper error message : "Reservation {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} for Shipper {KEY_LIST_OF_CREATED_RESERVATIONS[1].shipperId} has status <action>. Cannot delete route."
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | <action>                                         |
    Examples:
      | Note    | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Success | Success | Parcel       | Standard      | true                          |
      | Fail    | Fail    | Parcel       | Standard      | true                          |

  @route-delete @MediumPriority @wip
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Delivery Transaction - <Status>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "<terminal_state>" "DELIVERY" waypoint
    And Operator search for "DELIVERY" transaction with status "<terminal_state>"
    When Operator delete driver route with status code 500
    And Operator verify delete route response with proper error message : "Delivery for Order {KEY_CREATED_ORDER_ID} has already been attempted. Cannot delete route."
    And DB Core - verify transactions record:
      | id      | {KEY_TRANSACTION_ID}   |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}      |
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | seqNo    | not null               |
      | status   | <Status>               |

    Examples:
      | Status  | terminal_state | service_type | service_level | parcel_job_is_pickup_required |
      | Success | SUCCESS        | Parcel       | Standard      | false                         |
      | Fail    | FAIL           | Parcel       | Standard      | false                         |

  @route-delete @MediumPriority @wip
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Pickup Transaction - <Status>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "PP" route
    And Operator force "<terminal_state>" "PICKUP" waypoint
    And Operator search for "PICKUP" transaction with status "<terminal_state>"
    When Operator delete driver route with status code 500
    Then Operator verify delete route response with proper error message : "Pickup for Order {KEY_CREATED_ORDER_ID} has already been attempted. Cannot delete route."
    And DB Core - verify transactions record:
      | id      | {KEY_TRANSACTION_ID}   |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}      |
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | seqNo    | not null               |
      | status   | <Status>               |

    Examples:
      | Status  | terminal_state | service_type | service_level | parcel_job_is_pickup_required |
      | Success | SUCCESS        | Return       | Standard      | true                          |
      | Fail    | FAIL           | Return       | Standard      | true                          |