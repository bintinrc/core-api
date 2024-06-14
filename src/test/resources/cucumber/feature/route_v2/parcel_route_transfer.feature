@ArchiveDriverRoutes @parcel-route-transfer
Feature: Parcel Route Transfer

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Resolve MISSING PETS Ticket
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{date: 1 days next, yyyy-MM-dd}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{date: 1 days next, yyyy-MM-dd}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Recovery - Operator create recovery ticket:
      | trackingId         | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | ticketType         | MISSING                               |
      | entrySource        | RECOVERY SCANNING                     |
      | investigatingParty | {DEFAULT-INVESTIGATING-PARTY}         |
      | investigatingHubId | {DEFAULT-INVESTIGATING-HUB}           |
      | orderOutcomeName   | ORDER OUTCOME (MISSING)               |
      | creatorUserId      | {DEFAULT-CREATOR-USER-ID}             |
      | creatorUserName    | {DEFAULT-CREATOR-USERNAME}            |
      | creatorUserEmail   | {DEFAULT-CREATOR-EMAIL}               |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ON_HOLD"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
    Then API Recovery - verify ticket details:
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}   |
      | ticketId   | {KEY_CREATED_RECOVERY_TICKET.ticket.id} |
      | status     | RESOLVED                                |
      | outcome    | FOUND - INBOUND                         |
    And API Core - Operator verify that "TICKET_RESOLVED" event is published for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Unrouted Single Delivery
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{date: 1 days next, yyyy-MM-dd}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{date: 1 days next, yyyy-MM-dd}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | hubId                | {sorting-hub-id}                      |
      | globalInboundRequest | { "hubId":{sorting-hub-id} }          |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
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
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Unrouted Multiple Deliveries
    Given API Order - Shipper create multiple V4 orders using data below:
      | numberOfOrder       | 3                                                                                                                                                                                                                                                                                                                                |
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[3] |
    And API Sort - Operator global inbound multiple parcel for "{sorting-hub-id}" hub id with data below:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[3] |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    # check order 1
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
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
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
       #check order 2
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[2]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      # check order 3
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[3]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[3].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[3].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[3].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Routed Delivery
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{date: 1 days next, yyyy-MM-dd}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{date: 1 days next, yyyy-MM-dd}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | hubId                | {sorting-hub-id}                      |
      | globalInboundRequest | { "hubId":{sorting-hub-id} }          |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Routed Fail Delivery
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{date: 1 days next, yyyy-MM-dd}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{date: 1 days next, yyyy-MM-dd}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | hubId                | {sorting-hub-id}                      |
      | globalInboundRequest | { "hubId":{sorting-hub-id} }          |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                                                                                     |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-2-id}                      |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                  |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                                          |
      | routes          | KEY_DRIVER_ROUTES                                                                                   |
      | jobType         | TRANSACTION                                                                                         |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL","failure_reason_id":18}] |
      | jobAction       | FAIL                                                                                                |
      | jobMode         | DELIVERY                                                                                            |
      | failureReasonId | 18                                                                                                  |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "PENDING_RESCHEDULE"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Route has Assigned Delivery Waypoint
    Given API Order - Shipper create multiple V4 orders using data below:
      | numberOfOrder       | 2                                                                                                                                                                                                                                                                                                                                |
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
    And API Sort - Operator global inbound multiple parcel for "{sorting-hub-id}" hub id with data below:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
        #check order 2
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[2]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Completed
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Core - Operator force success order "{KEY_LIST_OF_CREATED_ORDERS[1].id}" with cod collected "false"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And Verify Parcel Route Transfer Failed Orders with message : "ORDER_STATUS_IS_COMPLETED"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "COMPLETED"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Cancelled
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Core - cancel order "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And Verify Parcel Route Transfer Failed Orders with message : "ORDER_STATUS_IS_CANCELLED"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "CANCELLED"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel with Status = Returned to Sender
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Core - Operator update order granular status:
      | orderId        | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | granularStatus | Returned to Sender                 |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And Verify Parcel Route Transfer Failed Orders with message : "ORDER_STATUS_IS_RETURNED_TO_SENDER"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "RETURNED_TO_SENDER"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | null                                               |

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel to Past Date Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Operator create an empty route with past date
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    When Driver Transfer Parcel to Route with route past date "{KEY_CREATED_ROUTE_ID}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    Then Operator verify response code is 400 with error message "{\"error\":{\"application_exception_code\":173000,\"application\":\"ROUTE-V2\",\"title\":\"REQUEST_ERR\",\"message\":\"[routeDate={gradle-previous-1-day-yyyy-MM-dd}][todayDate={gradle-current-date-yyyy-MM-dd}]: cannot add waypoint to route with date before today\"}}"

  @MediumPriority
  Scenario: Driver Not Allowed to Route Transfer Parcel - route archived
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Core - Operator archives routes below:
      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    When Driver Transfer Parcel to Archived route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
    Then Operator verify response code is 400 with error message "{\"error\":{\"application_exception_code\":173000,\"application\":\"ROUTE-V2\",\"title\":\"REQUEST_ERR\",\"message\":\"[routeID={KEY_LIST_OF_CREATED_ROUTES[1].id}][status=ARCHIVED]: cannot add/remove waypoint if route not in [PENDING IN_PROGRESS] status\"}}"

  @HighPriority
  Scenario: Driver Route Transfer Parcel - Merged Waypoints
    Given API Order - Shipper create multiple V4 orders using data below:
      | numberOfOrder       | 2                                                                                                                                                                                                                                                                                                                                |
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
    And API Sort - Operator global inbound multiple parcel for "{sorting-hub-id}" hub id with data below:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    And API Core - Operator add parcel to the route using data below:
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                           |
      | addParcelToRouteRequest | {"tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
    And API Core - Operator add parcel to the route using data below:
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[2].id}                                                                                           |
      | addParcelToRouteRequest | {"tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[2].trackingId}","route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
    And API Core - Operator merge routed waypoints:
      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
    Then API Core - Operator verifies "Delivery" transactions of following orders have different waypoint id:
      | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      # check order 1
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
       #check order 2
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[2]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |

  @MediumPriority
  Scenario: Driver Route Transfer Parcel - Partial Transfer Waypoints
    Given API Order - Shipper create multiple V4 orders using data below:
      | numberOfOrder       | 3                                                                                                                                                                                                                                                                                                                                |
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                          |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get multiple order details for tracking ids:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[3] |
    When API Core - Operator force success order "{KEY_LIST_OF_CREATED_ORDERS[3].id}" with cod collected "false"
    And API Sort - Operator global inbound multiple parcel for "{sorting-hub-id}" hub id with data below:
      | KEY_LIST_OF_CREATED_TRACKING_IDS[1] |
      | KEY_LIST_OF_CREATED_TRACKING_IDS[2] |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Route - Operator transfer following parcels to a new route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[2]} |
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    # check order 1 success
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
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
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
       #check order 2 success
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[2]}" with granular status "ARRIVED_AT_SORTING_HUB"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[2].waypointId} |
      | seqNo    | 100                                                        |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ROUTE_TRANSFER_SCAN                |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ROUTE_TRANSFER                     |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[2].id} |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      #check order 3 failed
    And Verify Parcel Route Transfer Failed Orders with message : "ORDER_STATUS_IS_COMPLETED"
      | {KEY_LIST_OF_CREATED_TRACKING_IDS[3]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[3]}" with granular status "COMPLETED"
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | null                                               |
    And DB Routing Search - verify transactions record:
      | txnId   | {KEY_LIST_OF_CREATED_ORDERS[3].transactions[2].id} |
      | routeId | null                                               |


