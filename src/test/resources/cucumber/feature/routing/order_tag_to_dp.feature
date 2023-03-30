@ForceSuccessOrder @DeleteReservationAndAddress @routing @order-tag-to-dp @routing-refactor
Feature: Order Tag to DP

  @happy-path
  Scenario: Add to DP Holding Route upon Hub Inbound
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD {dp-address-unit-number}","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {dp-holding-route-id}                                      |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {dp-holding-route-id}              |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event   | HUB_INBOUND_SCAN                   |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: Add to DP Holding Route upon Hub Inbound - Routed Order
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD {dp-address-unit-number}","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {dp-holding-route-id}                                      |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {dp-holding-route-id}              |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |
    And API Event - Operator verify that event is published with the following details:
      | event   | HUB_INBOUND_SCAN                   |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  @ArchiveDriverRoutes
  Scenario: PUT /2.0/orders/:orderId/routes-dp - Add Order to DP Holding Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "236890","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator new add parcel to DP holding route:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    Then DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo   | not null                                                   |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status  | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    And DB Core - verify transactions record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status     | Pending                                                    |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Unrouted Order To DP
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route": { "route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "type": "DELIVERY" }, "dp_tag": { "dp_id": {dpms-id}, "authorized_by": "SYSTEM_CONFIRMED", "collect_by": "{gradle-next-1-day-yyyy-MM-dd}", "dp_service_type": "NORMAL", "drop_off_on": "{gradle-next-1-day-yyyy-MM-dd}", "end_date": "{gradle-next-1-day-yyyy-MM-dd}", "reason": "Automated Semi Tagging", "should_reserve_slot": false, "skip_ATL_validation": true, "start_date": "{gradle-next-1-day-yyyy-MM-dd}" } } |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Routed Order To DP
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route": { "route_id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "type": "DELIVERY" }, "dp_tag": { "dp_id": {dpms-id}, "authorized_by": "SYSTEM_CONFIRMED", "collect_by": "{gradle-next-1-day-yyyy-MM-dd}", "dp_service_type": "NORMAL", "drop_off_on": "{gradle-next-1-day-yyyy-MM-dd}", "end_date": "{gradle-next-1-day-yyyy-MM-dd}", "reason": "Automated Semi Tagging", "should_reserve_slot": false, "skip_ATL_validation": true, "start_date": "{gradle-next-1-day-yyyy-MM-dd}" } } |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Unrouted DP Order To Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id":{dp-id},"drop_off_date":"{gradle-current-date-yyyy-MM-dd}"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route": { "route_id": {KEY_LIST_OF_CREATED_ROUTES[1].id}, "type": "DELIVERY" }, "dp_tag":null } |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                        |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                     |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  @ArchiveDriverRoutes @happy-path
  Scenario: DELETE /2.0/orders/:orderId/routes-dp - Remove DP Order From Holding Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "123456","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator new add parcel to DP holding route:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    Then DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo   | not null                                                   |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status  | Routed                                                     |
    When API Core - Operator pull out dp order from DP holding route for order
      | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Then DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo   | null                                                       |
      | routeId | null                                                       |
      | status  | Pending                                                    |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | null                                                       |
      | routeId             | null                                                       |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Routed DP Order To New Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id":{dp-id},"drop_off_date":"{gradle-current-date-yyyy-MM-dd}"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route": { "route_id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "type": "DELIVERY" }, "dp_tag":null} |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                       |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                    |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Routed DP Order To New DP
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id":{alternate-dp-id},"drop_off_date":"{gradle-current-date-yyyy-MM-dd}"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route": null, "dp_tag": { "dp_id": {dpms-id}, "authorized_by": "SYSTEM_CONFIRMED", "collect_by": "{gradle-next-1-day-yyyy-MM-dd}", "dp_service_type": "NORMAL", "drop_off_on": "{gradle-next-1-day-yyyy-MM-dd}", "end_date": "{gradle-next-1-day-yyyy-MM-dd}", "reason": "Automated Semi Tagging", "should_reserve_slot": false, "skip_ATL_validation": true, "start_date": "{gradle-next-1-day-yyyy-MM-dd}" } } |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                                                                                                                                         |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                                                                                                                                                                                                                                                                      |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[1].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: PUT /2.0/orders/:orderId/dps/routes-dp - Add Routed DP Order To New DP and Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API DP - Operator tag order to DP:
      | request | {"order_id":{KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id":{alternate-dp-id},"drop_off_date":"{gradle-current-date-yyyy-MM-dd}"} |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    When API Core - Operator tag to dp for the order:
      | request    | { "add_to_route":  { "route_id": {KEY_LIST_OF_CREATED_ROUTES[2].id}, "type": "DELIVERY" }, "dp_tag": { "dp_id": {dpms-id}, "authorized_by": "SYSTEM_CONFIRMED", "collect_by": "{gradle-next-1-day-yyyy-MM-dd}", "dp_service_type": "NORMAL", "drop_off_on": "{gradle-next-1-day-yyyy-MM-dd}", "end_date": "{gradle-next-1-day-yyyy-MM-dd}", "reason": "Automated Semi Tagging", "should_reserve_slot": false, "skip_ATL_validation": true, "start_date": "{gradle-next-1-day-yyyy-MM-dd}" } } |
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | trackingId | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
    Then DB Core - verify waypoints record:
      | id      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo   | not null                                                   |
      | routeId | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status  | Routed                                                     |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | toAddress1 | 119, CLEMENTI ROAD, SG, 129801     |
      | toAddress2 | Add 4-5                            |
      | toPostcode | 238900                             |
      | toCity     | SG                                 |
      | toCountry  | SG                                 |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
      | country             | SG                                                         |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {KEY_LIST_OF_CREATED_ROUTES[2].id}                         |
      | status   | Routed                                                     |
      | address1 | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2 | Add 4-5                                                    |
      | postcode | 238900                                                     |
      | city     | SG                                                         |
      | country  | SG                                                         |
    And API Event - Operator verify that event is published with the following details:
      | event   | ASSIGNED_TO_DP                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_AV                          |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event            | ADD_TO_ROUTE                       |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeId          | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
      | routeEventSource | ADD_BY_ORDER_DP                    |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |

  Scenario: DELETE /2.0/orders/:orderId/dps/routes-dp - Remove and Unassigned DP Order From Holding Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD {dp-address-unit-number}","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
    When API Core - Operator untag from dp and remove from holding route:
      | request | {"dp_untag": {"user_id": 120701}, "remove_from_route_dp": {"type": "DELIVERY"}} |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                              |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And DB Core - verify route_monitoring_data is hard-deleted:
      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | toAddress1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | toAddress2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | toPostcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | toCountry  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::generateOrderDataBean   |
      | seq_no   | 1                                          |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | null                                                       |
      | routeId             | null                                                       |
      | address1            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode            | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country             | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UNASSIGNED_FROM_DP                 |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event            | PULL_OUT_OF_ROUTE                  |
      | orderId          | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | oldRouteId       | {dp-holding-route-id}              |
      | routeEventSource | REMOVE_BY_ORDER_DP                 |

  Scenario: DELETE /2.0/orders/:orderId/dps - Remove DP Order From Holding Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD {dp-address-unit-number}","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
    When API Core - Operator untag from dp:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | version | 2.0                                |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {dp-holding-route-id}                                      |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | toAddress1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | toAddress2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | toPostcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | toCountry  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | null                                                       |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode            | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country             | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UNASSIGNED_FROM_DP                 |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: DELETE /2.1/orders/:orderId/dps - Remove DP Order From Holding Route
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFrom        | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD {dp-address-unit-number}","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | {dpms-id}                                                  |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | 119, CLEMENTI ROAD, SG, 129801                             |
      | address2            | Add 4-5                                                    |
      | postcode            | 238900                                                     |
      | city                | SG                                                         |
    When API Core - Operator untag from dp:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | version | 2.0                                |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And DB Core - verify route_monitoring_data record:
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | routeId    | {dp-holding-route-id}                                      |
    And DB Core - verify orders record:
      | id         | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | toAddress1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | toAddress2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | toPostcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | toCountry  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].id}         |
      | waypointId          | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | status              | Pending                                                    |
      | distributionPointId | null                                                       |
      | routeId             | {dp-holding-route-id}                                      |
      | address1            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode            | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country             | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId} |
      | seqNo    | not null                                                   |
      | routeId  | {dp-holding-route-id}                                      |
      | status   | Routed                                                     |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}                 |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}                 |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}                 |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}                  |
    And API Event - Operator verify that event is published with the following details:
      | event   | UPDATE_ADDRESS                     |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Event - Operator verify that event is published with the following details:
      | event   | UNASSIGNED_FROM_DP                 |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: POST /orders/:orderId/overstay - Overstay DP Order
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | numberOfOrder       | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","from":{"name": "binti v4.1","phone_number": "+65189168","email": "binti@test.co", "address": {"address1": "Orchard Road central","address2": "","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{"dimension":{"weight":1}, "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API DP - Operator tag order to DP:
      | request | { "order_id": {KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id": {dp-id},"drop_off_date": "{date: 0 days next, yyyy-MM-dd}"} |
    And API Core - Operator perform dp drop off with order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Core - Operator overstay order from dp:
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | dpId    | {dpms-id}                          |
    And API Core - Operator get order details for previous order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Then DB Core - verify orders record:
      | id           | {KEY_LIST_OF_CREATED_ORDERS[1].id}             |
      | rts          | 1                                              |
      | toAddress1   | {KEY_LIST_OF_CREATED_ORDERS[1].fromAddress1}   |
      | toAddress2   | {KEY_LIST_OF_CREATED_ORDERS[1].fromAddress2}   |
      | toPostcode   | {KEY_LIST_OF_CREATED_ORDERS[1].fromPostcode}   |
      | toCountry    | {KEY_LIST_OF_CREATED_ORDERS[1].fromCountry}    |
      | toName       | {KEY_LIST_OF_CREATED_ORDERS[1].fromName} (RTS) |
      | toEmail      | {KEY_LIST_OF_CREATED_ORDERS[1].fromEmail}      |
      | toContact    | {KEY_LIST_OF_CREATED_ORDERS[1].fromContact}    |
      | fromAddress1 | {KEY_LIST_OF_CREATED_ORDERS[1].fromAddress1}   |
      | fromAddress2 | {KEY_LIST_OF_CREATED_ORDERS[1].fromAddress2}   |
      | fromPostcode | {KEY_LIST_OF_CREATED_ORDERS[1].fromPostcode}   |
      | fromCountry  | {KEY_LIST_OF_CREATED_ORDERS[1].fromCountry}    |
      | fromName     | {KEY_LIST_OF_CREATED_ORDERS[1].fromName}       |
      | fromEmail    | {KEY_LIST_OF_CREATED_ORDERS[1].fromEmail}      |
      | fromContact  | {KEY_LIST_OF_CREATED_ORDERS[1].fromContact}    |
#  Check new PP transaction
    And DB Core - verify transactions record:
      | id                  | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[3].id} |
      | status              | Pending                                            |
      | routeId             | null                                               |
      | distributionPointId | {dpms-id}                                          |
      | name                | core-api-dp                                        |
      | email               | support_sg@ninjavan.co                             |
      | contact             | 650909087                                          |
      | address1            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1}         |
      | address2            | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2}         |
      | postcode            | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode}         |
      | country             | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}          |
