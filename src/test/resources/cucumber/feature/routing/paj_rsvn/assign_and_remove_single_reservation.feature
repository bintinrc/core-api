@ArchiveRouteCommonV2 @CancelCreatedReservations @routing2 @reservation
Feature: Assign and Remove Single Reservation To Route

  @HighPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 100                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status   | Routed                                           |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | waypointStatus | Routed                                   |
      | driverId       | {driver-id}                              |
    And DB Events - verify pickup_events record:
      | pickupId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId      | {pickup-user-id}                                |
      | userName    | {pickup-user-name}                              |
      | userEmail   | {pickup-user-email}                             |
      | type        | 1                                               |
      | pickup_type | 1                                               |
      | data        | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Reservation Id Doesn't Exist
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator failed to add reservation to route using data below:
      | reservationId                | 124                                |
      | routeId                      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | overwrite                    | false                              |
      | expectedStatusCode           | 404                                |
      | expectedApplicationErrorCode | 103016                             |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Route Id Doesn't Exist
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    When API Core - Operator failed to add reservation to route using data below:
      | reservationId                | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId                      | 124                                      |
      | overwrite                    | false                                    |
      | expectedStatusCode           | 500                                      |
      | expectedApplicationErrorCode | 103102                                   |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Update a Single Routed Reservation to a New Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    When API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[2].id}       |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo    | 100                                              |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}               |
      | status   | Routed                                           |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[2].id}       |
      | waypointStatus | Routed                                   |
      | driverId       | {driver-id}                              |
    And DB Events - verify pickup_events record:
      | pickupId    | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}                                                          |
      | userId      | {pickup-user-id}                                                                                  |
      | userName    | {pickup-user-name}                                                                                |
      | userEmail   | {pickup-user-email}                                                                               |
      | type        | 2                                                                                                 |
      | pickup_type | 1                                                                                                 |
      | data        | {"old_route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id}} |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Reservation Status Success
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","parcel_job":{"is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{"start_time":"12:00","end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}","delivery_timeslot":{"start_time":"09:00","end_time":"22:00"}},"to":{"name":"Sort Automation Customer","email":"sort.automation.customer@ninjavan.co","phone_number":"+6598980004","address":{"address1":"30A ST. THOMAS WALK 102600 SG","address2":"","postcode":"102600","country":"SG","latitude":"1.288147","longitude":"103.740233"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]" with granular status "PENDING_PICKUP"
    And DB Core - get reservation id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_LIST_OF_RESERVATION_IDS[1]}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId            | {driver-id}                              |
      | expectedRouteId     | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | expectedWaypointIds | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
    When API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                    |
      | waypointId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId}                                              |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}", "action": "SUCCESS"}] |
      | routes          | KEY_DRIVER_ROUTES                                                                     |
      | jobType         | RESERVATION                                                                           |
      | jobAction       | SUCCESS                                                                               |
      | jobMode         | PICK_UP                                                                               |
      | globalShipperId | {shipper-id}                                                                          |
    Then API Core - Operator failed to add reservation to route using data below:
      | reservationId                | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId                      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | overwrite                    | false                              |
      | expectedStatusCode           | 400                                |
      | expectedApplicationErrorCode | 103088                             |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/route - Assign a Single Reservation to a Route - Reservation Status Fail
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","parcel_job":{"is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{"start_time":"12:00","end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}","delivery_timeslot":{"start_time":"09:00","end_time":"22:00"}},"to":{"name":"Sort Automation Customer","email":"sort.automation.customer@ninjavan.co","phone_number":"+6598980004","address":{"address1":"30A ST. THOMAS WALK 102600 SG","address2":"","postcode":"102600","country":"SG","latitude":"1.288147","longitude":"103.740233"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]" with granular status "PENDING_PICKUP"
    And DB Core - get reservation id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_LIST_OF_RESERVATION_IDS[1]}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId            | {driver-id}                              |
      | expectedRouteId     | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | expectedWaypointIds | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
    When API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                          |
      | waypointId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId}                                                                    |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}", "action": "FAIL", "failure_reason_id":139}] |
      | failureReasonId | 139                                                                                                         |
      | routes          | KEY_DRIVER_ROUTES                                                                                           |
      | jobType         | RESERVATION                                                                                                 |
      | jobAction       | FAIL                                                                                                        |
      | jobMode         | PICK_UP                                                                                                     |
      | globalShipperId | {shipper-id}                                                                                                |
    Then API Core - Operator failed to add reservation to route using data below:
      | reservationId                | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId                      | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | overwrite                    | false                              |
      | expectedStatusCode           | 400                                |
      | expectedApplicationErrorCode | 103088                             |

  @HighPriority
  Scenario: PUT /2.0/reservations/:routeid/unroute - Remove a Single Reservation from Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    When API Core - Operator remove reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" from route
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

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/unroute - Remove a Single Reservation from Route - Reservation Has No Route
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":{shipper-2-address-id}, "global_shipper_id":{shipper-2-id},  "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    Then API Core - Operator failed to remove reservation id "{KEY_LIST_OF_CREATED_RESERVATIONS[1].id}" from route
      | expectedStatusCode           | 400    |
      | expectedApplicationErrorCode | 103088 |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/unroute - Remove a Single Reservation from Route - Reservation Status Success
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","parcel_job":{"is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{"start_time":"12:00","end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}","delivery_timeslot":{"start_time":"09:00","end_time":"22:00"}},"to":{"name":"Sort Automation Customer","email":"sort.automation.customer@ninjavan.co","phone_number":"+6598980004","address":{"address1":"30A ST. THOMAS WALK 102600 SG","address2":"","postcode":"102600","country":"SG","latitude":"1.288147","longitude":"103.740233"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]" with granular status "PENDING_PICKUP"
    And DB Core - get reservation id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_LIST_OF_RESERVATION_IDS[1]}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId            | {driver-id}                              |
      | expectedRouteId     | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | expectedWaypointIds | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
    When API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                    |
      | waypointId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId}                                              |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}", "action": "SUCCESS"}] |
      | routes          | KEY_DRIVER_ROUTES                                                                     |
      | jobType         | RESERVATION                                                                           |
      | jobAction       | SUCCESS                                                                               |
      | jobMode         | PICK_UP                                                                               |
      | globalShipperId | {shipper-id}                                                                          |
    Then API Core - Operator failed to remove reservation id "{KEY_LIST_OF_RESERVATIONS[1].id}" from route
      | expectedStatusCode           | 400    |
      | expectedApplicationErrorCode | 103088 |

  @MediumPriority
  Scenario: PUT /2.0/reservations/:routeid/unroute - Remove a Single Reservation from Route - Reservation Status Fail
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","parcel_job":{"is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{"start_time":"12:00","end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}","delivery_timeslot":{"start_time":"09:00","end_time":"22:00"}},"to":{"name":"Sort Automation Customer","email":"sort.automation.customer@ninjavan.co","phone_number":"+6598980004","address":{"address1":"30A ST. THOMAS WALK 102600 SG","address2":"","postcode":"102600","country":"SG","latitude":"1.288147","longitude":"103.740233"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]" with granular status "PENDING_PICKUP"
    And DB Core - get reservation id from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_LIST_OF_RESERVATION_IDS[1]}"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId            | {driver-id}                              |
      | expectedRouteId     | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | expectedWaypointIds | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
    When API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                          |
      | waypointId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId}                                                                    |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}", "action": "FAIL", "failure_reason_id":139}] |
      | failureReasonId | 139                                                                                                         |
      | routes          | KEY_DRIVER_ROUTES                                                                                           |
      | jobType         | RESERVATION                                                                                                 |
      | jobAction       | FAIL                                                                                                        |
      | jobMode         | PICK_UP                                                                                                     |
      | globalShipperId | {shipper-id}                                                                                                |
    Then API Core - Operator failed to remove reservation id "{KEY_LIST_OF_RESERVATIONS[1].id}" from route
      | expectedStatusCode           | 400    |
      | expectedApplicationErrorCode | 103088 |
