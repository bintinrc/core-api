@ForceSuccessOrder @ArchiveDriverRoutes @batch-update-pods
Feature: Batch Update PODs

  Scenario: Driver picks up all X number of return parcels in one waypoint (uid:112970b2-7df4-424b-9c6b-bd779a33c7f8)
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
    When API Batch Update Job Request to Success All Created Orders "Pickup" with pod type "RECIPIENT"
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify all "PICKUP" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Pickup"

  Scenario: Driver picks up X return parcels and fails Y return parcels in one waypoint (uid:8e613bce-1d89-4468-ae25-beb96bb24a8d)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Delivery, Completed, Pending Reschedule, First Attempt Delivery Fail" webhook
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

  Scenario: Driver delivers all X number of parcels in one waypoint (uid:739b3745-fd53-43e8-b302-50c4b1319778)
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
    When API Batch Update Job Request to Success All Created Orders "Delivery" with pod type "RECIPIENT"
    Then DB Operator verifies waypoint status is "SUCCESS"
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"

  Scenario: Driver delivers X parcels and fails Y parcels in one waypoint (partial success) (uid:07fe3f7d-ee7a-4937-b7e1-9406fc239ad5)
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

  Scenario: Driver picks up all X number of parcels in one reservation (uid:e3adbedd-c9f6-4d68-8299-41cfbe2c2073)
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

  Scenario: Driver success reservation and doesnt success any parcel (uid:e9166198-1c27-447e-bb75-62de915715eb)
    Given Shipper id "{routing-shipper-id}" subscribes to "Successful Pickup" webhook
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
    And Verify NO "Successful Pickup" event sent for all orders

  Scenario: Driver successes the reservation but fails X no of parcels (uid:804f5c6b-27ef-4ff0-871e-60ad0e13a774)
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

  Scenario: Driver fails the reservation and fail X number of parcels (uid:5c2299fa-cd51-4be8-9027-5f2bce2e7621)
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

  Scenario: Driver fails the reservation and does not fail any parcels (uid:82380b11-8ee9-48bd-a47c-9defda349ab8)
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
