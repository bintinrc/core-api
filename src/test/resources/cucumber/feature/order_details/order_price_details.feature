@ForceSuccessOrders @order-price-details
Feature: Order Price Details

  @ArchiveRouteCommonV2 @HighPriority
  Scenario: Get Success Return Pickup Order Price Details for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | { "service_type":"Return","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[1].id},"type":"PICKUP"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                              |
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                              |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId}                      |
      | routes          | KEY_DRIVER_ROUTES                                                               |
      | jobType         | TRANSACTION                                                                     |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction       | SUCCESS                                                                         |
      | jobMode         | PICK_UP                                                                         |
      | globalShipperId | {shipper-id}                                                                    |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "ENROUTE_TO_SORTING_HUB"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                  |
      | trackingId            | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}               |
      | granularStatus        | En-route to Sorting Hub                             |
      | createdAt             | not null                                            |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | toCity                | null                                                |
      | toProvince            | null                                                |
      | toDistrict            | null                                                |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384           |
      | toPostcode            | 455384                                              |
      | toLatitude            | 1.3184395712682                                     |
      | toLongitude           | 103.925311276846                                    |
      | toName                | Elsa Sender                                         |
      | fromCity              | null                                                |
      | fromLongitude         | 103.825580873988                                    |
      | fromLatitude          | 1.45694483734937                                    |
      | installationRequired  | null                                                |
      | orderType             | RETURN                                              |
      | deliveryType          | STANDARD                                            |
      | deliveryTypeValue     | RETURN_THREE_DAYS_ANYTIME                           |
      | deliveryTypeId        | 29                                                  |
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}          |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}        |
      | serviceType           | RETURN                                              |
      | serviceLevel          | STANDARD                                            |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}     |
      | originHub             | -                                                   |
      | destinationHub        | -                                                   |
      | bulkyCategoryName     | null                                                |
      | flightOfStairs        | null                                                |
      | deliveryDate          | null                                                |
      | isRts                 | false                                               |
      | timeslot              | NONE                                                |
      | shipperId             | {shipper-legacy-id}                                 |
      | codValue              | null                                                |
      | codCollected          | 0                                                   |
      | insuredValue          | null                                                |
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId} |
    And DB Route - verify waypoints record:
      | legacyId  | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[1].waypointId} |
      | latitude  | 1.45694483734937                                           |
      | longitude | 103.825580873988                                           |

  @HighPriority
  Scenario: Get Order Price Details with Various Address Fields for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | v4OrderRequest      | {"service_type":"Return","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                  |
      | trackingId            | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}               |
      | granularStatus        | Pending Pickup                                      |
      | createdAt             | not null                                            |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | toCity                | null                                                |
      | toProvince            | null                                                |
      | toDistrict            | null                                                |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384           |
      | toPostcode            | 455384                                              |
      | toLatitude            | 1.3184395712682                                     |
      | toLongitude           | 103.925311276846                                    |
      | toName                | Elsa Sender                                         |
      | fromCity              | null                                                |
      | fromLongitude         | 103.825580873988                                    |
      | fromLatitude          | 1.45694483734937                                    |
      | installationRequired  | null                                                |
      | orderType             | RETURN                                              |
      | deliveryType          | STANDARD                                            |
      | deliveryTypeValue     | RETURN_THREE_DAYS_ANYTIME                           |
      | deliveryTypeId        | 29                                                  |
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}          |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}        |
      | serviceType           | RETURN                                              |
      | serviceLevel          | STANDARD                                            |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}     |
      | originHub             | -                                                   |
      | destinationHub        | -                                                   |
      | bulkyCategoryName     | null                                                |
      | flightOfStairs        | null                                                |
      | deliveryDate          | null                                                |
      | isRts                 | false                                               |
      | timeslot              | NONE                                                |
      | shipperId             | {shipper-legacy-id}                                 |
      | codValue              | null                                                |
      | codCollected          | 0                                                   |
      | insuredValue          | null                                                |
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId} |

  @ArchiveRouteCommonV2 @HighPriority
  Scenario: Get Success RTS Order Price Details without Change Delivery Address for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                   |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                                           |
      | routes          | KEY_DRIVER_ROUTES                                                                                    |
      | jobType         | TRANSACTION                                                                                          |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL", "failure_reason_id":18}] |
      | jobAction       | FAIL                                                                                                 |
      | jobMode         | DELIVERY                                                                                             |
      | failureReasonId | 18                                                                                                   |
    And API Core - Operator rts order:
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                              |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "RETURNED_TO_SENDER"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                  |
      | trackingId            | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}               |
      | granularStatus        | Returned to Sender                                  |
      | createdAt             | not null                                            |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | toCity                | null                                                |
      | toProvince            | null                                                |
      | toDistrict            | null                                                |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384           |
      | toPostcode            | 455384                                              |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}                |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}               |
      | toName                | Elsa Customer (RTS)                                 |
      | fromCity              | null                                                |
      | fromLongitude         | 132.89808                                           |
      | fromLatitude          | 1.38797979                                          |
      | installationRequired  | null                                                |
      | orderType             | NORMAL                                              |
      | deliveryType          | STANDARD                                            |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                         |
      | deliveryTypeId        | 2                                                   |
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}          |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}        |
      | serviceType           | PARCEL                                              |
      | serviceLevel          | STANDARD                                            |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}     |
      | originHub             | {sorting-hub-name}                                  |
      | destinationHub        | {sorting-hub-name}                                  |
      | bulkyCategoryName     | null                                                |
      | flightOfStairs        | null                                                |
      | deliveryDate          | null                                                |
      | isRts                 | false                                               |
      | timeslot              | NONE                                                |
      | shipperId             | {shipper-legacy-id}                                 |
      | codValue              | null                                                |
      | codCollected          | 0                                                   |
      | insuredValue          | null                                                |
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId} |

  @ArchiveRouteCommonV2 @HighPriority
  Scenario: Get Success RTS Order Price Details with Change Delivery Address for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                   |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                                           |
      | routes          | KEY_DRIVER_ROUTES                                                                                    |
      | jobType         | TRANSACTION                                                                                          |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL", "failure_reason_id":18}] |
      | jobAction       | FAIL                                                                                                 |
      | jobMode         | DELIVERY                                                                                             |
      | failureReasonId | 18                                                                                                   |
    And API Core - Operator rts order:
      | orderId    | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                                                                                |
      | rtsRequest | {"name":"Elsa Customer","contact":"+6583014911","email":"elsa@ninja.com","address1":"501 ORCHARD ROAD","address2":"WHEELOCK PLACE","postcode":"238880","city":"Singapore","country":"Singapore","latitude":1.3045363600053,"longitude":103.830714230777,"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "RETURNED_TO_SENDER"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                  |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDERS[1].trackingId}          |
      | granularStatus        | Returned to Sender                                  |
      | createdAt             | not null                                            |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | toCity                | null                                                |
      | toProvince            | null                                                |
      | toDistrict            | null                                                |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384           |
      | toPostcode            | 455384                                              |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}                |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}               |
      | toName                | Elsa Customer (RTS)                                 |
      | fromCity              | null                                                |
      | fromLongitude         | 132.89808                                           |
      | fromLatitude          | 1.38797979                                          |
      | installationRequired  | null                                                |
      | orderType             | NORMAL                                              |
      | deliveryType          | STANDARD                                            |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                         |
      | deliveryTypeId        | 2                                                   |
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}          |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}        |
      | serviceType           | PARCEL                                              |
      | serviceLevel          | STANDARD                                            |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}     |
      | originHub             | {sorting-hub-name}                                  |
      | destinationHub        | {sorting-hub-name}                                  |
      | bulkyCategoryName     | null                                                |
      | flightOfStairs        | null                                                |
      | deliveryDate          | null                                                |
      | isRts                 | false                                               |
      | timeslot              | NONE                                                |
      | shipperId             | {shipper-legacy-id}                                 |
      | codValue              | null                                                |
      | codCollected          | 0                                                   |
      | insuredValue          | null                                                |
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId} |

  @ArchiveRouteCommonV2 @HighPriority
  Scenario: Get Success Rescheduled Delivery Order Price Details without Change Delivery Address for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                   |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                                           |
      | routes          | KEY_DRIVER_ROUTES                                                                                    |
      | jobType         | TRANSACTION                                                                                          |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL", "failure_reason_id":18}] |
      | jobAction       | FAIL                                                                                                 |
      | jobMode         | DELIVERY                                                                                             |
      | failureReasonId | 18                                                                                                   |
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}        |
      | rescheduleRequest | {"date":"{date: 0 days ago, yyyy-MM-dd}"} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "COMPLETED"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                  |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDERS[1].trackingId}          |
      | granularStatus        | Completed                                           |
      | createdAt             | not null                                            |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | toCity                | null                                                |
      | toProvince            | null                                                |
      | toDistrict            | null                                                |
      | toAddress             | 9 TUA KONG GREEN MANILA GARDENS SG 455384           |
      | toPostcode            | 455384                                              |
      | toLatitude            | {KEY_CORE_WAYPOINT_DETAILS.latitude}                |
      | toLongitude           | {KEY_CORE_WAYPOINT_DETAILS.longitude}               |
      | toName                | Elsa Sender                                         |
      | fromCity              | null                                                |
      | fromLongitude         | 132.89808                                           |
      | fromLatitude          | 1.38797979                                          |
      | installationRequired  | null                                                |
      | orderType             | NORMAL                                              |
      | deliveryType          | STANDARD                                            |
      | deliveryTypeValue     | DELIVERY_THREE_DAYS_ANYTIME                         |
      | deliveryTypeId        | 2                                                   |
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}   |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}   |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}    |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}          |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}        |
      | serviceType           | PARCEL                                              |
      | serviceLevel          | STANDARD                                            |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}              |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}     |
      | originHub             | {sorting-hub-name}                                  |
      | destinationHub        | {sorting-hub-name}                                  |
      | bulkyCategoryName     | null                                                |
      | flightOfStairs        | null                                                |
      | deliveryDate          | null                                                |
      | isRts                 | false                                               |
      | timeslot              | NONE                                                |
      | shipperId             | {shipper-legacy-id}                                 |
      | codValue              | null                                                |
      | codCollected          | 0                                                   |
      | insuredValue          | null                                                |
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId} |

  @ArchiveRouteCommonV2 @HighPriority
  Scenario: Get Success Rescheduled Delivery Order Price Details with Change Delivery Address for Specific Country - SG
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | v4OrderRequest      | {"service_type":"Parcel","service_level":"Standard","from":{"name":"Elsa Customer","phone_number":"+6583014911","email":"elsa@ninja.com","address":{"address1":"233E ST. JOHN'S ROAD","address2":"","postcode":"757995","city":"Singapore","country":"Singapore","latitude":1.45694483734937,"longitude":103.825580873988}},"to":{"name":"Elsa Sender","phone_number":"+6583014912","email":"elsaf@ninja.com","address":{"address1":"9 TUA KONG GREEN","address2":"MANILA GARDENS","country":"Singapore","postcode":"455384","city":"Singapore","latitude":1.3184395712682,"longitude":103.925311276846}},"parcel_job":{ "is_pickup_required":false,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
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
    And API Driver - Driver login with username "{driver-username}" and "{driver-password}"
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[1].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[1].id} |
    And API Driver - Driver submit POD:
      | routeId         | {KEY_LIST_OF_CREATED_ROUTES[1].id}                                                                   |
      | waypointId      | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[2].waypointId}                                           |
      | routes          | KEY_DRIVER_ROUTES                                                                                    |
      | jobType         | TRANSACTION                                                                                          |
      | parcels         | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"FAIL", "failure_reason_id":18}] |
      | jobAction       | FAIL                                                                                                 |
      | jobMode         | DELIVERY                                                                                             |
      | failureReasonId | 18                                                                                                   |
    And API Core - Operator reschedule order:
      | orderId           | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                                                                                                            |
      | rescheduleRequest | {"name":"Elsa Customer","contact":"+6583014911","email":"elsa@ninja.com","address_1":"288J BUKIT BATOK STREET 25","address_2":"NATURE VIEW","postal_code":"659288","city":"Singapore","country":"Singapore","latitude": 1.3453,"longitude":103.7587,"date":"{date: 1 days next, yyyy-MM-dd}","timeWindow":-1} |
    And API Core - Operator get order details for tracking order "KEY_LIST_OF_CREATED_TRACKING_IDS[1]"
    Given API Core - Operator create new route using data below:
      | createRouteRequest | { "zoneId":{zone-id}, "hubId":{sorting-hub-id}, "vehicleId":{vehicle-id}, "driverId":{driver-id} } |
    And API Core - Operator add parcel to the route using data below:
      | addParcelToRouteRequest | {"route_id":{KEY_LIST_OF_CREATED_ROUTES[2].id},"type":"DELIVERY"} |
      | orderId                 | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
    And API Driver - Driver start route "{KEY_LIST_OF_CREATED_ROUTES[2].id}"
    And API Driver - Driver read routes:
      | driverId        | {driver-id}                        |
      | expectedRouteId | {KEY_LIST_OF_CREATED_ROUTES[2].id} |
    And API Driver - Driver submit POD:
      | routeId    | {KEY_LIST_OF_CREATED_ROUTES[2].id}                                              |
      | waypointId | {KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}                      |
      | routes     | KEY_DRIVER_ROUTES                                                               |
      | jobType    | TRANSACTION                                                                     |
      | parcels    | [{ "tracking_id": "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}", "action":"SUCCESS"}] |
      | jobAction  | SUCCESS                                                                         |
      | jobMode    | DELIVERY                                                                        |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with granular status "COMPLETED"
    When DB Core - operator get waypoints details for "{KEY_LIST_OF_CREATED_ORDERS[1].transactions[3].waypointId}"
    And API Core - verify order pricing details:
      | orderId               | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                |
      | trackingId            | {KEY_LIST_OF_CREATED_ORDERS[1].trackingId}                        |
      | granularStatus        | Completed                                                         |
      | createdAt             | not null                                                          |
      | shipperProvidedWeight | {KEY_LIST_OF_CREATED_ORDERS[1].weight}                            |
      | shipperProvidedHeight | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}                 |
      | shipperProvidedLength | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}                 |
      | shipperProvidedWidth  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}                  |
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
      | measuredHeight        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.height}                 |
      | measuredLength        | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.length}                 |
      | measuredWidth         | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.width}                  |
      | parcelSizeValue       | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSize}                        |
      | parcelSizeId          | {KEY_LIST_OF_CREATED_ORDERS[1].parcelSizeId}                      |
      | serviceType           | PARCEL                                                            |
      | serviceLevel          | STANDARD                                                          |
      | weight                | {KEY_LIST_OF_CREATED_ORDERS[1].weight}                            |
      | size                  | {KEY_LIST_OF_CREATED_ORDERS[1].dimensions.size}                   |
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
      | shipperOrderRefNo     | {KEY_LIST_OF_CREATED_ORDERS[1].requestedTrackingId}               |
