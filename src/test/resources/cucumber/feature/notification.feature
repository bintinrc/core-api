@ArchiveDriverRoutes @notification
Feature: Notification

  @happy-path @HighPriority
  Scenario: Send Successful Delivery Webhook on Force Success from Edit Order
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator force success order
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  @happy-path @HighPriority
  Scenario: Send Successful Delivery Webhook on Force Success from Route Manifest
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
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
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  @HighPriority
  Scenario Outline: Send Successful Delivery Webhook with COD - Single Force Success - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 500.20   |
    And Operator search for created order
    When API Core - Operator force success order "{KEY_LIST_OF_CREATED_ORDER[1].id}" with cod collected "<codCollected>"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  @HighPriority
  Scenario Outline: Send Successful Delivery Webhook with COD - Admin Force Success Route Manifest - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 45.0     |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order by tracking id to driver "DD" route
    When Operator admin manifest force success waypoint with cod collected : "<codCollected>"
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  @HighPriority
  Scenario Outline: Send Successful Delivery Webhook with COD - Bulk Force Success - <Note>
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 150      |
    And Operator search for created order
    When API Core - Operator bulk force success below orders with cod collected "<codCollected>":
      | {KEY_CREATED_ORDER_ID} |
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Examples:
      | Note              | codCollected |
      | COD Collected     | true         |
      | COD not Collected | false        |

  @HighPriority
  Scenario: Send Successful Delivery Webhook with COD - Bulk Force Success
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When API Core - Operator bulk force success below orders with cod collected "false":
      | {KEY_CREATED_ORDER_ID} |
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"

  @happy-path @HighPriority
  Scenario: Send Route Start Webhook Notification
    Given Shipper id "{shipper-4-id}" subscribes to "On Vehicle for Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
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
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE_ID}                                                                                                                                                               |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDER[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDER[1].transactions[2].waypointId}}]} |
    And API Sort - Operator get hub details of hub id "{sorting-hub-id}"
    And API Driver - Driver start route "{KEY_CREATED_ROUTE_ID}"
    Then Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Shipper gets webhook request for event "On Vehicle for Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "On Vehicle for Delivery"

  @HighPriority
  Scenario: Send Route Start Webhook Notification - RTS
    Given Shipper id "{shipper-4-id}" subscribes to "On Vehicle for Delivery (RTS)" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "On Vehicle for Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Core - Operator rts order:
      | orderId    | {KEY_CREATED_ORDER.id}                                                                                          |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE_ID}                                                                                                                                                               |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDER[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDER[1].transactions[2].waypointId}}]} |
    And API Sort - Operator get hub details of hub id "{sorting-hub-id}"
    And API Driver - Driver start route "{KEY_CREATED_ROUTE_ID}"
    Then Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And Shipper gets webhook request for event "On Vehicle for Delivery (RTS)" for all orders
    And Shipper verifies webhook request payload has correct details for status "On Vehicle for Delivery (RTS)"
    And Verify NO "On Vehicle for Delivery" event sent for all orders

  @HighPriority
  Scenario: Send Successful Delivery Webhook on Customer Collection of DP Order
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "Completed" webhook
    And Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_CREATED_ORDER.id},"dp_id":{dp-id},"drop_off_date":"{date: 0 days next, yyyy-MM-dd}"} |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "SUCCESS" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    And API DP - DP user authenticate with username "{dp-user-username}" password "{dp-user-password}" and dp id "{dp-id}"
    And DB DP - get DP job order with order "{KEY_LIST_OF_CREATED_ORDERS[1].id}" and status "PENDING"
    And API DP - DP success parcel:
      | request | [{ "tracking_id": "{KEY_CREATED_ORDER_TRACKING_ID}", "job_id": {KEY_DP_LIST_OF_DP_JOB_ORDERS[1].dpJobId},"received_from": "DRIVER"}] |
    And API DP - DP Order is collected by customer:
      | dpId               | {dp-id}                                              |
      | customerUnlockCode | {KEY_DP_LIST_OF_DP_JOB_ORDERS[1].customerUnlockCode} |
      | trackingId         | {KEY_CREATED_ORDER_TRACKING_ID}                      |
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    And Operator verify all "DELIVERY" transactions status is "SUCCESS"
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status   | Success                                                    |
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
    Then Shipper gets webhook request for event "Completed" for all orders
    And Shipper verifies webhook request payload has correct details for status "Completed"
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                      |
      | orderId            | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | updateStatusReason | RELEASED_FROM_DP                   |
    And API Event - Operator verify that event is published with the following details:
      | event   | FROM_DP_TO_CUSTOMER                |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  @happy-path @HighPriority
  Scenario: Send First Attempt Delivery Fail & First Pending Reschedule Webhook on Driver Fails Delivery Order
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
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
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "FAIL" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"

  @HighPriority
  Scenario: Send First Attempt Delivery Fail & Second Pending Reschedule Webhook on Driver Fails Rescheduled Delivery Order
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
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
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "FAIL" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}        |
      | rescheduleRequest | {"date":"{date: 0 days ago, yyyy-MM-dd}"} |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And Operator add order to driver "DD" route
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    And Driver submit pod to "FAIL" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"

  @HighPriority
  Scenario: Send First Attempt Delivery Fail & First Pending Reschedule Webhook on Global Inbound Rescheduled Delivery Order
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
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
    Given Shipper id "{shipper-4-id}" subscribes to "First Attempt Delivery Fail" webhook
    Given Shipper id "{shipper-4-id}" subscribes to "Pending Reschedule" webhook
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "FAIL" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}        |
      | rescheduleRequest | {"date":"{date: 0 days ago, yyyy-MM-dd}"} |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    Given Shipper id "{shipper-4-id}" subscribes to "Arrived at Sorting Hub" webhook
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Sort - Operator get hub details of hub id "{sorting-hub-id}"
    And Shipper gets webhook request for event "First Attempt Delivery Fail" for all orders
    And Shipper verifies webhook request payload has correct details for status "First Attempt Delivery Fail"
    And Shipper gets webhook request for event "Pending Reschedule" for all orders
    And Shipper verifies webhook request payload has correct details for status "Pending Reschedule"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" for all orders
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub"

  @happy-path @HighPriority
  Scenario: Send Successful Delivery Webhook with COD - Driver Success Delivery with COD
    Given Shipper id "{shipper-4-id}" subscribes to "Successful Delivery" webhook
    Given Shipper authenticates using client id "{shipper-4-client-id}" and client secret "{shipper-4-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50.67    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And API Core - Operator get order details for tracking order "KEY_CREATED_ORDER_TRACKING_ID"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_CREATED_ROUTE.id}                                                                                                                                                      |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_CREATED_ORDER_TRACKING_ID}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_CREATED_ROUTE.id}"
    And Driver submit pod to "SUCCESS" waypoint
      | routeId    | {KEY_CREATED_ROUTE.id}                                     |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | driverId   | {driver-2-id}                                              |
    Then Shipper gets webhook request for event "Successful Delivery" for all orders
    And Shipper verifies webhook request payload has correct details for status "Successful Delivery"
