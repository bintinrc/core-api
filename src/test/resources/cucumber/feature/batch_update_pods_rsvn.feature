@ForceSuccessOrders @ArchiveDriverRoutes @batch-update-pods-rsvn
Feature: Batch Update PODs

  @happy-path @update-rsvn @HighPriority
  Scenario: Driver picks up all X number of Normal parcels in one reservation
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to "SUCCESS" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Success"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Success                                          |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    And DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And Operator get proof details for "SUCCESS" transaction of "Normal" orders
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @update-rsvn @HighPriority
  Scenario: Driver Picks Up All X number of Return Parcels in One Reservation
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to "SUCCESS" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Success"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Success                                          |
    And Operator verify that all orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Shipper gets webhook request for event "En-route to Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "En-route to Sorting Hub" for all orders
    And Shipper gets webhook request for event "Successful Pickup" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Pickup" for all orders
    When API Batch Update Proof Request to "SUCCESS" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    And DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And Operator get proof details for "SUCCESS" transaction of "Return" orders
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                     |
      | orderId            | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | updateStatusReason | BATCH_POD_UPDATE                  |

  @update-rsvn @HighPriority
  Scenario: Driver success reservation without scanning any parcel
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to "SUCCESS" Reservation without any Parcel
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Success"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Success                                          |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "En-route to Sorting Hub" event sent for all orders
    And Verify NO "Successful Pickup" event sent for all orders
    When API Batch Update Proof Request to "SUCCESS" Reservation without any Parcel
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct

  @update-rsvn @HighPriority
  Scenario: Driver successes the reservation with X number of parcels but fails Y number of parcels (Partial Success)
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Pickup, En-route to Sorting Hub, Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 4 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to Partial Success Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Success"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Success                                          |
    And Operator verify that "Success" orders status-granular status is "Transit"-"Enroute_to_Sorting_Hub"
    And Operator verify that "Fail" orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify for "Success" Orders, Shipper gets webhook event "En-route to Sorting Hub"
    And Verify for "Success" Orders, Shipper gets webhook event "Successful Pickup"
    And Verify for "Failed" Orders, Shipper gets webhook event "Pickup fail"
    When API Batch Update Proof Request to Partial Success & Fail Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct

  @update-rsvn @HighPriority
  Scenario: Driver fails the reservation and fail all X number of normal parcels under a reservation
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to "FAIL" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Fail"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Fail                                             |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And DB Core - verify reservation_failure_reason record:
      | reservationId       | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                  |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}             |
    And Operator get proof details for "FAIL" transaction of "Normal" orders

  @update-rsvn @HighPriority
  Scenario: Driver fails the reservation and fail all X number of return parcels under a reservation
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    And Shipper creates multiple "Return" orders
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    When API Batch Update Job Request to "FAIL" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Fail"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Fail                                             |
    And Operator verify that all orders status-granular status is "Pickup_fail"-"Pickup_fail"
    And Shipper gets webhook request for event "Pickup fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pickup fail" for all orders
    When API Batch Update Proof Request to "FAIL" All Orders under the reservation
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And DB Core - verify reservation_failure_reason record:
      | reservationId       | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                  |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}             |
    And Operator get proof details for "FAIL" transaction of "Return" orders
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

  @happy-path @update-rsvn @HighPriority
  Scenario: Driver fails the reservation without failing any parcel
    Given Shipper id "{shipper-4-id}" subscribes to "Pickup fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                   |
    When API Batch Update Job Request to "FAIL" Reservation without any Parcel
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then Operator verify that reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" status is "Fail"
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | status   | Fail                                             |
    And Operator verify that all orders status-granular status is "Pending"-"Pending_Pickup"
    And Verify NO "Pickup fail" event sent for all orders
    When API Batch Update Proof Request to "FAIL" Reservation without any Parcel
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}         |
      | waypointId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId       | {KEY_CREATED_ROUTE_ID}                           |
      | jobType       | RESERVATION                                      |
    Then DB Core - verify reservation_blob record:
      | {KEY_UPDATE_PROOFS_REQUEST[1].job.id} |
    And Verify blob data is correct
    And DB Core - verify reservation_failure_reason record:
      | reservationId       | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | failureReasonId     | {KEY_FAILURE_REASON_ID}                  |
      | failureReasonCodeId | {KEY_FAILURE_REASON_CODE_ID}             |

