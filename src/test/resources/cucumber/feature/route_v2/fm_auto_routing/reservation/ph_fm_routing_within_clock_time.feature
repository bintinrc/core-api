@routing-ph @CancelCreatedReservations @fm-routing-rsvn-ph-2
Feature: PH - FM Automated Routing

   # Can only run within: 6am - 6pm PH time

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Date = Today, Creation = Within Start & End Clock Time, Driver has Existing Route - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":<zone_id>, "hubId":<hub_id>, "vehicleId":{vehicle-id}, "driverId":<driver_id> } |
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":<address_id>,"global_shipper_id":<global_shipper_id>, "legacy_shipper_id":<shipper_legacy_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    Then DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | status   | 0                                  |
      | hubId    | <hub_id>                           |
      | zoneId   | <zone_id>                          |
      | driverId | <driver_id>                        |
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
      | Note                      | zone_id        | hub_id                     | shipper_legacy_id                     | global_shipper_id              | driver_id     | address_id                     |
      | Pickup Type: FM Dedicated | {fm-zone-id-1} | {fm-hub-id-1-fm-dedicated} | {fm-shipper-legacy-id-1-fm-dedicated} | {fm-shipper-id-1-fm-dedicated} | {fm-driver-1} | {fm-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-zone-id-1} | {fm-hub-id-1-truck}        | {fm-shipper-legacy-id-1-truck}        | {fm-shipper-id-1-truck}        | {fm-driver-1} | {fm-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Date = Today, Creation = Within Start & End Clock Time, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>,"global_shipper_id":<global_shipper_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
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
      | Note                      | zone_id        | hub_id                     | shipper_legacy_id                     | global_shipper_id              | driver_id     | address_id                     |
      | Pickup Type: FM Dedicated | {fm-zone-id-1} | {fm-hub-id-1-fm-dedicated} | {fm-shipper-legacy-id-1-fm-dedicated} | {fm-shipper-id-1-fm-dedicated} | {fm-driver-1} | {fm-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-zone-id-1} | {fm-hub-id-1-truck}        | {fm-shipper-legacy-id-1-truck}        | {fm-shipper-id-1-truck}        | {fm-driver-1} | {fm-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Date = Today, No Driver Assigned for the Zone, Creation = Within Start & End Clock Time - <Note>
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>,"global_shipper_id":<global_shipper_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | Note                      | zone_id        | shipper_legacy_id                     | global_shipper_id              | address_id                     |
      | Pickup Type: FM Dedicated | {fm-zone-id-3} | {fm-shipper-legacy-id-3-fm-dedicated} | {fm-shipper-id-3-fm-dedicated} | {fm-address-id-3-fm-dedicated} |
      | Pickup Type: Truck        | {fm-zone-id-3} | {fm-shipper-legacy-id-3-truck}        | {fm-shipper-id-3-truck}        | {fm-address-id-3-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Date = Today, Pickup Type = Hybrid, Creation = Within Start & End Clock Time
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>,"global_shipper_id":<global_shipper_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 0 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 0 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | zone_id        | shipper_legacy_id               | global_shipper_id        | address_id               |
      | {fm-zone-id-4} | {fm-shipper-legacy-id-4-hybrid} | {fm-shipper-id-4-hybrid} | {fm-address-id-4-hybrid} |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Date = Tomorrow, Creation = Within Start & End Clock Time
    Given API Route - Operator archive all unarchived routes of driver id "<driver_id>"
    Given API Core - Operator create reservation using data below:
      | reservationRequest | { "pickup_address_id":<address_id>, "legacy_shipper_id":<shipper_legacy_id>,"global_shipper_id":<global_shipper_id>, "pickup_approx_volume":"Less than 10 Parcels", "pickup_start_time":"{date: 1 days next, yyyy-MM-dd}T09:00:00{gradle-timezone-XXX}", "pickup_end_time":"{date: 1 days next, yyyy-MM-dd}T22:00:00{gradle-timezone-XXX}" } |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId} |
      | seqNo         | null                                             |
      | routeId       | null                                             |
      | status        | Pending                                          |
      | routingZoneId | <zone_id>                                        |
    Examples:
      | Note                      | zone_id        | shipper_legacy_id                     | global_shipper_id              | driver_id     | address_id                     |
      | Pickup Type: FM Dedicated | {fm-zone-id-1} | {fm-shipper-legacy-id-1-fm-dedicated} | {fm-shipper-id-1-fm-dedicated} | {fm-driver-1} | {fm-address-id-1-fm-dedicated} |
      | Pickup Type: Truck        | {fm-zone-id-1} | {fm-shipper-legacy-id-1-truck}        | {fm-shipper-id-1-truck}        | {fm-driver-1} | {fm-address-id-1-truck}        |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Order Create Flow, Date = Today, Creation = Within Start & End Clock Time, Driver has No Routes - <Note>
    Given API Route - Operator archive all unarchived routes of driver id "{fm-driver-id-5}"
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-shipper-5-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | shipperClientSecret | {fm-shipper-5-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Core - get Order Pickup Data from order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get reservation from reservation id "{KEY_CORE_LIST_OF_ORDER_PICKUPS[1].reservationId}"
    And DB Route - get latest route_logs record for driver id "{fm-driver-id-5}"
    Then DB Route - verify route_logs record:
      | legacyId | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status   | 0                                        |
      | hubId    | {fm-hub-id-5}                            |
      | zoneId   | {fm-zone-id-5}                           |
      | driverId | {fm-driver-id-5}                         |
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_RESERVATIONS[1].waypointId} |
      | seqNo         | not null                                 |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].legacyId} |
      | status        | Routed                                   |
      | routingZoneId | {fm-zone-id-5}                           |
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
      | driverId       | {fm-driver-id-5}                         |
    Examples:
      | Note                      | pickup_address_id                      | pickup_address                                                                                                                                                                                                                                                                 |
      | Pickup Type: FM Dedicated | {fm-address-id-5-fm-dedicated-ext-ref} | { "name": "binti v4.1", "phone_number": "+65189189", "email": "binti@test.co", "address": { "address1": "barangay 140 pasay city metro manila", "address2": "#20-25", "country": "PH", "postcode": "1300", "latitude": "14.5400587875001", "longitude": "121.006363105892" } } |
      | Pickup Type: Truck        | {fm-address-id-5-truck-ext-ref}        | { "name": "binti v4.1", "phone_number": "+65189189", "email": "binti@test.co", "address": { "address1": "barangay 140 pasay city metro manila","address2": "#20-25","postcode": "1300","country": "PH","latitude": 14.5400587875001,"longitude": 121.006363105892} }           |

  @CancelCreatedReservations @HighPriority
  Scenario Outline: PH - Auto Route Reservation - Order Create Flow, Date = Today, Creation = Within Start & End Clock Time, Driver has Existing Route
    Given API Route - Operator archive all unarchived routes of driver id "{fm-driver-id-5}"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{fm-zone-id-5}, "hubId":{fm-hub-id-5}, "vehicleId":{vehicle-id}, "driverId":{fm-driver-id-5} } |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-shipper-5-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {fm-shipper-5-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | v4OrderRequest      | { "service_type": "Parcel", "service_level": "Standard", "from":<pickup_address>, "parcel_job": { "pickup_address_id": "<pickup_address_id_1>", "pickup_address": <pickup_address>, "dimensions": { "height": 2.7, "length": 2.8, "width": 1 }, "is_pickup_required": true, "pickup_date": "{date: 0 days next, yyyy-MM-dd}", "pickup_timeslot": { "start_time": "09:00", "end_time": "22:00" }, "delivery_start_date": "{date: 0 days next, yyyy-MM-dd}", "delivery_timeslot": { "start_time": "09:00", "end_time": "22:00" } } } |
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {fm-shipper-5-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {fm-shipper-5-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
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
      | routingZoneId | {fm-zone-id-5}                           |
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
      | driverId       | {fm-driver-id-5}                   |
    #    check 2nd rsvn
    And DB Route - verify waypoints record:
      | legacyId      | {KEY_LIST_OF_RESERVATIONS[2].waypointId} |
      | seqNo         | not null                                 |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
      | status        | Routed                                   |
      | routingZoneId | {fm-zone-id-5}                           |
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
      | driverId       | {fm-driver-id-5}                   |
    Examples:
      | pickup_address_id_1                    | pickup_address_id_2             | pickup_address                                                                                                                                                                                                                                                                 |
      | {fm-address-id-5-fm-dedicated-ext-ref} | {fm-address-id-5-truck-ext-ref} | { "name": "binti v4.1", "phone_number": "+65189189", "email": "binti@test.co", "address": { "address1": "barangay 140 pasay city metro manila", "address2": "#20-25", "country": "PH", "postcode": "1300", "latitude": "14.5400587875001", "longitude": "121.006363105892" } } |
