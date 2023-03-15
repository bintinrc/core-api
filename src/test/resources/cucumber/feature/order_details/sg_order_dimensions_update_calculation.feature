@ForceSuccessOrder @order-details @OrderDimensionsUpdateCalculationSG
Feature: SG - Order Dimensions Update Calculation

  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 0        |
    And Operator search for created order
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | 0.1 |
      | orders.dimensions.weight              | 0   |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0   |
    And Verify NO "Parcel Weight" event sent for all orders
    And Verify NO "Parcel Measurements Update" event sent for all orders

  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight = NULL
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | generateFromAndTo | RANDOM                                                                                                                                                                                                                                                                                                                                                                                |
      | v4OrderRequest    | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And Operator search for created order
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | 0.1 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0.1 |
    And Verify NO "Parcel Weight" event sent for all orders
    And Verify NO "Parcel Measurements Update" event sent for all orders

  @happy-path
  Scenario: SG - Global Inbound Order with No Weight Changes - Shipper Submitted Weight > 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 3.5      |
    And Operator search for created order
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | 3.5 |
      | orders.dimensions.weight              | 3.5 |
      | orders.data.originalWeight            | 3.5 |
      | orders.data.originalDimensions.weight | 3.5 |
    And Verify NO "Parcel Weight" event sent for all orders
    And Verify NO "Parcel Measurements Update" event sent for all orders

  Scenario: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight = 0
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 0        |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | 1.2 |
      | length | 10  |
      | width  | 20  |
      | height | 30  |
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | 1.2 |
      | orders.dimensions.weight              | 1.2 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0   |
    Then Shipper gets webhook request for event "Parcel Weight" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight"
    Then Shipper gets webhook request for event "Parcel Measurements Update" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update"

  Scenario: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight = NULL
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given API Shipper set Shipper V4 using data below:
      | shipperV4ClientId     | {shipper-client-id}     |
      | shipperV4ClientSecret | {shipper-client-secret} |
    When API Shipper create V4 order using data below:
      | generateFromAndTo | RANDOM                                                                                                                                                                                                                                                                                                                                                                                |
      | v4OrderRequest    | { "service_type":"Parcel","service_level":"Standard", "parcel_job":{"dimensions": {"height": 2.7,"length": 2.8,"width": 1},"is_pickup_required":false, "pickup_date":"{{next-1-day-yyyy-MM-dd}}", "pickup_timeslot":{ "start_time":"12:00", "end_time":"15:00"}, "delivery_start_date":"{{next-1-day-yyyy-MM-dd}}", "delivery_timeslot":{ "start_time":"09:00", "end_time":"22:00"}}} |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | 2.0 |
      | length | 10  |
      | width  | 20  |
      | height | 30  |
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | 2.0 |
      | orders.dimensions.weight              | 2.0 |
      | orders.data.originalWeight            | 0.1 |
      | orders.data.originalDimensions.weight | 0.1 |
    Then Shipper gets webhook request for event "Parcel Weight" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight"
    Then Shipper gets webhook request for event "Parcel Measurements Update" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update"

  Scenario Outline: SG - Global Inbound Order with Weight Changes - Shipper Submitted Weight > 0 - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 1.5      |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | <new_weight> |
      | length | 10           |
      | width  | 20           |
      | height | 30           |
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | <new_weight> |
      | orders.dimensions.weight              | <new_weight> |
      | orders.data.originalWeight            | 1.5          |
      | orders.data.originalDimensions.weight | 1.5          |
    Then Shipper gets webhook request for event "Parcel Weight" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight"
    Then Shipper gets webhook request for event "Parcel Measurements Update" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update"
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |

  @happy-path
  Scenario Outline: SG - Update Order Weight on Edit Order - <Note>
    Given Shipper id "{shipper-id}" subscribes to "Parcel Weight" webhook
    And Shipper id "{shipper-id}" subscribes to "Parcel Measurements Update" webhook
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 1.5      |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <new_weight> |
      | length | 60           |
      | width  | 20           |
      | height | 30           |
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | <new_weight> |
      | orders.dimensions.weight              | <new_weight> |
      | orders.data.originalWeight            | 1.5          |
      | orders.data.originalDimensions.weight | 1.5          |
    Then Shipper gets webhook request for event "Parcel Weight" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight"
    Then Shipper gets webhook request for event "Parcel Measurements Update" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update"
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |

  @happy-path
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
    And Verify NO "Parcel Weight" event sent for all orders
    And Verify NO "Parcel Measurements Update" event sent for all orders
    Examples:
      | Note                        | new_weight |
      | New Weight > Current Weight | 3.5        |
      | New Weight < Current Weight | 1.1        |
