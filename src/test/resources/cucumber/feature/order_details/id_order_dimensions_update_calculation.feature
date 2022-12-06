@ForceSuccessOrder @order-details-id @OrderDimensionsUpdateCalculationID
Feature: ID - Order Dimensions Update Calculation

  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight > 100 KG (divide by 1000), Adjusted Weight <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then Operator verifies orders.weight is updated to highest weight correctly
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then Operator verifies orders.weight is updated to highest weight correctly
    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted weight > 100 KG (divide by 1000), Adjusted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    Examples:
      | Note                                     | shipper_weight_case | use_weight_range | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | true             | 2.5             | 2500                     | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | false            | 2.0             | 1500                     | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | false            | 3.0             | 1500                     | 1               | 20     | 30    | 30     |

  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then Operator verifies orders.weight is updated to highest weight correctly
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then Operator verifies orders.weight is updated to highest weight correctly
    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  Scenario Outline: ID - Update Weight upon Global Inbound - Shipper Submitted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    Examples:
      | Note                                     | shipper_weight_case | use_weight_range | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | true             | 2.5             | 2.5                      | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | false            | 2.0             | 1.5                      | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | false            | 3.0             | 1.5                      | 1               | 20     | 30    | 30     |

  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 0.55            | 0.55                     | 0               | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 0.59            | 0.45                     | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 0.55            | 0.45                     | 0               | 33     | 10    | 10     |

  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 100 KG - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    Examples:
      | Note                                     | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | 550             | 550                      | 0               | 60     | 100   | 400    |
      | Highest Weight = Measured Weight         | 456             | 450                      | 456             | 60     | 100   | 400    |
      | Highest Weight = Volumetric Weight       | 550             | 550                      | 0               | 330    | 100   | 100    |

  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight> |
      | use_weight_range | false             |
    Examples:
      | Note                                     | shipper_weight_case | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | 2.5             | 2.5                      | 0               | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | 2.0             | 1.5                      | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | 3.0             | 1.5                      | 0               | 20     | 30    | 30     |

  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted Weight > 100 KG (divide by 1000), Adjusted Weight <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then Operator verifies orders.weight is updated to highest weight correctly
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then Operator verifies orders.weight is updated to highest weight correctly
    Examples:
      | Note                                     | shipper_weight_case | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | <= 0.6 KG           | 550                      | 0.45            | 40     | 6     | 10     |
      | Highest Weight = Measured Weight         | <= 0.6 KG           | 450                      | 0.59            | 40     | 6     | 10     |
      | Highest Weight = Volumetric Weight       | <= 0.6 KG           | 450                      | 0.49            | 33     | 10    | 10     |

  Scenario Outline: ID - Update Weight upon Edit Order Dimensions - Shipper Submitted weight > 100 KG (divide by 1000), Adjusted Weight > 0.6 & <shipper_weight_case> - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel                     |
      | service_level                 | Standard                   |
      | parcel_job_is_pickup_required | false                      |
      | weight                        | <shipper_submitted_weight> |
    And Operator search for created order
    When Operator updates order dimensions with following details
      | weight | <measured_weight> |
      | length | <length>          |
      | width  | <width>           |
      | height | <height>          |
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then DB Operator verifies order weight updated to highest weight within range
      | weight           | <expected_weight>  |
      | use_weight_range | <use_weight_range> |
    Examples:
      | Note                                     | shipper_weight_case | use_weight_range | expected_weight | shipper_submitted_weight | measured_weight | length | width | height |
      | Highest Weight = Shipper Adjusted Weight | < 100 KG            | true             | 2.5             | 2500                     | 1.2             | 10     | 10    | 60     |
      | Highest Weight = Measured Weight         | < 100 KG            | false            | 2.0             | 1500                     | 2               | 10     | 10    | 60     |
      | Highest Weight = Volumetric Weight       | < 100 KG            | false            | 3.0             | 1500                     | 1               | 20     | 30    | 30     |

  Scenario Outline: ID - Override Weight with Pricing Weight When Update Order Weight on Edit Order - <Note>
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
      | weight         | <weight>         |
      | pricing_weight | <pricing_weight> |
      | length         | 10               |
      | width          | 20               |
      | height         | 30               |
    Then DB Operator verifies orders.weight and dimensions updated correctly
      | orders.weight                         | <pricing_weight> |
      | orders.dimensions.weight              | <weight>         |
      | orders.data.originalWeight            | 1.5              |
      | orders.data.originalDimensions.weight | 1.5              |
    Then Shipper gets webhook request for event "Parcel Weight" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Weight"
    Then Shipper gets webhook request for event "Parcel Measurements Update" for all orders
    And Shipper verifies webhook request payload has correct details for status "Parcel Measurements Update"
    Examples:
      | Note                            | weight | pricing_weight |
      | Pricing Weight > Current Weight | 3.6    | 2.5            |
      | Pricing Weight < Current Weight | 3.6    | 1.2            |

  Scenario: ID - Update Weight upon Global Inbound - Inbound Second Time with no Changes
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | weight                        | 1.5      |
    And Operator search for created order
    When Operator global inbound at hub "{sorting-hub-id}" with changes in dimensions
      | weight | 3.2 |
      | length | 60  |
      | width  | 20  |
      | height | 30  |
    Then Operator verifies orders.weight is updated to highest weight correctly
    When Operator perform global inbound at hub "{sorting-hub-id}"
    Then Operator verifies orders.weight is updated to highest weight correctly
