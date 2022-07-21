#@ForceSuccessOrder  @ArchiveDriverRoutes @DeleteReservationAndAddress @cancel-order @/2.0/orders/:uuid
Feature: Cancel DELETE /2.0/orders/:uuid

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Staging (uid:f375785d-1963-4329-8087-b5c9192557a2)
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
    When API Operator cancel order with DELETE /2.0/orders/:uuid
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Pending Pickup (uid:f00ad4fa-36c8-47ba-ae37-7ac548f4c26d)
    Given Shipper id "{shipper-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /2.0/orders/:uuid
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "Cancellation reason : api cancellation request"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies waypoint status is "PENDING"
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Van En-route to Pickup (uid:6ca033a5-449c-4c9d-b4ff-2f3f1acf379d)
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
    When API Operator cancel order with DELETE /2.0/orders/:uuid
    And API Operator get order details
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
    When API Operator get order details
    And API Operator verify Pickup transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator checks that "PULL_OUT_OF_ROUTE" event is published
    And API Operator verify Delivery transaction of the created order using data below:
      | status   | CANCELLED                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Pickup Fail (uid:955b4cb8-f4de-4ef7-af0a-7fc18f929ba8)
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

    And Operator add order to driver "PP" route
    And Operator force "FAIL" "PICKUP" waypoint
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /2.0/orders/:uuid
    And API Operator get order details
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And Operator checks that "CANCEL" event is published
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
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
      | comments | Cancellation reason : API CANCELLATION REQUEST |
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_waypoint is hard-deleted
    And DB Operator verifies route_monitoring_data is hard-deleted
    And DB Operator verify Jaro Scores of the created order after cancel
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Returned to Sender (uid:ed7a57f2-6fe2-4f85-9281-14310b21ca52)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Returned to Sender! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Completed (uid:0c82aa2a-c946-47e0-adcd-b053290fe55d)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is Completed!   |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Cancelled (uid:c235975e-9524-4c3c-ac8f-f1e63d27628a)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And DB Operator gets async handle of an order from its Tracking ID
    When API Operator cancel order with DELETE /2.0/orders/:uuid
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Arrived at Distribution Point (uid:dedbbf05-aaaa-407b-9d37-df9f010b965f)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                                  |
      | message     | Order is Arrived at Distribution Point! |
      | application | core                                    |
      | description | ORDER_DETAILS_INVALID                   |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Arrived at Sorting Hub (uid:9cf17e5d-0767-49c9-a9b7-ccee32f44b0e)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                           |
      | message     | Order is Arrived at Sorting Hub! |
      | application | core                             |
      | description | ORDER_DETAILS_INVALID            |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - En-route to Sorting Hub (uid:7cbeb99f-68d6-4e92-a6b8-2abf0b2c8bed)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "En-route to Sorting Hub"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is En-route to Sorting Hub! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - On Vehicle for Delivery (uid:5f66e727-8af3-4546-bbd1-54f941ff493c)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Vehicle for Delivery"
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is On Vehicle for Delivery! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE /2.0/orders/:uuidId - Cancel Order - On Hold (uid:b0dd1641-7df7-43d1-8192-904cab22fefb)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "On Hold"
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is On Hold!     |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "CANCEL" event is NOT published

  Scenario: DELETE 2.0/orders/:uuidId - Cancel Order - Transferred to 3PL (uid:160ef468-1709-4fbb-b22d-4d0ae4e8334a)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Operator update order granular status to = "Transferred to 3PL"
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And DB Operator gets async handle of an order from its Tracking ID
    When Operator failed to cancel invalid status with DELETE /2.0/orders/:uuid
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Transferred to 3PL! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And Operator checks that "CANCEL" event is NOT published
