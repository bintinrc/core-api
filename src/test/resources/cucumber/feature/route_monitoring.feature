@ForceSuccessOrder @route-monitoring
Feature: Route Minitoring

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Single Waypoint - Transaction - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 1 |

    Examples:
      | Note      | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Pickup    | uid:d2431020-3dcd-4c18-89f9-d30d4a58b6ef |PP         | Return       | Standard      |true                         |
      | Delivery  | uid:15d6dd67-f31c-4cf1-b192-b2759c0089a3 |DD         | Parcel       | Standard      |false                        |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Single Waypoint - Multiple Merged Transactions - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
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
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 1 |

    Examples:
      | Note      | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Pickup    | uid:3b79de68-7155-43a5-bf99-6e10fed09789 |PP         | Return       | Standard      |true                         |
      | Delivery  | uid:4c58d0dc-cdc4-4396-a352-b02405a84672 |DD         | Parcel       | Standard      |false                        |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Single Waypoint - Single Reservation <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 1 |

    Examples:
      | Note  | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      |       | uid:8d3d3129-cdb3-447b-b0a0-47732f32d05a |PP         | Parcel       | Standard      |true                         |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Multiple Waypoints - Multiple Reservations <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
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
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 2 |

    Examples:
      | Note           | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      |                | uid:a2fb0a53-0443-4f1c-8eb7-400247271488 |PP         | Parcel       | Standard      |true                         |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Multiple Waypoints - Multiple Transactions - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
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
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 2 |
    When Operator pull order out of "<transaction_type>" route
    And Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 1 |

    Examples:
      | Note                              | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Pickup                            | uid:c0c80479-c1a0-4354-beac-2f7027dd68c3 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Delivery                          | uid:a0d8285a-b8f9-44c7-8fa5-a8ec42f71e43 |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Multiple Waypoints - Mix of PP, DD, & Reservation - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | true                            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
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
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 5 |
    When Operator pull order out of "PICKUP" route
    And Operator Filter Route Monitoring Data for Today's Date
    And Operator verifies Route Monitoring Data has correct total parcels count
      |total-expected-waypoints     | 4 |

    Examples:
      | Note                         | hiptest-uid                              |
      |                              | uid:75ac2e9a-7cf0-4704-94a4-eb4257fbbec1 |
