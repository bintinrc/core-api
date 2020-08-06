@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @route-monitoring-v2
Feature: Route Monitoring V2

  @rmv2-empty-route
  Scenario Outline: Operator Create Empty Route And Verifies Route Monitoring Data - <Note> - <hiptest-uid>
    Given Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details

    Examples:
      | Note      | hiptest-uid                              |
      |           | uid:c7b7310d-2693-48ef-8245-789af66b802d |

  @rmv2-add-to-route @rmv2-pull-out-of-route
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Single Waypoint - Transaction - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 1 |
    And Operator verifies waypoint details for pending case
    When Operator pull order out of "<transaction_type>" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details

    Examples:
      | Note      | hiptest-uid                              |route_type |transaction_type |service_type | service_level |parcel_job_is_pickup_required|
      | Pickup    | uid:d2431020-3dcd-4c18-89f9-d30d4a58b6ef |PP         |PICKUP           |Return       | Standard      |true                         |
      | Delivery  | uid:15d6dd67-f31c-4cf1-b192-b2759c0089a3 |DD         |DELIVERY         |Parcel       | Standard      |false                        |

  @rmv2-add-to-route
  Scenario Outline: Operator Add to Route And Verifies Route Monitoring Data - Single Waypoint - Multiple Merged Transactions - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order to driver "<route_type>" route
    And Operator merge transaction waypoints
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 1 |
    And Operator verifies waypoint details for pending case

    Examples:
      | Note      | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Pickup    | uid:3b79de68-7155-43a5-bf99-6e10fed09789 |PP         | Return       | Standard      |true                         |
      | Delivery  | uid:4c58d0dc-cdc4-4396-a352-b02405a84672 |DD         | Parcel       | Standard      |false                        |

  @rmv2-add-to-route @rmv2-pull-out-of-route
  Scenario Outline: Operator Add to Route & Pull Out of Route And Verifies Route Monitoring Data - Single Waypoint - Single Reservation <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 1 |
    And Operator verifies waypoint details for pending case
    When Operator Pull Reservation Out of Route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data for Empty Route has correct details

    Examples:
      | Note  | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      |       | uid:8d3d3129-cdb3-447b-b0a0-47732f32d05a |PP         | Parcel       | Standard      |true                         |

  @rmv2-add-to-route
  Scenario Outline: Operator Add to Route And Verifies Route Monitoring Data - Multiple Waypoints - Multiple Reservations <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Route the Reservation Pickup
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 2 |
    And Operator verifies waypoint details for pending case

    Examples:
      | Note           | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      |                | uid:a2fb0a53-0443-4f1c-8eb7-400247271488 |PP         | Parcel       | Standard      |true                         |

  @rmv2-add-to-route @rmv2-pull-out-of-route
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Multiple Waypoints - Multiple Transactions - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator add order to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 2 |
    And Operator verifies waypoint details for pending case
    When Operator pull order out of "<transaction_type>" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 1 |
    And Operator verifies waypoint details for pending case

    Examples:
      | Note                              | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Pickup                            | uid:c0c80479-c1a0-4354-beac-2f7027dd68c3 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Delivery                          | uid:a0d8285a-b8f9-44c7-8fa5-a8ec42f71e43 |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @rmv2-add-to-route @rmv2-pull-out-of-route
  Scenario Outline: Operator Add to Route & Pull Out Of Route And Verifies Route Monitoring Data - Multiple Waypoints - Mix of PP, DD, & Reservation - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | true                            |
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | false                           |
    And Operator add order to driver "DD" route
    When Shipper create another order with the same parameters as before
    And Operator add order to driver "DD" route
    And Operator merge transaction waypoints
    When Shipper create order with parameters below
      |service_type                  | Return                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | true                            |
    And Operator add order to driver "PP" route
    When Shipper create another order with the same parameters as before
    And Operator add order to driver "PP" route
    And Operator merge transaction waypoints
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | false                           |
    And Operator add order to driver "DD" route
    When Shipper create order with parameters below
      |service_type                  | Return                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | true                            |
    And Operator add order to driver "PP" route
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 5 |
    And Operator verifies waypoint details for pending case
    When Operator pull order out of "PICKUP" route
    And Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies Route Monitoring Data Has Correct Details for Pending Case
      |total-expected-waypoints     | 4 |

    Examples:
      | Note                         | hiptest-uid                              |
      |                              | uid:75ac2e9a-7cf0-4704-94a4-eb4257fbbec1 |

  @rmv2-pending-priority-parcels
  Scenario Outline: Operator Tag Routed Orders as PRIOR Parcels And Verifies Route Monitoring Data - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper creates multiple orders :"3" orders
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags all orders with PRIOR tag
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      |total-expected-waypoints                 | 3 |
      |total-expected-pending-priority-parcels  | 3 |
    And Operator get pending priority parcel details for "<route_type>"
    And Operator verifies pending priority parcel details

    Examples:
      | Note      | hiptest-uid                              |route_type |service_type | service_level |parcel_job_is_pickup_required|
      | Pickup    | uid:d5aae6ab-c47c-4b31-9809-4516544a6eea |PP         |Return       | Standard      |true                         |
      | Delivery  | uid:e8e138af-e86e-450c-beaa-b79d83c31d52 |DD         |Parcel       | Standard      |false                        |

  @rmv2-pending-priority-parcels
  Scenario Outline: Exclude Attempted PRIOR Parcel as Pending Priority On Route Monitoring - Delivery - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags order with PRIOR tag
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      |total-expected-waypoints                 | 1 |
      |total-expected-pending-priority-parcels  | 1 |
    When Driver authenticated to login with username "{route-monitoring-driver-username}" and password "{route-monitoring-driver-password}"
    And Driver Starts the route
    And Driver "<action>" Parcel "DELIVERY"
    Then Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total pending priority parcels is now 0
    And Operator get empty pending priority parcel details for "dd"

    Examples:
      | Note      | hiptest-uid                              |action    |service_type | service_level |parcel_job_is_pickup_required|
      | Failed    | uid:fc3071a6-109e-483d-a658-e2d7ea215f80 |FAIL      |Parcel       | Standard      |false                        |
      | Success   | uid:88c82f11-db09-493b-acb5-a93d87dbb23f |SUCCESS   |Parcel       | Standard      |false                        |
    
  @rmv2-pending-priority-parcels
  Scenario Outline: Exclude Attempted PRIOR Parcel as Pending Priority On Route Monitoring - Pickup - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags order with PRIOR tag
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "PP" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      |total-expected-waypoints                 | 1 |
      |total-expected-pending-priority-parcels  | 1 |
    When Driver authenticated to login with username "{route-monitoring-driver-username}" and password "{route-monitoring-driver-password}"
    And Driver Starts the route
    And Driver "<action>" Parcel "PICKUP"
    When Operator Filter Route Monitoring Data for Today's Date
    Then Operator verifies total pending priority parcels is now 0
    And Operator get empty pending priority parcel details for "pp"

    Examples:
      | Note      | hiptest-uid                              |action    |service_type | service_level |parcel_job_is_pickup_required|
      | Failed    | uid:7bb5bc99-d1bd-4385-8ec0-e2d3ca34085a |FAIL      |Return       | Standard      |true                         |
      | Success   | uid:93ba3047-3e8e-4591-aa63-be7cbdcf5ecc |SUCCESS   |Return       | Standard      |true                         |

  @rmv2-pending-priority-parcels
  Scenario Outline: Operator Get Pending Priority Parcel Details Inside a Route with NON-PRIOR Waypoints (Reservation & Non-PRIOR Delivery) - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{route-monitoring-shipper-client-id}" and client secret "{route-monitoring-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator tags order with PRIOR tag
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator add order to driver "DD" route
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | true                            |
    And Operator Search for Created Pickup for Shipper "{route-monitoring-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies total pending priority parcels and other details
      |total-expected-waypoints                 | 3 |
      |total-expected-pending-priority-parcels  | 1 |
    And Operator get pending priority parcel details for "DD"
    And Operator verifies pending priority parcel details

    Examples:
      | Note      | hiptest-uid                              | service_type | service_level |parcel_job_is_pickup_required|
      |           | uid:ee4c2d09-e6ed-4ba9-996c-6fa1036e71ce | Parcel       | Standard      |false                        |

