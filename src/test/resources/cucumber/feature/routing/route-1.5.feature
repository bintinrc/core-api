@ForceSuccessOrder @DeleteReservationAndAddress @route-1.5-refactor @routing-refactor
Feature: Route 1.5

  Scenario: Add to DP Holding Route upon Hub Inbound (uid:5cbbfa8e-f896-42b4-b4b0-217d79475e4c)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                   |
      | service_level                 | Standard                 |
      | parcel_job_is_pickup_required | false                    |
      | dp-address-unit-number        | {dp-address-unit-number} |
      | dp-address-postcode           | {dp-address-postcode}    |
      | dp-holding-route-id           | {dp-holding-route-id}    |
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And DB Operator get routes dummy waypoints
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies route_monitoring_data record
    And Operator checks that "ADD_TO_ROUTE" event is published

  Scenario: Add Order to DP Holding Route (uid:eddb26ba-5d01-4256-9916-3c4f9216a7e4)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                   |
      | service_level                 | Standard                 |
      | parcel_job_is_pickup_required | false                    |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator new add parcel to DP holding route
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And DB Operator get routes dummy waypoints
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies first & last waypoints.seq_no are dummy waypoints
    And DB Operator verifies route_monitoring_data record
    And Operator checks that "ADD_TO_ROUTE" event is published

  Scenario: Remove DP Order From Holding Route (uid:7c6abd1e-6591-4027-9217-8e6e69c07232)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                   |
      | service_level                 | Standard                 |
      | parcel_job_is_pickup_required | false                    |
      | dp-address-unit-number        | {dp-address-unit-number} |
      | dp-address-postcode           | {dp-address-postcode}    |
      | dp-holding-route-id           | {dp-holding-route-id}    |
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    When Operator pull DP order out of route
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And DB Operator get routes dummy waypoints
    Then DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published

  Scenario: Unmerge waypoint with multiple transactions (uid:a7196db7-0635-45a8-a9d5-e201740e95b8)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper creates multiple orders : 3 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator merge transactions on Zonal Routing
    And API Operator verifies Delivery transactions of following orders have same waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    When Operator unmerge transactions
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    Then DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL
