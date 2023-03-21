@ForceSuccessOrder @DeleteReservationAndAddress @routing @order-tag-to-dp @routing-refactor
Feature: Order Tag to DP

  @happy-path
  Scenario: Add to DP Holding Route upon Hub Inbound
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                   |
      | service_level                 | Standard                 |
      | parcel_job_is_pickup_required | false                    |
      | dp-address-unit-number        | {dp-address-unit-number} |
      | dp-address-postcode           | {dp-address-postcode}    |
      | dp-holding-route-id           | {dp-holding-route-id}    |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And Operator search for "DELIVERY" transaction with status "PENDING"

    Then DB Operator verifies transaction routed to new route id

    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies route_monitoring_data record
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE           |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeId          | {KEY_CREATED_ROUTE_ID} |
      | routeEventSource | ADD_BY_ORDER_DP        |
    And API Event - Operator verify that event is published with the following details:
      | event   | HUB_INBOUND_SCAN       |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP         |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS         |
      | orderId | {KEY_CREATED_ORDER_ID} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV              |
      | orderId | {KEY_CREATED_ORDER_ID} |

  @ArchiveDriverRoutes
  Scenario: PUT /2.0/orders/:orderId/routes-dp - Add Order to DP Holding Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator new add parcel to DP holding route
    And Operator search for "DELIVERY" transaction with status "PENDING"

    Then DB Operator verifies transaction routed to new route id

    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies route_monitoring_data record
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE           |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeId          | {KEY_CREATED_ROUTE_ID} |
      | routeEventSource | ADD_BY_ORDER_DP        |

  @happy-path
  Scenario: DELETE /2.0/orders/:orderId/routes-dp - Remove DP Order From Holding Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel                   |
      | service_level                 | Standard                 |
      | parcel_job_is_pickup_required | false                    |
      | dp-address-unit-number        | {dp-address-unit-number} |
      | dp-address-postcode           | {dp-address-postcode}    |
      | dp-holding-route-id           | {dp-holding-route-id}    |
    And Operator perform global inbound at hub "{sorting-hub-id}"
    When Operator pull DP order out of route
    And Operator search for "DELIVERY" transaction with status "PENDING"

    Then DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | REMOVE_BY_ORDER_DP     |

  Scenario: POST /2.0/orders/:orderId/dropoff - Drop Off DP Order
    Given Shipper id "{shipper-id}" subscribes to "Arrived at Distribution Point" webhook
    When Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | numberOfOrder       | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","from":{"name": "binti v4.1","phone_number": "+65189168","email": "binti@test.co", "address": {"address1": "Orchard Road central","address2": "","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
   # And Operator inbounds all orders at hub "{sorting-hub-id}"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
#    And Operator search for "DELIVERY" transaction with status "PENDING"
    And API DP - Operator tag order to DP:
      | request | { "order_id": {KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id": {dp-id},"drop_off_date": "{date: 0 days next, yyyy-MM-dd}"} |
    And API Core - Operator perform dp drop off with order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And Operator search for "DELIVERY" transaction with status "SUCCESS" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Operator verifies all waypoints status is "SUCCESS"
   # And Shipper gets webhook request for event "Arrived at Distribution Point"
    And Shipper gets webhook request for event "Arrived at Distribution Point" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    #And Shipper verifies webhook request payload has correct details for status "Arrived at Distribution Point"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Distribution Point" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Operator verify that all orders status-granular status is "Transit"-"ARRIVED_AT_DISTRIBUTION_POINT"
  #And Operator verify that all orders status-granular status is {string}-{string}
#    And Operator verify that order status-granular status is "Transit"-"ARRIVED_AT_DISTRIBUTION_POINT"
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                      |
      | orderId            | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | updateStatusReason | TRANSFER_FROM_DRIVER_TO_PUDO       |