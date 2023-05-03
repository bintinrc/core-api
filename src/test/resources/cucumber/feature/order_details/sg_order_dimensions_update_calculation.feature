@ForceSuccessOrder @order-details @OrderDimensionsUpdateCalculationSG
Feature: SG - Order Dimensions Update Calculation

  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 0.1 |
      | orders.dimensions.weight              | 0   |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0   |
    And Verify NO "Parcel Weight" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Verify NO "Parcel Measurements Update" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight = NULL
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                   |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                               |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 0.1 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0.1 |
    And Verify NO "Parcel Weight" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Verify NO "Parcel Measurements Update" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @happy-path
  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight > 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 3.5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And API Sort - Operator global inbound
      | globalInboundRequest | {"inbound_type":"SORTING_HUB","to_reschedule":false,"to_show_shipper_info":false,"tags":[]} |
      | trackingId           | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                       |
      | hubId                | {sorting-hub-id}                                                                            |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 3.5 |
      | orders.dimensions.weight              | 3.5 |
      | orders.data.originalWeight            | 3.5 |
      | orders.data.originalDimensions.weight | 3.5 |
    And Verify NO "Parcel Weight" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Verify NO "Parcel Measurements Update" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  Scenario: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 1.2 |
      | length | 10  |
      | width  | 20  |
      | height | 30  |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 1.2 |
      | orders.dimensions.weight              | 1.2 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0   |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  Scenario: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight = NULL
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                   |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                               |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 2.0 |
      | length | 10  |
      | width  | 20  |
      | height | 30  |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 2.0 |
      | orders.dimensions.weight              | 2.0 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0.1 |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  Scenario Outline: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight > 0 - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1.5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | <new_weight> |
      | length | 10           |
      | width  | 20           |
      | height | 30           |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | <new_weight> |
      | orders.dimensions.weight              | <new_weight> |
      | orders.data.originalWeight            | 1.5          |
      | orders.data.originalDimensions.weight | 1.5          |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |

  @happy-path
  Scenario Outline: SG - Update Order Weight on Edit Order - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"weight": 1.5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator updates order dimensions with following details for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | weight | <new_weight> |
      | length | 60           |
      | width  | 20           |
      | height | 30           |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | <new_weight> |
      | orders.dimensions.weight              | <new_weight> |
      | orders.data.originalWeight            | 1.5          |
      | orders.data.originalDimensions.weight | 1.5          |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |

  @happy-path @wiptodo
  Scenario Outline: SG - Update Order Weight on Upload CSV Order Weight Update Page - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 1.5      |
    And Operator search for created order
    When API Operator update order pricing_weight to <new_weight> using order-weight-update
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | <new_weight> |
      | orders.dimensions.weight              | <new_weight> |
      | orders.data.originalWeight            | 1.5          |
      | orders.data.originalDimensions.weight | 1.5          |
    And Verify NO "Parcel Weight" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Verify NO "Parcel Measurements Update" event sent for order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |
