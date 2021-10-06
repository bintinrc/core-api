@ForceSuccessOrder @order-details @Populate-Pricing-Zone-L1-L3
Feature: Populate Pricing Zone L1-L3

  Scenario Outline: SG - Populate Pricing Info with Address Billing Zone L1-L3 upon Global Inbound (uid:9e87ca32-6dc0-4c1e-aac9-c727f626e3d4)
    Given API Shipper set Shipper V4 using data below:
      | legacyId | {shipper-legacy-id} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"contact": "+6598980057","email": "address.sg.6598980000@ninjavan.co","address1": "34 LORONG 30 GEYLANG","address2": "1-1","postcode": "398367","country": "SG","city": "SG","state": "Singapore","sub_district": "sub district","district": "district","street": "Street","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"contact": "+6598980001","email": "address.sg.6598980000@ninjavan.co","address1": "8 MARINA BOULEVARD","address2": "#01-01","postcode": "018981","country": "SG","city": "SG","state": "Singapore","sub_district":"sub district","district":"district","street":"Marina St","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator Global Inbound parcel using data below:
      | globalInboundRequest | { "hubId":{sorting-hub-id} } |
    Then DB Operator verify pricing info of "KEY_CREATED_ORDER_ID" order:
      | fromBillingZone.billingZone | {KEY_LIST_OF_FOUND_ZONES_INFO[1].billingZone} |
      | fromBillingZone.latitude    | <fromLatitude>                                |
      | fromBillingZone.longitude   | <fromLongitude>                               |
      | fromBillingZone.l1_id       | null                                          |
      | fromBillingZone.l1_name     | null                                          |
      | fromBillingZone.l2_id       | null                                          |
      | fromBillingZone.l2_name     | null                                          |
      | fromBillingZone.l3_id       | null                                          |
      | fromBillingZone.l3_name     | null                                          |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | null                                          |
      | toBillingZone.l1_name       | null                                          |
      | toBillingZone.l2_id         | null                                          |
      | toBillingZone.l2_name       | null                                          |
      | toBillingZone.l3_id         | null                                          |
      | toBillingZone.l3_name       | null                                          |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | 1.2853069    | 103.8061058   | 1.3880089  | 103.8946339 |

  Scenario Outline: SG - Populate Pricing Info with Address Billing Zone L1-L3 upon Edit Delivery Address (uid:c8848877-84e0-4e1f-aca4-2bad278155ce)
    Given API Shipper set Shipper V4 using data below:
      | legacyId | {shipper-legacy-id} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"contact": "+6598980057","email": "address.sg.6598980000@ninjavan.co","address1": "34 LORONG 30 GEYLANG","address2": "1-1","postcode": "398367","country": "SG","city": "SG","state": "Singapore","sub_district": "sub district","district": "district","street": "Street","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"contact": "+6598980001","email": "address.sg.6598980000@ninjavan.co","address1": "8 MARINA BOULEVARD","address2": "#01-01","postcode": "018981","country": "SG","city": "SG","state": "Singapore","sub_district":"sub district","district":"district","street":"Marina St","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Operator edits the delivery details of an order using data below:
      | orderId | {KEY_CREATED_ORDER_ID}                                                                                                                                                                                                                                                                                                  |
      | request | {"to":{"name":"George Ezra","email":"address.sg.6598980000@ninjavan.co","phone_number":"+6281386061359","address":{"address1":"204a Compassvale Drive, Singapore 541204, Singapore","address2":"204a","postcode":"018981","city":"Singapore","country":"Singapore","latitude":<toLatitude>,"longitude":<toLongitude>}}} |
    Then DB Operator verify pricing info of "KEY_CREATED_ORDER_ID" order:
      | fromBillingZone.billingZone | {KEY_LIST_OF_FOUND_ZONES_INFO[1].billingZone} |
      | fromBillingZone.latitude    | <fromLatitude>                                |
      | fromBillingZone.longitude   | <fromLongitude>                               |
      | fromBillingZone.l1_id       | null                                          |
      | fromBillingZone.l1_name     | null                                          |
      | fromBillingZone.l2_id       | null                                          |
      | fromBillingZone.l2_name     | null                                          |
      | fromBillingZone.l3_id       | null                                          |
      | fromBillingZone.l3_name     | null                                          |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | null                                          |
      | toBillingZone.l1_name       | null                                          |
      | toBillingZone.l2_id         | null                                          |
      | toBillingZone.l2_name       | null                                          |
      | toBillingZone.l3_id         | null                                          |
      | toBillingZone.l3_name       | null                                          |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | 1.2853069    | 103.8061058   | 1.3880089  | 103.8946339 |

  @DeleteRouteGroups
  Scenario Outline: SG - Populate Pricing Info with Address Billing Zone L1-L3 upon Single OJS Address Verification (uid:78808e0c-7326-4384-b2c6-9ba01c43de02)
    Given API Shipper set Shipper V4 using data below:
      | legacyId | {shipper-legacy-id} |
    Given API Operator get Billing Zone info:
      | latitude       | longitude       |
      | <fromLatitude> | <fromLongitude> |
      | <toLatitude>   | <toLongitude>   |
    When API Shipper create V4 order using data below:
      | v4OrderRequest | { "service_type":"Return","service_level":"Standard","from":{"name": "binti v4.1 ID","phone_number":"+6281386061359","email":"customer.return.kuc8tny9@ninjavan.co","address": {"contact": "+6598980057","email": "address.sg.6598980000@ninjavan.co","address1": "34 LORONG 30 GEYLANG","address2": "1-1","postcode": "398367","country": "SG","city": "SG","state": "Singapore","sub_district": "sub district","district": "district","street": "Street","latitude":<fromLatitude>,"longitude":<fromLongitude>}},"to":{"name":"George Ezra","phone_number":"+6281386061359","email":"address.sg.6598980000@ninjavan.co","address":{"contact": "+6598980001","email": "address.sg.6598980000@ninjavan.co","address1": "8 MARINA BOULEVARD","address2": "#01-01","postcode": "018981","country": "SG","city": "SG","state": "Singapore","sub_district":"sub district","district":"district","street":"Marina St","latitude":<toLatitude>,"longitude":<toLongitude>}},"parcel_job":{ "is_pickup_required":true,"pickup_date":"{{next-1-day-yyyy-MM-dd}}","pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"},"delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
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
      | fromBillingZone.l1_id       | null                                          |
      | fromBillingZone.l1_name     | null                                          |
      | fromBillingZone.l2_id       | null                                          |
      | fromBillingZone.l2_name     | null                                          |
      | fromBillingZone.l3_id       | null                                          |
      | fromBillingZone.l3_name     | null                                          |
      | toBillingZone.billingZone   | {KEY_LIST_OF_FOUND_ZONES_INFO[2].billingZone} |
      | toBillingZone.latitude      | <toLatitude>                                  |
      | toBillingZone.longitude     | <toLongitude>                                 |
      | toBillingZone.l1_id         | null                                          |
      | toBillingZone.l1_name       | null                                          |
      | toBillingZone.l2_id         | null                                          |
      | toBillingZone.l2_name       | null                                          |
      | toBillingZone.l3_id         | null                                          |
      | toBillingZone.l3_name       | null                                          |
    Examples:
      | fromLatitude | fromLongitude | toLatitude | toLongitude |
      | 1.2853069    | 103.8061058   | 1.3880089  | 103.8946339 |