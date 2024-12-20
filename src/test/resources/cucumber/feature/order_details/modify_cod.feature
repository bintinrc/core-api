@ForceSuccessOrders @ArchiveDriverRoutes @order-details @modify-cod
Feature: Order Details

  @modify-cod @MediumPriority
  Scenario Outline: Do not allow to Modify COD if Order State is Completed - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And Operator force success order
    When Operator "<action>" Order COD value with value 50.0
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                  |
      | message     | Not allowed to update 'Completed' order |
      | application | core                                    |
      | description | INVALID_ORDER_EXCEPTION                 |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    | 0   | uid:746af929-4ea9-43c6-b8b0-96f016cf1f90 |
      | Update COD | Update | 30  | uid:3c77e509-5b9d-46d9-a6ab-593a939b2101 |

  @modify-cod @MediumPriority
  Scenario Outline: Do not allow to Modify COD if Order State is Returned to Sender - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Core - Operator rts order:
      | orderId    | {KEY_CREATED_ORDER.id}                                                                                          |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And Operator force success order
    When Operator "<action>" Order COD value with value 50.0
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                             |
      | message     | Not allowed to update an RTS order |
      | application | core                               |
      | description | INVALID_ORDER_EXCEPTION            |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    | 0   | uid:26a72716-a98f-41b4-94f2-fc5b7920c48a |
      | Update COD | Update | 50  | uid:ca54ac49-1b0b-4753-bca3-42059040b975 |

  @modify-cod @ArchiveDriverRoutes @MediumPriority
  Scenario Outline: Do not allow to Modify COD if Order State is On Vehicle for Delivery - <Note>
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id}  |
      | granularStatus | On Vehicle for Delivery |
    When Operator "<action>" Order COD value with value 50.0
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                                |
      | message     | Not allowed to update 'On Vehicle for Delivery' order |
      | application | core                                                  |
      | description | INVALID_ORDER_EXCEPTION                               |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    | 0   | uid:fc92e5f7-ffc3-4503-8e66-2994360251a7 |
      | Update COD | Update | 50  | uid:469e522e-7d0a-4010-bfae-529daea0b8e0 |

  @modify-cod @MediumPriority
  Scenario: Do not allow to Modify COD if Order State is Completed - Delete COD
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And Operator force success order
    When Operator deletes Order COD value
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                  |
      | message     | Not allowed to update 'Completed' order |
      | application | core                                    |
      | description | INVALID_ORDER_EXCEPTION                 |

  @modify-cod @MediumPriority
  Scenario: Do not allow to Modify COD if Order State is Returned to Sender - Delete COD
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And Operator perform global inbound at hub "{sorting-hub-id}"
    And API Core - Operator rts order:
      | orderId    | {KEY_CREATED_ORDER.id}                                                                                          |
      | rtsRequest | { "reason": "Return to sender: Nobody at address", "timewindow_id":1, "date":"{date: 1 days next, yyyy-MM-dd}"} |
    And Operator force success order
    When Operator deletes Order COD value
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                           |
      | message     | Not allowed to update 'Returned to Sender' order |
      | application | core                                             |
      | description | INVALID_ORDER_EXCEPTION                          |

  @modify-cod @ArchiveDriverRoutes @MediumPriority
  Scenario: Do not allow to Modify COD if Order State is On Vehicle for Delivery - Delete COD
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And API Core - Operator update order granular status:
      | orderId        | {KEY_CREATED_ORDER.id}  |
      | granularStatus | On Vehicle for Delivery |
    When Operator deletes Order COD value
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                                |
      | message     | Not allowed to update 'On Vehicle for Delivery' order |
      | application | core                                                  |
      | description | INVALID_ORDER_EXCEPTION                               |
