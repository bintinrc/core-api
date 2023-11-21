@ForceSuccessOrders @order-details @OrderDimensionsPartialUpdateCalculationSG
Feature: SG - Partial Update Order Dimensions on Inbound

  https://studio.cucumber.io/projects/208144/test-plan/folders/2788728

  @HighPriority
  Scenario: SG - Global Inbound Order with All Dimensions ( L / W / H )  != 0 & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight":0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 20 |
      | length | 40 |
      | width  | 30 |
      | height | 20 |
      | size   | L  |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                     |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                                                                                       |
      | eventData | {"weight":{"new_value":20},"length":{"new_value":40},"width":{"new_value":30},"height":{"new_value":20},"parcel_size_id":{"old_value":0,"new_value":2},"raw_height":20,"raw_length":40,"raw_width":30,"raw_weight":20} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    Then DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 20                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 20 |
      | length | 40 |
      | width  | 30 |
      | height | 20 |
      | size   | L  |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.manual_dimensions record:
      | weight | 20    |
      | length | 40    |
      | width  | 30    |
      | height | 20    |
      | size   | LARGE |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 20 |
      | orders.dimensions.weight              | 20 |
      | orders.data.originalWeight            | 0  |
      | orders.data.originalDimensions.weight | 0  |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - Global Inbound Order with One Of Dimensions ( L / W / H ) = 0 & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight":0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 10 |
      | length | 0  |
      | width  | 60 |
      | height | 13 |
      | size   | M  |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                                            |
      | eventData | {"weight":{"new_value":10},"length":{},"width":{},"height":{},"parcel_size_id":{"old_value":0,"new_value":1},"raw_height":13,"raw_length":0,"raw_width":60,"raw_weight":10} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    Then DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 10                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 10 |
      | length | 0  |
      | width  | 0  |
      | height | 0  |
      | size   | M  |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.manual_dimensions record:
      | weight | 10     |
      | length | 0      |
      | width  | 60     |
      | height | 13     |
      | size   | MEDIUM |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 10 |
      | orders.dimensions.weight              | 10 |
      | orders.data.originalWeight            | 0  |
      | orders.data.originalDimensions.weight | 0  |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - Global Inbound Order with All Dimensions ( L / W / H ) = 0  & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 20,"width": 30,"height": 40,"weight":10}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 85 |
      | length | 0  |
      | width  | 0  |
      | height | 0  |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                                  |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                                                                                    |
      | eventData | {"weight":{"old_value":10,"new_value":85},"length":{"old_value":20,"new_value":20},"width":{"old_value":30,"new_value":30},"height":{"old_value":40,"new_value":40},"parcel_size_id":{"old_value":0,"new_value":4}} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    Then DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 85                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 85  |
      | length | 20  |
      | width  | 30  |
      | height | 40  |
      | size   | XXL |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.manual_dimensions record:
      | weight | 85      |
      | length | 0       |
      | width  | 0       |
      | height | 0       |
      | size   | XXLARGE |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 85 |
      | orders.dimensions.weight              | 85 |
      | orders.data.originalWeight            | 10 |
      | orders.data.originalDimensions.weight | 10 |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - Global Inbound Order with All Dimensions ( L / W / H ) != 0 & weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight":5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 0  |
      | length | 30 |
      | width  | 10 |
      | height | 20 |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                    |
      | eventType | HUB_INBOUND_SCAN                                                                                                      |
      | eventData | {"weight":{"old_value":5,"new_value":5},"length":{"new_value":30},"width":{"new_value":10},"height":{"new_value":20}} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    Then DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 5                                  |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 5  |
      | length | 30 |
      | width  | 10 |
      | height | 20 |
      | size   | XS |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.manual_dimensions record:
      | weight | 0      |
      | length | 30     |
      | width  | 10     |
      | height | 20     |
      | size   | XSMALL |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 5 |
      | orders.dimensions.weight              | 5 |
      | orders.data.originalWeight            | 5 |
      | orders.data.originalDimensions.weight | 5 |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - Global Inbound Order with All Dimensions ( L / W / H ) = 0 & weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 20,"width": 30,"height": 40,"weight":10}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When Operator global inbound at hub "{sorting-hub-id}" for tid "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}" with changes in dimensions
      | weight | 0 |
      | length | 0 |
      | width  | 0 |
      | height | 0 |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                   |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                                     |
      | eventData | {"weight":{"old_value":10,"new_value":10},"length":{"old_value":20,"new_value":20},"width":{"old_value":30,"new_value":30},"height":{"old_value":40,"new_value":40}} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    Then DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 10                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 10 |
      | length | 20 |
      | width  | 30 |
      | height | 40 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.manual_dimensions record:
      | weight | 0 |
      | length | 0 |
      | width  | 0 |
      | height | 0 |
    Then DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.weight                         | 10 |
      | orders.dimensions.weight              | 10 |
      | orders.data.originalWeight            | 10 |
      | orders.data.originalDimensions.weight | 10 |
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - DWS Inbound Order with All Dimensions ( L / W / H ) != 0 & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight":0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Sort - DWS inbound
      | barcodes          | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                              |
      | hubId             | {sorting-hub-id}                                                                                                                                                                   |
      | dwsInboundRequest | { "dimensions": {"l": 70.0,"w": 80.0,"h": 90.0}, "weight": {"value": 3.0}, "timestamp": "{date: 0 days next, yyyy-MM-dd'T'hh:mm:ss'+08:00'}","dimweightPhoto": "{based-64-image}"} |
    Then API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                     |
      | eventType | HUB_INBOUND_SCAN                                                                                                       |
      | eventData | {"weight": {"new_value": 0.003},"length": {"new_value": 7.0},"width": {"new_value": 8.0},"height": {"new_value": 9.0}} |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    And DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 0.003                              |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 0.003 |
      | length | 7     |
      | width  | 8     |
      | height | 9     |
      | size   | XS    |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.belt_dimensions record:
      | weight | 0.003  |
      | length | 7      |
      | width  | 8      |
      | height | 9      |
      | size   | XSMALL |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - DWS Inbound Order with One Of Dimensions ( L / W / H ) = 0 & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight":0}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Sort - DWS inbound
      | barcodes          | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                            |
      | hubId             | {sorting-hub-id}                                                                                                                                                                 |
      | dwsInboundRequest | { "dimensions": {"l": 70.0,"w": 0,"h": 90.0}, "weight": {"value": 3000}, "timestamp": "{date: 0 days next, yyyy-MM-dd'T'hh:mm:ss'+08:00'}","dimweightPhoto": "{based-64-image}"} |
    Then API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                        |
      | eventType | HUB_INBOUND_SCAN                                                          |
      | eventData | { "weight": {"new_value": 3.0}, "length": {}, "width": {}, "height": {} } |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    And DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 3                                  |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 3 |
      | length | 0 |
      | width  | 0 |
      | height | 0 |
      | size   | S |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.belt_dimensions record:
      | weight | 3     |
      | length | 7     |
      | width  | 0     |
      | height | 9     |
      | size   | SMALL |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - DWS Inbound Order with All Dimensions ( L / W / H ) = 0 & weight != 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 40,"width": 20,"height": 30,"weight": 10}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Sort - DWS inbound
      | barcodes          | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                       |
      | hubId             | {sorting-hub-id}                                                                                                                                                            |
      | dwsInboundRequest | { "dimensions": {"l": 0,"w": 0,"h": 0}, "weight": {"value": 85000}, "timestamp": "{date: 0 days next, yyyy-MM-dd'T'hh:mm:ss'+08:00'}","dimweightPhoto": "{based-64-image}"} |
    Then API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                                                 |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                                                                   |
      | eventData | { "weight": {"old_value": 10.0,"new_value": 85.0},"length": {"old_value": 40.0,"new_value": 40.0},"width": {"old_value": 20.0,"new_value": 20.0},"height": {"old_value": 30.0,"new_value": 30.0} } |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    And DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.data.originalWeight | 10 |
    And DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 85                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 85  |
      | length | 40  |
      | width  | 20  |
      | height | 30  |
      | size   | XXL |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.belt_dimensions record:
      | weight | 85      |
      | length | 0       |
      | width  | 0       |
      | height | 0       |
      | size   | XXLARGE |
    And Shipper gets webhook request for event "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - DWS Inbound Order with All Dimensions ( L / W / H ) != 0 & weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 0,"width": 0,"height": 0,"weight": 5}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Sort - DWS inbound
      | barcodes          | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                            |
      | hubId             | {sorting-hub-id}                                                                                                                                                                 |
      | dwsInboundRequest | { "dimensions": {"l": 70.0,"w": 80.0,"h": 90.0}, "weight": {"value": 0}, "timestamp": "{date: 0 days next, yyyy-MM-dd'T'hh:mm:ss'+08:00'}","dimweightPhoto": "{based-64-image}"} |
    Then API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                      |
      | eventType | HUB_INBOUND_SCAN                                                                                                                        |
      | eventData | { "weight": {"old_value": 5.0,"new_value": 5.0},"length": {"new_value": 7.0},"width": {"new_value": 8.0},"height": {"new_value": 9.0} } |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    And DB Core - verify orders.weight and dimensions updated correctly for order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}"
      | orders.data.originalWeight | 5 |
    And DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 5                                  |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 5  |
      | length | 7  |
      | width  | 8  |
      | height | 9  |
      | size   | XS |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.belt_dimensions record:
      | weight | 0      |
      | length | 7      |
      | width  | 8      |
      | height | 9      |
      | size   | XSMALL |
    And Shipper gets webhook request for event "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    And Shipper verifies webhook request payload has correct details for status "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"

  @HighPriority
  Scenario: SG - DWS Inbound Order with All Dimension ( L / W / H ) = 0 & weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    And Shipper id "{shipper-id}" subscribes to "Arrived at Sorting Hub" webhook
    And API Order - Shipper create multiple V4 orders using data below:
      | shipperClientId     | {shipper-client-id}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
      | shipperClientSecret | {shipper-client-secret}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | generateFromAndTo   | RANDOM                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
      | v4OrderRequest      | { "service_type":"Parcel","service_level":"Standard","to":{"name": "QA core api automation","phone_number": "+65189681","email": "qa@test.co", "address": {"address1": "80 MANDAI LAKE ROAD","address2": "Singapore Zoological","country": "SG","postcode": "{dp-address-postcode}","latitude": 1.3248209,"longitude": 103.6983167}},"parcel_job":{ "dimensions": {"length": 40,"width": 20,"height": 30,"weight": 10}, "is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And API Core - Operator get order details for tracking order "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
    When API Sort - DWS inbound
      | barcodes          | {KEY_LIST_OF_CREATED_TRACKING_IDS[1]}                                                                                                                                   |
      | hubId             | {sorting-hub-id}                                                                                                                                                        |
      | dwsInboundRequest | { "dimensions": {"l": 0,"w": 0,"h": 0}, "weight": {"value": 0}, "timestamp": "{date: 0 days next, yyyy-MM-dd'T'hh:mm:ss'+08:00'}","dimweightPhoto": "{based-64-image}"} |
    Then API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                             |
      | eventType | HUB_INBOUND_SCAN                                                                                                                                               |
      | eventData | { "weight":{"oldValue":10,"newValue":10},"length":{"oldValue":40,"newValue":40},"height":{"oldValue":30,"newValue":30},"width":{"oldValue":20,"newValue":20} } |
    And API Core - Operator verify that event is published with correct details:
      | orderId   | {KEY_LIST_OF_CREATED_ORDERS[1].id}                                                                                                                                          |
      | eventType | UPDATE_STATUS                                                                                                                                                               |
      | eventData | {"granular_status":{"old_value":"Pending Pickup","new_value":"Arrived at Sorting Hub"},"order_status":{"old_value":"Pending","new_value":"Transit"},"reason":"HUB_INBOUND"} |
    And DB Core - verify orders record:
      | id     | {KEY_LIST_OF_CREATED_ORDERS[1].id} |
      | weight | 10                                 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.dimensions record:
      | weight | 10 |
      | length | 40 |
      | width  | 20 |
      | height | 30 |
    And DB Core - verify order id "{KEY_LIST_OF_CREATED_ORDERS[1].id}" orders.data.belt_dimensions record:
      | weight | 0 |
      | length | 0 |
      | width  | 0 |
      | height | 0 |
    And Shipper gets webhook request for event "Arrived at Sorting Hub" and tracking id "{KEY_LIST_OF_CREATED_TRACKING_IDS[1]}"
