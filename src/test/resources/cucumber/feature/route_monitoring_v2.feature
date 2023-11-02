@ForceSuccessOrder  @ArchiveDriverRoutes @route-monitoring-v2
Feature: Route Monitoring V2

  @rmv2-empty-route
  Scenario Outline: Operator Create Empty Route And Verifies Route Monitoring Data
    Given Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details
      | KEY_TOTAL_EXPECTED_VALID_FAILED | 0 |
    Examples:
      | Note | hiptest-uid                              |
      |      | uid:c7b7310d-2693-48ef-8245-789af66b802d |

  @rmv2-add-to-route @rmv2-pull-out-of-route
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
      | Note     | hiptest-uid                              | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:d2431020-3dcd-4c18-89f9-d30d4a58b6ef | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | uid:15d6dd67-f31c-4cf1-b192-b2759c0089a3 | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route
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
      | Note     | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:3b79de68-7155-43a5-bf99-6e10fed09789 | PP         | Return       | Standard      | true                          |
      | Delivery | uid:4c58d0dc-cdc4-4396-a352-b02405a84672 | DD         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route @rmv2-pull-out-of-route
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
      | Note | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:8d3d3129-cdb3-447b-b0a0-47732f32d05a | PP         | Parcel       | Standard      | true                          |

  @rmv2-add-to-route
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
      | Note | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:a2fb0a53-0443-4f1c-8eb7-400247271488 | PP         | Parcel       | Standard      | true                          |

  @rmv2-add-to-route @rmv2-pull-out-of-route
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
      | Note     | hiptest-uid                              | route_type | transaction_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:c0c80479-c1a0-4354-beac-2f7027dd68c3 | PP         | PICKUP           | Return       | Standard      | true                          |
      | Delivery | uid:a0d8285a-b8f9-44c7-8fa5-a8ec42f71e43 | DD         | DELIVERY         | Parcel       | Standard      | false                         |

  @rmv2-add-to-route @rmv2-pull-out-of-route @happy-path @HighPriority
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Multiple Waypoints - Mix of PP, DD, & Reservation
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

    Examples:
      | Note | hiptest-uid                              |
      |      | uid:75ac2e9a-7cf0-4704-94a4-eb4257fbbec1 |

  @rmv2-pending-priority-parcels
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
      | Note     | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      | Pickup   | uid:d5aae6ab-c47c-4b31-9809-4516544a6eea | PP         | Return       | Standard      | true                          |
      | Delivery | uid:e8e138af-e86e-450c-beaa-b79d83c31d52 | DD         | Parcel       | Standard      | false                         |

  @rmv2-pending-priority-parcels
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
      | Note    | hiptest-uid                              | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Failed  | uid:fc3071a6-109e-483d-a658-e2d7ea215f80 | FAIL    | Parcel       | Standard      | false                         |
      | Success | uid:88c82f11-db09-493b-acb5-a93d87dbb23f | SUCCESS | Parcel       | Standard      | false                         |

  @rmv2-pending-priority-parcels
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
      | Note    | hiptest-uid                              | action  | service_type | service_level | parcel_job_is_pickup_required |
      | Failed  | uid:7bb5bc99-d1bd-4385-8ec0-e2d3ca34085a | FAIL    | Return       | Standard      | true                          |
      | Success | uid:93ba3047-3e8e-4591-aa63-be7cbdcf5ecc | SUCCESS | Return       | Standard      | true                          |

  @rmv2-pending-priority-parcels
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
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:ee4c2d09-e6ed-4ba9-996c-6fa1036e71ce | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries
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
      | Note | hiptest-uid                              | action | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:0a866bb1-4faa-4bc7-88ed-0f6e6c167b04 | FAIL   | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries
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
      | Note | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:c48d6ef8-f5e8-49fb-9eef-d92744829d9a | DD         | Parcel       | Standard      | false                         |


  @rmv2-invalid-failed-deliveries
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
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:ef58d1f6-0fc8-452d-9fb8-4e218322ec77 | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-deliveries
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
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:9eb23b81-043d-4581-8e9e-add8d7a7f99d | Parcel       | Standard      | false                         |

  @rmv2-invalid-failed-pickups
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
      | Note | hiptest-uid                              | action | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:84c25fc3-2f5b-4282-a9a6-717eb80fe0f9 | FAIL   | Return       | Standard      | true                          |

  @rmv2-invalid-failed-pickups
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
      | Note | hiptest-uid                              | route_type | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:7690b4b1-d616-474a-a51e-2cfc8a67a966 | PP         | Return       | Standard      | true                          |


  @rmv2-invalid-failed-pickups
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
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:e140c322-853a-494b-b6b6-c8dfbff5ea0a | Return       | Standard      | true                          |

  @rmv2-invalid-failed-pickups
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
      | Note | hiptest-uid                              | service_type | service_level | parcel_job_is_pickup_required |
      |      | uid:ac3dc935-5c7b-43df-b7ca-ee21607e2b7d | Return       | Standard      | true                          |


  @rmv2-invalid-failed-reservations
  Scenario Outline: Operator Get Invalid Failed Reservation Details After Driver Failed with Invalid Reason
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

    Examples:
      | Note | hiptest-uid                              |
      |      | uid:cc1bca2d-177b-4bc3-ade5-8965a899a706 |


  @rmv2-invalid-failed-reservations
  Scenario Outline: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Failed Reservation with Valid Reason)
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

    Examples:
      | Note | hiptest-uid                              |
      |      | uid:8e12f8da-bd52-4760-b05c-6d8d610b6a51 |


  @rmv2-invalid-failed-reservations
  Scenario Outline: Operator Get Invalid Failed Reservation Details on Route with NON-Invalid Failed Reservation (Pending Reservation)
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

    Examples:
      | Note | hiptest-uid                              |
      |      | uid:1609ead7-b2d6-4475-951f-db6eebcb32e3 |
