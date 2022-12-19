@ArchiveDriverRoutes @driver-api
Feature: Driver API

  @ForceSuccessOrder
  Scenario: Driver Van Inbound an Order Delivery
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
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
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_INBOUND_SCAN    |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  Scenario: Driver Success a Return Pickup
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
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN     |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Reservation Pickup by Scanning Normal Order
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
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN     |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Failed Delivery that was Rescheduled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
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
    And Operator verify all "DELIVERY" transactions status is "FAIL"
    And DB Operator verifies all transaction_failure_reason is created correctly
    When API Operator reschedule failed delivery order
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    When Operator add order to driver "DD" route
    And Driver "SUCCESS" Parcel previous "DELIVERY"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | TRANSACTION_UNROUTE    |
    And DB Operator verifies transaction is soft-deleted
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator search for "DELIVERY" transaction with status "SUCCESS"
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And DB Operator verifies transactions after reschedule
      | number_of_txn       | 3       |
      | old_delivery_status | Success |
      | new_delivery_status | Pending |
      | new_delivery_type   | DD      |

  Scenario: Driver Success a Failed Pickup that was Rescheduled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "PP" route
    And Operator get "PICKUP" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "PICKUP"
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    And Operator verify all "PICKUP" transactions status is "FAIL"
    And DB Operator verifies all transaction_failure_reason is created correctly
    When API Operator reschedule failed delivery order
    And Operator search for "PICKUP" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Pending"-"Pending_Pickup"
    When Operator add order to driver "PP" route
    And Driver "SUCCESS" Parcel previous "PICKUP"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | TRANSACTION_UNROUTE    |
    And DB Operator verifies transaction is soft-deleted
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator search for "PICKUP" transaction with status "SUCCESS"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And DB Operator verifies transactions after reschedule pickup
      | old_pickup_status | Success |
      | new_pickup_status | Pending |
      | new_pickup_type   | PP      |
