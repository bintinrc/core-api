@ForceSuccessOrders @ArchiveDriverRoutes @batch-update-pods-txn
Feature: Batch Update PODs - TXN

  @happy-path @HighPriority
  Scenario Outline: Driver picks up all X number of return parcels in one waypoint with POD type - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Success All Created Orders "Pickup" with pod type "<type>"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify all "PICKUP" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Pickup"
    Then DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

    Examples:
      | Note       | hiptest-uid                              | type       |
      | RECIPIENT  | uid:70cd7f37-bca6-464e-866f-918528b7a14c | RECIPIENT  |
      | SUBSTITUTE | uid:024b7c50-548c-4429-826a-eb8166effb86 | SUBSTITUTE |

  @HighPriority
  Scenario: Driver picks up X number of return parcels and fails Y number of return parcels in one waypoint (Partial Success)
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub, Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Partial Success Orders "Pickup"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Routed            |
    And Operator verify that "Success" orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify that "Fail" orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Operator verify that "Success" orders "Pickup" transactions status is "Success"
    And Operator verify that "Fail" orders "Pickup" transactions status is "Fail"
    And Verify for "Success" Orders, Shipper gets webhook event "En-route to Sorting Hub"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Pickup"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pickup fail"
    When API Batch Update Proof Request to Partial Success Orders "Pickup"
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[2].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[3].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[4].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[3].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[4].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[4]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @happy-path @HighPriority
  Scenario: Driver fails all X number of return pickup parcels in one waypoint
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Fail All Created Orders "Pickup"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Fail              |
    And Operator verify that all orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Operator verify all "PICKUP" transactions status is "FAIL"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to Fail All Created Orders "Pickup"
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[2].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @happy-path @HighPriority
  Scenario Outline: Driver delivers all X number of normal parcels in one waypoint with POD type - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery, Completed" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Success All Created Orders "Delivery" with pod type "<type>"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

    Examples:
      | Note       | hiptest-uid                              | type       |
      | RECIPIENT  | uid:bfa103c7-66e1-4d84-add4-8bb43ca9c9fd | RECIPIENT  |
      | SUBSTITUTE | uid:3e86a2e5-1e5d-4e76-911a-5330f7859161 | SUBSTITUTE |

  @HighPriority
  Scenario Outline: Driver delivers all X number of return parcels in one waypoint with POD type - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery, Completed" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Success All Created Orders "Delivery" with pod type "<type>"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

    Examples:
      | Note       | hiptest-uid                              | type       |
      | RECIPIENT  | uid:11b78edd-3021-40ab-9e8f-52913dfa1e66 | RECIPIENT  |
      | SUBSTITUTE | uid:3f5ab4a0-d234-4756-964f-a9eaebffcc99 | SUBSTITUTE |

  @HighPriority
  Scenario: Driver Delivers X number of Parcels and Fails Y number of Parcels in One Waypoint (Partial Success)
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery, Completed, Pending Reschedule, First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Partial Success Orders "Delivery"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Routed            |
    And Operator verify that "Success" orders status-granular status is "Completed"-"Completed"
    And Operator verify that "Fail" orders status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator verify that "Success" orders "Delivery" transactions status is "Success"
    And Operator verify that "Fail" orders "Delivery" transactions status is "Fail"
    And Verify for "Success" Orders, Shipper gets webhook event "Completed"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Delivery"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pending Reschedule"
    And Verify for "Failed" Orders, Shipper gets webhook event "First Attempt Delivery Fail"
    When API Batch Update Proof Request to Partial Success Orders "Delivery"
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[2].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[3].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[4].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[3].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[4].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[4]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @happy-path @HighPriority
  Scenario: Driver fails all X number of Deliveries in one waypoint
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule, First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    When Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Fail All Created Orders "Delivery"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Fail              |
    And Operator verify that all orders status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator verify all "DELIVERY" transactions status is "FAIL"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule" for all orders
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail" for all orders
    When API Batch Update Proof Request to Fail All Created Orders "Delivery"
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    Then DB Core - verify transaction_failure_reason record:
      | transactionId       | {KEY_LIST_OF_TRANSACTION_DETAILS[2].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                 |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}            |
    And DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
      | {KEY_UPDATE_PROOFS_REQUEST[2].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |


  @HighPriority
  Scenario: Shipper Got POD Webhook (Successful Pickup) with NO PODs Details after Driver Success Return Pickup with NO Proof Details
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "PP" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Success All Created Orders "Pickup" with NO Proof Details
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify all "PICKUP" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders

  Scenario: Shipper Got POD Webhook (Successful Delivery) with NO PODs Details after Driver Success Deliveries with NO Proof Details
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator inbounds all orders at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for all created orders
    And Operator add all orders to driver "DD" route
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    When API Batch Update Job Request to Success All Created Orders "Delivery" with NO Proof Details
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders

  @HighPriority
  Scenario: Driver delivers order with COD to collect
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery, Completed" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 56.78    |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for created order
    And Operator add order to driver "DD" route
    When API Batch Update Job Request to Success COD Delivery
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID} |
      | status   | Success           |
    And Operator verify that all orders status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And DB Core - Operator verifies cod_collections record:
      | waypointId   | {KEY_LIST_OF_CREATED_ORDER[1].transactions[2].waypointId} |
      | collectedSum | 56.78                                                     |
      | driverId     | {driver-2-id}                                             |
    And Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed" for all orders
    And Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery" for all orders
    When API Batch Update Proof Request to Success All Created Orders "Delivery"
    Then DB Core - verify transaction_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
