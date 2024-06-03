@ForceSuccessOrders @CancelCreatedReservations @ArchiveDriverRoutes  @routing1 @zonal-routing-api @routing-refactor
Feature: Zonal Routing API

  @happy-path @HighPriority
  Scenario: Zonal Routing API - Create Driver Route & Assign Waypoints
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest      | { "service_type":"Return","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} ]} |
#    check delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 200                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
        #   check return waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} |
      | seqNo    | 300                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
#    check reservation waypoint
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 100                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
#    check order events
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ZONAL_ROUTING_CREATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ZONAL_ROUTING_CREATE               |
#    check pickup_events
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @HighPriority
  Scenario: Zonal Routing API - Create Driver Route & Assign Reservation Waypoints
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 100                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |