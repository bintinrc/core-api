@ForceSuccessOrder @ArchiveDriverRoutes @driver-api
Feature: Driver API

  Scenario: Driver Van Inbound an Order Delivery (uid:1d621734-5703-41e5-9c91-5aac51abf358)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    Then Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "DRIVER_INBOUND_SCAN" event is published
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  Scenario: Driver Success a Return Pickup (uid:1b8ddf1f-9112-4919-a27a-4e1090e35ade)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for created order
    And Operator add order to driver "PP" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "SUCCESS" Parcel "PICKUP"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And Operator checks that "DRIVER_PICKUP_SCAN" event is published
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Reservation Pickup by Scanning Normal Order (uid:53cfcc56-2c2f-40f3-a06c-ced1a86b1bc2)
    Given Shipper authenticates using client id "{shipper-3-client-id}" and client secret "{shipper-3-client-secret}"
    When Shipper creates a reservation
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And Operator Search for Created Pickup for Shipper "{shipper-3-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver "Success" Reservation Pickup
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And Operator checks that "DRIVER_PICKUP_SCAN" event is published
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Failed Delivery that was Rescheduled (uid:601a050d-a9a7-47c3-b886-1572264012f3)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    When API Operator reschedule failed delivery order
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    When Operator add order to driver "DD" route
    And Driver "SUCCESS" Parcel previous "DELIVERY"
    Then Operator checks that "PULL_OUT_OF_ROUTE" event is published
    And DB Operator verifies transaction is soft-deleted
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
