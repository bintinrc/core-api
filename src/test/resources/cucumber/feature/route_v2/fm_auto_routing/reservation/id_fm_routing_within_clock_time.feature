@routing-id @CancelCreatedReservations @ArchiveDriverRoutes @fm-routing-rsvn-id-within
Feature: ID - FM Automated Routing - Within Clock Time

  # Can only run within: 8am - 8pm ID time

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Date = Today, Creation = Within Start & End Clock Time, Driver has Existing Route - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":<zone_id>, "hubId":<hub_id>, "vehicleId":{vehicle-id}, "driverId":<driver_id> } |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "global_shipper_id": <shipper_global_id>, "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    Then DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
    And DB Core - verify waypoints record:
      | id            | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                         |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status        | Routed                                           |
      | routingZoneId | <zone_id>                                        |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                         |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
      | status        | Routed                                           |
      | routingZoneId | <zone_id>                                        |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}               |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}        |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | waypointStatus | Routed                                   |
      | driverId       | <driver_id>                              |
    Examples:
      | Note                      | zone_id             | hub_id                          | shipper_legacy_id                          | shipper_global_id                   | driver_id          | address_id                          |
      | Pickup Type: FM Dedicated | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-fm-dedicated} | {fm-rsvn-shipper-legacy-id-1-fm-dedicated} | {fm-rsvn-shipper-id-1-fm-dedicated} | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-truck}        | {fm-rsvn-shipper-legacy-id-1-truck}        | {fm-rsvn-shipper-id-1-truck}        | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Date = Today, Creation = Within Start & End Clock Time, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | {"global_shipper_id": <shipper_global_id>, "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - get latest route_logs record for driver id "<driver_id>"
    Then DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status   | 0                                        |
      | hubId    | <hub_id>                                 |
      | zoneId   | <zone_id>                                |
      | driverId | <driver_id>                              |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                         |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId}         |
      | status        | Routed                                           |
      | routingZoneId | <zone_id>                                        |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId}         |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id}              |
      | userId     | {route-v2-service-user-id}                            |
      | userName   | {route-v2-service-user-name}                          |
      | userEmail  | {route-v2-service-user-email}                         |
      | type       | 1                                                     |
      | pickupType | 1                                                     |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].legacyId}} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | waypointStatus | Routed                                   |
      | driverId       | <driver_id>                              |
    Examples:
      | Note                      | zone_id             | hub_id                          | shipper_legacy_id                          | shipper_global_id                   | driver_id          | address_id                          |
      | Pickup Type: FM Dedicated | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-fm-dedicated} | {fm-rsvn-shipper-legacy-id-1-fm-dedicated} | {fm-rsvn-shipper-id-1-fm-dedicated} | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-truck}        | {fm-rsvn-shipper-legacy-id-1-truck}        | {fm-rsvn-shipper-id-1-truck}        | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Date = Today, No Driver Assigned for the Zone, Creation = Within Start & End Clock Time - <Note>
    Given API Core - Operator create reservation using data below:
      | reservationRequest | {"global_shipper_id": <shipper_global_id>, "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | Note                      | zone_id             | shipper_legacy_id                          | shipper_global_id                   | address_id                          |
      | Pickup Type: FM Dedicated | {fm-rsvn-zone-id-2} | {fm-rsvn-shipper-legacy-id-2-fm-dedicated} | {fm-rsvn-shipper-id-2-fm-dedicated} | {fm-rsvn-address-id-2-fm-dedicated} |
      | Pickup Type: Truck        | {fm-rsvn-zone-id-2} | {fm-rsvn-shipper-legacy-id-2-truck}        | {fm-rsvn-shipper-id-2-truck}        | {fm-rsvn-address-id-2-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Date = Today, Pickup Type = Hybrid, Creation = Within Start & End Clock Time
    Given API Core - Operator create reservation using data below:
      | reservationRequest | {"global_shipper_id": <shipper_global_id>, "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | zone_id             | shipper_legacy_id                    | shipper_global_id             | address_id                    |
      | {fm-rsvn-zone-id-3} | {fm-rsvn-shipper-legacy-id-3-hybrid} | {fm-rsvn-shipper-id-3-hybrid} | {fm-rsvn-address-id-3-hybrid} |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Date = Tomorrow, Creation = Within Start & End Clock Time
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | {"global_shipper_id": <shipper_global_id>, "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 1 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 1 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | Note                      | zone_id             | hub_id                          | shipper_legacy_id                          | shipper_global_id                   | driver_id          | address_id                          |
      | Pickup Type: FM Dedicated | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-fm-dedicated} | {fm-rsvn-shipper-legacy-id-1-fm-dedicated} | {fm-rsvn-shipper-id-1-fm-dedicated} | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-rsvn-zone-id-1} | {fm-rsvn-hub-id-1-truck}        | {fm-rsvn-shipper-legacy-id-1-truck}        | {fm-rsvn-shipper-id-1-truck}        | {fm-rsvn-driver-1} | {fm-rsvn-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Order Create Flow, Date = Today, Creation = Within Start & End Clock Time, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "{fm-rsvn-driver-id-4}"
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-rsvn-shipper-4-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | shipperClientSecret | {fm-rsvn-shipper-4-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Core - get Order Pickup Data from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_CORE_LIST_OF_ORDER_PICKUPS[1].reservationId}"
    And DB Route - get latest route_logs record for driver id "{fm-rsvn-driver-id-4}"
    Then DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status   | 0                                        |
      | hubId    | {fm-rsvn-hub-id-4}                       |
      | zoneId   | {fm-rsvn-zone-id-4}                      |
      | driverId | {fm-rsvn-driver-id-4}                    |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                 |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status        | Routed                                   |
      | routingZoneId | {fm-rsvn-zone-id-4}                      |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_RESERVATIONS[1].id}                      |
      | userId     | {route-v2-service-user-id}                            |
      | userName   | {route-v2-service-user-name}                          |
      | userEmail  | {route-v2-service-user-email}                         |
      | type       | 1                                                     |
      | pickupType | 1                                                     |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].legacyId}} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_RESERVATIONS[1].id}         |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | waypointStatus | Routed                                   |
      | driverId       | {fm-rsvn-driver-id-4}                    |
    Examples:
      | Note                      | pickup_address_id                           | pickup_address                                                                                                                                                                                                                                              |
      | Pickup Type: FM Dedicated | {fm-rsvn-address-id-4-fm-dedicated-ext-ref} | { "name": "CoreFmIdRsvn4", "phone_number": "+62821333333", "email": "CoreFmIdRsvn4@gmail.com", "address": { "address1": "Papua4", "address2": "", "country": "ID", "postcode": "45115", "latitude": -2.9233724110958113, "longitude": 132.3026922746305 } } |
      | Pickup Type: Truck        | {fm-rsvn-address-id-4-truck-ext-ref}        | { "name": "CoreFmIdRsvn4", "phone_number": "+62821333333", "email": "CoreFmIdRsvn4@gmail.com", "address": { "address1": "Papua4", "address2": "", "country": "ID", "postcode": "45115", "latitude": -2.9233724110958113, "longitude": 132.3026922746305 } } |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: ID - Auto Route Reservation - Order Create Flow, Date = Today, Creation = Within Start & End Clock Time, Driver has Existing Route
    Given API Route - Operator archive all unarchived routes of driver id "{fm-rsvn-driver-id-4}"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{fm-rsvn-zone-id-4}, "hubId":{fm-rsvn-hub-id-4}, "vehicleId":{vehicle-id}, "driverId":{fm-rsvn-driver-id-4} } |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-rsvn-shipper-4-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | shipperClientSecret | {fm-rsvn-shipper-4-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id_1>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-rsvn-shipper-4-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | shipperClientSecret | {fm-rsvn-shipper-4-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id_2>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Core - get Order Pickup Data from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[2]}"
    And DB Core - get Order Pickup Data from order id "{KEY_LIST_OF_CREATED_ORDERS[2].id}"
    And API Core - Operator get reservation from reservation id "{KEY_CORE_LIST_OF_ORDER_PICKUPS[1].reservationId}"
    And API Core - Operator get reservation from reservation id "{KEY_CORE_LIST_OF_ORDER_PICKUPS[2].reservationId}"
#    check 1st rsvn
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                 |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | status        | Routed                                   |
      | routingZoneId | {fm-rsvn-zone-id-4}                      |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_RESERVATIONS[1].id}                |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_RESERVATIONS[1].id}   |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | waypointStatus | Routed                             |
      | driverId       | {fm-rsvn-driver-id-4}              |
    #    check 2nd rsvn
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_RESERVATIONS[2].waypointId} |
      | seqNo         | not null                                 |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | status        | Routed                                   |
      | routingZoneId | {fm-rsvn-zone-id-4}                      |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_RESERVATIONS[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    And DB Events - verify pickup_events record:
      | pickupId   | {KEY_LIST_OF_RESERVATIONS[2].id}                |
      | userId     | {route-v2-service-user-id}                      |
      | userName   | {route-v2-service-user-name}                    |
      | userEmail  | {route-v2-service-user-email}                   |
      | type       | 1                                               |
      | pickupType | 1                                               |
      | data       | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id}} |
    And DB Core - verify shipper_pickup_search record:
      | reservationId  | {KEY_LIST_OF_RESERVATIONS[2].id}   |
      | routeId        | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | waypointStatus | Routed                             |
      | driverId       | {fm-rsvn-driver-id-4}              |
    Examples:
      | pickup_address_id_1                         | pickup_address_id_2                  | pickup_address                                                                                                                                                                                                                                              |
      | {fm-rsvn-address-id-4-fm-dedicated-ext-ref} | {fm-rsvn-address-id-4-truck-ext-ref} | { "name": "CoreFmIdRsvn4", "phone_number": "+62821333333", "email": "CoreFmIdRsvn4@gmail.com", "address": { "address1": "Papua4", "address2": "", "country": "ID", "postcode": "45115", "latitude": -2.9233724110958113, "longitude": 132.3026922746305 } } |