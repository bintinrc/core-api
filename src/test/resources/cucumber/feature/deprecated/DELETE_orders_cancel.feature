#@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @cancel-order @/orders/cancel
Feature: Cancel DELETE /orders/cancel

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Staging (uid:b80be344-3ec8-493f-bd21-64a1b29f2dfc)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
      | is_staged                     | true     |
    And Operator verify that order status-granular status is "Staging"-"Staging"
    And Operator search for created order
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by TID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
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

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Pending Pickup (uid:7cbab742-2853-42ac-bb36-38fc1f370f7e)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by TID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Van En-route to Pickup (uid:b1acc37c-40e7-48ce-a161-f4c329bc6f20)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by TID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Pickup Fail (uid:3e840d42-8e45-4650-adff-9873cd914202)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator get routes dummy waypoints
    And Operator add order to driver "PP" route
    And Operator force "FAIL" "PICKUP" waypoint
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by TID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status | FAIL |
    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "FAIL"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies route_monitoring_data record
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Returned to Sender (uid:a4f65af2-e265-4aa6-abf0-56d6e85fded9)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Completed (uid:eda4dd11-ef04-40ac-9cd5-d3154f9cc424)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Cancelled (uid:dae34644-0089-480a-abf2-afdb64ac6d15)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by TID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Arrived at Distribution Point (uid:3477397f-01ca-4a83-93b1-3f4121609d1d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Arrived at Sorting Hub (uid:54452d45-8c0d-4da3-b4f9-261ca95496cc)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - En-route to Sorting Hub (uid:b18462c8-25e9-4415-ba8c-76509b2879ea)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "En-route to Sorting Hub"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - On Vehicle for Delivery (uid:dc14f525-cff7-4161-9ca1-1dffc4047a9e)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Vehicle for Delivery"
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - On Hold (uid:088e2953-1442-437f-b9d8-60f8d6be37bb)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Hold"
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by TID - Cancel Order - Transferred to 3PL (uid:3c302884-8b26-49d1-a0db-78004e2ae42d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "Transferred to 3PL"
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by TID
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Staging (uid:b80be344-3ec8-493f-bd21-64a1b29f2dfc)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
      | is_staged                     | true     |
    And Operator verify that order status-granular status is "Staging"-"Staging"
    And Operator search for created order
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by UUID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
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

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Pending Pickup (uid:7cbab742-2853-42ac-bb36-38fc1f370f7e)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by UUID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Van En-route to Pickup (uid:b1acc37c-40e7-48ce-a161-f4c329bc6f20)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by UUID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Pickup Fail (uid:3e840d42-8e45-4650-adff-9873cd914202)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator get routes dummy waypoints
    And Operator add order to driver "PP" route
    And Operator force "FAIL" "PICKUP" waypoint
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by UUID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd}"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status | FAIL |
    And DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "FAIL"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies route_waypoint record exist
    And DB Operator verifies route_monitoring_data record
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Returned to Sender (uid:a4f65af2-e265-4aa6-abf0-56d6e85fded9)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Completed (uid:eda4dd11-ef04-40ac-9cd5-d3154f9cc424)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Cancelled (uid:dae34644-0089-480a-abf2-afdb64ac6d15)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /orders/cancel by UUID
      | reason | Cancelled by automated test {gradle-current-date-yyyy-MM-dd} |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Arrived at Distribution Point (uid:3477397f-01ca-4a83-93b1-3f4121609d1d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Arrived at Sorting Hub (uid:54452d45-8c0d-4da3-b4f9-261ca95496cc)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - En-route to Sorting Hub (uid:b18462c8-25e9-4415-ba8c-76509b2879ea)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "En-route to Sorting Hub"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - On Vehicle for Delivery (uid:dc14f525-cff7-4161-9ca1-1dffc4047a9e)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Vehicle for Delivery"
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - On Hold (uid:088e2953-1442-437f-b9d8-60f8d6be37bb)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Hold"
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /orders/cancel by UUID - Cancel Order - Transferred to 3PL (uid:3c302884-8b26-49d1-a0db-78004e2ae42d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "Transferred to 3PL"
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel order with DELETE /orders/cancel by UUID
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And Operator checks that "CANCEL" event is NOT published
