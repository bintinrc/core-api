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
  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Add Unrouted Waypoints to Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    Given API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} ]} |
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
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
#    check 1st delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    #    check 2nd delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 300                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    #   check return waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].waypointId} |
      | seqNo    | 400                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
#    check reservation waypoint
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 200                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
#    check order events
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
#    check pickup_events
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @happy-path @HighPriority
  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Edit Waypoint Sequence
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
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId},  {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
#    check delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
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
      | seqNo    | 200                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
#    check reservation waypoint
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 300                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |

  @HighPriority
  Scenario: Zonal Routing Edit Route API - Edit Waypoints Inside a Route - Remove Waypoints From Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
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
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    Given API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].waypointId}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
#    check 1st delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    #    check 2nd delivery waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
    #   check return waypoint
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].id} |
      | routeId | null                                               |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[1].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
#    check reservation waypoint
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | null                                             |
      | routeId  | null                                             |
      | status   | Pending                                          |
#    check rmd deleted
    #    check order events
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[3].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
#    check pickup_events
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 3                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @happy-path @HighPriority
  Scenario: Zonal Routing Edit Route API - Bulk Edit Waypoints Inside Multiple Routes - Move Routed Waypoints to Another Route
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
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} ]} |
    When API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [ { "id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "waypoints": [ {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} ], "zoneId": {zone-id}, "hubId": {sorting-hub-id}, "vehicleId": {vehicle-id}, "driverId": {driver-id} }, { "id": {KEY_LIST_OF_CREATED_ROUTES[1].id }, "waypoints": [ {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} ], "zoneId": {zone-id}, "hubId": {sorting-hub-id}, "vehicleId": {vehicle-id}, "driverId": {driver-id} } ] |
    #  TRANSACTION - DELIVERY
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    #  TRANSACTION - PICKUP
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    #  WAYPOINT - RESERVATION
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status   | Routed                                           |
    #  WAYPOINT - DELIVERY
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    #  WAYPOINT - PICKUP
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[1].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    #  WAYPOINT - DELIVERY
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeEventSource | ZONAL_ROUTING_UPDATE               |

  @HighPriority
  Scenario: Add Merged Unrouted Waypoint to a Route from Zonal Routing Edit Route
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When Shipper creates multiple orders : 2 orders with the same params
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2]} |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}, {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId}]} |
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2]} |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator get multiple order details for tracking ids:
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[2]} |
    #  WAYPOINT - RESERVATION
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
#    WAYPOINT - DELIVERY Routed
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
#  WAYPOINT - DELIVERY Unrouted
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | null                                               |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ADD_BY_ORDER                       |

  @MediumPriority
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
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[1]} |
      | seqNo    | not null                      |
      | routeId  | {KEY_CREATED_ROUTE_ID}        |
      | status   | Success                       |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_WAYPOINT_IDS[2]} |
      | seqNo    | not null                      |
      | routeId  | {KEY_CREATED_ROUTE_ID}        |
      | status   | Success                       |

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

  @HighPriority
  Scenario: Zonal Routing Edit Route API - Edit Reservation Waypoints Inside a Route - Add Unrouted Reservation Waypoints to Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
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

  @HighPriority
  Scenario: Zonal Routing Edit Route API - Bulk Edit Reservation Waypoints Inside Multiple Routes - Move Routed Reservation Waypoints to Another Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[2].id}, "waypoints":[{KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | not null                                         |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status   | Routed                                           |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}                                                          |
      | userId     | {pickup-user-id}                                                                                  |
      | userName   | {pickup-user-name}                                                                                |
      | userEmail  | {pickup-user-email}                                                                               |
      | type       | 2                                                                                                 |
      | pickupType | 1                                                                                                 |
      | data       | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @DeletePickupAppointmentJob @HighPriority
  Scenario: Zonal Routing Edit Route API - Edit Reservation Waypoints Inside a Route - Remove Reservation Waypoints From Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Control - Operator create pickup appointment job with data below:
      | createPickupJobRequest | { "shipperId":{shipper-5-id}, "from":{ "addressId":{shipper-5-address-id}}, "pickupService":{ "level":"Standard", "type":"Scheduled"}, "pickupTimeslot":{ "ready":"{gradle-next-1-day-yyyy-MM-dd}T09:00:00+08:00", "latest":"{gradle-next-1-day-yyyy-MM-dd}T12:00:00+08:00"}, "pickupApproxVolume":"Less than 10 Parcels"} |
    And DB Route - get waypoint id for job id "{KEY_CONTROL_CREATED_PA_JOBS[1].id}"
    And API Core - Operator create new route from zonal routing using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}, "waypoints":[{KEY_WAYPOINT_ID}, {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}]} |
    When API Core - Operator Edit Route Waypoint on Zonal Routing Edit Route:
      | editRouteRequest | [{"id":{KEY_LIST_OF_CREATED_ROUTES[1].id}, "waypoints":[{KEY_WAYPOINT_ID}],"zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id}}] |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | null                                             |
      | routeId  | null                                             |
      | status   | Pending                                          |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {pickup-user-id}                                |
      | userName   | {pickup-user-name}                              |
      | userEmail  | {pickup-user-email}                             |
      | type       | 3                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
