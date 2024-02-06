@ForceSuccessOrders @order-details-id @OrderDimensionsUpdateCalculationID
Feature: ID - Order Dimensions Update Calculation

  @HighPriority
  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight > 100 KG (divide by 1000), Adjusted Weight <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |
    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted weight > 100 KG (divide by 1000), Adjusted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2500                     | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1500                     | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1500                     | 1               | 20     | 30    | 30     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |
    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |

    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2.5                      | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1.5                      | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1.5                      | 1               | 20     | 30    | 30     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 0.55            | 0.55                     | 0               | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 0.59            | 0.45                     | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 0.55            | 0.45                     | 0               | 33     | 10    | 10     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 100 KG - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Examples:
      | Note                                     | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | 550             | 550                      | 0               | 60     | 100   | 400    |
      | Highest Weight = Measured Weight         | 456             | 450                      | 456             | 60     | 100   | 400    |
      | Highest Weight = Volumetric Weight       | 550             | 550                      | 0               | 330    | 100   | 100    |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2.5                      | 0               | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1.5                      | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1.5                      | 0               | 20     | 30    | 30     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 100 KG (divide by 1000), Adjusted Weight <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | <shipper_submitted_weight>             |

    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted weight > 100 KG (divide by 1000), Adjusted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2500                     | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1500                     | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1500                     | 1               | 20     | 30    | 30     |

  @HighPriority
  Scenario Outline: ID - Override Weight with Pricing Weight When Update Order Weight on Edit Order - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1.5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight         | <weight>         |
      | pricing_weight | <pricing_weight> |
      | length         | 10               |
      | width          | 20               |
      | height         | 30               |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | <pricing_weight> |
      | orders.dimensions.weight              | <weight>         |
      | orders.data.originalWeight            | 1.5              |
      | orders.data.originalDimensions.weight | 1.5              |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Examples:
      | Note                            | weight | pricing_weight |
      | Pricing Weight > Current Weight | 3.6    | 2.5            |
      | Pricing Weight < Current Weight | 3.6    | 1.2            |

  @HighPriority
  Scenario: ID - Update Weight upon Global Inbound - Inbound Second Time with no Changes
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1.5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 3.2 |
      | length | 60  |
      | width  | 20  |
      | height | 30  |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | 1.5                                    |
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight is updated to highest weight correctly
      | orderId                | {KEY_LIST_OF_CREATED_ORDERS[1].id}     |
      | length                 | {KEY_DIMENSION_CHANGES_REQUEST.length} |
      | width                  | {KEY_DIMENSION_CHANGES_REQUEST.width}  |
      | height                 | {KEY_DIMENSION_CHANGES_REQUEST.height} |
      | weight                 | {KEY_DIMENSION_CHANGES_REQUEST.weight} |
      | shipperSubmittedWeight | 1.5                                    |

  @HighPriority
  Scenario Outline: ID - Update Weight upon Global Inbound - Override Measured Weight as Highest Weight - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": <shipper_submitted_weight>}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","dimensions":{"width": <width>,"height": <height>,"length": <length>,"weight": <measured_weight>},"to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                                         |
      | hubId                | {sorting-hub-id}                                                                                                                                                                              |
    Then DB Core - verify order weight updated correctly
      | weight   | <expected_weight>                  |
      | order_id | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.data.originalWeight | <shipper_submitted_weight> |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2.5                      | 0               | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1.5                      | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1.5                      | 0               | 20     | 30    | 30     |
