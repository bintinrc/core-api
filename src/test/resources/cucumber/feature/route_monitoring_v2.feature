@ForceSuccessOrders  @ArchiveDriverRoutes @route-monitoring-v2
Feature: Route Monitoring V2

  @rmv2-empty-route @HighPriority
  Scenario: Operator Create Empty Route And Verifies Route Monitoring Data
    Given Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
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
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data Has Correct Details for "Pending" Case
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    When Operator Pull Reservation Out of Route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 0 |

    Examples:
      | Note | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | PP         | Parcel       | Standard      | true                          |

  @rmv2-add-to-route @HighPriority
  Scenario Outline: Operator Add to Route And Verifies Route Monitoring Data - Multiple Waypoints - Multiple Reservations <Note>
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Route the Reservation Pickup
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator Route the Reservation Pickup
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
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
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "<action>" Parcel "DELIVERY"
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "PP" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT         | 1 |
      | KEY_TOTAL_EXPECTED_PENDING_PRIORITY | 1 |
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "<action>" Parcel "PICKUP"
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create order with parameters below
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create order with parameters below
      | service_type                  | <service_type>  |
      | service_level                 | <service_level> |
      | parcel_job_is_pickup_required | true            |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
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
    When Shipper creates multiple orders : 3 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "<action>" "DELIVERY" for All Orders
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 3 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 3 |
      | KEY_TOTAL_EXPECTED_EARLY          | 3 |
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "FAIL" "DELIVERY" for All Orders
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver Fails Parcel "DELIVERY" with Valid Reason
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    When Shipper create order with parameters below
      | service_type                  | <service_type>  |
      | service_level                 | <service_level> |
      | parcel_job_is_pickup_required | true            |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator get empty invalid failed deliveries parcel details

    Examples:
      | Note | service_type | service_level | parcel_job_is_pickup_required |
      |      | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-pickups @HighPriority
  Scenario Outline: Operator Get Invalid Failed Pickup Details After Driver Failed with Invalid Reason - Order with No Tags
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple orders : 3 orders
      | service_type                  | <service_type>                  |
      | service_level                 | <service_level>                 |
      | requested_tracking_number     | <requested_tracking_number>     |
      | parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "<action>" "PICKUP" for All Orders
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 3 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 3 |
      | KEY_TOTAL_EXPECTED_EARLY          | 3 |
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "<route_type>" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "FAIL" "PICKUP" for All Orders
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for created order
    And Operator add order to driver "PP" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver Fails Parcel "PICKUP" with Valid Reason
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
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
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for created order
    And Operator add order to driver "PP" route
    When Shipper create order with parameters below
      | service_type                  | Parcel          |
      | service_level                 | <service_level> |
      | parcel_job_is_pickup_required | true            |
    And Operator Search for Created Pickup for Shipper "{shipper-2-legacy-id}" with status "Pending"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 2 |
    And Operator get empty invalid failed pickup parcel details

    Examples:
      | service_type | service_level | parcel_job_is_pickup_required |
      | Return       | Standard      | true                          |


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details After Driver Failed with Invalid Reason
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates multiple 3 reservations
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for all reservations for shipper legacy id {shipper-2-legacy-id}
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route All Reservation Pickups
    And Operator admin manifest force fail all reservations with invalid reason
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Invalid Failed Waypoints
      | KEY_TOTAL_EXPECTED_WAYPOINT       | 3 |
      | KEY_TOTAL_EXPECTED_INVALID_FAILED | 3 |
      | KEY_TOTAL_EXPECTED_EARLY          | 0 |
    When Operator get invalid failed reservation details
    Then Operator verifies invalid failed reservations details


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Failed Reservation with Valid Reason)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates a reservation
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for all reservations for shipper legacy id {shipper-2-legacy-id}
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route All Reservation Pickups
    And Operator admin manifest force fail reservation with valid reason
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT     | 1 |
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 1 |
      | KEY_TOTAL_EXPECTED_EARLY        | 0 |
    And Operator get empty invalid failed reservation details


  @rmv2-invalid-failed-reservations @HighPriority
  Scenario: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Pending Reservation)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    When Shipper creates a reservation
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for all reservations for shipper legacy id {shipper-2-legacy-id}
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route All Reservation Pickups
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total invalid failed is 0 and other details
      | KEY_TOTAL_EXPECTED_WAYPOINT | 1 |
    And Operator get empty invalid failed reservation details
