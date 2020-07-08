@ForceSuccessOrder @routing
Feature: Routing

  @add-parcel-to-route
  Scenario Outline: Operator Add Parcel to Driver Route - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
    |service_type                  | <service_type>                  |
    |service_level                 | <service_level>                 |
    |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route

    Examples:
      | Note     | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Pickup   | uid:cb335201-b86a-4373-ac57-de37c724c6e1 |PP         | Return       | Standard      |true                         |
      | Delivery | uid:ad5982ad-1289-4255-95e3-707890c0b533 |DD         | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Operator delete driver route
    Then DB Operator verifies soft-deleted route
    And Operator search for "<transaction_type>" transaction with status "PENDING"
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies route_waypoint is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Single Pending Waypoint - Pickup   | uid:643fba31-d471-44a9-91a4-81a68225b1e5 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Single Pending Waypoint - Delivery | uid:fe9f9c79-b9ed-4b86-ac12-c94a035723ad |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    When Operator delete driver route
    And DB Operator verifies soft-deleted route
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies route_waypoint is hard-deleted
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note                                   | hiptest-uid                              | service_type | service_level |parcel_job_is_pickup_required|
      | Single Pending Waypoint - Reservation  | uid:9ad5b19f-70ed-4b9d-ae0a-d852ce2db557 | Parcel       | Standard      |true                         |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Shipper create another order with the same parameters as before
    And Operator add order to driver "<route_type>" route
    And Operator merge transaction waypoints
    When Operator delete driver route
    Then DB Operator verifies soft-deleted route
    And Operator search for multiple "<transaction_type>" transactions with status "PENDING"
    And DB Operator verifies all transactions route id is null
    And DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all route_waypoint route id is hard-deleted
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Merged Pending Waypoint - Pickup   | uid:b6d4c0a7-426b-48fe-9fee-beaf7af6fe72 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Merged Pending Waypoint - Delivery | uid:2cd68cce-b8f2-4fec-861f-dfdff8f00db3 |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - <Note> - <hiptest-uid>
    When Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator delete driver route
    Then DB Operator verifies soft-deleted route
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |
      | Single Empty Route                 | uid:5ad46eb9-e371-49f4-b8b7-b3655ea577ae |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - <Note> - <hiptest-uid>
    When Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator delete multiple driver routes
    Then DB Operator verifies multiple routes are soft-deleted
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |
      | Multiple Routes                    | uid:a0b4a7f3-2994-4751-ac10-6f2d2d915c3a |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Route the Reservation Pickup
    And Operator force finish "<action>" reservation
    Then Operator delete driver route with status code "500"
    And DB Operator verifies waypoint status is "<action>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note                                   | hiptest-uid                              |action | service_type | service_level |parcel_job_is_pickup_required|
      | Success Waypoint - Reservation         | uid:de50fc99-3509-48f1-8326-15608b145106 |Success| Parcel       | Standard      |true                         |
      | Fail Waypoint - Reservation            | uid:6d5f538f-b302-482c-9030-60ded5245d92 |Fail   | Parcel       | Standard      |true                         |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    And Operator force "<terminal_state>" "DELIVERY" waypoint
    And Operator search for "DELIVERY" transaction with status "<terminal_state>"
    When Operator delete driver route with status code "500"
    Then DB Operator verifies transaction remains routed to previous route id
    And DB Operator verifies waypoint status is "<terminal_state>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note                               | hiptest-uid                              |terminal_state  | service_type | service_level |parcel_job_is_pickup_required|
      | Success Transaction - Delivery     | uid:83a33e13-1f1a-468e-823d-a3d9c292fb92 |SUCCESS         | Parcel       | Standard      |false                        |
      | Failed Transaction - Delivery      | uid:358117ad-8d9c-4e31-be8a-ace6f1e94a83 |FAIL            | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "PP" route
    And Operator force "<terminal_state>" "PICKUP" waypoint
    And Operator search for "PICKUP" transaction with status "<terminal_state>"
    When Operator delete driver route with status code "500"
    Then DB Operator verifies transaction remains routed to previous route id
    And DB Operator verifies waypoint status is "<terminal_state>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note                               | hiptest-uid                              |terminal_state  | service_type | service_level |parcel_job_is_pickup_required|
      | Success Transaction - Pickup       | uid:6310a1f2-1456-4c28-bc46-aae200f25944 |SUCCESS         | Return       | Standard      |true                         |
      | Failed Transaction - Pickup        | uid:db126ed5-ea58-4ee2-952d-442c0abe3e66 |FAIL            | Return       | Standard      |true                         |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Single Route,  Status = Pending    | uid:8bd86dcd-3c26-43a2-b00f-9d2aa8fa28e2 |DD         | Parcel       | Standard      |false                        |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    And Driver Starts the route
    When Operator archives driver route
    Then DB Operator verifies route status is archived
    And Archived route is not shown on his list routes
    Examples:
      | Note                                | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Single Route,  Status = In Progress | uid:5fd8e9e9-00ff-4449-87b3-ce09b833bcb9 |DD         | Parcel       | Standard      |false                        |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes
    When Operator archives driver the same archived route
    Then DB Operator verifies route status is archived
    Examples:
      | Note                               | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Single Route,  Status = Archived   | uid:ac3db78f-0c3f-430f-b759-c3bf536ed65e |DD         | Parcel       | Standard      |false                        |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |
      | Single Empty Route                 | uid:b298f901-c556-4fb0-a422-ec443a7b773e |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And  Operator archives multiple driver routes
    Then DB Operator verifies multiple routes status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes
    Examples:
      | Note                               | hiptest-uid                              |
      | Multiple Routes                    | uid:2a61338e-97bd-497f-b4cd-e7e56f37c444 |

  @route-archive
  Scenario Outline: Operator Archive Driver Invalid Route Id - <Note> - <hiptest-uid>
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | <service_type>                  |
      |service_level                 | <service_level>                 |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | <parcel_job_is_pickup_required> |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "<route_type>" route
    When Operator delete driver route
    And Operator archives invalid driver route
    Examples:
      | Note             | hiptest-uid                              |route_type | service_type | service_level |parcel_job_is_pickup_required|
      | Deleted Route    | uid:e21699bb-df37-447f-a85c-3ac552ec05f3 |DD         | Parcel       | Standard      |false                        |

  @route-archive
  Scenario Outline: Operator Archive Driver Route Successfully - <Note> - <hiptest-uid>
    Given Operator archives invalid driver route
    Examples:
      | Note             | hiptest-uid                              |
      | Route Not Found  | uid:5b94cc8c-2a21-43d9-beb0-7bd00b2e2ef1 |
