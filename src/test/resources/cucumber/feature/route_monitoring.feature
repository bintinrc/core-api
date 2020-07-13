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
      | Pickup    | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         | Return       | Standard      |true                         |
      | Delivery  | uid:ad5982ad-1289-4255-95e3-707890c0b533 |DD         | Parcel       | Standard      |false                        |

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
      | Delivery  | uid:ad5982ad-1289-4255-95e3-707890c0b533 |DD         | Parcel       | Standard      |false                        |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Single Waypoint - Reservation <Note> - <hiptest-uid>
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
      |       | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         | Parcel       | Standard      |true                         |

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
      |                | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         | Parcel       | Standard      |true                         |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Multiple Waypoints - Transactions - <Note> - <hiptest-uid>
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
      | Pickup                            | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Delivery                          | uid:ad5982ad-1289-4255-95e3-707890c0b533 |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @total-parcels-count
  Scenario Outline: Operator Filter Route Monitoring Data And Checks Total Parcel for Each Route - Multiple Waypoints - Mix of PP, DD, & Reservation <Note> - <hiptest-uid>
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
      | Note                                                | hiptest-uid                              |
      | Mix of Multiple Pickups, Deliveries, & Reservation  | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |