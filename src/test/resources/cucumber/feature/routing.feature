@ForceSuccessOrder @DeleteReservationAndAddress @ArchiveDriverRoutes @routing
Feature: Routing

  @add-parcel-to-route
  Scenario Outline: Operator Add Parcel to Driver Route Successfully - <Note> - <hiptest-uid>
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
      | Pickup   | uid:d9266718-dcf6-4131-8d77-6e3f5d239173 |PP         | Return       | Standard      |true                         |
      | Delivery | uid:1917f9ef-8275-4dce-8f2d-500b4fa80930 |DD         | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Single Pending Transaction - <Note> - <hiptest-uid>
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
    When Operator delete driver route with status code "200"
    Then DB Operator verifies soft-deleted route
    And Operator search for "<transaction_type>" transaction with status "PENDING"
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies route_waypoint is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Pickup   | uid:a9e166f2-0ca5-4aaf-baae-0593ba83dc00 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Delivery | uid:c5e68f1d-09f8-4d9e-8632-8b9a5bd9d572 |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Single Pending Reservation <Note> - <hiptest-uid>
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
    When Operator delete driver route with status code "200"
    And DB Operator verifies soft-deleted route
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies route_waypoint is hard-deleted
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note  | hiptest-uid                              | service_type | service_level |parcel_job_is_pickup_required|
      |       | uid:5cf6b734-73e3-4689-b052-b04dc3fd467c | Parcel       | Standard      |true                         |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Merged Pending Waypoint - <Note> - <hiptest-uid>
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
    When Operator delete driver route with status code "200"
    Then DB Operator verifies soft-deleted route
    And Operator search for multiple "<transaction_type>" transactions with status "PENDING"
    And DB Operator verifies all transactions route id is null
    And DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all route_waypoint route id is hard-deleted
    And Operator checks that for all orders, "PULL_OUT_OF_ROUTE" event is published
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note     | hiptest-uid                              |route_type |transaction_type| service_type | service_level |parcel_job_is_pickup_required|
      | Pickup   | uid:6512cf1c-ae48-408f-9815-444cc6357935 |PP         |PICKUP          | Return       | Standard      |true                         |
      | Delivery | uid:e806f2f4-a939-4e3d-89f0-0363d439880e |DD         |DELIVERY        | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Single Empty Route <Note> - <hiptest-uid>
    When Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator delete driver route with status code "200"
    Then DB Operator verifies soft-deleted route
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Deleted route is not shown on his list routes
    Examples:
      | Note           | hiptest-uid                              |
      |                | uid:24bdb220-fac4-4791-81d1-65ce3bcf2061 |

  @route-delete
  Scenario Outline: Operator Delete Driver Route Successfully - Multiple Routes <Note> - <hiptest-uid>
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
      | Note               | hiptest-uid                              |
      |                    | uid:991188e0-9c44-421b-b549-5b37d1f386af |
  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Reservation - <Note> - <hiptest-uid>
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
    And Operator admin manifest force "<action>" reservation
    Then Operator delete driver route with status code "500"
    And Operator verify delete route response with proper error message : "Reservation $reservation_id for Shipper $shipper_id has status <action>. Cannot delete route."
    And DB Operator verifies waypoint status is "<action>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note            | hiptest-uid                              |action | service_type | service_level |parcel_job_is_pickup_required|
      | Success         | uid:35a3e49a-435a-47ed-92dd-410ada4fad34 |Success| Parcel       | Standard      |true                         |
      | Fail            | uid:540916c7-68d9-4692-85b3-0097f460cc88 |Fail   | Parcel       | Standard      |true                         |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Delivery Transaction - <Note> - <hiptest-uid>
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
    And Operator verify delete route response with proper error message : "Delivery for Order $order_id has already been attempted. Cannot delete route."
    Then DB Operator verifies transaction remains routed to previous route id
    And DB Operator verifies waypoint status is "<terminal_state>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note        | hiptest-uid                              |terminal_state  | service_type | service_level |parcel_job_is_pickup_required|
      | Success     | uid:adeef437-d902-453a-8da1-e6962f9454a2 |SUCCESS         | Parcel       | Standard      |false                        |
      | Failed      | uid:8dc735c2-de57-4caf-b0f6-e407cc287753 |FAIL            | Parcel       | Standard      |false                        |

  @route-delete
  Scenario Outline: Operator Not Allowed to Delete Driver Route With Attempted Pickup Transaction - <Note> - <hiptest-uid>
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
    Then Operator verify delete route response with proper error message : "Pickup for Order $order_id has already been attempted. Cannot delete route."
    Then DB Operator verifies transaction remains routed to previous route id
    And DB Operator verifies waypoint status is "<terminal_state>"
    And DB Operator verifies route_waypoint record remains exist
    Examples:
      | Note          | hiptest-uid                              |terminal_state  | service_type | service_level |parcel_job_is_pickup_required|
      | Success       | uid:94d33396-3638-4e91-bb8b-92be0adc9bfc |SUCCESS         | Return       | Standard      |true                         |
      | Failed        | uid:bdd977cd-adec-4e56-9604-7fb178c66e64 |FAIL            | Return       | Standard      |true                         |

  @route-archive @debug
  Scenario: Operator Archive Driver Route Successfully - Empty Route (uid:6274cf87-9e6d-4087-912c-937093311538)
    Given Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive @debug
  Scenario: Operator Archive Driver Route Successfully - Status = PENDING (uid:8a99328a-9070-4fe4-9a51-a40ff025975c)
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |requested_tracking_number     | <requested_tracking_number>     |
      |parcel_job_is_pickup_required | false                           |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    And Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes

  @route-archive @debug
  Scenario: Operator Archive Driver Route Successfully - Status = IN_PROGRESS (uid:33dfaebd-6ce1-4022-abc3-8c443db4e72e)
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | false                           |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    And Driver Starts the route
    When Operator archives driver route with status code 204
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    And Archived route is not shown on his list routes

  @route-archive @debug
  Scenario: Operator not Allowed to Archive an already Archived Route (uid:0d211076-23da-4e20-ba06-c41fc1b122e3)
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | false                           |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Driver authenticated to login with username "{routing-driver-username}" and password "{routing-driver-password}"
    Then Archived route is not shown on his list routes
    When Operator archives driver route with status code 400
    Then Operator verify archive route response with proper error message : Route "is already archived!"

  @route-archive @debug
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Deleted Route  (uid:10fd732f-6326-4e7d-9ad2-6ec0da9ef4e8)
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper create order with parameters below
      |service_type                  | Parcel                          |
      |service_level                 | Standard                        |
      |parcel_job_is_pickup_required | false                           |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add order to driver "DD" route
    When Operator delete driver route
    And Operator archives driver route with status code 404
    Then Operator verify archive route response with proper error message : Route "not found!"

  @route-archive @debug
  Scenario: Operator not Allowed to Archive Driver Invalid Route Id - Route Not Found (uid:547956f4-da74-462e-9a14-ce8ed59a3a67)
    Given Operator archives driver route with status code 404
    Then Operator verify archive route response with proper error message : Route "not found!"


  @route-unarchive @debug
  Scenario: Operator Unarchive Driver Route Successfully - Empty Route (uid:33e2b7c1-51ef-4021-b71d-122de32e10d1)
    Given Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0


  @route-unarchive @debug
  Scenario: Operator Unarchive Driver Route Successfully - Route has Waypoints (uid:9621bd52-7238-4b37-a542-2e4850a5ed1e)
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders
      |service_type                  | Parcel       |
      |service_level                 | Standard     |
      |parcel_job_is_pickup_required | false        |
    And Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator archives driver route
    Then DB Operator verifies route status is archived
    When Operator unarchives driver route with status code 200
    Then DB Operator verifies route status = IN_PROGRESS & archived = 0


  @route-unarchive @debug
  Scenario: Operator Unarchive NON-archived Route (uid:d0370a75-e80e-4ba2-a0a9-19007af580e4)
    Given Operator create an empty route
      | driver_id  | {routing-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    When Operator unarchives driver route with status code 400
    Then Operator verify unarchive route response with proper error message : Route "is not archived!"

  @route-unarchive @debug
  Scenario: Operator Unarchive Invalid Route Id (uid:27d2eaec-d712-46db-b29d-300669495267)
    When Operator unarchives driver route with status code 404
    Then Operator verify unarchive route response with proper error message : Route "not found!"
