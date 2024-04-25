@ArchiveRouteCommonV2 @CancelCreatedReservations @driver-api
Feature: Driver API

  @ForceSuccessOrders @happy-path @HighPriority
  Scenario: Driver Van Inbound an Order Delivery
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver van inbound:
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                                                                                     |
      | request | {"parcels":[{"inbound_type":"VAN_FROM_NINJAVAN","tracking_id":"{KEY_LIST_OF_CREATED_ORDERS[1].trackingId}","waypoint_id":{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}}]} |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "On_Vehicle_for_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_INBOUND_SCAN                |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | hubId   | {hub-id}                           |
      | type    | 4                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @HighPriority
  Scenario: Driver Success a Return Pickup
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"PICKUP"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                              |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-2-id}                      |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | PICK_UP                                                                         |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Enroute_to_sorting_hub"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN                 |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | hubId   | {hub-id}                           |
      | type    | 1                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @HighPriority
  Scenario: Driver Success a Reservation Pickup by Scanning Normal Order
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    Given API Shipper - Operator create new shipper address using data below:
      | shipperId       | {shipper-3-id} |
      | generateAddress | RANDOM         |
    And API Core - Operator create reservation using data below:
      | reservationRequest | {"global_shipper_id":{shipper-3-id}, "legacy_shipper_id":{shipper-3-legacy-id}, "pickup_address_id":{KEY_LIST_OF_CREATED_ADDRESSES[1].id}, "pickup_start_time":"{gradle-current-date-yyyy-MM-dd}T15:00:00{gradle-timezone-XXX}","pickup_end_time":"{gradle-current-date-yyyy-MM-dd}T18:00:00{gradle-timezone-XXX}" } |
    And API Core - Operator add reservation to route using data below:
      | reservationId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].id} |
      | routeId       | {KEY_LIST_OF_CREATED_ROUTES[1].id}       |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-3-client-id}                                                                                                                                                                                                                                                                                                            |
      | shipperClientSecret | {shipper-3-client-secret}                                                                                                                                                                                                                                                                                                        |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                           |
      | v4OrderRequest      | { "service_type":"Parcel", "service_level":"Standard", "parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-2-id}                      |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                                  |
      | waypointId | {KEY_LIST_OF_CREATED_RESERVATIONS[1].waypointId}                                                                    |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}","shipper_id":{shipper-3-legacy-id}, "action": "SUCCESS"}] |
      | routes     | KEY_DRIVER_ROUTES                                                                                                   |
      | jobType    | RESERVATION                                                                                                         |
      | jobAction  | SUCCESS                                                                                                             |
      | jobMode    | PICK_UP                                                                                                             |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Enroute_to_sorting_hub"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN                 |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And DB Core - Operator verifies inbound_scans record:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | hubId   | {hub-id}                           |
      | type    | 1                                  |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |

  @HighPriority
  Scenario: Driver Success a Failed Delivery that was Rescheduled
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator add parcel to the route using data below:
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
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Pending_Reschedule"
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}        |
      | rescheduleRequest | {"date":"{date: 0 days ago, yyyy-MM-dd}"} |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Enroute_To_Sorting_Hub"
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - save the last Delivery transaction of "{KEY_LIST_OF_CREATED_ORDERS[1].id}" order from "KEY_LIST_OF_CREATED_ORDERS" as "KEY_TRANSACTION"
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Completed"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | TRANSACTION_UNROUTE                |
    And DB Core - verify transactions record:
      | id        | {KEY_TRANSACTION.id} |
      | status    | Pending              |
      | type      | DD                   |
      | deletedAt | not null             |
    And DB Routing Search - verify transactions record is hard deleted:
      | txnId | {KEY_TRANSACTION.id} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_TRANSACTION.waypointId} |
      | status   | Pending                      |
      | routeId  | null                         |
      | seqNo    | null                         |

  @HighPriority
  Scenario: Driver Success a Failed Pickup that was Rescheduled
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-2-id} } |
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                         |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return", "service_level":"Standard", "parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"PICKUP"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                              |
    And API Driver - Driver login with username "{driver-2-username}" and "{driver-2-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-2-id}                      |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                   |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId}                                           |
      | routes          | KEY_DRIVER_ROUTES                                                                                    |
      | jobType         | TRANSACTION                                                                                          |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL","failure_reason_id":139}] |
      | jobAction       | FAIL                                                                                                 |
      | jobMode         | PICK_UP                                                                                              |
      | failureReasonId | 139                                                                                                  |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Pickup_Fail"
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}        |
      | rescheduleRequest | {"date":"{date: 0 days ago, yyyy-MM-dd}"} |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Pending_Pickup"
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"PICKUP"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                              |
    And API Core - save the last Pickup transaction of "{KEY_LIST_OF_CREATED_ORDERS[1].id}" order from "KEY_LIST_OF_CREATED_ORDERS" as "KEY_TRANSACTION"
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | PICK_UP                                                                         |
    Then API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "Enroute_To_Sorting_Hub"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | TRANSACTION_UNROUTE                |
    And DB Core - verify transactions record:
      | id        | {KEY_TRANSACTION.id} |
      | status    | Pending              |
      | type      | PP                   |
      | deletedAt | not null             |
    And DB Routing Search - verify transactions record is hard deleted:
      | txnId | {KEY_TRANSACTION.id} |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_TRANSACTION.waypointId} |
      | status   | Pending                      |
      | routeId  | null                         |
      | seqNo    | null                         |

  @HighPriority
  Scenario: Success Delivery Order - Create PETS Ticket - Resolve PETS ticket - Success New Delivery Transaction from Driver App
    Given Shipper id "{shipper-id}" subscribes to "Successful Delivery" webhook
    Given Shipper id "{shipper-id}" subscribes to "Completed" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "238900","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator force success waypoint via route manifest:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
    When API Recovery - Operator create recovery ticket:
      | trackingId         | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]} |
      | ticketType         | PARCEL EXCEPTION                      |
      | subTicketType      | COMPLETED ORDER                       |
      | entrySource        | RECOVERY SCANNING                     |
      | orderOutcomeName   | ORDER OUTCOME (COMPLETED ORDER)       |
      | investigatingParty | {DEFAULT-INVESTIGATING-PARTY}         |
      | investigatingHubId | {DEFAULT-INVESTIGATING-HUB}           |
      | creatorUserId      | {DEFAULT-CREATOR-USER-ID}             |
      | creatorUserName    | {DEFAULT-CREATOR-USERNAME}            |
      | creatorUserEmail   | {DEFAULT-CREATOR-EMAIL}               |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "COMPLETED"
    And DB Recovery - get id from ticket_custom_fields table Hibernate
      | ticketId      | {KEY_CREATED_RECOVERY_TICKET.ticket.id} |
      | customFieldId | {KEY_CREATED_ORDER_OUTCOME_ID}          |
    And DB Recovery - get id from ticket_custom_fields table Hibernate
      | ticketId      | {KEY_CREATED_RECOVERY_TICKET.ticket.id} |
      | customFieldId | 90                                      |
    And API Recovery - Operator update recovery ticket:
      | ticketId         | {KEY_CREATED_RECOVERY_TICKET.ticket.id}  |
      | customFieldId    | {KEY_LIST_OF_TICKET_CUSTOM_FIELD_IDS[1]} |
      | orderOutcomeName | {KEY_CREATED_ORDER_OUTCOME}              |
      | status           | RESOLVED                                 |
      | outcome          | RTS                                      |
      | reporterId       | {DEFAULT-CREATOR-USER-ID}                |
      | reporterName     | {DEFAULT-CREATOR-USERNAME}               |
      | reporterEmail    | {DEFAULT-CREATOR-EMAIL}                  |
      | rtsCustomFieldId | {KEY_LIST_OF_TICKET_CUSTOM_FIELD_IDS[2]} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ARRIVED_AT_SORTING_HUB"
    Then API Recovery - verify ticket details:
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}   |
      | ticketId   | {KEY_CREATED_RECOVERY_TICKET.ticket.id} |
      | status     | RESOLVED                                |
      | outcome    | RTS                                     |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "RETURNED_TO_SENDER"
    And DB Core - verify orders record:
      | id             | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | status         | Completed                          |
      | granularStatus | Returned to Sender                 |
      | rts            | 1                                  |
    And DB Core - verify transactions record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].id} |
      | status  | Success                                            |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                 |
    And DB Routing Search - verify transactions record:
      | txnId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].id}         |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId} |
      | txnStatus  | SUCCESS                                                    |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    And DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId} |
      | seqNo   | not null                                                   |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status  | Success                                                    |
    And DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Success                                                    |
    And Shipper gets webhook request for event "Successful Delivery" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Completed" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
