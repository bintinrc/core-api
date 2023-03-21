@ForceSuccessOrder @ArchiveDriverRoutes @DeleteReservationAndAddress @routing @zonal-routing-api @routing-refactor
Feature: Zonal Routing API

  @happy-path
  Scenario: Zonal Routing API - Create Driver Route & Assign Waypoints
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_CREATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_CREATE              |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly

  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Add Unrouted Waypoints to Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator edit route from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly

  @happy-path
  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Edit Waypoint Sequence
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator edit route from Zonal Routing API
      | driver_id        | {driver-id}  |
      | vehicle_id       | {vehicle-id} |
      | to_edit_sequence | true         |
    And DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly
    And Verify waypoints.seq_no & driver list waypoint ordering is correct

  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Remove Waypoints From Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then DB Operator verifies all transactions routed to new route id
    When Operator edit route by removing waypoints from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    # check for still routed waypoint
    Then DB Operator verifies transaction routed to new route id
    And DB Operator verifies waypoint status is "ROUTED"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies route_monitoring_data record

    # check for removed waypoints
    Then DB Operator verifies all transactions route id is null
    And DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL
    And DB Operator verifies all route_monitoring_data is hard-deleted
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that driver "{driver-id}" list route showing only routed waypoints

  @happy-path
  Scenario: Zonal Routing Edit Route API - Bulk Edit Waypoints Inside Multiple Routes - Move Routed Waypoints to Another Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then DB Operator verifies all transactions routed to new route id
    When API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And Operator edit route by moving to another route from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    #  TRANSACTION - DELIVERY
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[1]} |
      | routeId | {KEY_CREATED_ROUTE_ID}           |
    #  TRANSACTION - PICKUP
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_TRANSACTION_IDS[2]} |
      | routeId | {KEY_CREATED_ROUTE_ID}           |
    #  WAYPOINT - RESERVATION
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_WAYPOINT_IDS[1]}      |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[1]}      |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    #  WAYPOINT - DELIVERY
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_WAYPOINT_IDS[2]}      |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[2]}      |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    #  WAYPOINT - PICKUP
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_WAYPOINT_IDS[3]}      |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[3]}      |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    # RMD - RESERVATION
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_WAYPOINT_IDS[1]}      |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    # RMD - DELIVERY
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_WAYPOINT_IDS[2]}      |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    # RMD - PICKUP
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_WAYPOINT_IDS[3]}      |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                 |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | routeEventSource | ZONAL_ROUTING_UPDATE              |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And Verify that waypoints are shown on driver "{driver-id}" list route correctly
    And Verify that waypoints are not shown on previous driver list route


  Scenario: Add Merged Unrouted Waypoint to a Route from Zonal Routing Edit Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for multiple "DELIVERY" transactions with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Operator edit route by removing merged waypoints from Zonal Routing API
      | driver_id  | {driver-id}  |
      | vehicle_id | {vehicle-id} |
    And Operator add order to driver "DELIVERY" route
    And Operator gets only eligible routed orders
    #    verify remaining unrouted order
    And DB Operator verifies transaction route id is null
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL
    And DB Operator verifies route_monitoring_data is hard-deleted
    #    verify routed orders
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all waypoints status is "ROUTED"
    And DB Operator verifies all waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                      |
      | orderId          | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | routeId          | {KEY_CREATED_ROUTE_ID}            |
      | routeEventSource | ADD_BY_ORDER                      |

  Scenario: Zonal Routing Edit Route API - Not Allowed to Move Success Waypoints to Another Route
    Given Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    When Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for "DELIVERY" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator force success all orders
    When API Route - Operator edit route from Zonal Routing API with Invalid State
      | driverId  | {driver-id}                       |
      | vehicleId | {vehicle-id}                      |
      | id        | {KEY_LIST_OF_CREATED_ROUTE_ID[1]} |
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103102                                                                                                                       |
      | message     | Unexpected Exception [Exception:java.lang.RuntimeException: Attempted waypoints are not allowed to be removed! Waypoints:%s] |
      | application | core                                                                                                                         |
      | description | INTERNAL_SERVER_ERROR                                                                                                        |
      | values      | {KEY_LIST_OF_WAYPOINT_IDS[1]},{KEY_LIST_OF_WAYPOINT_IDS[2]}                                                                  |
    Then DB Operator verifies all transactions routed to new route id
    And DB Operator verifies all waypoints status is "SUCCESS"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly
    And DB Operator verifies all route_monitoring_data records


  Scenario: Zonal Routing API - Set Routed Waypoint to Pending
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When API Route - Operator create route from Zonal Routing API with Invalid State
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then Operator verify response code is 400 with error message "[{KEY_LIST_OF_WAYPOINT_IDS[1]}]"
    Then API Core - Operator update routed waypoint to pending
      | id             | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | status         | PENDING                       |
      | rawAddressFlag | false                         |
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted

  Scenario Outline: Zonal Routing API - Not Allowed to Set Attempted Waypoint to Pending - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for "PICKUP" transaction with status "PENDING"
    And Operator create a route and assign waypoint from Zonal Routing API
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And API Operator update order granular status:
      | orderId        | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | granularStatus | <granularStatus>                  |
    When API Route - Operator create route from Zonal Routing API with Invalid State
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    Then Operator verify response code is 400 with error message "[{KEY_LIST_OF_WAYPOINT_IDS[1]}]"
    Then API Core - Operator update routed waypoint to pending
      | id             | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | status         | PENDING                       |
      | rawAddressFlag | false                         |
    And DB Operator verifies transaction routed to new route id

    And DB Operator verifies waypoint status is "<waypointStatus>"
    And DB Operator verifies waypoints.route_id & seq_no is populated correctly

    And DB Operator verifies route_monitoring_data record

    Examples:
      | Note             | granularStatus         | waypointStatus |
      | Success Waypoint | Arrived at Sorting Hub | Success        |
      | Fail Waypoint    | Pickup fail            | Fail           |

  @happy-path
  Scenario: Zonal Routing API - Unmerge Waypoint with Multiple Transactions
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
    Then API Operator verifies Delivery transactions of following orders have different waypoint id:
      | {KEY_LIST_OF_CREATED_ORDER_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[2]} |
      | {KEY_LIST_OF_CREATED_ORDER_ID[3]} |
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    Then DB Operator verifies all waypoints status is "PENDING"
    And DB Operator verifies all waypoints.route_id & seq_no is NULL

  Scenario: Zonal Routing API - Create Driver Route & Assign Reservation Waypoints
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | 397                                             |
      | userName   | AUTOMATION EDITED                               |
      | userEmail  | qa@ninjavan.co                                  |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  Scenario: Zonal Routing Edit Route API - Edit Reservation Waypoints Inside a Route - Add Unrouted Reservation Waypoints to Route
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | 397                                             |
      | userName   | AUTOMATION EDITED                               |
      | userEmail  | qa@ninjavan.co                                  |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  Scenario: Zonal Routing Edit Route API - Bulk Edit Reservation Waypoints Inside Multiple Routes - Move Routed Reservation Waypoints to Another Route
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}]} |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[2].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_WAYPOINT_ID}                  |
      | seqNo   | not null                           |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status  | Routed                             |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_WAYPOINT_ID}                  |
      | seqNo    | not null                           |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | status   | Routed                             |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_WAYPOINT_ID}                  |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}                                                          |
      | userId     | 397                                                                                               |
      | userName   | AUTOMATION EDITED                                                                                 |
      | userEmail  | qa@ninjavan.co                                                                                    |
      | type       | 2                                                                                                 |
      | pickupType | 1                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePickupAppointmentJob
  Scenario: Zonal Routing Edit Route API - Edit Reservation Waypoints Inside a Route - Remove Reservation Waypoints From Route
    When API Operator create new shipper address V2 using data below:
      | shipperId       | {shipper-2-id} |
      | generateAddress | RANDOM         |
    And API Operator create V2 reservation using data below:
      | reservationRequest | { "legacy_shipper_id":{shipper-2-legacy-id}, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":717, "from":{ "addressId":1547535}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Core - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo   | null                                             |
      | routeId | null                                             |
      | status  | Pending                                          |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | null                                             |
      | routeId  | null                                             |
      | status   | Pending                                          |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | 397                                             |
      | userName   | AUTOMATION EDITED                               |
      | userEmail  | qa@ninjavan.co                                  |
      | type       | 3                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
