@ForceSuccessOrder @order-details
Feature: Order Details

  @modify-cod
  Scenario Outline: Do not allow to Modify COD if Order State is Completed - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And Operator force success order
    When Operator "<action>" Order COD value with value 50
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                 |
      | message     | Not allowed to update Completed order. |
      | application | core                                   |
      | description | INVALID_ORDER_EXCEPTION                |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    |     | uid:746af929-4ea9-43c6-b8b0-96f016cf1f90 |
      | Update COD | Update | 30  | uid:3c77e509-5b9d-46d9-a6ab-593a939b2101 |

  @modify-cod
  Scenario Outline: Do not allow to Modify COD if Order State is Returned to Sender - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    When Operator "<action>" Order COD value with value 50
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                          |
      | message     | Not allowed to update Returned to Sender order. |
      | application | core                                            |
      | description | INVALID_ORDER_EXCEPTION                         |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    |     | uid:26a72716-a98f-41b4-94f2-fc5b7920c48a |
      | Update COD | Update | 50  | uid:ca54ac49-1b0b-4753-bca3-42059040b975 |

  @modify-cod @ArchiveDriverRoutes
  Scenario Outline: Do not allow to Modify COD if Order State is On Vehicle for Delivery - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | <cod>    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    And API Operator Van Inbound parcel
    And Driver Starts the route
    When Operator "<action>" Order COD value with value 50
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                               |
      | message     | Not allowed to update On Vehicle for Delivery order. |
      | application | core                                                 |
      | description | INVALID_ORDER_EXCEPTION                              |

    Examples:
      | Note       | action | cod | hiptest-uid                              |
      | Add COD    | Add    |     | uid:fc92e5f7-ffc3-4503-8e66-2994360251a7 |
      | Update COD | Update | 50  | uid:469e522e-7d0a-4010-bfae-529daea0b8e0 |

  @modify-cod
  Scenario: Do not allow to Modify COD if Order State is Completed - Delete COD (uid:b1c5ad3a-474c-4b8a-b108-2d7e5f9ee5fc)
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
      | code        | 103042                                 |
      | message     | Not allowed to update Completed order. |
      | application | core                                   |
      | description | INVALID_ORDER_EXCEPTION                |

  @modify-cod
  Scenario: Do not allow to Modify COD if Order State is Returned to Sender - Delete COD (uid:4477d811-4166-4655-9186-5b7fa60e52c4)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    When Operator deletes Order COD value
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                          |
      | message     | Not allowed to update Returned to Sender order. |
      | application | core                                            |
      | description | INVALID_ORDER_EXCEPTION                         |

  @modify-cod @ArchiveDriverRoutes
  Scenario: Do not allow to Modify COD if Order State is On Vehicle for Delivery - Delete COD (uid:77c86505-a1f0-400d-b0f8-4b82e87f4c93)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And Operator create an empty route
      | driver_id  | {driver-id}      |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator search for "DELIVERY" transaction with status "PENDING"
    When Driver authenticated to login with username "{driver-username}" and password "{driver-password}"
    And API Operator Van Inbound parcel
    And Driver Starts the route
    When Operator deletes Order COD value
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103042                                               |
      | message     | Not allowed to update On Vehicle for Delivery order. |
      | application | core                                                 |
      | description | INVALID_ORDER_EXCEPTION                              |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method of Order Tagged to DP (uid:790dc171-e624-4606-b78d-ae7d073f7e98)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103092                          |
      | message     | Delivery is tagged to DP        |
      | application | core                            |
      | description | WAYPOINT_ROUTED_TO_DP_EXCEPTION |

  @update-delivery-mechanism
  Scenario Outline: DO NOT Allow to Change Delivery Verification Method of Order with NO ATL - <Note> (<hiptest-uid>)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                             | Parcel   |
      | service_level                            | Standard |
      | parcel_job_is_pickup_required            | false    |
      | parcel_job_cash_on_delivery              | 50       |
      | parcel_job_allow_doorstep_dropoff        | false    |
      | parcel_job_enforce_delivery_verification | true     |
      | parcel_job_delivery_verification_mode    | <method> |
    And Operator search for created order
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103062                            |
      | message     | Invalid verification mode         |
      | application | core                              |
      | description | INVALID_REQUEST_PAYLOAD_EXCEPTION |

    Examples:
      | Note                                   | method         | hiptest-uid                              |
      | delivery verification = SIGNATURE      | SIGNATURE      | uid:736186d1-8418-43cd-836e-f552b68aac3e |
      | delivery verification = AGE            | AGE            | uid:c9678118-9a5b-47dd-ad68-7bcc3d233ef0 |
      | delivery verification = IDENTIFICATION | IDENTIFICATION | uid:1943e648-14bd-4b48-a7de-a43e6377e631 |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method of RTS Order (uid:3cd9e3b0-a576-4c1e-b098-09513ea85702)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
      | parcel_job_cash_on_delivery   | 50       |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103099                   |
      | message     | Order is in an end state |
      | application | core                     |
      | description | ORDER_ALREADY_RTS        |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method for High Value Shipper (uid:140795fb-0905-4992-ba1d-6db8a807348d)
    Given Shipper authenticates using client id "{shipper-2-client-id}" and client secret "{shipper-2-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 400 with error message details as follow
      | code        | 103080                                                  |
      | message     | Cannot update delivery mechanism for high value shipper |
      | application | core                                                    |
      | description | BAD_REQUEST_EXCEPTION                                   |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Completed (uid:a38d0d53-e63d-4061-abe2-88ab1c1438aa)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Completed"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Cancelled (uid:69e77074-370a-4c8b-9186-a29d68330408)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And API Operator cancel created order
    Then Operator verify that order status-granular status is "Cancelled"-"Cancelled"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Returned to Sender (uid:b0a51f09-ad5b-43af-9d5e-ff971ee912b7)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator RTS created order:
      | rtsRequest | {"reason":"Return to sender: Nobody at address","timewindow_id":1,"date":"{gradle-next-1-day-yyyy-MM-dd}"} |
    And Operator force success order
    Then Operator verify that order status-granular status is "Completed"-"Returned_to_Sender"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |

  @update-delivery-mechanism
  Scenario: DO NOT Allow to Change Delivery Verification Method for Terminal State Order - Arrived at Distribution Point (uid:d2d4e7a1-9959-4623-a2f3-bfcc4db11106)
    Given Shipper authenticates using client id "{shipper-client-id}" and client secret "{shipper-client-secret}"
    And Shipper create order with parameters below
      | service_type                  | Parcel   |
      | service_level                 | Standard |
      | parcel_job_is_pickup_required | false    |
    And Operator search for created order
    And Operator perform global inbound for created order at hub "{sorting-hub-id}"
    And API Operator assign delivery waypoint of an order to DP Include Today with ID = "{dpms-id}"
    And Operator create an empty route
      | driver_id  | {driver-2-id}    |
      | hub_id     | {sorting-hub-id} |
      | vehicle_id | {vehicle-id}     |
      | zone_id    | {zone-id}        |
    And Operator add order to driver "DD" route
    And Operator force "SUCCESS" "DELIVERY" waypoint
    Then Operator verify that order status-granular status is "Transit"-"Arrived_at_Distribution_Point"
    When Operator update delivery verfication with value "NONE"
    Then Operator verify response code is 500 with error message details as follow
      | code        | 103090                    |
      | message     | Order is in an end state  |
      | application | core                      |
      | description | ORDER_COMPLETED_EXCEPTION |
