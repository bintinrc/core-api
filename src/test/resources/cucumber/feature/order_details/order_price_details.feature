@ForceSuccessOrder @order-price-details
Feature: Order Price Details

  @DeleteOrArchiveRoute
  Scenario: Get Success Return Pickup Order Price Details for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"PP" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver pickup the created parcel successfully
    And API Operator verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | status         | TRANSIT                                    |
      | granularStatus | ENROUTE_TO_SORTING_HUB                     |
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                     |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | granularStatus        | En-route to Sorting Hub                    |
      | createdAt             | not null                                   |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                 |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}      |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}      |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}       |
      | toCity                | null                                       |
      | toProvince            | null                                       |
      | toDistrict            | null                                       |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384  |
      | toPostcode            | 455384                                     |
      | toLatitude            | 1.3184395712682                            |
      | toLongitude           | 103.925311276846                           |
      | toName                | Elsa Sender                                |
      | fromCity              | null                                       |
      | fromLongitude         | 103.825580873988                           |
      | fromLatitude          | 1.45694483734937                           |
      | installationRequired  | null                                       |
      | orderType             | RETURN                                     |
      | deliveryType          | STANDARD                                   |
      | deliveryTypeValue     | RETURN_THREE_DAYS_ANYTIME                  |
      | deliveryTypeId        | 29                                         |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}      |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}      |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}       |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}             |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}           |
      | serviceType           | RETURN                                     |
      | serviceLevel          | STANDARD                                   |
      | weight                | {KEY_CREATED_ORDER.weight}                 |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}        |
      | originHub             | -                                          |
      | destinationHub        | -                                          |
      | bulkyCategoryName     | null                                       |
      | flightOfStairs        | null                                       |
      | deliveryDate          | null                                       |
      | isRts                 | false                                      |
      | timeslot              | NONE                                       |
      | shipperId             | {shipper-legacy-id}                        |
      | codValue              | null                                       |
      | codCollected          | 0                                          |
      | insuredValue          | null                                       |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}    |
    And DB Operator verifies waypoint details:
      | id        | {KEY_DELIVERY_WAYPOINT_ID} |
      | latitude  | 1.45694483734937           |
      | longitude | 103.825580873988           |

  Scenario: Get Order Price Details with Various Address Fields for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | {"service_type":"Return","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                     |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | granularStatus        | Pending Pickup                             |
      | createdAt             | not null                                   |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                 |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}      |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}      |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}       |
      | toCity                | null                                       |
      | toProvince            | null                                       |
      | toDistrict            | null                                       |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384  |
      | toPostcode            | 455384                                     |
      | toLatitude            | 1.3184395712682                            |
      | toLongitude           | 103.925311276846                           |
      | toName                | Elsa Sender                                |
      | fromCity              | null                                       |
      | fromLongitude         | 103.825580873988                           |
      | fromLatitude          | 1.45694483734937                           |
      | installationRequired  | null                                       |
      | orderType             | RETURN                                     |
      | deliveryType          | STANDARD                                   |
      | deliveryTypeValue     | RETURN_THREE_DAYS_ANYTIME                  |
      | deliveryTypeId        | 29                                         |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}      |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}      |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}       |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}             |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}           |
      | serviceType           | RETURN                                     |
      | serviceLevel          | STANDARD                                   |
      | weight                | {KEY_CREATED_ORDER.weight}                 |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}        |
      | originHub             | -                                          |
      | destinationHub        | -                                          |
      | bulkyCategoryName     | null                                       |
      | flightOfStairs        | null                                       |
      | deliveryDate          | null                                       |
      | isRts                 | false                                      |
      | timeslot              | NONE                                       |
      | shipperId             | {shipper-legacy-id}                        |
      | codValue              | null                                       |
      | codCollected          | 0                                          |
      | insuredValue          | null                                       |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}    |

  @DeleteOrArchiveRoute
  Scenario: Get Success RTS Order Price Details without Change Delivery Address for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver failed the delivery of the created parcel using data below:
      | failureReasonFindMode  | findAdvance |
      | failureReasonCodeId    | 6           |
      | failureReasonIndexMode | FIRST       |
    When Operator save the last Delivery transaction of the created order as "KEY_TRANSACTION_BEFORE"
    And API Operator RTS order:
      | orderId    | {KEY_CREATED_ORDER_ID}                                                                                     |
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver deliver the created parcel successfully
    And API Operator verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | status         | COMPLETED                                  |
      | granularStatus | RETURNED_TO_SENDER                         |
    And API Core - Operator get order details for tracking order "{KEY_CREATED_ORDER_TRACKING_ID}"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}"
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                     |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | granularStatus        | Returned to Sender                         |
      | createdAt             | not null                                   |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                 |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}      |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}      |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}       |
      | toCity                | null                                       |
      | toProvince            | null                                       |
      | toDistrict            | null                                       |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384  |
      | toPostcode            | 455384                                     |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}       |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}      |
      | toName                | Elsa Customer (RTS)                        |
      | fromCity              | null                                       |
      | fromLongitude         | 132.89808                                  |
      | fromLatitude          | 1.38797979                                 |
      | installationRequired  | null                                       |
      | orderType             | NORMAL                                     |
      | deliveryType          | STANDARD                                   |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                |
      | deliveryTypeId        | 2                                          |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}      |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}      |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}       |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}             |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}           |
      | serviceType           | PARCEL                                     |
      | serviceLevel          | STANDARD                                   |
      | weight                | {KEY_CREATED_ORDER.weight}                 |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}        |
      | originHub             | {sorting-hub-name}                         |
      | destinationHub        | {sorting-hub-name}                         |
      | bulkyCategoryName     | null                                       |
      | flightOfStairs        | null                                       |
      | deliveryDate          | null                                       |
      | isRts                 | false                                      |
      | timeslot              | NONE                                       |
      | shipperId             | {shipper-legacy-id}                        |
      | codValue              | null                                       |
      | codCollected          | 0                                          |
      | insuredValue          | null                                       |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}    |
    And DB Operator verifies waypoint details:
      | id        | {KEY_TRANSACTION_BEFORE.waypointId}   |
      | latitude  | {KEY_CORE_WAYPOINT_DETAILS.latitude}  |
      | longitude | {KEY_CORE_WAYPOINT_DETAILS.longitude} |

  @DeleteOrArchiveRoute
  Scenario: Get Success RTS Order Price Details with Change Delivery Address for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver failed the delivery of the created parcel using data below:
      | failureReasonFindMode  | findAdvance |
      | failureReasonCodeId    | 6           |
      | failureReasonIndexMode | FIRST       |
    When Operator save the last Delivery transaction of the created order as "KEY_TRANSACTION_BEFORE"
    And API Operator RTS order:
      | orderId    | {KEY_CREATED_ORDER_ID}                                                                                                                                                                                                                                                                                                                                            |
      | rtsRequest | {"name":"Elsa Customer","contact":"+6583014911","email":"elsa@ninja.com","address1":"501 ORCHARD ROAD","address2":"WHEELOCK PLACE","postcode":"238880","city":"Singapore","country":"Singapore","latitude":1.3045363600053,"longitude":103.830714230777,"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver deliver the created parcel successfully
    And API Operator verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | status         | COMPLETED                                  |
      | granularStatus | RETURNED_TO_SENDER                         |
    And API Core - Operator get order details for tracking order "{KEY_CREATED_ORDER_TRACKING_ID}"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}"
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                     |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | granularStatus        | Returned to Sender                         |
      | createdAt             | not null                                   |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                 |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}      |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}      |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}       |
      | toCity                | null                                       |
      | toProvince            | null                                       |
      | toDistrict            | null                                       |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384  |
      | toPostcode            | 455384                                     |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}       |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}      |
      | toName                | Elsa Customer (RTS)                        |
      | fromCity              | null                                       |
      | fromLongitude         | 132.89808                                  |
      | fromLatitude          | 1.38797979                                 |
      | installationRequired  | null                                       |
      | orderType             | NORMAL                                     |
      | deliveryType          | STANDARD                                   |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                |
      | deliveryTypeId        | 2                                          |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}      |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}      |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}       |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}             |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}           |
      | serviceType           | PARCEL                                     |
      | serviceLevel          | STANDARD                                   |
      | weight                | {KEY_CREATED_ORDER.weight}                 |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}        |
      | originHub             | {sorting-hub-name}                         |
      | destinationHub        | {sorting-hub-name}                         |
      | bulkyCategoryName     | null                                       |
      | flightOfStairs        | null                                       |
      | deliveryDate          | null                                       |
      | isRts                 | false                                      |
      | timeslot              | NONE                                       |
      | shipperId             | {shipper-legacy-id}                        |
      | codValue              | null                                       |
      | codCollected          | 0                                          |
      | insuredValue          | null                                       |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}    |
    And DB Operator verifies waypoint details:
      | id        | {KEY_TRANSACTION_BEFORE.waypointId}   |
      | latitude  | {KEY_CORE_WAYPOINT_DETAILS.latitude}  |
      | longitude | {KEY_CORE_WAYPOINT_DETAILS.longitude} |

  @DeleteOrArchiveRoute
  Scenario: Get Success Rescheduled Delivery Order Price Details without Change Delivery Address for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver failed the delivery of the created parcel using data below:
      | failureReasonFindMode  | findAdvance |
      | failureReasonCodeId    | 6           |
      | failureReasonIndexMode | FIRST       |
    And API Operator reschedule order:
      | orderId | {KEY_CREATED_ORDER_ID}                    |
      | request | {"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver deliver the created parcel successfully
    And API Operator verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | status         | COMPLETED                                  |
      | granularStatus | COMPLETED                                  |
    And API Core - Operator get order details for tracking order "{KEY_CREATED_ORDER_TRACKING_ID}"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}"
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                     |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | granularStatus        | Completed                                  |
      | createdAt             | not null                                   |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                 |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}      |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}      |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}       |
      | toCity                | null                                       |
      | toProvince            | null                                       |
      | toDistrict            | null                                       |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384  |
      | toPostcode            | 455384                                     |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}       |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}      |
      | toName                | Elsa Sender                                |
      | fromCity              | null                                       |
      | fromLongitude         | 132.89808                                  |
      | fromLatitude          | 1.38797979                                 |
      | installationRequired  | null                                       |
      | orderType             | NORMAL                                     |
      | deliveryType          | STANDARD                                   |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                |
      | deliveryTypeId        | 2                                          |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}      |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}      |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}       |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}             |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}           |
      | serviceType           | PARCEL                                     |
      | serviceLevel          | STANDARD                                   |
      | weight                | {KEY_CREATED_ORDER.weight}                 |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}        |
      | originHub             | {sorting-hub-name}                         |
      | destinationHub        | {sorting-hub-name}                         |
      | bulkyCategoryName     | null                                       |
      | flightOfStairs        | null                                       |
      | deliveryDate          | null                                       |
      | isRts                 | false                                      |
      | timeslot              | NONE                                       |
      | shipperId             | {shipper-legacy-id}                        |
      | codValue              | null                                       |
      | codCollected          | 0                                          |
      | insuredValue          | null                                       |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}    |
    And DB Operator verifies waypoint details:
      | id        | {KEY_DELIVERY_WAYPOINT_ID}            |
      | latitude  | {KEY_CORE_WAYPOINT_DETAILS.latitude}  |
      | longitude | {KEY_CORE_WAYPOINT_DETAILS.longitude} |

  @DeleteOrArchiveRoute
  Scenario: Get Success Rescheduled Delivery Order Price Details with Change Delivery Address for Specific Country - SG
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver failed the delivery of the created parcel using data below:
      | failureReasonFindMode  | findAdvance |
      | failureReasonCodeId    | 6           |
      | failureReasonIndexMode | FIRST       |
    And API Operator reschedule order:
      | orderId | {KEY_CREATED_ORDER_ID}                                                                                                                                                                                                                                                                                       |
      | request | {"name":"Elsa Customer","contact":"+6583014911","email":"elsa@ninja.com","address_1":"288J BUKIT BATOK STREET 25","address_2":"NATURE VIEW","postal_code":"659288","city":"Singapore","country":"Singapore","latitude": 1.3453,"longitude":103.7587,"date":"{gradle-next-1-day-yyyy-MM-dd}","timeWindow":-1} |
    And API Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Operator add parcel to the route using data below:
      | addParcelToRouteRequest | { "type":"DD" } |
    When API Driver set credentials "{driver-username}" and "{driver-password}"
    And API Driver collect all his routes
    And API Driver get pickup/delivery waypoint of the created order
    And API Operator Van Inbound parcel
    And API Core - Operator start the route with following data:
      | routeId  | {KEY_CREATED_ROUTE_ID}                                                                                                                              |
      | driverId | {driver-id}                                                                                                                                         |
      | request  | {"user_id":"{driver-id}","user_name":"{driver-username}","user_grant_type":"{driver-password}","user_email":"opv2-core-driver.auto@hg.ninjavan.co"} |
    And API Driver deliver the created parcel successfully
    And API Operator verifies order state:
      | trackingId     | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]} |
      | status         | COMPLETED                                  |
      | granularStatus | COMPLETED                                  |
    And API Operator verify order pricing details:
      | orderId               | {KEY_CREATED_ORDER_ID}                                            |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDER_TRACKING_ID[1]}                        |
      | granularStatus        | Completed                                                         |
      | createdAt             | not null                                                          |
      | shipperProvidedWeight | {KEY_CREATED_ORDER.weight}                                        |
      | shipperProvidedHeight | {KEY_CREATED_ORDER.dimensions.height}                             |
      | shipperProvidedLength | {KEY_CREATED_ORDER.dimensions.length}                             |
      | shipperProvidedWidth  | {KEY_CREATED_ORDER.dimensions.width}                              |
      | toCity                | Singapore                                                         |
      | toProvince            | null                                                              |
      | toDistrict            | null                                                              |
      | toAddress             | 288J BUKIT BATOK STREET 25 NATURE VIEW Singapore Singapore 659288 |
      | toPostcode            | 659288                                                            |
      | toLatitude            | 1.3453                                                            |
      | toLongitude           | 103.7587                                                          |
      | toName                | Elsa Customer                                                     |
      | fromCity              | null                                                              |
      | fromLongitude         | 132.89808                                                         |
      | fromLatitude          | 1.38797979                                                        |
      | installationRequired  | null                                                              |
      | orderType             | NORMAL                                                            |
      | deliveryType          | STANDARD                                                          |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                                       |
      | deliveryTypeId        | 2                                                                 |
      | measuredHeight        | {KEY_CREATED_ORDER.dimensions.height}                             |
      | measuredLength        | {KEY_CREATED_ORDER.dimensions.length}                             |
      | measuredWidth         | {KEY_CREATED_ORDER.dimensions.width}                              |
      | parcelSizeValue       | {KEY_CREATED_ORDER.parcelSize}                                    |
      | parcelSizeId          | {KEY_CREATED_ORDER.parcelSizeId}                                  |
      | serviceType           | PARCEL                                                            |
      | serviceLevel          | STANDARD                                                          |
      | weight                | {KEY_CREATED_ORDER.weight}                                        |
      | size                  | {KEY_CREATED_ORDER.dimensions.size}                               |
      | originHub             | {sorting-hub-name}                                                |
      | destinationHub        | {sorting-hub-name}                                                |
      | bulkyCategoryName     | null                                                              |
      | flightOfStairs        | null                                                              |
      | deliveryDate          | null                                                              |
      | isRts                 | false                                                             |
      | timeslot              | NONE                                                              |
      | shipperId             | {shipper-legacy-id}                                               |
      | codValue              | null                                                              |
      | codCollected          | 0                                                                 |
      | insuredValue          | null                                                              |
      | shipperOrderRefNo     | {KEY_CREATED_ORDER.requestedTrackingId}                           |
    And DB Operator verifies waypoint details:
      | id        | {KEY_DELIVERY_WAYPOINT_ID} |
      | latitude  | 1.3453                     |
      | longitude | 103.7587                   |