#  Check new DD transaction
    And DB Core - verify transactions record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[4].id} |
      | status   | Pending                                            |
      | routeId  | null                                               |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[2].fromName} (RTS)     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[2].fromEmail}          |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[2].fromContact}        |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress1}       |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress2}       |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[2].fromPostcode}       |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[2].fromCountry}        |
    Then DB Core - verify waypoints record:
      | id       | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[4].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress1}               |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress2}               |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[2].fromPostcode}               |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[2].fromCountry}                |
    Then DB Route - verify waypoints record:
      | legacyId | {KEY_LIST_OF_CREATED_ORDERS[2].transactions[4].waypointId} |
      | seqNo    | null                                                       |
      | routeId  | null                                                       |
      | status   | Pending                                                    |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress1}               |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[2].fromAddress2}               |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[2].fromPostcode}               |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[2].fromCountry}                |
    And DB Core - operator verify orders.data.previousDeliveryDetails is updated correctly:
      | orderId  | {KEY_LIST_OF_CREATED_ORDERS[1].id}         |
      | address1 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress1} |
      | address2 | {KEY_LIST_OF_CREATED_ORDERS[1].toAddress2} |
      | postcode | {KEY_LIST_OF_CREATED_ORDERS[1].toPostcode} |
      | country  | {KEY_LIST_OF_CREATED_ORDERS[1].toCountry}  |
      | name     | {KEY_LIST_OF_CREATED_ORDERS[1].toName}     |
      | email    | {KEY_LIST_OF_CREATED_ORDERS[1].toEmail}    |
      | contact  | {KEY_LIST_OF_CREATED_ORDERS[1].toContact}  |
      | comments | OrdersManagerImpl::rts                     |
      | seq_no   | 2                                          |
    And API Event - Operator verify that event is published with the following details:
      | event   | RTS                                |
      | orderId | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

  Scenario: POST /2.0/orders/:orderId/dropoff - Drop Off DP Order
    Given Shipper id "{shipper-id}" subscribes to "Arrived at Distribution Point" webhook
    When API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | numberOfOrder       | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | generateTo          | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","from":{"name": "binti v4.1","phone_number": "+65189168","email": "binti@test.co", "address": {"address1": "Orchard Road central","address2": "","country": "SG","postcode": "511200","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "is_pickup_required":true, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":null,"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                         |
      | hubId                | {sorting-hub-id}                                                                                              |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API DP - Operator tag order to DP:
      | request | { "order_id": {KEY_LIST_OF_CREATED_ORDERS[1].id},"dp_id": {dp-id},"drop_off_date": "{date: 0 days next, yyyy-MM-dd}"} |
    And API Core - Operator perform dp drop off with order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
    And Operator search for "DELIVERY" transaction with status "SUCCESS" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And DB Operator verifies all waypoints status is "SUCCESS"
    And Shipper gets webhook request for event "Arrived at Distribution Point" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Distribution Point" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Operator verify that order with status-granular status is "Transit"-"ARRIVED_AT_DISTRIBUTION_POINT" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Event - Operator verify that event is published with the following details:
      | event              | UPDATE_STATUS                      |
      | orderId            | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | updateStatusReason | TRANSFER_FROM_DRIVER_TO_PUDO       |
