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
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_TRANSACTION_DETAILS.id} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    Then Deleted route is not shown on his list routes
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | driverId | {driver-id}            |
    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor @happy-path @HighPriority
  Scenario: Operator Delete Driver Route Successfully - Single Pending Reservation
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_CREATED_ROUTE_ID} |
      | deletedAt | not null               |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    Then Deleted route is not shown on his list routes
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | driverId | {driver-id}            |

  @route-delete @routing-refactor @HighPriority
  Scenario Outline: Operator Delete Driver Route Successfully - Merged Pending Waypoint - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add order by tracking id to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order by tracking id to driver "<route_type>" route
    And Operator search for all created orders
    And API Core - Operator merge routed waypoints:
      | {KEY_CREATED_ROUTE_ID} |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_CREATED_ROUTE_ID} |
      | deletedAt | not null               |
    And Operator search for multiple "<transaction_type>" transactions with status "PENDING"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[1]} |
      | routeId | null                             |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_TRANSACTION_IDS[1]} |
      | routeId | null                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | routeId  | null                          |
      | seqNo    | null                          |
      | status   | Pending                       |
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[2]} |
      | routeId | null                             |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_TRANSACTION_IDS[2]} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    Then Deleted route is not shown on his list routes
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | driverId | {driver-id}            |
    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor @MediumPriority
  Scenario: Operator Delete Driver Route Successfully - Single Empty Route
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator delete driver route with status code 200
    Then DB Route - verify route_logs record:
      | legacyId  | {KEY_CREATED_ROUTE_ID} |
      | deletedAt | not null               |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    Then Deleted route is not shown on his list routes
      | routeId  | {KEY_CREATED_ROUTE_ID} |
      | driverId | {driver-id}            |

  @route-delete @MediumPriority
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Reservation - Fail
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                           |
      | waypointId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | failureReasonId | {failure-reason-id}                              |
    Then Operator delete driver route with status code 500
    And Operator verify delete route response with proper error message : "Reservation {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} for Shipper {KEY_LIST_OF_CREATED_RESERVATIONS[1].legacyShipperId} has status <action>. Cannot delete route."
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | <action>                                         |
    Examples:
      | Note | action | service_type | service_level | parcel_job_is_pickup_required |
      | Fail | Fail   | Parcel       | Standard      | true                          |

  @route-delete @MediumPriority
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Reservation - Success
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id}, "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
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
    And Operator verify delete route response with proper error message : "Reservation {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} for Shipper {KEY_LIST_OF_CREATED_RESERVATIONS[1].legacyShipperId} has status <action>. Cannot delete route."
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | <action>                                         |
    Examples:
      | Note    | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Success | Success | Parcel       | Standard      | true                          |

  @route-delete @MediumPriority
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
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_TRANSACTION_ID}   |
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

  @route-delete @MediumPriority
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
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_TRANSACTION_ID}   |
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

  @route-delete @MediumPriority
  Scenario: Operator Not Allowed to Delete Driver Route With Order Status = On Vehicle for Delivery
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                                                                                     |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    Then API Core - Verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | status         | TRANSIT                               |
      | granularStatus | ON_VEHICLE_FOR_DELIVERY               |
    When Operator delete driver route with status code 500
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | seqNo    | not null                                                   |
      | status   | Routed                                                     |

  @route-delete @MediumPriority
  Scenario: Operator Not Allowed to Delete Driver Route With Order Status = Completed
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                                                                                     |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    Then API Core - Verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | status         | COMPLETED                             |
      | granularStatus | COMPLETED                             |
    When Operator delete driver route with status code 500
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | seqNo    | not null                                                   |
      | status   | Success                                                    |

  @route-delete @MediumPriority
  Scenario: Operator Not Allowed to Delete Driver Route With Order Status = Success
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                                                                                     |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    Then API Core - Verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | status         | COMPLETED                             |
      | granularStatus | COMPLETED                             |
    When Operator delete driver route with status code 500
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | seqNo    | not null                                                   |
      | status   | Success                                                    |

  @route-delete @MediumPriority
  Scenario: Operator Not Allowed to Delete Driver Route With Order Status = Returned to Sender
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator rts order:
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                              |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator force success order "{KEY_LIST_OF_CREATED_ORDERS[1].id}" with cod collected "false"
    Then API Core - Verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | status         | COMPLETED                             |
      | granularStatus | RETURNED_TO_SENDER                    |
    When Operator delete driver route with status code 500
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | seqNo    | not null                                                   |
      | status   | Success                                                    |