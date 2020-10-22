@ForceSuccessOrder @ArchiveDriverRoutes @batch-update-pods
Feature: Batch Update PODs

  Scenario Outline: Driver picks up all X number of return parcels in one waypoint with POD type - <Note> (<hiptest-uid>)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "PP" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Success All Created Orders "Pickup" with pod type "<type>"
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify all "PICKUP" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Pickup"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

    Examples:
      | Note         | hiptest-uid                              |type      |
      | RECIPIENT    | uid:70cd7f37-bca6-464e-866f-918528b7a14c |RECIPIENT |
      | SUBSTITUTE   | uid:024b7c50-548c-4429-826a-eb8166effb86 |SUBSTITUTE|

  Scenario: Driver picks up X number of return parcels and fails Y number of return parcels in one waypoint (Partial Success) (uid:8e613bce-1d89-4468-ae25-beb96bb24a8d)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub, Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                   |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "PP" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Partial Success Orders "Pickup"
    Then DB Operator verifies waypoint status is "ROUTED"
    And Operator verify that "Success" orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify that "Fail" orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Operator verify that "Success" orders "Pickup" transactions status is "Success"
    And Operator verify that "Fail" orders "Pickup" transactions status is "Fail"
    And Verify for "Success" Orders, Shipper gets webhook event "En-route to Sorting Hub"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Pickup"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pickup fail"
    When API Batch Update Proof Request to Partial Success Orders "Pickup"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario: Driver fails all X number of return pickup parcels in one waypoint (uid:5cfb9c8c-2fc8-49f1-b30a-3105c30e854d)
    Given Shipper id "{routing-shipper-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
       |service_type                  | Return                  |
       |service_level                 | Standard                |
       |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "PP" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Fail All Created Orders "Pickup"
    Then DB Operator verifies waypoint status is "FAIL"
    And Operator verify that all orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Operator verify all "PICKUP" transactions status is "FAIL"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to Fail All Created Orders "Pickup"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario Outline: Driver delivers all X number of normal parcels in one waypoint with POD type - <Note> (<hiptest-uid>)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery, Completed" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | false                   |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Success All Created Orders "Delivery" with pod type "<type>"
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

    Examples:
      | Note         | hiptest-uid                              |type      |
      | RECIPIENT    | uid:bfa103c7-66e1-4d84-add4-8bb43ca9c9fd |RECIPIENT |
      | SUBSTITUTE   | uid:3e86a2e5-1e5d-4e76-911a-5330f7859161 |SUBSTITUTE|

  Scenario Outline: Driver delivers all X number of return parcels in one waypoint with POD type - <Note> (<hiptest-uid>)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery, Completed" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Success All Created Orders "Delivery" with pod type "<type>"
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

    Examples:
      | Note         | hiptest-uid                              |type      |
      | RECIPIENT    | uid:11b78edd-3021-40ab-9e8f-52913dfa1e66 |RECIPIENT |
      | SUBSTITUTE   | uid:3f5ab4a0-d234-4756-964f-a9eaebffcc99 |SUBSTITUTE|

  Scenario: Driver Delivers X number of Parcels and Fails Y number of Parcels in One Waypoint (Partial Success) (uid:07fe3f7d-ee7a-4937-b7e1-9406fc239ad5)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery, Completed, Pending Reschedule, First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | false                   |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Partial Success Orders "Delivery"
    Then DB Operator verifies waypoint status is "ROUTED"
    And Operator verify that "Success" orders status-granular status is "Completed"-"Completed"
    And Operator verify that "Fail" orders status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator verify that "Success" orders "Delivery" transactions status is "Success"
    And Operator verify that "Fail" orders "Delivery" transactions status is "Fail"
    And Verify for "Success" Orders, Shipper gets webhook event "Completed"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Delivery"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pending Reschedule"
    And Verify for "Failed" Orders, Shipper gets webhook event "First Attempt Delivery Fail"
    When API Batch Update Proof Request to Partial Success Orders "Delivery"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario: Driver fails all X number of Deliveries in one waypoint (uid:9073a13d-8707-4075-944a-a227e394fa27)
    Given Shipper id "{routing-shipper-id}" subscribes to "Pending Reschedule, First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | false                   |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Fail All Created Orders "Delivery"
    Then DB Operator verifies waypoint status is "FAIL"
    And Operator verify that all orders status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator verify all "DELIVERY" transactions status is "FAIL"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule" for all orders
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    Then DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario: Driver picks up all X number of Normal parcels in one reservation (uid:e3adbedd-c9f6-4d68-8299-41cfbe2c2073)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When API Batch Update Job Request to "SUCCESS" All Orders under the reservation
    Then Operator verify that reservation status is "SUCCESS"
    And DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the reservation
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct
    And Operator get proof details for transaction of "Normal" orders
    And DB Operator verifies transaction_blob is NOT created
    
  Scenario: Driver Picks Up All X number of Return Parcels in One Reservation (uid:6408c80d-acce-4956-87d8-76db59d666bd)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates a reservation
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    And Shipper creates multiple "Return" orders
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    When API Batch Update Job Request to "SUCCESS" All Return Orders under the reservation
    Then Operator verify that reservation status is "SUCCESS"
    And DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the reservation
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct
    And Operator get proof details for transaction of "Return" orders
    And DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario: Driver success reservation without scanning any parcel (uid:e9166198-1c27-447e-bb75-62de915715eb)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When API Batch Update Job Request to "SUCCESS" Reservation without any Parcel
    Then Operator verify that reservation status is "SUCCESS"
    And DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "En-route to Sorting Hub" event sent for all orders
    And Verify NO "Successful Pickup" event sent for all orders
    When API Batch Update Proof Request to "SUCCESS" Reservation without any Parcel
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct

  Scenario: Driver successes the reservation with X number of parcels but fails Y number of parcels (Partial Success) (uid:804f5c6b-27ef-4ff0-871e-60ad0e13a774)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup, En-route to Sorting Hub, Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When API Batch Update Job Request to Partial Success Orders under the reservation
    Then Operator verify that reservation status is "SUCCESS"
    And DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that "Success" orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify that "Fail" orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify for "Success" Orders, Shipper gets webhook event "En-route to Sorting Hub"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Pickup"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pickup fail"
    When API Batch Update Proof Request to Partial Success & Fail Orders under the reservation
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct

  Scenario: Driver fails the reservation and fail all X number of normal parcels under a reservation (uid:5c2299fa-cd51-4be8-9027-5f2bce2e7621)
    Given Shipper id "{routing-shipper-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When API Batch Update Job Request to "FAIL" All Orders under the reservation
    Then Operator verify that reservation status is "FAIL"
    And DB Operator verifies waypoint status is "FAIL"
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the reservation
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct
    And Operator get proof details for transaction of "Normal" orders
    And DB Operator verifies transaction_blob is NOT created

  Scenario: Driver fails the reservation and fail all X number of return parcels under a reservation (uid:843069d4-281a-427c-9d84-a10e03c2d19a)
    Given Shipper id "{routing-shipper-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates a reservation
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    And Shipper creates multiple "Return" orders
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    When API Batch Update Job Request to "FAIL" All Return Orders under the reservation
    Then Operator verify that reservation status is "FAIL"
    And DB Operator verifies waypoint status is "FAIL"
    And Operator verify that all orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the reservation
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct
    And Operator get proof details for transaction of "Return" orders
    And DB Operator verifies transaction_blob is created
    And Verify blob data is correct

  Scenario: Driver fails the reservation without failing any parcel (uid:82380b11-8ee9-48bd-a47c-9defda349ab8)
    Given Shipper id "{routing-shipper-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Parcel                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator Search for Created Pickup for Shipper "{routing-shipper-legacy-id}" with status "PENDING"
    And Operator Route the Reservation Pickup
    When API Batch Update Job Request to "FAIL" Reservation without any Parcel
    Then Operator verify that reservation status is "FAIL"
    And DB Operator verifies waypoint status is "FAIL"
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "Pickup fail" event sent for all orders
    When API Batch Update Proof Request to "FAIL" Reservation without any Parcel
    Then DB Operator verifies reservation_blob is created
    And Verify blob data is correct

  Scenario: Shipper Got POD Webhook (Successful Pickup) with NO PODs Details after Driver Success Return Pickup with NO Proof Details (uid:d95ca9a7-5572-45b6-9990-88547abff44f)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "PP" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Success All Created Orders "Pickup" with NO Proof Details
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify all "PICKUP" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders

  Scenario: Shipper Got POD Webhook (Successful Delivery) with NO PODs Details after Driver Success Deliveries with NO Proof Details (uid:84b4f474-2ccf-4ec9-8127-b3944d1073d5)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery" webhook
    Given Shipper authenticates using client id "{routing-shipper-client-id}" and client secret "{routing-shipper-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      |service_type                  | Return                  |
      |service_level                 | Standard                |
      |parcel_job_is_pickup_required | true                    |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {route-monitoring-driver-id}  |
      | hub_id     | {sorting-hub-id}     |
      | vehicle_id | {vehicle-id}         |
      | zone_id    | {zone-id}            |
    And Operator add all orders to driver "DD" route
    And Operator merge transaction waypoints
    When API Batch Update Job Request to Success All Created Orders "Delivery" with NO Proof Details
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
