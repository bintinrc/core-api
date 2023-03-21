@ForceSuccessOrder @DeleteReservationAndAddress @routing @route-delete
Feature: Delete Route

  @route-delete @routing-refactor @happy-path
  Scenario Outline: Operator Delete Driver Route Successfully - Single Pending Transaction - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator add order to driver "<route_type>" route
    When Operator delete driver route with status code 200
    Then DB Operator verifies soft-deleted route
    And Operator search for "<transaction_type>" transaction with status "PENDING"
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | ZONAL_ROUTING_REMOVE   |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | hiptest-uid                              | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:a9e166f2-0ca5-4aaf-baae-0593ba83dc00 | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | uid:c5e68f1d-09f8-4d9e-8632-8b9a5bd9d572 | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor @happy-path
  Scenario Outline: Operator Delete Driver Route Successfully - Single Pending Reservation
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator Route the Reservation Pickup
    When Operator delete driver route with status code 200
    And DB Operator verifies soft-deleted route
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL



    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verifies shipper_pickups_search data updated correctly
      | status          | PENDING |
      | waypoint_status | Pending |
      | route_id        | 0       |
      | driver_id       | 0       |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:5cf6b734-73e3-4689-b052-b04dc3fd467c | Parcel       | Standard      | true                          |

  @route-delete @routing-refactor
  Scenario Outline: Operator Delete Driver Route Successfully - Merged Pending Waypoint - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator search for all created orders
    And Operator add order by tracking id to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order by tracking id to driver "<route_type>" route
    And Operator search for all created orders
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    When Operator delete driver route with status code 200
    Then DB Operator verifies soft-deleted route
    And Operator search for multiple "<transaction_type>" transactions with status "PENDING"
    And DB Operator verifies all transactions route id is null
    And DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies all route_monitoring_data is hard-deleted
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | ZONAL_ROUTING_REMOVE   |
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | hiptest-uid                              | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:6512cf1c-ae48-408f-9815-444cc6357935 | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | uid:e806f2f4-a939-4e3d-89f0-0363d439880e | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @route-delete @routing-refactor
  Scenario Outline: Operator Delete Driver Route Successfully - Single Empty Route
    When API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When Operator delete driver route with status code 200
    Then DB Operator verifies soft-deleted route


    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note | hiptest-uid                              |
      |      | uid:24bdb220-fac4-4791-81d1-65ce3bcf2061 |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Multiple Routes
    When Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator delete multiple driver routes
    Then DB Operator verifies multiple routes are soft-deleted
    When Driver id "{driver-id}" authenticated to login with username "{driver-username}" and password "{driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note | hiptest-uid                              |
      |      | uid:991188e0-9c44-421b-b549-5b37d1f386af |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Reservation - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{shipper-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |

    And Operator Route the Reservation Pickup
    And Operator admin manifest force "<action>" reservation
    Then Operator delete driver route with status code 500
    And Operator verify delete route response with proper error message : "Reservation $reservation_id for Shipper $shipper_id has status <action>. Cannot delete route."
    And DB Operator verifies waypoint status is "<action>"

    Examples:
      | Note    | hiptest-uid                              | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Success | uid:35a3e49a-435a-47ed-92dd-410ada4fad34 | Success | Parcel       | Standard      | true                          |
      | Fail    | uid:540916c7-68d9-4692-85b3-0097f460cc88 | Fail    | Parcel       | Standard      | true                          |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Delivery Transaction - <Note>
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
    And Operator verify delete route response with proper error message : "Delivery for Order $order_id has already been attempted. Cannot delete route."
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "<terminal_state>"

    Examples:
      | Note    | hiptest-uid                              | terminal_state | service_type | service_level | parcel_job_is_pickup_required |
      | Success | uid:adeef437-d902-453a-8da1-e6962f9454a2 | SUCCESS        | Parcel       | Standard      | false                         |
      | Fail    | uid:8dc735c2-de57-4caf-b0f6-e407cc287753 | FAIL           | Parcel       | Standard      | false                         |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Pickup Transaction - <Note>
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
    Then Operator verify delete route response with proper error message : "Pickup for Order $order_id has already been attempted. Cannot delete route."
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "<terminal_state>"

    Examples:
      | Note    | hiptest-uid                              | terminal_state | service_type | service_level | parcel_job_is_pickup_required |
      | Success | uid:94d33396-3638-4e91-bb8b-92be0adc9bfc | SUCCESS        | Return       | Standard      | true                          |
      | Fail    | uid:bdd977cd-adec-4e56-9604-7fb178c66e64 | FAIL           | Return       | Standard      | true                          |