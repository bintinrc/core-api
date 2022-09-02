Feature: ID - Populate Pricing Zone L1-L3

  Scenario Outline: ID - Populate Pricing Info with Address Billing Zone L1-L3 upon Global Inbound (uid:2275c571-7692-470e-82d7-aa188eea0863)
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"address1": "Jalan Ciwastra Raya","address2": "#30-35","country": "ID","kecamatan": "Mekarjaya","city": "Bandung","province": "Jawa Barat","postcode": "40287","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"address1": "Jalan Surabaya Raya","address2": "#20-25","country": "ID","kecamatan": "Medaeng Waru","city": "Sidoarjo","province": "Jawa Tmur","postcode": "61256","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00", "timezone": "Asia/Jakarta"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00", "timezone": "Asia/Jakarta"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    Then DB Operator verify pricing info of "KEY_CREATED_ORDER_ID" order:
      | fromBillingZone.billingZone | {KEY_LIST_OF_FOUND_ZONES_INFO[1].billingZone} |
      | fromBillingZone.latitude    | <fromLatitude>                                |
      | fromBillingZone.longitude   | <fromLongitude>                               |
      | fromBillingZone.l1_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Id}        |
      | fromBillingZone.l1_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Name}      |
      | fromBillingZone.l2_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Id}        |
      | fromBillingZone.l2_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Name}      |
      | fromBillingZone.l3_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Id}        |
      | fromBillingZone.l3_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Name}      |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Id}        |
      | toBillingZone.l1_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Name}      |
      | toBillingZone.l2_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Id}        |
      | toBillingZone.l2_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Name}      |
      | toBillingZone.l3_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Id}        |
      | toBillingZone.l3_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Name}      |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | -6.1594307   | 106.7856113   | -8.0021898 | 110.503534  |

  Scenario Outline: ID - Populate Pricing Info with Address Billing Zone L1-L3 upon Edit Delivery Address (uid:f5c023d9-43d0-404c-a789-b8d3a827b1f6)
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"address1": "Jalan Ciwastra Raya","address2": "#30-35","country": "ID","kecamatan": "Mekarjaya","city": "Bandung","province": "Jawa Barat","postcode": "40287","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"address1": "Jalan Surabaya Raya","address2": "#20-25","country": "ID","kecamatan": "Medaeng Waru","city": "Sidoarjo","province": "Jawa Tmur","postcode": "61256","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00", "timezone": "Asia/Jakarta"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00", "timezone": "Asia/Jakarta"}}} |
    And API Operator edits the delivery details of an order using data below:
      | orderId | {KEY_CREATED_ORDER_ID}                                                                                                                                                                                                                                                                                                                                               |
      | request | {"to":{"name":"binti v4.1 ID","email":"customer.return.kuc8tny9@ninjavan.co","phone_number":"+6598980030","address":{"address1":"Masjid Baiturahim II Paliyan, Paliyan,GK, Gunung Kidul, Special Region of Yogyakarta 55871, Indonesia","address2":"","postcode":"40287","city":"Paliyan","country":"Indonesia","latitude":<toLatitude>,"longitude":<toLongitude>}}} |
    Then DB Operator verify pricing info of "KEY_CREATED_ORDER_ID" order:
      | fromBillingZone.billingZone | {KEY_LIST_OF_FOUND_ZONES_INFO[1].billingZone} |
      | fromBillingZone.latitude    | <fromLatitude>                                |
      | fromBillingZone.longitude   | <fromLongitude>                               |
      | fromBillingZone.l1_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Id}        |
      | fromBillingZone.l1_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Name}      |
      | fromBillingZone.l2_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Id}        |
      | fromBillingZone.l2_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Name}      |
      | fromBillingZone.l3_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Id}        |
      | fromBillingZone.l3_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Name}      |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Id}        |
      | toBillingZone.l1_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Name}      |
      | toBillingZone.l2_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Id}        |
      | toBillingZone.l2_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Name}      |
      | toBillingZone.l3_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Id}        |
      | toBillingZone.l3_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Name}      |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | -6.1594307   | 106.7856113   | -8.0021898 | 110.503534  |

  Scenario Outline: ID - Populate Pricing Info with Address Billing Zone L1-L3 upon Single OJS Address Verification (uid:56d0f163-a28c-416a-b3bb-7090c7b7e23d)
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"address1": "Jalan Ciwastra Raya","address2": "#30-35","country": "ID","kecamatan": "Mekarjaya","city": "Bandung","province": "Jawa Barat","postcode": "40287","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"address1": "Jalan Surabaya Raya","address2": "#20-25","country": "ID","kecamatan": "Medaeng Waru","city": "Sidoarjo","province": "Jawa Tmur","postcode": "61256","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00", "timezone": "Asia/Jakarta"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00", "timezone": "Asia/Jakarta"}}} |
    And API Operator create new Route Group:
      | name        | ARG-{gradle-current-date-yyyyMMddHHmmsss}                                                                    |
      | description | This Route Group is created by automation test from Operator V2. Created at {gradle-current-date-yyyy-MM-dd} |
    And API Operator get order details
    And API Operator add Delivery transaction to "{KEY_CREATED_ROUTE_GROUP.id}" Route Group
    And DB Operator unarchive Jaro Scores of Delivery Transaction waypoint of created order
    And API Operator fetch addresses of "{KEY_CREATED_ROUTE_GROUP.id}" route group
    And API Operator verifies single address:
      | addressId        | manual                                                   |
      | latitude         | <toLatitude>                                             |
      | longitude        | <toLongitude>                                            |
      | orderJaroScoreId | {KEY_LIST_OF_ORDER_JARO_SCORES_INFO[1].orderJaroScoreId} |
      | sameday          | false                                                    |
      | waypointId       | {KEY_LIST_OF_ORDER_JARO_SCORES_INFO[1].waypointId}       |
    Then DB Operator verify pricing info of "KEY_CREATED_ORDER_ID" order:
      | fromBillingZone.billingZone | {KEY_LIST_OF_FOUND_ZONES_INFO[1].billingZone} |
      | fromBillingZone.latitude    | <fromLatitude>                                |
      | fromBillingZone.longitude   | <fromLongitude>                               |
      | fromBillingZone.l1_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Id}        |
      | fromBillingZone.l1_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l1Name}      |
      | fromBillingZone.l2_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Id}        |
      | fromBillingZone.l2_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l2Name}      |
      | fromBillingZone.l3_id       | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Id}        |
      | fromBillingZone.l3_name     | {KEY_LIST_OF_FOUND_ZONES_INFO[1].l3Name}      |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Id}        |
      | toBillingZone.l1_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l1Name}      |
      | toBillingZone.l2_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Id}        |
      | toBillingZone.l2_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l2Name}      |
      | toBillingZone.l3_id         | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Id}        |
      | toBillingZone.l3_name       | {KEY_LIST_OF_FOUND_ZONES_INFO[2].l3Name}      |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | -6.1594307   | 106.7856113   | -8.0021898 | 110.503534  |