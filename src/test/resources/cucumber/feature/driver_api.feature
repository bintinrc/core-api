@ArchiveDriverRoutes @driver-api
Feature: Driver API

  @ForceSuccessOrder @happy-path @HighPriority
  Scenario: Driver Van Inbound an Order Delivery
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    Then Operator verify that order status-granular status is "Transit"-"On_Vehicle_for_Delivery"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_INBOUND_SCAN    |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "4" and correct route_id

  Scenario: Driver Success a Return Pickup
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator search for created order
    And Operator add order to driver "PP" route
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "SUCCESS" Parcel "PICKUP"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN     |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Reservation Pickup by Scanning Normal Order
    Given Shipper authenticates using client id "{shipper-3-client-id}" and client secret "{shipper-3-client-secret}"
    When Shipper creates a reservation
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And Operator Search for Created Pickup for Shipper "{shipper-3-legacy-id}" with status "Pending"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator Route the Reservation Pickup
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver "Success" Reservation Pickup
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And API Event - Operator verify that event is published with the following details:
      | event   | DRIVER_PICKUP_SCAN     |
      | orderId | {KEY_CREATED_ORDER_ID} |
      | routeId | {KEY_CREATED_ROUTE_ID} |
    And DB Operator verifies inbound_scans record with type "1" and correct route_id

  Scenario: Driver Success a Failed Delivery that was Rescheduled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
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
    And Operator get "DELIVERY" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Van Inbound Parcel at hub id "{sorting-hub-id}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "DELIVERY"
    Then Operator verify that order status-granular status is "Delivery_Fail"-"Pending_Reschedule"
    And Operator verify all "DELIVERY" transactions status is "FAIL"
    And DB Operator verifies all transaction_failure_reason is created correctly
    When API Operator reschedule failed delivery order
    And Operator search for "DELIVERY" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    When Operator add order to driver "DD" route
    And Driver "SUCCESS" Parcel previous "DELIVERY"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | TRANSACTION_UNROUTE    |
    And DB Operator verifies transaction is soft-deleted
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator search for "DELIVERY" transaction with status "SUCCESS"
    And Operator verify that order status-granular status is "Completed"-"Completed"
    And DB Operator verifies transactions after reschedule
      | number_of_txn       | 3       |
      | old_delivery_status | Success |
      | new_delivery_status | Pending |
      | new_delivery_type   | DD      |

  Scenario: Driver Success a Failed Pickup that was Rescheduled
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    When Shipper create order with parameters below
      | service_type                  | Return   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | true     |
    And Operator search for created order
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "PP" route
    And Operator get "PICKUP" transaction waypoint Ids for all orders
    When Driver id "{driver-2-id}" authenticated to login with username "{driver-2-username}" and password "{driver-2-password}"
    And Driver Starts the route
    And Driver "FAIL" Parcel "PICKUP"
    Then Operator verify that order status-granular status is "Pickup_Fail"-"Pickup_Fail"
    And Operator verify all "PICKUP" transactions status is "FAIL"
    And DB Operator verifies all transaction_failure_reason is created correctly
    When API Operator reschedule failed delivery order
    And Operator search for "PICKUP" transaction with status "PENDING"
    Then Operator verify that order status-granular status is "Pending"-"Pending_Pickup"
    When Operator add order to driver "PP" route
    And Driver "SUCCESS" Parcel previous "PICKUP"
    Then API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE      |
      | orderId          | {KEY_CREATED_ORDER_ID} |
      | routeEventSource | TRANSACTION_UNROUTE    |
    And DB Operator verifies transaction is soft-deleted
    And DB Operator verifies waypoint status is "PENDING"
    And DB Operator verifies waypoints.route_id & seq_no is NULL

    And DB Operator verifies route_monitoring_data is hard-deleted
    And Operator search for "PICKUP" transaction with status "SUCCESS"
    And Operator verify that order status-granular status is "Transit"-"Enroute_to_sorting_hub"
    And DB Operator verifies transactions after reschedule pickup
      | old_pickup_status | Success |
      | new_pickup_status | Pending |
      | new_pickup_type   | PP      |

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
