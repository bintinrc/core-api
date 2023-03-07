@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @cancel-order @/orders/:orderId/cancel
Feature: Cancel PUT /orders/:orderId/cancel

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Staging
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
      | is_staged                     | true     |
    And Operator verify that order status-granular status is "Staging"-"Staging"
    And Operator search for created order
    When API Operator cancel order with PUT /orders/:orderId/cancel
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Pending Pickup
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator verify that order status-granular status is "Pending"-"Pending_Pickup"
    And Operator search for created order
    When API Operator cancel order with PUT /orders/:orderId/cancel
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Van En-route to Pickup
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"PP" } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    And API Operator start the route
    Then Operator verify that order status-granular status is "Transit"-"Van_Enroute_To_Pickup"
    When API Operator cancel order with PUT /orders/:orderId/cancel
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | REMOVE_BY_ORDER_CANCEL |
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Pickup Fail
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |

    And Operator add order to driver "PP" route
    And Operator force "FAIL" "PICKUP" waypoint
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    When API Operator cancel order with PUT /orders/:orderId/cancel
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status | FAIL |
    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "FAIL"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies route_monitoring_data record
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                                                          |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"
    And DB Operator verify Jaro Scores record
      | waypointId        | archived | status  |
      | {KEY_WAYPOINT_ID} | 1        | Pending |

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Returned to Sender
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Returned to Sender! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Completed
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is Completed!   |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Cancelled
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103098                     |
      | message     | Order is already cancelled |
      | application | core                       |
      | description | ORDER_ALREADY_CANCELLED    |

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Arrived at Distribution Point
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                                  |
      | message     | Order is Arrived at Distribution Point! |
      | application | core                                    |
      | description | ORDER_DETAILS_INVALID                   |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Arrived at Sorting Hub
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                           |
      | message     | Order is Arrived at Sorting Hub! |
      | application | core                             |
      | description | ORDER_DETAILS_INVALID            |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - En-route to Sorting Hub
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "En-route to Sorting Hub"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is En-route to Sorting Hub! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - On Vehicle for Delivery
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Vehicle for Delivery"
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is On Vehicle for Delivery! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - On Hold
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Hold"
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is On Hold!     |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: PUT /orders/:orderId/cancel - Cancel Order - Transferred to 3PL
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "Transferred to 3PL"
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    When Operator failed to cancel invalid status with PUT /orders/:orderId/cancel
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Transferred to 3PL! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And Operator checks that "CANCEL" event is NOT published
