@ForceSuccessOrders @CancelCreatedReservations @ArchiveDriverRoutes @route-monitoring-v2
Feature: Route Monitoring V2

  @rmv2-empty-route @HighPriority
  Scenario: Operator Create Empty Route And Verifies Route Monitoring Data
    Given Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 0 |

  @rmv2-add-to-route @rmv2-pull-out-of-route @HighPriority
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Single Waypoint - Transaction - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for created order
    And Operator add order to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    When Operator pull order out of "<transaction_type>" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 0 |

    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route @HighPriority
  Scenario Outline: Operator Add to Route And Verifies Route Monitoring Data - Single Waypoint - Multiple Merged Transactions - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    When Shipper create another order with the same parameters as before
    When Shipper create another order with the same parameters as before
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |

    Examples:
      | Note     | route_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | Return       | Standard      | true                          |
      | Delivery | DD         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route @rmv2-pull-out-of-route @HighPriority
  Scenario Outline: Operator Add to Route & Pull Out of Route And Verifies Route Monitoring Data - Single Waypoint - Single Reservation <Note>
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    And API Core - Operator remove reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" from route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 0 |

    Examples:
      | Note | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | PP         | Parcel       | Standard      | true                          |

  @rmv2-add-to-route @HighPriority
  Scenario Outline: Operator Add to Route And Verifies Route Monitoring Data - Multiple Waypoints - Multiple Reservations <Note>
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[2].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |

    Examples:
      | Note | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | PP         | Parcel       | Standard      | true                          |

  @rmv2-add-to-route @rmv2-pull-out-of-route @HighPriority
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Multiple Waypoints - Multiple Transactions - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for all created orders
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add all orders to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    When Operator pull order out of "<transaction_type>" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |

    Examples:
      | Note     | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route @rmv2-pull-out-of-route @happy-path @HighPriority
  Scenario: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Multiple Waypoints - Mix of PP, DD, & Reservation
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create another order with the same parameters as before
    And Operator add order by tracking id to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator add order by tracking id to driver "PP" route
    When Shipper create another order with the same parameters as before
    And Operator add order by tracking id to driver "PP" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator add order by tracking id to driver "PP" route
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 5 |
    When Operator pull order out of "PICKUP" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 4 |


  @rmv2-pending-priority-parcels @HighPriority
  Scenario Outline: Operator Tag Routed Orders as PRIOR Parcels And Verifies Route Monitoring Data - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 3 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags all orders with PRIOR tag
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 3 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 3 |
    And Operator verifies Route Monitoring Data Has Correct Details for "pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 3 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 3 |
    And Operator get pending priority parcel details for "<route_type>"
    And Operator verifies pending priority parcel details

    Examples:
      | Note     | route_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | PP         | Return       | Standard      | true                          |
      | Delivery | DD         | Parcel       | Standard      | false                         |

  @rmv2-pending-priority-parcels @HighPriority
  Scenario Outline: Exclude Attempted PRIOR Parcel as Pending Priority On Route Monitoring - Delivery - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator tags order with PRIOR tag
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add order to driver "DD" route
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "<action>" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total pending priority parcels is now 0
    And Operator get empty pending priority parcel details for "dd"

    Examples:
      | Note    | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Failed  | FAIL    | Parcel       | Standard      | false                         |
      | Success | SUCCESS | Parcel       | Standard      | false                         |

  @rmv2-pending-priority-parcels @HighPriority
  Scenario Outline: Exclude Attempted PRIOR Parcel as Pending Priority On Route Monitoring - Pickup - <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator tags order with PRIOR tag
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add order to driver "PP" route
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "<action>" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId} |
      | driverId   | {driver-2-id}                                              |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total pending priority parcels is now 0
    And Operator get empty pending priority parcel details for "pp"

    Examples:
      | Note    | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Failed  | FAIL    | Return       | Standard      | true                          |
      | Success | SUCCESS | Return       | Standard      | true                          |

  @rmv2-pending-priority-parcels @HighPriority
  Scenario Outline: Operator Get Pending Priority Parcel Details Inside a Route with NON-PRIOR Waypoints (Reservation & Non-PRIOR Delivery)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags order with PRIOR tag
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator add order by tracking id to driver "DD" route
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 3 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 3 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    And Operator get pending priority parcel details for "DD"
    And Operator verifies pending priority parcel details

    Examples:
      | Note | service_type | service_level | parcel_job_is_pickup_required |
      |      | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries @HighPriority
  Scenario Outline: Operator Get Invalid Failed Deliveries Details After Driver Failed with Invalid Reason - Order with No Tags
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 2 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | failureReasonId | {delivery-failure-reason-id}                               |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | failureReasonId | {delivery-failure-reason-id}                               |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 2 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 2 |
      | KEY_TOTAL_EXPECTED_EARLY          | 2 |
    When Operator get "invalid failed deliveries" parcel details
    Then Operator verifies "invalid failed deliveries" parcel details

    Examples:
      | Note | action | service_type | service_level | parcel_job_is_pickup_required |
      |      | FAIL   | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries @HighPriority
  Scenario Outline: Operator Get Invalid Failed Deliveries Details After Driver Failed with Invalid Reason - Order Has PRIOR Tag
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 2 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator tags all orders with PRIOR tag
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | failureReasonId | {delivery-failure-reason-id}                               |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | failureReasonId | {delivery-failure-reason-id}                               |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 2 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 2 |
      | KEY_TOTAL_EXPECTED_EARLY          | 2 |
    When Operator get "invalid failed deliveries" parcel details
    Then Operator verifies "invalid failed deliveries" parcel details

    Examples:
      | Note | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | DD         | Parcel       | Standard      | false                         |


  @rmv2-invalid-failed-deliveries @HighPriority
  Scenario Outline: Operator Get Invalid Failed Deliveries Details on Route with NON-Invalid Failed Deliveries (Failed Delivery with Valid Reason)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add order by tracking id to driver "DD" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | failureReasonId | {delivery-valid-failure-reason-id}                         |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "invalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 1 |
    And Operator get empty invalid failed deliveries parcel details

    Examples:
      | Note | service_type | service_level | parcel_job_is_pickup_required |
      |      | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries @HighPriority
  Scenario Outline: Operator Get Invalid Failed Deliveries Details on Route with NON-Invalid Failed Deliveries (Pending Delivery & Reservation)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator add order by tracking id to driver "DD" route
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator verifies Route Monitoring Data Has Correct Details for "invalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator get empty invalid failed deliveries parcel details

    Examples:
      | Note | service_type | service_level | parcel_job_is_pickup_required |
      |      | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-pickups @HighPriority
  Scenario Outline: Operator Get Invalid Failed Pickup Details After Driver Failed with Invalid Reason - Order with No Tags
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 2 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId} |
      | failureReasonId | {pickup-failure-reason-id}                                 |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} |
      | failureReasonId | {pickup-failure-reason-id}                                 |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 2 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 2 |
      | KEY_TOTAL_EXPECTED_EARLY          | 2 |
    When Operator get "invalid failed pickups" parcel details
    Then Operator verifies "invalid failed pickups" parcel details

    Examples:
      | Note | action | service_type | service_level | parcel_job_is_pickup_required |
      |      | FAIL   | Return       | Standard      | true                          |

  @rmv2-invalid-failed-pickups @HighPriority
  Scenario Outline: Operator Get Invalid Failed Pickup Details After Driver Failed with Invalid Reason - Order Has PRIOR Tag
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 2 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags all orders with PRIOR tag
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId} |
      | failureReasonId | {pickup-failure-reason-id}                                 |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} |
      | failureReasonId | {pickup-failure-reason-id}                                 |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 2 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 2 |
      | KEY_TOTAL_EXPECTED_EARLY          | 2 |
    When Operator get "invalid failed pickups" parcel details
    Then Operator verifies "invalid failed pickups" parcel details

    Examples:
      | Note | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | PP         | Return       | Standard      | true                          |


  @rmv2-invalid-failed-pickups @HighPriority
  Scenario Outline: Operator Get Invalid Failed Pickup Details on Route with NON-Invalid Failed Pickup (Failed Pickup with Valid Reason)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for created order
    And Operator add order to driver "PP" route
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1] |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                                     |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId} |
      | failureReasonId | {pickup-valid-failure-reason-id}                           |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "invalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 1 |
    And Operator get empty invalid failed pickup parcel details

    Examples:
      | service_type | service_level | parcel_job_is_pickup_required |
      | Return       | Standard      | true                          |

  @rmv2-invalid-failed-pickups @HighPriority
  Scenario Outline: Operator Get Invalid Failed Pickup Details on Route with NON-Invalid Failed Pickup (Pending Return Pickup & Reservation)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And Operator search for created order
    And Operator add order to driver "PP" route
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator verifies Route Monitoring Data Has Correct Details for "invalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator get empty invalid failed pickup parcel details

    Examples:
      | service_type | service_level | parcel_job_is_pickup_required |
      | Return       | Standard      | true                          |


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details After Driver Failed with Invalid Reason
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}","pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{date: 1 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}","pickup_end_time":"{date: 1 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[2].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                           |
      | waypointId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | failureReasonId | {reservation-failure-reason-id}                  |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                           |
      | waypointId      | {KEY_LIST_OF_CREATED_RESERVATIONS[2].waypointId} |
      | failureReasonId | {reservation-failure-reason-id}                  |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 2 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 2 |
      | KEY_TOTAL_EXPECTED_EARLY          | 0 |
    When Operator get invalid failed reservation details
    Then Operator verifies invalid failed reservations details with address "{KEY_LIST_OF_CREATED_ADDRESSES[1].getFullSpaceSeparatedAddress}"


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Failed Reservation with Valid Reason)
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    And API Core - Operator force fail waypoint via route manifest:
      | routeId         | {KEY_CREATED_ROUTE_ID}                           |
      | waypointId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | failureReasonId | {reservation-valid-failure-reason-id}            |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 0 |
    And Operator verifies Route Monitoring Data Has Correct Details for "infalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 0 |
    And Operator get empty invalid failed reservation details


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Pending Reservation)
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}      |
      | hub_id     | {sorting-hub-id-2} |
      | vehicle_id | {vehicle-id}       |
      | zone_id    | {zone-id}          |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE.id}                   |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    And Operator verifies Route Monitoring Data Has Correct Details for "invalid-failed" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    And Operator get empty invalid failed reservation details
