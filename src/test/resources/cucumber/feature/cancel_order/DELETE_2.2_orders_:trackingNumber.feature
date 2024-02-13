@ForceSuccessOrders @ArchiveDriverRoutes @cancel-order @/2.2/orders/:trackingNumber @NVQA-13557
Feature: Cancel DELETE /2.2/orders/:trackingNumber

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Staging
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
      | is_staged                     | true     |
    And Operator verify that order status-granular status is "Staging"-"Staging"
    And Operator search for created order
    When API Operator cancel order with DELETE /2.2/orders/:trackingNumber
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[1].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | PP                                             |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[1].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | PICKUP                                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[1].waypointId} |
      | status   | Pending                                        |
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[2].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | DD                                             |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[2].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | DELIVERY                               |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[2].waypointId} |
      | status   | Pending                                        |
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  @happy-path @HighPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Pending Pickup
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    When API Operator cancel order with DELETE /2.2/orders/:trackingNumber
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "Cancellation reason : api cancellation request"
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[1].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | PP                                             |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[1].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | PICKUP                                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[1].waypointId} |
      | status   | Pending                                        |
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[2].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | DD                                             |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[2].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | DELIVERY                               |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[2].waypointId} |
      | status   | Pending                                        |
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Van En-route to Pickup
    Given Shipper id "{shipper-4-id}" subscribes to "Cancelled" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
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
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_CREATED_ROUTE_ID},"type":"PICKUP"} |
      | orderId                 | {KEY_CREATED_ORDER.id}                              |
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id} |
      | granularStatus | Van En-route to Pickup |
    Then Operator verify that order status-granular status is "Transit"-"Van_Enroute_To_Pickup"
    When API Operator cancel order with DELETE /2.2/orders/:trackingNumber
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[1].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | PP                                             |
      | routeId  | null                                           |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[1].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | PICKUP                                 |
      | routeId   | null                                   |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[1].waypointId} |
      | status   | Pending                                        |
      | routeId  | null                                           |
      | seqNo    | null                                           |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_CREATED_ORDER.transactions[1].waypointId} |
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[2].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | DD                                             |
      | routeId  | null                                           |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[2].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | DELIVERY                               |
      | routeId   | null                                   |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[2].waypointId} |
      | status   | Pending                                        |
      | routeId  | null                                           |
      | seqNo    | null                                           |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | REMOVE_BY_ORDER_CANCEL |
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Pickup Fail
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
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_CREATED_ROUTE_ID},"type":"PICKUP"} |
      | orderId                 | {KEY_CREATED_ORDER.id}                              |
    And Operator force "FAIL" "PICKUP" waypoint
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    When API Operator cancel order with DELETE /2.2/orders/:trackingNumber
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    And API Event - Operator verify that event is published with the following details:
      | event   | CANCEL                 |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS          |
      | orderId            | {KEY_CREATED_ORDER_ID} |
      | updateStatusReason | CANCEL                 |
    And Operator verify that order comment is appended with cancel reason = "cancellation reason : api cancellation request"
    And DB Core - verify transactions record:
      | id      | {KEY_CREATED_ORDER.transactions[1].id} |
      | status  | Fail                                   |
      | type    | PP                                     |
      | routeId | {KEY_CREATED_ROUTE_ID}                 |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[1].id} |
      | txnStatus | FAIL                                   |
      | txnType   | PICKUP                                 |
      | routeId   | {KEY_CREATED_ROUTE_ID}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[1].waypointId} |
      | status   | Fail                                           |
      | routeId  | {KEY_CREATED_ROUTE_ID}                         |
      | seqNo    | not null                                       |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_CREATED_ORDER.transactions[1].waypointId} |
      | routeId    | {KEY_CREATED_ROUTE_ID}                         |
    And DB Core - verify transactions record:
      | id       | {KEY_CREATED_ORDER.transactions[2].id}         |
      | status   | Cancelled                                      |
      | comments | Cancellation reason : API CANCELLATION REQUEST |
      | type     | DD                                             |
      | routeId  | null                                           |
    And DB Routing Search - verify transactions record:
      | txnId     | {KEY_CREATED_ORDER.transactions[2].id} |
      | txnStatus | CANCELLED                              |
      | txnType   | DELIVERY                               |
      | routeId   | null                                   |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_CREATED_ORDER.transactions[2].waypointId} |
      | status   | Pending                                        |
      | routeId  | null                                           |
      | seqNo    | null                                           |
    And Shipper gets webhook request for event "Cancelled"
    And Shipper verifies webhook request payload has correct details for status "Cancelled"

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Returned to Sender
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Core - Operator rts order:
      | orderId    | {KEY_CREATED_ORDER.id}                                                                                          |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Returned to Sender! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Completed
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is Completed!   |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Cancelled
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Core - cancel order "{KEY_CREATED_ORDER.id}"
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103098                     |
      | message     | Order is already cancelled |
      | application | core                       |
      | description | ORDER_ALREADY_CANCELLED    |
    And Operator verify that order status-granular status is "Cancelled"-"Cancelled"

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Arrived at Distribution Point
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id}        |
      | granularStatus | Arrived at Distribution Point |
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                                  |
      | message     | Order is Arrived at Distribution Point! |
      | application | core                                    |
      | description | ORDER_DETAILS_INVALID                   |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Arrived at Sorting Hub
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                           |
      | message     | Order is Arrived at Sorting Hub! |
      | application | core                             |
      | description | ORDER_DETAILS_INVALID            |
    And Operator verify that order status-granular status is "Transit"-"Arrived_at_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - En-route to Sorting Hub
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id}  |
      | granularStatus | En-route to Sorting Hub |
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is En-route to Sorting Hub! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - On Vehicle for Delivery
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id}  |
      | granularStatus | On Vehicle for Delivery |
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                            |
      | message     | Order is On Vehicle for Delivery! |
      | application | core                              |
      | description | ORDER_DETAILS_INVALID             |
    And Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - On Hold
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id} |
      | granularStatus | On Hold                |
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                |
      | message     | Order is On Hold!     |
      | application | core                  |
      | description | ORDER_DETAILS_INVALID |
    And Operator verify that order status-granular status is "On_Hold"-"On_Hold"
    And Operator checks that "CANCEL" event is NOT published

  @MediumPriority
  Scenario: DELETE /2.2/orders/:trackingNumber - Cancel Order - Transferred to 3PL
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id} |
      | granularStatus | Transferred to 3PL     |
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    When Operator failed to cancel invalid status with DELETE /2.2/orders/:trackingNumber
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103093                       |
      | message     | Order is Transferred to 3PL! |
      | application | core                         |
      | description | ORDER_DETAILS_INVALID        |
    And Operator verify that order status-granular status is "Transit"-"Transferred_to_3PL"
    And Operator checks that "CANCEL" event is NOT published
